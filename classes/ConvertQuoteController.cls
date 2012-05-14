public class ConvertQuoteController {
    public EVQuote__c theQuote {get;set;} 
    public Set<Id> oppIds {get;set;}   
    public List<Opportunity> oppsToClose {get;set;} 
    public List<LOA__c> loasToCreate {get;set;}
	public Integer stepcount {get;set;}
    public Map<Id,Opportunity> oppsMap {get;set;}
    public Map<Id,Quote_Item__c> quoteItemsMap {get;set;}
    
    public ConvertQuoteController (ApexPages.StandardController stdController){
		theQuote = (EVQuote__c)stdController.getRecord();
		init();
    }

    public void init(){
    	stepcount = 1;
    	quoteItemsMap = new Map<Id,Quote_Item__c>();
		oppIds = new Set<Id>();
		oppsToClose = new List<Opportunity>();
    	loasToCreate = new List<LOA__c>();
	
		for(Quote_Item__c item: [SELECT Id, LOA_Quote__c, Opportunity__c, Opportunity_Price__c, Product_Group__c, Opportunity_Type__c
											FROM Quote_item__c WHERE LOA_Quote__c = :theQuote.Id ORDER BY Opportunity_Type__c])
    	{
    		oppIds.add(item.Opportunity__c);
    		quoteItemsMap.put(item.Opportunity__c, item);
    	}					
        
        for(Opportunity anOpp: [Select Id, AccountId, StageName, Product_Group__c, Name, Amount, Type, Close_Date_New__c, RecordTypeId,
        						Owner.Name, (SELECT UnitPrice FROM OpportunityLineItems) 
            					From Opportunity WHERE Id in :oppIds ORDER BY  Product_Group__c DESC, Close_Date_New__c])
		{
			anOpp.StageName = 'Closed Won';
			anOpp.Close_Date_New__c = System.today();
			anOpp.Product_Group__c = quoteItemsMap.get(anOpp.Id).Product_Group__c;
			anOpp.Amount = quoteItemsMap.get(anOpp.Id).Opportunity_Price__c;
			oppsToClose.add(anOpp);
		}

    	if(theQuote.Status__c != 'Approved')
        {
        	ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, '<font style="color:red;font-weight:bold;">This quote has NOT been approved by finance, please submit it<font style="color:red;font-weight:bold;">'));            
        }		       	
    }
  
    public PageReference next(){
    	if(stepcount == 1)
    	{
			stepcount = stepcount + 1;
    	}
    	else if	(stepcount == 2)
    	{
    		generateLOAs();
    	} else if (stepcount == 3)
    	{
    		save();
    	} 
    	return null;
    }    
    
    public PageReference back(){
    	stepcount = stepcount - 1;
    	return null;
    }
            
    public PageReference generateLOAs(){
    	loasToCreate.clear();
    	oppsMap = new Map<Id,Opportunity>();
		for(Opportunity closedOpp : oppsToClose)
		{
			oppsMap.put(closedOpp.Id,closedOpp);
		}
			
        for(Quote_item__c qi :quoteItemsMap.values())
        {
        	String tempType = qi.Opportunity_Type__c.replace(' Business','');
	       	LOA__c temp = new LOA__c(
    						RecordTypeId = '01230000000DMbx',
    						Account__c = theQuote.Account__c,
    						Name = theQuote.Account__r.Name + '-' + qi.Product_Group__c,
					        Agreement_Date__c = oppsMap.get(qi.Opportunity__c).Close_Date_New__c,
					        Start_Date__c = theQuote.LOA_Start_Date__c,
					        End_Date__c = theQuote.LOA_Start_Date__c.addMonths(integer.valueOf(theQuote.Contract_Length__c)),
					        Type__c = tempType,
					        Amount__c = qi.Opportunity_Price__c,
					        Program__c = qi.Product_Group__c,
					        Hybrid__c = theQuote.Hybrid__c,
					        Company_Contact__c = theQuote.Primary_Contact__c,
					        Division_LOA__c = 'LC',
					        AMM_Pass_Count__c = theQuote.AMM_Pass_Count__c,
					        LOA_Quote__c = theQuote.Id,
					       	Member_Roundtable_Access__c = theQuote.Member_Roundtable_Access__c,
					        Strategy_Session_Access__c = theQuote.Strategy_Session_Access__c,
							Website_Access__c = theQuote.Website_Access__c,					       	
   					        Opportunity__c = qi.Opportunity__c,   
					        Payment_Terms__c = theQuote.Payment_Terms__c,
					        Salesperson__c = oppsMap.get(qi.Opportunity__c).Owner.Name,
					        Sales_Territory__c = oppsMap.get(qi.Opportunity__c).Sales_Territory__c
    					);
    		if(theQuote.Custom_Analysis_Limit__c != null)
    		{
    			temp.Custom_Analysis_Limit__c = theQuote.Custom_Analysis_Limit__c;
    		}    					
        	loasToCreate.add(temp);				
        }
       	stepcount = stepcount + 1;	
        return null;
    }

	public PageReference save() {
		List<OpportunityLineItem> oppItemsToUpdate = new List<OpportunityLineItem>();
		Boolean savedOK = true;

		Decimal bookedDollars = 0.00;
		for(LOA__c temp : loasToCreate)
		{
			bookedDollars = bookedDollars + temp.Amount__c;
		}
		
		if(bookedDollars > theQuote.Price__c)
		{
			ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Booking Error: The combined dollar amount of the booked LOAs ($' + bookedDollars + ') is more than the approved Quote ($'+ theQuote.Price__c + '). Please fix LOA Amounts.'));            
        	return null;
		} else if (bookedDollars < theQuote.Price__c)
		{
			ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Booking Error: The combined dollar amount of the booked LOAs ($' + bookedDollars + ') is less than the approved Quote ($'+ theQuote.Price__c + '). Please fix LOA Amounts.'));            
        	return null;
		}

    	for(LOA__c l : loasToCreate)
    	{
    		for(Opportunity o : oppsToClose)
    		{
    			if( l.Opportunity__c == o.Id)
    			{
		    		if(o.OpportunityLineItems.isEmpty())
		    		{
						o.Amount = l.Amount__c;
		    		} else 
		    		{
		    			OpportunityLineItem tempOLI = o.OpportunityLineItems[0];
		        		tempOLI.UnitPrice = l.Amount__c;
		        		oppItemsToUpdate.add(tempOLI);
		        	}    				
    			}   			
    		}  		
    	}
		if(!oppItemsToUpdate.isEmpty())
		{
			update oppItemsToUpdate;
		}

		Database.Saveresult[] saveOppResults = Database.update(oppsToClose, false);
        for (Database.SaveResult sResult : saveOppResults) 
        {		
			if(!sResult.isSuccess())
	        {
	            Database.Error errMsg = sResult.getErrors()[0];
	            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'There was a problem saving the Opportunity: ' + errMsg.getMessage()));            
	        	savedOK = false;
	        }
        } 
        
        if(savedOK == false)
        {
        	return null;
        }
        
        for(LOA__c l: loasToCreate)
        {
        	l.Name = l.Name + '-' + l.Agreement_Date__c.format();
        }
    	Database.SaveResult[] createLOAsResults = Database.Insert(loasToCreate, false);
        for (Database.SaveResult cResult : createLOAsResults) 
        {		
			if(!cResult.isSuccess())
		    {
		        Database.Error errMsg = cResult.getErrors()[0];
		        ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR,errMsg.getMessage()));
		        savedOK = false;
		    }
        }
        
        if(savedOK == false)
        {
        	return null;
        } else 
        {
        	theQuote.Status__c = 'Closed Won';
        	update theQuote;
   	    	stepcount = stepcount + 1;
        	return new PageReference(theQuote.Id);
        }      
		
	}
	
	public PageReference cancel() {
		return new PageReference( '/' + theQuote.Id);
	}
}