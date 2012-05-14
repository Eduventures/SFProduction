trigger MembershipAfterUpdate on Membership__c (after update) {
    List<Id> acctIdsToUpdate = new List<Id>();
    List<Account> acctsToUpdate = new List<Account>();
    for (Integer i = 0; i < Trigger.new.size(); i++)
    {
        if(Trigger.old[i].Status__c != Trigger.new[i].Status__c)
        {
        	acctIdsToUpdate.add(Trigger.new[i].Account__c);
        }
        
        if(!acctIdsToUpdate.isEmpty())
        {
        	acctsToUpdate = [ Select Id from Account where Id in :acctIdsToUpdate];
        	update acctsToUpdate;
        }
        /*
        1/4/2012 - AJD - This section would handle removing website access when a membership moves from an LOA with
        website access one without it. At this time this is so rare we can handle removing the access manually.
        Also, the process to make sure "website Access" is checked off when it should be, specifically 
        when putting in LOAs 'the old way' (without the quote tool) is still a work in progress.
        
        if( (old.Website_Access__c != m.Website_Access__c) && m.Website_Access__c = false)
        {
        	//process Contacts of account to remove website access
        }
        
        */
    }
}