public class LoaRenewalRisk {
     
    @future (callout=true)
    public static void process() {
        Date today = System.today();
        Integer year = today.year(); 
        List<LOA__c> lostLoas = [SELECT Id, End_Date__c, Extension_Date__c, Program__c, Renewal_Risk__c, Status__c FROM LOA__c 
                            WHERE RecordTypeId = '01230000000DMbx' and Renewal_Risk__c in ('At Risk','Not At Risk','')
                            and Status__c in ('Expired','Extended') and CALENDAR_YEAR(End_Date__c) >= 2010 and 
                            Program__c not in ('RPT','Sponsorship','ECS') 
                            and ( (End_Date__c < :today-60 ) and ( (Extension_Date__c = null) OR (Extension_Date__c < :today) ) )];
       System.debug('found ' + lostLoas.size() + ' loas');
        
        for(LOA__c l:lostLoas)
        {
            l.Renewal_Risk__c = 'Not Renewing';
        }
         
        try { 
            update lostLoas;       
        } catch (Exception e) {  
        	System.debug(e.getMessage());
        }
        
        List<LOA__c> renewedLoas = [SELECT Id, End_Date__c, Extension_Date__c, Program__c, Renewal_Risk__c, Status__c FROM LOA__c 
                            WHERE RecordTypeId = '01230000000DMbx' and Renewal_Risk__c in ('At Risk','Not Renewing','')
                            and Renewed__c = true and CALENDAR_YEAR(End_Date__c) >= 2010 and 
                            Program__c not in ('RPT','Sponsorship','ECS')];
        System.debug('found ' + renewedLoas.size() + ' loas');
        
        for(LOA__c l:renewedLoas)
        {
            l.Renewal_Risk__c = 'Not At Risk';
        }
         
        try { 
            update renewedLoas;       
        } catch (Exception e) {  
        	System.debug(e.getMessage());
        }               
    }
    
    static testMethod void testLoaRenewalRisk() {
        
        LoaRenewalRisk.process(); 
    }

}