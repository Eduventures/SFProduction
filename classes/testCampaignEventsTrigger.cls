@isTest
private class testCampaignEventsTrigger {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        Event[] testEvents;
        Campaign testcampaign = new Campaign( name = 'trigger test',
        									  type = 'Email',
        									  Display_on_Marketing_Calendar__c = true,        									  
        									  Calendar_Name__c = 'Test Campaign for Marketing Calendar',
											  Description = 'this is a test campaign');
											  
		try {
			insert testcampaign;
			testEvents = [select id, Subject, StartDateTime, EndDateTime, WhatId, OwnerId, RecordTypeId 
							from Event where WhatId = :testcampaign.Id and OwnerId = '02380000000o01m'
											and RecordTypeId = '01280000000HefQ'];
        	System.assert(testEvents.isEmpty());
			
		} catch (Exception e)
		{
			System.debug(e.getMessage());
		}
		
		testcampaign.StartDate = System.today();
		testcampaign.EndDate = System.today()+ 15;
		try {
			insert testcampaign;
			testEvents = [select id, Subject, StartDateTime, EndDateTime, WhatId, OwnerId, RecordTypeId 
							from Event where WhatId = :testcampaign.Id and OwnerId = '02380000000o01m'
											and RecordTypeId = '01280000000HefQ'];
        	System.assert(testEvents.isEmpty());
			
		} catch (Exception e)
		{
			System.debug(e.getMessage());
		}
		
		testcampaign.EndDate = System.today()+ 5;
		try {
			insert testcampaign;
			testEvents = [select id, Subject, StartDateTime, EndDateTime, WhatId, OwnerId, RecordTypeId 
							from Event where WhatId = :testcampaign.Id and OwnerId = '02380000000o01m'
											and RecordTypeId = '01280000000HefQ'];
        	System.assert(!testEvents.isEmpty());
			
		} catch (Exception e)
		{
			System.debug(e.getMessage());
		}
		
		testcampaign.Display_on_Marketing_Calendar__c = false;
		try {
			update testcampaign;
			testEvents = [select id, Subject, StartDateTime, EndDateTime, WhatId, OwnerId, RecordTypeId 
							from Event where WhatId = :testcampaign.Id and OwnerId = '02380000000o01m'
											and RecordTypeId = '01280000000HefQ'];
			System.assert(testEvents.isEmpty());
			
		} catch (Exception e)
		{
			System.debug(e.getMessage());
		}
		
		testcampaign.Display_on_Marketing_Calendar__c = true;					
		testcampaign.EndDate = null;
		try {
			update testcampaign;
			testEvents = [select id, Subject, StartDateTime, EndDateTime, WhatId, OwnerId, RecordTypeId 
							from Event where WhatId = :testcampaign.Id and OwnerId = '02380000000o01m'
											and RecordTypeId = '01280000000HefQ'];
		} catch (Exception e)
		{
			System.debug(e.getMessage());
		}
				
		testcampaign.EndDate = System.today() + 28;
		try {
			update testcampaign;
			testEvents = [select id, Subject, StartDateTime, EndDateTime, WhatId, OwnerId, RecordTypeId 
							from Event where WhatId = :testcampaign.Id and OwnerId = '02380000000o01m'
											and RecordTypeId = '01280000000HefQ'];
			System.assert(testEvents.isEmpty());
			
		} catch (Exception e)
		{
			System.debug(e.getMessage());
		}
		testcampaign.EndDate = System.today() + 2;
		try {
			update testcampaign;
			testEvents = [select id, Subject, StartDateTime, EndDateTime, WhatId, OwnerId, RecordTypeId 
							from Event where WhatId = :testcampaign.Id and OwnerId = '02380000000o01m'
											and RecordTypeId = '01280000000HefQ'];
			System.assert(!testEvents.isEmpty());
			
		} catch (Exception e)
		{
			System.debug(e.getMessage());
		}	
					
		testcampaign.EndDate = System.today() + 1;
		try {
			update testcampaign;
			testEvents = [select id, Subject, StartDateTime, EndDateTime, WhatId, OwnerId, RecordTypeId 
							from Event where WhatId = :testcampaign.Id and OwnerId = '02380000000o01m'
											and RecordTypeId = '01280000000HefQ'];
			System.assert(!testEvents.isEmpty());
			
		} catch (Exception e)
		{
			System.debug(e.getMessage());
		}				
				
		try {
			delete testcampaign;
			testEvents = [select id, Subject, StartDateTime, EndDateTime, WhatId, OwnerId, RecordTypeId 
							from Event where WhatId = :testcampaign.Id and OwnerId = '02380000000o01m'
											and RecordTypeId = '01280000000HefQ'];
			System.assert(testEvents.isEmpty());
			
		} catch (Exception e)
		{
			System.debug(e.getMessage());
		}	
		
		
    }
}