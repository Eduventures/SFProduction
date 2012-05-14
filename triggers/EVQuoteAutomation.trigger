trigger EVQuoteAutomation on EVQuote__c (before insert, before update) {
	Map<String,Decimal> listPriceMap = new Map<String,Decimal>();
	listPriceMap.put('ACL', 29000.00);
	listPriceMap.put('AIE', 29000.00);
	listPriceMap.put('CPE', 29000.00);
	listPriceMap.put('DEV', 29500.00);
	listPriceMap.put('ENM', 29000.00);
	listPriceMap.put('OHE', 29000.00);
	listPriceMap.put('SEM', 23000.00);
	listPriceMap.put('SOE', 23000.00);
	listPriceMap.put('ACL-RL', 16000.00);
	listPriceMap.put('AIE-RL', 16000.00);
	listPriceMap.put('CPE-RL', 16000.00);
	listPriceMap.put('DEV-RL', 16000.00);
	listPriceMap.put('ENM-RL', 16000.00);
	listPriceMap.put('OHE-RL', 16000.00);
	listPriceMap.put('SOE-RL', 13000.00);
	listPriceMap.put('Hybrid', 45000.00);

	Integer maxdiscount = 20;
	 
	if(Trigger.isBefore)
	{
		if(Trigger.isInsert)
		{
			for(EVQuote__c evq : Trigger.new)
			{	
				evq.Calculated_List_Price__c = 0.00;
				if( evq.Hybrid__c == true )
				{				
					evq.Calculated_List_Price__c = Math.roundToLong((listPriceMap.get('Hybrid')/12)* evq.Contract_Length__c);	
				} else 
				{
					for(String product: evq.Product_Group__c.split(';',0))
					{
						evq.Calculated_List_Price__c = Math.roundToLong(evq.Calculated_List_Price__c + ( (listPriceMap.get(product)/12)* evq.Contract_Length__c) );
					}
				}			
				
				evq.Calculated_Discount__c = evq.Calculated_List_Price__c - evq.Price__c;
				if(evq.Calculated_Discount__c > 0)
				{
					evq.Calculated_Discount_Percent__c = Math.roundToLong((evq.Calculated_Discount__c / evq.Calculated_List_Price__c) * 100);
				} else 
				{
					evq.Calculated_Discount_Percent__c = 0;
				}
					
				if(evq.Calculated_Discount_Percent__c > maxdiscount)
				{
					evq.Discount_Exemption_Required__c = true;
				} else
				{
					evq.Discount_Exemption_Required__c = false;
				}			
			}
		}
		if(Trigger.isUpdate)
		{
			Set<ID> ids = Trigger.newMap.keySet();
		    Map<Id,EVQuote__c> updatedQuotesMap = new Map<Id,EVQuote__c> ([SELECT Id, 
		                 (SELECT Id, Opportunity__c, Opportunity_Price__c, Product_Group__c, Opportunity_Type__c from Quote_items__r) 
		                  FROM EVQuote__c WHERE Id in :ids]);
		                  			
			for(EVQuote__c evq : Trigger.new)
			{	
				
				evq.Product_Group__c = '';
				evq.Price__c = 0;
					        	//and loop thru each kid in the child set}
	            for(Quote_Item__c qi : updatedQuotesMap.get(evq.Id).Quote_items__r)
	            {
					evq.Product_Group__c = evq.Product_Group__c + qi.Product_Group__c + ';';
					evq.Price__c = evq.Price__c + qi.Opportunity_Price__c;
		        }
				
				evq.Calculated_List_Price__c = 0.00;
				if(evq.Hybrid__c == true )
				{				
					evq.Calculated_List_Price__c = Math.roundToLong( (listPriceMap.get('Hybrid')/12)* evq.Contract_Length__c);	
				} else 
				{
					for(String product: evq.Product_Group__c.split(';',0))
					{
						evq.Calculated_List_Price__c = evq.Calculated_List_Price__c +  Math.roundToLong((listPriceMap.get(product)/12)* evq.Contract_Length__c );
					}
				}			
			
				evq.Calculated_Discount__c = evq.Calculated_List_Price__c - evq.Price__c;
				if(evq.Calculated_Discount__c > 0)
				{
					evq.Calculated_Discount_Percent__c = Math.roundToLong((evq.Calculated_Discount__c / evq.Calculated_List_Price__c) * 100);
				} else 
				{
					evq.Calculated_Discount_Percent__c = 0;
				}
					
				if(evq.Calculated_Discount_Percent__c > maxdiscount)
				{
					evq.Discount_Exemption_Required__c = true;
				} else
				{
					evq.Discount_Exemption_Required__c = false;
				}			
			}
		}	
	}
}