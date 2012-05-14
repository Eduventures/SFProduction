trigger ProjectProcedures on LABSMPM__Milestone1_Project__c (after insert) {

	List<Id> projectIds = new List<Id>(); 
	List<Projects__c> projects2update = new List<Projects__c>();
	Map<Id, Projects__c> plans2ProjectMap = new Map<Id, Projects__c>();
		
	if(Trigger.isInsert)
	{
		for(LABSMPM__Milestone1_Project__c m : Trigger.new)
		{
			projectIds.add(m.Project__c);
		}
		
		for(Projects__c p : [SELECT Id, Project_Plan__c FROM Projects__c WHERE Id in :projectIds])
		{
			plans2ProjectMap.put(p.Id,p);	
		}
		
		for(LABSMPM__Milestone1_Project__c m : Trigger.new)
		{
			if(plans2ProjectMap.containsKey(m.Project__c))
			{
				Projects__c temp = plans2ProjectMap.get(m.Project__c);
				temp.Project_Plan__c = m.Id;
				projects2update.add(temp);				
			}
		}		
	}
	
	if(!projects2update.isEmpty())
	{
		update projects2update;
	}
}