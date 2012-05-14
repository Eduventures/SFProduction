public class NewQuoteController {
    public Map<string,string> savedparams {get;set;}
    public EVQuote__c theQuote {get;set;}
    public Opportunity theOpp {get;set;}   
    public Map<Id,Opportunity> accountOppsMap {get;set;}
    public Map<Id,Opportunity> selectedOppsMap {get;set;}       
    public Map<Id,Quote_Item__c> quoteItemsMap {get;set;}
    public String tempPG  {get;set;}
    public Map<String,List<String>> pgOptions {get;set;}
    public Quote_Item__c editingItem {get;set;}
	public Boolean editMode {get;set;}
    
    public NewQuoteController (ApexPages.StandardController stdController){
        theQuote = (EVQuote__c)stdController.getRecord();
        
    }

	/*Project Notes - AJD  -  09/20/11
	This form allows users to pick opporutnites and then create quotes for one or more products.
	The page creates temporary quote items in order to provide the sales staff with the ability to manipulate
	 the price or product of an opp without changing the opportunity details (or duplicating opps 
	 for 'Full' and 'RL') from Quote to Quote.
	 
	 When the quote is saved, then the code creates the Quote and it's quote items. If there are any errors, 
	 the transcation is cancelled and a message is displayed
	 */
	 
    public PageReference init(){
    	editMode = false;
    	editingItem = new Quote_Item__c();
    	tempPG = 'undefined';
        savedparams = ApexPages.currentPage().getParameters();
        theOpp = new Opportunity();
        accountOppsMap = new Map<Id,Opportunity>();
        selectedOppsMap = new Map<Id,Opportunity>();       
   		quoteItemsMap = new Map<Id,Quote_Item__c>();
   		pgOptions = new Map<String,List<String>>();
   		pgOptions.put('ACL',new String[]{'ACL','ACL-RL'});
   		pgOptions.put('AIE',new String[]{'AIE','AIE-RL'});
   		pgOptions.put('CPE',new String[]{'CPE','CPE-RL'});
   		pgOptions.put('DEV',new String[]{'DEV','DEV-RL'});
   		pgOptions.put('ENM',new String[]{'ENM','ENM-RL','SEM'});
   		pgOptions.put('OHE',new String[]{'OHE','OHE-RL'});
   		pgOptions.put('SOE',new String[]{'SOE','SOE-RL'});
   		
        theQuote.Price__c = 0.00; 
        theQuote.Contract_Length__c = 12;
        if(savedparams.containsKey('oppid'))
        {
            //if there is a preselected Opp, capture it and add it to the 'selected opportunites' list
            theOpp = [ SELECT Id, AccountId, StageName, Product_Group__c, Product_Family__c, Name, Amount, Type, Close_Date_New__c, 
                            Original_LOA__r.End_Date__c, (SELECT ContactId,IsPrimary FROM OpportunityContactRoles ORDER BY IsPrimary DESC)
                        FROM Opportunity WHERE Id = :savedparams.get('oppid')];
            if(theOpp.Type == 'Renewal Business' && theOpp.Original_LOA__r.End_Date__c != null)            
            {
                theQuote.LOA_Start_Date__c = theOpp.Original_LOA__r.End_Date__c;
            }
            selectedOppsMap.put(theOpp.Id, theOpp);
            theQuote.Product_Group__c = theOpp.Product_Group__c;      
			Quote_Item__c initialItem = new Quote_Item__c( 
                        Opportunity__c = theOpp.Id, 
                        Opportunity_Price__c = theOpp.Amount,
                        Product_Family__c = theOpp.Product_Family__c,
                        Product_Group__c = theOpp.Product_Group__c,
                        Opportunity_Type__c = theOpp.Type);
            quoteItemsMap.put(theOpp.Id, initialItem);
            	
            //fetch main account's list of open opps
            for(Opportunity ao : [Select Id, AccountId, StageName, Product_Group__c, Product_Family__c, Name, Amount, Type, Close_Date_New__c, Original_LOA__r.End_Date__c, 
                                (SELECT ContactId,IsPrimary FROM OpportunityContactRoles ORDER BY IsPrimary DESC)
                                From Opportunity WHERE AccountId = :theOpp.AccountId and 
                                    StageName not in ('Remarket','Closed Won','Closed Lost') 
                                    and Id != :theOpp.Id ORDER BY  Product_Group__c DESC, Close_Date_New__c])
            {
                accountOppsMap.put(ao.Id, ao);                      
            }  
            //prefill some known quote info based on the first selected opp
            theQuote.Account__c = theOpp.AccountId;
            if(!theOpp.OpportunityContactRoles.isEmpty())
            {
                theQuote.Primary_Contact__c = theOpp.OpportunityContactRoles[0].ContactId;
            } 
            //add price info from the selected opp
            if(theOpp.Amount != null)
            {
	            theQuote.Price__c = theQuote.Price__c + theOpp.Amount;            	
            }
               
            theQuote.Payment_Terms__c = 'An invoice in the amount of $' + theQuote.Price__c.format() + ' will be sent upon receipt of this signed membership agreement. Payment is due 30 days from date of invoice.';              
            if(theOpp.Product_Group__c.contains('-RL'))
            {   
                theQuote.AMM_Pass_Count__c = 0;  
            } else 
            {
            	theQuote.Strategy_Session_Access__c = true; 
            	theQuote.AMM_Pass_Count__c = 1;
            }
        }
        
        return null;
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
        editingItem = null;
        editMode = false;
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
                    Product_Family__c = selectedOpp.Product_Family__c,
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
       
       	try {
	       		insert theQuote;
	    	    List<Quote_Item__c> itemsToInsert = new List<Quote_Item__c>();
		        for(Quote_Item__c qi : quoteItemsMap.values())
		        {
		        	qi.LOA_Quote__c = theQuote.Id;
		        	itemsToInsert.add(qi);	                        
		        }
			    if(itemsToInsert.size() != 0)
			    {
				    insert itemsToInsert;  		    	
			    }
			    return new PageReference( '/' + theQuote.Id);
		} 	catch (Exception e) 
    	{
			ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR,e.getMessage()));
		}
  		return null;             
    }
          
    public PageReference cancel() {
        return new PageReference( System.currentPageReference().getParameters().get('retURL'));
    }

}