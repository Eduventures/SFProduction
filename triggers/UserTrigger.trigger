trigger UserTrigger on User ( before update) {
 	set<ID> ids = Trigger.newMap.keySet();
 	
	Map<Id,List<Id> > activeRAMmap = new Map <Id,List<Id>>();
	for(LOA__c l : [Select Id, Status__c, Research_Account_Manager__c from LOA__c where Status__c in ('Active','Pending','Extended') and Research_Account_Manager__c in :ids])
	{
		if(activeRAMmap.containsKey(l.Research_Account_Manager__c))
		{
			activeRAMmap.get(l.Research_Account_Manager__c).add(l.Id);
		} else
		{
			List<Id> tempList = new List<Id>();
			tempList.add(l.Id);
			activeRAMmap.put(l.Research_Account_Manager__c,tempList);			
		}		
	}
	 
	for(User u : Trigger.new)
    {   	
    	if( u.IsActive == false)
    	{
    		system.debug('deactivating user!');
	        if(activeRAMmap.containsKey(u.Id))
	        {	
	        	system.debug('LOAs to wipe, found');
	        	system.debug('activeRAMmap size is ' + activeRAMmap.get(u.Id).size());
        		LOA_tools.clearResearchMgrs(activeRAMmap.get(u.Id));
	        }    		
    	}
    }
}