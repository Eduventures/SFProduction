global class scheduleLoaRenewalRiskSync implements Schedulable {

    global void execute(SchedulableContext SC) {
        LoaRenewalRisk.process();   
    }

}