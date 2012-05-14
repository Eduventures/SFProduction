global class scheduledAccountAutomation implements Schedulable {

    global void execute(SchedulableContext SC) {
        AccountAutomation.process();
        Database.executeBatch(new MembershipAutomation(), 20);
    }

	public static void scheduleMe() {
		String SCHEDULE_NAME = 'LOA/Account/Membership Automation';
		id cronid = System.schedule(SCHEDULE_NAME, '0 0 4 * * ? *', new scheduledAccountAutomation());
		system.debug('Acct automation Job Scheduled!'); 
	} 
}