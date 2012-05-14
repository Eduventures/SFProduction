trigger AccountDelete on Account (before delete) {
	List<Id> toBeDeleted = new List<Id>();
	Map<Id,Id> acctsWithLOAs = new Map<Id,Id> ();
    if(Trigger.isDelete) 
    { 
        for (Account a : Trigger.old)  //change Object Name 
        {
			toBeDeleted.add(a.Id);
        }
        
       	for(LOA__c l: [select Id, Account__r.Name, Account__c from LOA__c where Account__c in :toBeDeleted])
       	{
       		acctsWithLOAs.put(l.Account__c,l.Account__c);
       	}
        
        for (Account a : Trigger.old)  //change Object Name 
        {

        	if(acctsWithLOAs.containsKey(a.Id))
        	{
   				a.addError('You can not delete an Account that has an LOA on file!');					 
    		}
        } 
    }

}