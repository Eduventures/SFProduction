global class scheduledOpportunityExpiration implements Schedulable {
 
    global void execute(SchedulableContext SC) {
        OpportunityAutoExpiration.process(); 
    }

}