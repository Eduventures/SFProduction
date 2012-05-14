public class EditQuoteController {
	public Map<string,string> savedparams {get;set;}
    public EVQuote__c theQuote {get;set;}
    public Map<Id,Opportunity> accountOppsMap {get;set;}
    public Map<Id,Opportunity> selectedOppsMap {get;set;}
    public map<Id,Quote_Item__c> quoteItemsMap  {get;set;}
    public List<Quote_Item__c> itemsToDelete {get;set;}  
	public Set<Id> selectedOppIds {get;set;}  
    public String tempPG  {get;set;}
    public Map<String,List<String>> pgOptions {get;set;}
    public Quote_Item__c editingItem {get;set;}
    public Boolean editMode {get;set;}
    
    public EditQuoteController (ApexPages.StandardController stdController){
        theQuote = (EVQuote__c)stdController.getRecord();
        init();
    }
    
    public void init(){
    	editMode = false;
    	editingItem = new Quote_Item__c();
    	tempPG = 'undefined';    	
        savedparams = ApexPages.currentPage().getParameters();
        accountOppsMap = new Map<Id,Opportunity>();
        selectedOppsMap = new Map<Id,Opportunity>();
        quoteItemsMap = new map<Id,Quote_Item__c>();
        itemsToDelete = new List<Quote_Item__c>();
        selectedOppIds = new Set<Id>();
   		pgOptions = new Map<String,List<String>>();
   		pgOptions.put('ACL',new String[]{'ACL','ACL-RL'});
   		pgOptions.put('AIE',new String[]{'AIE','AIE-RL'});
   		pgOptions.put('CPE',new String[]{'CPE','CPE-RL'});
   		pgOptions.put('DEV',new String[]{'DEV','DEV-RL'});
   		pgOptions.put('ENM',new String[]{'ENM','ENM-RL','SEM'});
   		pgOptions.put('OHE',new String[]{'OHE','OHE-RL'});
   		pgOptions.put('SOE',new String[]{'SOE','SOE-RL'});
   		
		for(Quote_Item__c qi : [SELECT Id, LOA_Quote__c, Opportunity__c, Opportunity_Price__c, Product_Group__c, Product_Family__c,
								Opportunity_Type__c FROM Quote_Item__c WHERE LOA_Quote__c = :theQuote.Id])
		{
			selectedOppIds.add(qi.Opportunity__c);
			quoteItemsMap.put(qi.Opportunity__c,qi);
		}
        //fetch the account's opps
        for(Opportunity ao : [Select Id, AccountId, StageName, Product_Group__c, Name, Amount, Type, Close_Date_New__c, Original_LOA__r.End_Date__c,
 							(SELECT ContactId,IsPrimary FROM OpportunityContactRoles ORDER BY IsPrimary DESC)
           					From Opportunity WHERE AccountId = :theQuote.Account__c and 
           						StageName not in ('Remarket','Closed Won','Closed Lost') 
           					ORDER BY  Product_Group__c DESC, Close_Date_New__c])
		{
			if(selectedOppIds.contains(ao.Id))
			{
				selectedOppsMap.put(ao.Id, ao);
			} else
			{
				accountOppsMap.put(ao.Id, ao);	
			}						
		}  
    }

	public String findProductFamily(String theProduct)
	{
		String tempS = theProduct.substring(0,3);
		if(tempS != 'SEM')
		{
			return tempS;
		} else {
			return 'ENM';
		}
	}
	
	public PageReference edititem(){
		Id eId = apexpages.currentpage().getParameters().get('editid');
		editingItem = quoteItemsMap.get(eId);
		editMode = true;
		return null;
	}
	
    public PageReference cancelEdit() {
        quoteItemsMap.put(editingItem.Opportunity__c,editingItem);
        editingItem = null;
        editMode = false;
        return null;
    }
    
    public PageReference saveEdit() {
    	theQuote.Price__c = 0;
		String tempPG = '';
    	for(Quote_Item__c qi: quoteItemsMap.values())
        {
            tempPG = tempPG + ';' + qi.Product_Group__c;
            theQuote.Price__c = theQuote.Price__c + qi.Opportunity_Price__c;
        }
        theQuote.Product_Group__c = tempPG;
        editMode = false;
        editingItem = null;
        return null;
    }
    
    public List<SelectOption> getproductOptions() {
        List<SelectOption> optionList = new List<SelectOption>();
	    for(String s: pgOptions.get(editingItem.Product_Family__c))
	    {
	        optionList.add(new SelectOption(s,s));
	    }     	
        return optionList;
    }  
    public List<Quote_Item__c> getquoteItems() {
    	return quoteItemsMap.values();
    }

    public List<Opportunity> getaccountOpps() {
    	return accountOppsMap.values();
    }

    public List<Opportunity> getselectedOpps() {
    	return selectedOppsMap.values();
    }
         
    public PageReference selectOpp() {
        string addParam = '';
        if(apexpages.currentpage().getParameters().containsKey('addid'))
        {
            addParam = apexpages.currentpage().getparameters().get('addid');
            if(accountOppsMap.containsKey(addParam))
            {
            	Opportunity selectedOpp = accountOppsMap.get(addParam);
                selectedOppsMap.put(selectedOpp.Id, selectedOpp);
                Quote_Item__c tempQI = new Quote_Item__c( 
                    Opportunity__c = selectedOpp.Id, 
                    Opportunity_Price__c = selectedOpp.Amount,
                    Product_Family__c = findProductFamily(selectedOpp.Product_Group__c),
                    Product_Group__c = selectedOpp.Product_Group__c,
                    Opportunity_Type__c = selectedOpp.Type);
                quoteItemsMap.put(selectedOpp.Id,tempQI);    
                if( theQuote.Product_Group__c  == null)
                {
                    theQuote.Product_Group__c = selectedOpp.Product_Group__c;
                } else
                {
                    theQuote.Product_Group__c = theQuote.Product_Group__c + ';' + selectedOpp.Product_Group__c;
                }
                theQuote.Price__c = theQuote.Price__c + selectedOpp.Amount;
                
                if( theQuote.LOA_Start_Date__c == null && selectedOpp.Original_LOA__r.End_Date__c != null && selectedOpp.Type == 'Renewal Business')
                {
                    theQuote.LOA_Start_Date__c = selectedOpp.Original_LOA__r.End_Date__c;
                }
                if( theQuote.Primary_Contact__c == null && !selectedOpp.OpportunityContactRoles.isEmpty())
                {
                    theQuote.Primary_Contact__c = selectedOpp.OpportunityContactRoles[0].ContactId;
                }
                accountOppsMap.remove(selectedOpp.Id);
                if(selectedOppsMap.size() > 1)
                {
                    ApexPages.addMessage(
                   new ApexPages.Message( ApexPages.Severity.INFO,'You have chosen more than one program, if this quote is for a \'Hybrid\' Agreement then please check the box labelled \'Hybrid\' below.'));
                }
            }
        }
        return null;
    }
 
     public PageReference removeOpp() {
        string removeParam = '';
        if(apexpages.currentpage().getParameters().containsKey('remid'))
        {
            removeParam = apexpages.currentpage().getparameters().get('remid');
            if(selectedOppsMap.containsKey(removeParam))
            {                 
            	Opportunity removedOpp = selectedOppsMap.get(removeParam);
            	if( (theQuote.Price__c - removedOpp.Amount) > 0)
                {
                	theQuote.Price__c = theQuote.Price__c - removedOpp.Amount;
                } else 
                {
                	theQuote.Price__c = 0;
                }
                accountOppsMap.put(removedOpp.Id,removedOpp);
                //check if this is an existing Quote Item, if so we need to hold a copy of the item to delete when the page is saved
                if(quoteItemsMap.get(removeParam).Id != null)
                {
                	itemsToDelete.add(quoteItemsMap.get(removeParam));
                }
                quoteItemsMap.remove(removeParam);
                if(!quoteItemsMap.isEmpty())
                {
	                String tempPG = '';    
	                for(Quote_Item__c qi: quoteItemsMap.values())
	                {
	                    tempPG = tempPG + ';' + qi.Product_Group__c;
	                }
	                theQuote.Product_Group__c = tempPG;
	                if(theQuote.LOA_Start_Date__c == removedOpp.Original_LOA__r.End_Date__c)
	                {
	                	theQuote.LOA_Start_Date__c = null;
	                }
	                selectedOppsMap.remove(removeParam);                	
                } else 
                {
                	theQuote.Price__c = 0.00;
                	theQuote.Product_Group__c = '';
                	theQuote.LOA_Start_Date__c = null;
                }
            }
        }
        return null;
    }
 
     public PageReference save() {
     	//make sure the basic requirments are met - Price & Products are specified
		if(theQuote.Price__c == 0 || theQuote.Product_Group__c == '')
		{
			if(theQuote.Product_Group__c == '')
			{
				ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Problem - You are missing a product for this quote!'));	
			}
			if(theQuote.Price__c == 0)
			{
				ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Problem - The Quote price must be greater than $0'));	
			}		
			return null;
		}
    	Boolean savedOk = true;
  		List<Quote_Item__c> itemsToInsert = new List<Quote_Item__c>();
  		List<Quote_Item__c> itemsToUpdate = new List<Quote_Item__c>();
  		
    	for(Quote_Item__c qi : quoteItemsMap.values())
    	{
 		   	if(qi.Id == null)
    		{
    			qi.LOA_Quote__c =  theQuote.Id;
				itemsToInsert.add(qi);
    		} else 
    		{
    			itemsToUpdate.add(qi);
    		}	    				
    	}
    	
    	Savepoint sp = Database.setSavepoint();
		try {
			    if(itemsToInsert.size() != 0)
			    {
				    insert itemsToInsert;  		    	
			    }
		        if(itemsToUpdate.size() != 0)
			    {
					update itemsToUpdate;		    	
			    }			    
		        if(itemsToDelete.size() != 0)
			    {
			    	delete itemsToDelete;
			    }
   			    update theQuote;
			    return new PageReference( '/' + theQuote.Id);
		} 	catch (Exception e) 
    	{
			Database.rollback(sp);
			ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR,e.getDmlMessage(0)));
		}
  		return null;

    }
          
	public PageReference cancel() {
		return new PageReference( System.currentPageReference().getParameters().get('retURL'));
	}

}