@isTest
private class testProjectMilestoneDelete {

    public static testMethod void testProjectMilestoneDelete () {     

        Project_Milestone__c pmWithHours = [ select Id, Name from Project_Milestone__c 
        									where Id NOT IN ( select Project_Milestone__c from TimeSheetLine__c
        														where Project_Milestone__c != null ) limit 1];
                                                     
        Project_Milestone__c pmWithoutHours = [ select Id, Name from Project_Milestone__c 
        									where Id NOT IN ( select Project_Milestone__c from TimeSheetLine__c
        														where Project_Milestone__c = null ) limit 1];

    try
    {
    	delete pmWithoutHours;
        delete pmWithHours;                
    }
    catch (System.DmlException e) 
      {
        System.assert( e.getMessage().contains('You can not delete a milestone that has booked hours against it'), 
                e.getMessage() );

      }    
    } 

}