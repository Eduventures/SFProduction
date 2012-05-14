public with sharing class SendTimesheetReminders {
  
    public static void process() {
        Datetime todayDT = Datetime.now();
		String todayName = todayDT.format('E');
        Date today = Date.today();
        Date weekStartDate = today.toStartOfWeek();
        if(todayName.toLowerCase()=='fri' || todayName.toLowerCase()=='friday')
        {
            list<Timesheet__c> ts = [SELECT OwnerId FROM Timesheet__c WHERE Week_Commencing__c = last_week];
            set<id> goodUsers = new set<id>();
            for(integer i = 0; i < ts.size(); i++)
            {
                goodUsers.add(ts[i].OwnerId);       
            }
            list<user> badUsers = [SELECT Id, Name, Email, Receive_Timesheet_Reminders__c, UserType FROM User WHERE Id NOT IN : goodUsers and IsActive = true and UserType = 'Standard' ];   
            integer noOfEmailReceivers = 0;
            for(integer i = 0; i < badUsers.size(); i++)
            {
            	if(badUsers[i].Receive_Timesheet_Reminders__c)
            	{
            		noOfEmailReceivers++;
            	}
            }
            Messaging.SingleEmailMessage[] messageArr = new Messaging.SingleEmailMessage[noOfEmailReceivers];
            integer badUserCounter = 0;
            for(integer i = 0; i < badUsers.size(); i++)
            {
                if(badUsers[i].Receive_Timesheet_Reminders__c)
                {
	                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	                String[] toAddresses = new String[]{badUsers[i].Email};
	                mail.setToAddresses(toAddresses);
	                mail.setSubject('Timesheet Reminder');
	                string mailBody = 'Hi '+badUsers[i].Name+',<br/><br/>';
	                mailBody += 'You have not created a Timesheet for this week yet!<br/>'; 
	                mailBody += 'Click <a href=\'https://na6.salesforce.com/apex/myTimeSheets\'>HERE</a> to create one and log your hours<br/>';
	                mailBody += 'Regards,<br/>Eduventures SalesForce Admin';
	                mail.setHtmlBody(mailBody);
	                messageArr[badUserCounter] = mail;
	                badUserCounter++;
                }
            }
            if(messageArr.size()>0)
            {
                Messaging.sendEmail(messageArr);
            }   
        }

    }    	

    static testMethod void testAccountAutomation() {
        SendTimesheetReminders.process(); 
    }    
}