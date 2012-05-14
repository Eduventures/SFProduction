@istest
private class testSchedulerClasses {
	public static testMethod void testClasses() {
		test.starttest();
		
		scheduledAbandonCall sac = new scheduledAbandonCall();
		String sch1 = '0 0 5 * * ?';
		system.schedule('scheduledAbandonCall test', sch1,sac );
		
		scheduledAccountAutomation saa = new scheduledAccountAutomation();
		String sch2 = '0 0 6 * * ?';
		system.schedule('scheduledAccountAutomation test', sch2, saa);
				
		scheduledCaseReminder scr = new scheduledCaseReminder();
		String sch3 = '0 0 7 * * ?';
		system.schedule('scheduledCaseReminder test', sch3, scr );
		
		scheduledOpportunityExpiration soe = new scheduledOpportunityExpiration();
		String sch4 = '0 0 8 * * ?';
		system.schedule('scheduledOpportunityExpiration test', sch4,soe );
		
		scheduleLoaRenewalRiskSync slrrs = new scheduleLoaRenewalRiskSync();
		String sch5 = '0 0 9 * * ?';
		system.schedule('scheduleLoaRenewalRiskSync test', sch5, slrrs);
		
		scheduledTimesheetReminder str = new scheduledTimesheetReminder();
		String sch6 = '0 0 10 * * ?';
		system.schedule('scheduledTimesheetReminder test', sch6, str);
								
		test.stopTest();
	}
}