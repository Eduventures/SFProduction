@isTest
private class testProjectsDashboardController { 
    public static testMethod void testProjectsDashboardController () {
       
        List<User> consultingUsers = [ select Id, Name from User where IsActive = true 
        						and ProfileId = '00e30000000nDXP' limit 1];
                  
        List<Projects__c> activeConsultingProjects = [SELECT Name, Programs__c, Active__c from Projects__c
        										WHERE Programs__c = 'ECS' and Active__c = true ];
                       
        ProjectsDashboardController controllerPD = new ProjectsDashboardController();         
		PageReference pageRefPD = new PageReference('/apex/ProjectsDashboard');
        Test.setCurrentPage(pageRefPD);
    try
    {
    	controllerPD.setprojIndex(1); 
    	controllerPD.getprojIndex();
    	ApexPages.currentPage().getParameters().put('projIndex','1');    	
    	controllerPD.addProjectForUpdate();
     	controllerPD.next();   	
    	controllerPD.cancel();
    	controllerPD.addProjectForUpdate();
    	controllerPD.addProjectForUpdate();
    	controllerPD.save();   	    	    	
    	controllerPD.getProjectList();
    	controllerPD.getStaffList();
	   	controllerPD.getActiveProjects();
    	controllerPD.getWeeksData();
    	controllerPD.nextWeek();
    	controllerPD.previousWeek();
    	controllerPD.next();
    	controllerPD.previous();
    	controllerPD.next();
   
    }
    catch (System.DmlException e) 
      {
        System.debug('Failed to run testProjectsDashboardController: '+ e.getMessage());
      }    
    } 

}