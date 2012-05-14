trigger QuoteItemAutomation on Quote_Item__c (after update, after delete) {

	/*if(Trigger.isAfter)
	{
		if(Trigger.isUpdate)
		{		
			Set<ID> quoteIdsToUpdate = new Set<ID>();	
			for(integer i=0; i<Trigger.new.size();i++)
			{	
				Quote_Item__c oldqi = Trigger.old[i];
				Quote_Item__c newqi = Trigger.new[i];
				if(oldqi.Product_Group__c != newqi.Product_Group__c || oldqi.Opportunity_Type__c != newqi.Opportunity_Type__c || oldqi.Opportunity_Price__c != newqi.Opportunity_Price__c)
				{
					quoteIdsToUpdate.add(newqi.Loa_Quote__c);
				}
			}
			if( !quoteIdsToUpdate.isEmpty())
			{
				List<EVQuote__c> updates = new List<EVQuote__c>();
				for( EVQuote__c e : [SELECT Id, Status__c FROM EVQuote__c WHERE Id in :quoteIdsToUpdate and Status__c != 'Approved'])
				{
					updates.add(e);
				}			
				update updates;
			}
		}
		if(Trigger.isDelete)
		{
			List<Quote_Item__c> problemQuoteItems = [ SELECT Id  FROM Quote_Item__c WHERE Quote_Item__c.LOA_Quote__r.Status__c not in ('Preparing Quote (not submitted)', 'Rejected') and Id in :Trigger.oldMap.keyset()]; 
            if(!problemQuoteItems.isEmpty())
            {
                for(Quote_Item__c qi: problemQuoteItems)
                {
                    Trigger.oldMap.get(qi.Id).addError('You cannot delete this quote item because it is included in an existing quote (that has already either been submitted or approved.)');
                }
            } 			
		}		
	}*/
}