trigger LoaInsertBefore on LOA__c (before insert) {

/* ON HOLD until we have backfilled all current memebrship records - AJD  11/07/2011*/	
    for (LOA__C newloa : Trigger.new)
    {
        if(newloa.RecordTypeId == '01230000000DMbx' && newloa.Program__c != 'RPT')
        {
        	if( newloa.Type__c == 'New' && [ SELECT count() FROM Membership__c where Account__c = :newloa.Account__c and 
        					Program_Family__c = :newloa.Program_Family__c] == 0)
			{
				Account mainAccount = [ Select Id, Name FROM Account WHERE Id = :newloa.Account__c];
				Membership__c newMembership = new Membership__c(
												Account__c = newloa.Account__c,
												Website_Access__c = newloa.Website_Access__c, 
												Strategy_Session_Access__c = newloa.Strategy_Session_Access__c, 
												Status__c = newloa.Status__c, 
												Program_Family__c = newloa.Program_Family__c, 
												Name = mainAccount.Name + '-' + newloa.Program_Family__c, 
												Member_Roundtable_Access__c = newloa.Member_Roundtable_Access__c, 
												Join_Date__c = newloa.Start_Date__c, 
												Expiration_Date__c = newloa.End_Date__c, 
												Custom_Analysis_Limit__c = newloa.Custom_Analysis_Limit__c, 
												AMM_Pass_Count__c = newloa.AMM_Pass_Count__c
												);
												
				insert newMembership;
				newloa.Membership__c = newMembership.Id;
			} else if([ SELECT count() FROM Membership__c where Account__c = :newloa.Account__c and Program_Family__c = :newloa.Program_Family__c ] == 1)
			{
				Membership__c existingMembership = [ SELECT Id FROM Membership__c where Account__c = :newloa.Account__c and 
        					Program_Family__c = :newloa.Program_Family__c];
				newloa.Membership__c = existingMembership.Id;
			}
			
        	
        } 
    }
}