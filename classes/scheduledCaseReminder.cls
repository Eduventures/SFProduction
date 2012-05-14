global class scheduledCaseReminder implements Schedulable {

    global void execute(SchedulableContext SC) {
        CaseReminderEmail.process(); 
    }

}