global class scheduledAbandonCall implements Schedulable {
 
    global void execute(SchedulableContext SC) {
        ProjectCallExpiration.process();
    }

}