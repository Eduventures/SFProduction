public class OpportunityAutoExpiration {
    
    @future (callout=true)
    public static void process() {
        List<Opportunity> expiredOpps = [ select o.Id, o.StageName, o.Close_Date_New__c, o.Remarket_Lost_Reason__c, o.RecordTypeId from Opportunity o 
        									where o.Close_Date_New__c < LAST_N_DAYS:60 and o.RecordTypeId = '01230000000DMio'
                                            and o.StageName not in ('Closed Won','Closed Lost','Remarket')];       

        for(Opportunity o: expiredOpps)
        {
            o.StageName = 'Closed Lost';
            o.Renewal_Lost_Notes__c = 'Opportunity Expired (over 60 days)';
            o.Reason_Renewal_Remarket_or_Lost__c = 'Lapsed (60 Days)';
        }
        update expiredOpps;
    }
    
    static testMethod void testOpportunityAutoExpiration() {
        
        OpportunityAutoExpiration.process();
    }

}