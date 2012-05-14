public class CaseReminderEmail {
    
    @future (callout=true)
    public static void process() {
        List<String> idList = new List<String>();
		List<String> mailToAddresses = new List<String>();

		Group g = [SELECT (select UserOrGroupId from GroupMembers) FROM group g WHERE g.Id = '00G30000000uSU7'];
		for (GroupMember gm : g.groupMembers)
		{
			idList.add(gm.userOrGroupId);
		}

		User[] usr = [SELECT email FROM user WHERE id IN :idList];
		for(User u : usr)
		{
			mailToAddresses.add(u.email);
		}

        List<Case> casesWithReminders = [ select Id, CaseNumber, Type, Problem_Detail__c, CreatedDate, Follow_Up_Date__c, Contact.Name, OwnerId, Case_Manager__c from Case where Status != 'Closed' and Follow_Up_Date__c = TODAY];            
        for(Case c: casesWithReminders)
        {       	
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            if(c.Case_Manager__c != null)
            {
            	mail.setTargetObjectId(c.Case_Manager__c);
            }
            mail.setToAddresses(mailToAddresses);  
            System.debug(c.CreatedDate);
            mail.setSubject('Reminder note for Case ' + c.CaseNumber + ' opened on ' + c.CreatedDate);
            mail.setUseSignature(false);
            mail.setSaveAsActivity(false);
            string emailBody = 'Follow up required for ' + c.Contact.Name + '\'s case<br />Type:' + c.Type + '<br />Detail: ' + c.Problem_Detail__c + '<br />Link to Case: http://login.salesforce.com?startURL=' + c.Id ;                    
            System.debug(emailBody);
            mail.setHtmlBody(emailBody);     
        
            // Send the email you have created.
            try { 
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });       
            } catch (System.EmailException e) {     }    
        }        
    }
    
    static testMethod void testCaseReminderEmail() {
        
        CaseReminderEmail.process(); 
    }

}