trigger TimeSheetLineMilestoneRollup on TimeSheetLine__c (after insert, after update, after delete) {
   
    if(Trigger.isDelete)
    {
        Set<Id> projectsToUpdate = new  Set<Id>();
        for( TimeSheetLine__c tse : Trigger.old)
        {
            if(!projectsToUpdate.contains(tse.ProjectId__c))
            {
                projectsToUpdate.add(tse.ProjectId__c);
            }
        }
        
        List<Projects__c> updateProjects = [SELECT Id from Projects__c where Id in :projectsToUpdate];
        update  updateProjects;
    } else
    {  
        Set<Id> projectMilestonesToUpdate = new  Set<Id>();
        List<Project_Milestone__c> updatedMilestones = new List<Project_Milestone__c>();        
    
        for( TimeSheetLine__c tse : Trigger.new)
        {
            if(tse.Project_Milestone__c != null)
            {
                if(!projectMilestonesToUpdate.contains(tse.Project_Milestone__c))
                {
                    projectMilestonesToUpdate.add(tse.Project_Milestone__c);
                }
            }
        }
    
        Map<Id, Project_Milestone__c> theMilestones = new Map<Id, Project_Milestone__c>([SELECT Booked_Hours__c from Project_Milestone__c where Id in :projectMilestonesToUpdate]); 
    
        for(AggregateResult result: [SELECT SUM(Hour__c) totlHrs, Project_Milestone__c milestone 
                                        From TimeSheetLine__c WHERE Project_Milestone__c in :projectMilestonesToUpdate 
                                        GROUP BY Project_Milestone__c])
        {
            Project_Milestone__c tempPM = theMilestones.get((Id)result.get('milestone'));
            tempPM.Booked_Hours__c = (Double)result.get('totlHrs');
            updatedMilestones.add(  tempPM  ); 
        }
                
        update updatedMilestones;                                 
                //system.debug('new Total booked Hours for milestone ' + result.get('milestone') + ' = ' + result.get('totlHrs') );
    }                                                    
}