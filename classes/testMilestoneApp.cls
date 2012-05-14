@isTest
private class testMilestoneApp {

    public static testMethod void testMilestoneAutomation () {
    	LABSMPM__Milestone1_Project__c insertTriggerTest = new LABSMPM__Milestone1_Project__c();
    	Projects__c tempProject = new Projects__c(
    		RecordTypeId = '01230000000DMZc',
    		Product__c = 'CA',
    		Programs__c = 'CPE'
    	);
    	insert tempProject;
    	insertTriggerTest.Project__c = tempProject.Id;
    	insert insertTriggerTest;
    }
    
}