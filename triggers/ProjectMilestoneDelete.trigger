trigger ProjectMilestoneDelete on Project_Milestone__c (before delete) {
    if(Trigger.isDelete) 
    { 
    	List<Id> deletedIds = new List<Id>();
    	Map<Id,List<Id>> blockIdsMap = new Map<Id,List<Id>>();
    	
        for (Project_Milestone__c p : Trigger.old)  //change Object Name 
        {
			deletedIds.add(p.Id);
        }
        
        for(AggregateResult result: [ select Project_Milestone__c milestone from TimeSheetLine__c 
        									where Project_Milestone__c in :deletedIds GROUP BY Project_Milestone__c])
  		{
  			Id pmId = (Id)result.get('milestone');
			if(blockIdsMap.containsKey(pmId))
			{
				blockIdsMap.get(pmId).add(pmId);	
			} else 
			{
				List<Id> temp = new List<Id>();
				temp.add(pmId);
				blockIdsMap.put(pmId,temp);	
			}
		}

        for (Project_Milestone__c pm : Trigger.old)  //change Object Name 
        {
			if(blockIdsMap.containsKey(pm.Id))
			{
				pm.addError('You can not delete a milestone that has booked hours against it.' + 
				' Please delete any timesheet entries related to this milestone before deleting this it. ('
				 + blockIdsMap.get(pm.Id) + ')');
			}
        }        
									 
    }
}