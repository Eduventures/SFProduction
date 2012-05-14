public with sharing class ProjectCallExpiration {

    public static void process() {
    	Date cutoffDay  = System.today()-90;
    	List<Projects__c> callsToExpire = [ SELECT Id, Name, Stage__c, Product__c, Default_Call_Date__c, Total_Hours_Calc__c, Work_Completed_Date__c, Call_Scheduled_Time__c 
    										 FROM Projects__c 
    										WHERE Product__c IN ('OBC','MYC') AND Stage__c = 'Not Started' AND Default_Call_Date__c < :cutoffDay
    											AND Total_Hours_Calc__c = 0 and Work_Completed_Date__c = null and Call_Scheduled_Time__c = null ];
    	for(Projects__c p:callsToExpire)
    	{
    		p.Stage__c = 'Abandoned';
    	}
    
    	update callsToExpire;
    }
    
    static testMethod void testAccountAutomation() {
        
        ProjectCallExpiration.process();
    }       
}