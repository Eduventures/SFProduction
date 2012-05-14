@isTest
private class testManageWebsiteAccess {

    public static testMethod void testManageWebsiteAccess () {     
        Account acct = [SELECT Id, Name, Active_Engagements__c, (SELECT Id, Name, Seat_Holder__c FROM Contacts) 
                                        FROM Account WHERE Active_Engagements__c != 'XXX' and Active_Engagements__c != 'ECS'
                                         and Id = '0013000000G3YdY' LIMIT 1 ];
                                                                                                                      
		PageReference pageRefMWA = new PageReference('/apex/Manage_Website_Access?id='+ acct.Id);
        Test.setCurrentPage(pageRefMWA);
		ApexPages.StandardController tempStdController = new ApexPages.StandardController(acct);
      	ManageWebsiteAccessController controllerMWA = new ManageWebsiteAccessController(tempStdController);
		controllerMWA.getactiveEngagements();
		controllerMWA.getActivePrograms();
		controllerMWA.getaccountStaff();
   		ApexPages.currentPage().getParameters().put('cid', controllerMWA.accountStaff[0].con.Id);
   		ApexPages.currentPage().getParameters().put('status', 'true');  		
		controllerMWA.toggleSelected();
   		ApexPages.currentPage().getParameters().put('cid', controllerMWA.accountStaff[0].con.Id);
   		ApexPages.currentPage().getParameters().put('status', 'false');  		
		controllerMWA.toggleSelected();
		controllerMWA.cancel();
		controllerMWA.clearEdits();		
   		ApexPages.currentPage().getParameters().put('cid', controllerMWA.accountStaff[0].con.Id);
   		ApexPages.currentPage().getParameters().put('status', 'true');  		
		controllerMWA.toggleSelected();	
		controllerMWA.save();	
	}
}