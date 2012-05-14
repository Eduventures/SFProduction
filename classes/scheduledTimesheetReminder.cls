global class scheduledTimesheetReminder implements Schedulable {

    global void execute(SchedulableContext SC) {
        SendTimesheetReminders.process();
         
    }

}