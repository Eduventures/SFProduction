public class Contract_Year_tools {

    @future (callout=true)
    public static void linkCY (string cyid) {
        Contract_Year__c insertedCY = [ SELECT LOA__c, LOA__r.Membership__c, Recognition_Date__c, End_Date__c, Program_Family__c,
        								Type__c, Prior_Contract_Year__c, Renewal_Contract_Year__c FROM Contract_Year__c 
        								WHERE Id = :cyid ];
		Contract_Year__c prior = new Contract_Year__c();
		if([ SELECT count() FROM Contract_Year__c WHERE LOA__r.Membership__c = :insertedCY.LOA__r.Membership__c ] != 0)
		{
			if(insertedCY.Type__c == 'Renewal')
			{
				for(Contract_Year__c priorCY:[ SELECT LOA__c, LOA__r.Membership__c, Recognition_Date__c, End_Date__c, 
												Program_Family__c, Type__c, Prior_Contract_Year__c, Renewal_Contract_Year__c
												FROM Contract_Year__c WHERE LOA__r.Membership__c = :insertedCY.LOA__r.Membership__c
												AND End_Date__c <= :insertedCY.Recognition_Date__c ORDER BY End_Date__c DESC LIMIT 1])
				{
					insertedCY.Prior_Contract_Year__c = priorCY.Id;
					prior = priorCY;
					prior.Renewal_Contract_Year__c = insertedCY.Id;
				}				
			}
			for(Contract_Year__c renewalCY:[ SELECT LOA__c, LOA__r.Membership__c, Recognition_Date__c, End_Date__c, 
											Program_Family__c, Type__c, Prior_Contract_Year__c, Renewal_Contract_Year__c
											FROM Contract_Year__c WHERE LOA__r.Membership__c = :insertedCY.LOA__r.Membership__c
											AND Recognition_Date__c >= :insertedCY.End_Date__c ORDER BY Recognition_Date__c  LIMIT 1])
			{
				insertedCY.Renewal_Contract_Year__c = renewalCY.Id;
			}							
		}
			
        try { 
                update insertedCY;
                if(prior.Id != null)
                {
                	update prior;
                }
                      
        } catch (System.Exception e) {
        	//send email to admin
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			String[] toAddresses = new String[] {'adellicicchi@eduventures.com'}; 
			mail.setToAddresses(toAddresses); 
			mail.setSubject('Apex Error during Post-LOA insertion Contract Year linking');
			mail.setPlainTextBody(
			   'The LOAInsertAfter trigger called Contract_Year_tools, which threw the following exception: ' + 
			         e.getMessage());
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
    
    static testMethod void testContract_Year_tools() {
        Contract_Year_tools.linkCY('a0V80000005QQae');  
    }
}