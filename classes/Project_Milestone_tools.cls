public class Project_Milestone_tools {

    @future (callout=true)
    public static void updateBookedHours(string milestoneId, Decimal hourTotal) {
    System.debug('milestoneId = ' + milestoneId + ': hours = ' + hourTotal);
    Project_Milestone__c tempPM = [ select Booked_Hours__c from Project_Milestone__c where Id = :milestoneId];
    
    tempPM.Booked_Hours__c = hourTotal;    
        try { 
                update tempPM; 
                System.debug('Update success! tempPM.Booked_hours__c = ' + tempPM.Booked_hours__c);
        } catch (System.Exception e) {
            System.debug(e.getMessage());
        }
    }
    
    static testMethod void testContact_tools() {
        User consultingUser = [ select Id, Name from User where ProfileId = '00e30000000nDXP' and IsActive = true limit 1];
        List<Projects__c> activeConsultingProjects = [SELECT Name, Programs__c, Active__c from Projects__c
                                                WHERE Programs__c = 'ECS' and Active__c = true ];
        
        Projects__c tempProject = activeConsultingProjects[0];  
        Project_Milestone__c pmActive = new Project_Milestone__c(   Project__c = tempProject.Id,
                                                        Status__c = 'Planned', 
                                                        Start__c = System.today().toStartOfWeek()+1, 
                                                        Name = 'TEST MILESTONE ACTIVE',
                                                        Estimated_Hours__c = 8,
                                                        End__c = System.today().toStartOfWeek()+1,
                                                        Assigned_To__c = consultingUser.Id );
                                                   
        insert pmActive; 
        TimeSheet__c ts = new TimeSheet__c();
        ts.Name = System.today().toStartOfWeek().format();
        ts.OwnerId = '00530000000wbsQ';
        ts.Week_Commencing__c = System.today().toStartOfWeek();
        ts.Status__c = 'Approved';
        insert ts;                

        TimeSheetLine__c tse = new TimeSheetLine__c();
        tse.Timesheet__c = ts.Id;
        tse.Date__c = pmActive.End__c;
        tse.UserId__c = pmActive.Assigned_To__c;
        tse.Project_Milestone__c = pmActive.Id;
        tse.ProjectId__c = pmActive.Project__c;
        tse.Hour__c = pmActive.Estimated_Hours__c;
        insert tse;
 
        Project_Milestone__c testPM = [ select Booked_Hours__c from Project_Milestone__c Limit 1];
        Project_Milestone_tools.updateBookedHours( testPM.id, 1.0); 
    }
}