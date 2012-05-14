trigger ProjectMilestoneLogHours on Project_Milestone__c (after insert, after update) {
    set<Id> userSet = new set<Id>();
    Map<Id,User> userMap;
    for(Project_Milestone__c pm : Trigger.new)
    {     
    	userSet.add(pm.Assigned_To__c);
    }
    userMap = new Map<ID, User>([select id, isActive, Name from User where Id in :userSet]);
    for(Project_Milestone__c pm : Trigger.new)
    {     

        //if the milestone is for a contractor and it's complete, log the time to the project
        if(pm.Status__c == 'Complete' && userMap.containsKey(pm.Assigned_To__c) && userMap.get(pm.Assigned_To__c).IsActive == False)
        {
            Date weekStart = pm.End__c.toStartOfWeek();
            
            TimeSheet__c ts = new TimeSheet__c();
            
            if( [select count() from TimeSheet__c where Name = :weekStart.format() and OwnerId = '00530000000wbsQ'] == 0)
            {
                ts.Name = weekStart.format();
                ts.OwnerId = '00530000000wbsQ';
                ts.Week_Commencing__c = weekStart;
                ts.Status__c = 'Approved';
                insert ts;                
            }else
            {
                 ts = [select Id, Name from TimeSheet__c where Name = :weekStart.format() and OwnerId = '00530000000wbsQ'][0];   
            }
            
            if( [select count() from TimeSheetLine__c where Date__c = :pm.End__c and Project_Milestone__c = :pm.Id and UserId__c = :pm.Assigned_To__c] == 0)
            {
                TimeSheetLine__c tse = new TimeSheetLine__c();
                tse.Timesheet__c = ts.Id;
                tse.Date__c = pm.End__c;
                tse.UserId__c = pm.Assigned_To__c;
                tse.Project_Milestone__c = pm.Id;
                tse.ProjectId__c = pm.Project__c;
                tse.Hour__c = pm.Estimated_Hours__c;
                insert tse;
            }  
        }
    }

}