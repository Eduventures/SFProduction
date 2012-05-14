global class MembershipAutomation implements Database.Batchable<Sobject>{

	global Database.QueryLocator start (Database.BatchableContext ctx) {
		return Database.getQueryLocator ([Select Id	From Membership__c 
											WHERE Status__c = 'Active' OR Expiration_Date__c = YESTERDAY ]);
	}
	
	global void execute (Database.BatchableContext ctx, List<Sobject> rows) {
		List<Membership__c> memberships = (List<Membership__c>) rows;
		update memberships;
	}

	global void finish (Database.BatchableContext ctx) {	
		   	
		AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
	      TotalJobItems, CreatedBy.Email
	      FROM AsyncApexJob WHERE Id =
	      :ctx.getJobId()];
	    // Send an email to the Apex job's submitter notifying of job completion. 
	    
	    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	    String[] toAddresses = new String[] {a.CreatedBy.Email};
	    mail.setToAddresses(toAddresses);
	    mail.setSubject('Membership Automation ' + a.Status);
	    mail.setPlainTextBody
	    ('The batch Apex job processed ' + a.TotalJobItems +
	    ' batches with '+ a.NumberOfErrors + ' failures.');
	    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}
}