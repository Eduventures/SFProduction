public class monthlySalesTargetsController {
    public Integer actualNewMeetings {get;set;}
    public Integer actualFollowupMeetings {get;set;}
    public Integer actualUpsideOpps {get;set;}
    public Integer actualQualifiedOpps {get;set;}
    public Integer actualCloseableOpps {get;set;}
    public Integer actualClosedWonSnapshot {get;set;}
    public Integer actualClosedWonMTD {get;set;}    
    public monthlySalesTargetsController () {

    	actualNewMeetings = 0;
    	actualFollowupMeetings = 0;
        
        for(Event n: [SELECT Type,ActivityDate, WhatId FROM Event 
        			WHERE Type in ('Onsite Meeting','Conference Call') and ActivityDate = THIS_MONTH])
        {
        	if(n.WhatId != null && String.valueOf(n.WhatId).startsWith('006'))
        	{
        		actualNewMeetings = actualNewMeetings + 1;
        	}
        }                    
        for(Event f: [SELECT Type,ActivityDate, WhatId FROM Event WHERE 
        					Type in ('Follow up Conference Call','Follow up Onsite Meeting') and 
                            ActivityDate = THIS_MONTH])
        {
        	if(f.WhatId != null && String.valueOf(f.WhatId).startsWith('006'))
        	{
        		actualFollowupMeetings = actualFollowupMeetings + 1;
        	}        	
        }                              
        actualUpsideOpps = [ SELECT count() FROM Analytic_Snapshot_Opp_Scorecard__c WHERE Stage__c = 'Upside' and
                                Close_Date__c = THIS_MONTH and CreatedDate = THIS_MONTH]; 
        actualQualifiedOpps = [ SELECT count() FROM Analytic_Snapshot_Opp_Scorecard__c WHERE Stage__c= 'Qualified' and
                                Close_Date__c = THIS_MONTH and CreatedDate = THIS_MONTH ]; 
        actualCloseableOpps = [ SELECT count() FROM Analytic_Snapshot_Opp_Scorecard__c WHERE Stage__c = 'Closeable' and
                                Close_Date__c = THIS_MONTH and CreatedDate = THIS_MONTH];      
        actualClosedWonSnapshot = [ SELECT count() FROM Analytic_Snapshot_Opp_Scorecard__c WHERE Stage__c = 'Closed Won' and
                                Close_Date__c = THIS_MONTH and CreatedDate = THIS_MONTH]; 
        actualClosedWonMTD = [ SELECT count() FROM Opportunity WHERE StageName = 'Closed Won' and 
        						CloseDate = THIS_MONTH];         
    }
     
    public static testMethod void testMonthlySalesTargetsController() {
        PageReference pageRef = Page.dashboard_monthly_sales_targets;
        Test.setCurrentPage(pageRef);
      
        monthlySalesTargetsController controller = new monthlySalesTargetsController();  
    }

}