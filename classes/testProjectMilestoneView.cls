@isTest
private class testProjectMilestoneView {

    public static testMethod void testProjectMilestoneView () {     
        User consultingUser = [ select Id, Name from User where ProfileId = '00e30000000nDXP' and IsActive = true limit 1];
                  
        List<Projects__c> activeConsultingProjects = [SELECT Name, Programs__c, Active__c from Projects__c
        										WHERE Programs__c = 'ECS' and Active__c = true ];
        
		Projects__c tempProject = activeConsultingProjects[0];  
		
		List<Project_Milestone__c>  milestonesToCreate = new List<Project_Milestone__c>();
		
	    Project_Milestone__c pmActive = new Project_Milestone__c(   Project__c = tempProject.Id,
                                                                Status__c = 'Planned', 
                                                                Start__c = System.today().toStartOfWeek()+1, 
                                                                Name = 'TEST MILESTONE ACTIVE',
                                                                Estimated_Hours__c = 8,
                                                                End__c = System.today().toStartOfWeek()+1,
                                                                Assigned_To__c = consultingUser.Id );
        milestonesToCreate.add(pmActive);                                                        
        Project_Milestone__c pmInactive = new Project_Milestone__c(   Project__c = tempProject.Id,
                                                                Status__c = 'Planned', 
                                                                Start__c = System.today().toStartOfWeek()+2, 
                                                                Name = 'TEST MILESTONE INACTIVE',
                                                                Estimated_Hours__c = 16,
                                                                End__c = System.today().toStartOfWeek()+3,
                                                                Assigned_To__c = consultingUser.Id );
        milestonesToCreate.add(pmInactive);       
        insert milestonesToCreate; 
                                                                                                                       
		PageReference pageRefPMV = new PageReference('/apex/ProjectPMView?id='+ tempProject.Id);
        Test.setCurrentPage(pageRefPMV);
        ApexPages.currentPage().getParameters().put('selected', milestonesToCreate[0].Id);
        ApexPages.StandardController tempStdController = new ApexPages.StandardController(tempProject);
        ProjectPMViewController controllerPMV = new ProjectPMViewController(tempStdController);
    try
    {
    	controllerPMV.getStaff();
        controllerPMV.newMilestone = new Project_Milestone__c(  Project__c = tempProject.Id,
                                                                Status__c = 'Planned', 
                                                                Start__c = System.today().toStartOfWeek()+4, 
                                                                Name = 'TEST MILESTONE INSERT',
                                                                Estimated_Hours__c = 16,
                                                                End__c = System.today().toStartOfWeek()+5,
                                                                Assigned_To__c = consultingUser.Id);
        controllerPMV.saveNew();
   		ApexPages.currentPage().getParameters().put('editPreceedingId', milestonesToCreate[1].Id);
   		controllerPMV.editPreceeding();
    	ApexPages.currentPage().getParameters().put('preceedingId', milestonesToCreate[0].Id);
    	controllerPMV.linkPreceeding(); 
    	ApexPages.currentPage().getParameters().put('editPreceedingId', milestonesToCreate[1].Id);
   		controllerPMV.editPreceeding();
   		controllerPMV.cancelEdits();
   		Apexpages.currentPage().getParameters().put('mid',milestonesToCreate[0].Id);
   		controllerPMV.editMilestone();
   		controllerPMV.cancelEdits();
   		Apexpages.currentPage().getParameters().put('mid',milestonesToCreate[1].Id);
   		controllerPMV.editMilestone();
   		controllerPMV.cancelEdits(); 
   		controllerPMV.editAll(); 
   		controllerPMV.cancelEdits();
   		controllerPMV.editAll(); 
   		controllerPMV.saveEdits();
   		consultingUser.IsActive = false;
   		update consultingUser;
   		milestonesToCreate[1].Status__c = 'Complete';
   		update milestonesToCreate[1];
   		  		
    }
    catch (System.DmlException e) 
      {
        System.debug('Failed to run testProjectMilestoneView: '+ e.getMessage());
      }    
    } 
}