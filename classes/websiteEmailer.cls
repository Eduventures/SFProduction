public class websiteEmailer {

	//asynchronous method is declared using the keyword '@future' - this relaxes the limits on the number of 
	//SQL requests we cna do, because salesforce.com can process the messages when it's resources are free 
	@future (callout=true)
  	public static void inviteNewUsers(List<String> userIDs) {
  		
  		//create a copy of the new user
  		List<Contact> newUsers = [select Id, Liaision__c, AccountId, Account.Name, FirstName, LastName, Email, Website_Username__c, 
  							Website_Password__c, Membership_Access__c, Membership_Access_Abbreviations__c, Seat_Holder__c from Contact 
  							where Id IN :userIDs];
	  		  	
		Messaging.SingleEmailMessage[] emailsToSend = new Messaging.SingleEmailMessage[]{};
  		
  		for(Contact newUser : newUsers)
  		{
			//if there is more than one program being added, store a variable to make the emailtext plural  'learning collaborative[s]'
			string multiLC = '';	
			List<String> liaisonFilter = new List<String>();
	 	
		 	//build the research track section of the email body by looping through all the added programs...
			string trackInfo = '';
			integer loopCount = 0;
		  	//parse the programs being added
		  	List<String> progs = newUser.Seat_Holder__c.split(';',0);
		  	//we'll need to include the Liaison's info for the User's reference, so we need a list of Liaison
			for(string s : progs)
			{
				liaisonFilter.add(s + ' Liaison');
			}
	  		
	  		//get a list of liaisons for this account, exclude the names of people marked "liaison 2" or "liaison assistant"
		  	List<Contact> liaisons = new List<Contact>();
		  	set<Id> existingLiaisons = new set<Id>();
			
			for(string lvalue : liaisonFilter)
			{
				List<Contact> liaisonsTemp = [ select Id, Name, LastName, FirstName, AccountId, phone, email, Liaision__c, Membership_Role__c from Contact where AccountId = :newUser.AccountId and Liaision__c != 'XXX' and Membership_Role__c includes (:lvalue) ORDER by LastName ASC, Firstname ASC];	
				
				for(Contact lt : liaisonsTemp)
				{
					if(!existingLiaisons.contains(lt.Id))
					{
						liaisons.add(lt);
						existingLiaisons.add(lt.Id);
					}
				}			
			}
			string liaison_info = '';
			
			//for each liaision, add an html row to the body of the email
			for(Contact l : liaisons)
			{
				if(liaisonFilter.size() != 0 )
				{
					liaison_info = liaison_info + '<tr><td>' + l.Name + '</td><td>' + l.email + '</td><td>' + l.Liaision__c + '</td></tr>';
				} 
			}
								   
			// Create a new single email message object
			// that will send out a single email to the addresses in the To, CC & BCC list.
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			
			// Strings to hold the email addresses to which you are sending the email.
			String[] toAddresses = new String[] {newUser.email}; 
			
			// Assign the addresses for the To and CC lists to the mail object.
			//mail.setToAddresses(toAddresses);
			// Specify the name used as the display name.
			// mail.setSenderDisplayName('Eduventures Website');
			// The email address of the user executing the Apex Code will be used.
			mail.setTargetObjectId(newUser.Id);
			mail.setSubject('Username and Password for Eduventures Web site');
			mail.setBccSender(true);
			mail.setSaveAsActivity(true);
			mail.setUseSignature(false);
			
			// Specify the text content of the email.
			//mail.setPlainTextBody('Your Case: ' + case.Id +' has been created');	
			
			string liaisonIntro = '';
			string LiaisonOutro = '';
			string seatholderIntro = '';
			string seatholderOutro = '';
			
			string emailBody = '';
			
			if(newUser.Liaision__c == 'XXX' && newUser.AccountId != '0013000000G3Y0S')
			{
				emailBody = '<p>Dear ' + newUser.Firstname + ',<br><br>' +
				'Welcome to Eduventures! ' + newUser.Account.Name + ' is a member of the ' + newUser.Membership_Access__c + 
				' Learning Collaborative' + multiLC + ' (' + newUser.Membership_Access_Abbreviations__c  + '); you now have access to the many online resources available'
				+ ' as a seat holder. Your username and temporary password are below (note - passwords must be a minimum of 6 characters and contain both numbers and letters):<br><br>' + 
				'<b>Username: ' + newUser.Website_Username__c + '<br>' +
				'Password: ' + newUser.Website_Password__c + '</b><br><br>' +
				'website url: www.eduventures.com<br><br>' +
				' Periodically, you will receive newsletters and invitations to attend Member Roundtable webinars (past webinars are archived on the Web site). We encourage you to participate in ' +
				newUser.Membership_Access_Abbreviations__c + ' activities whenever possible.<br><br>' + 
				'Should you have any questions regarding your membership, please contact your campus liaison.<br><br>' + 
				'<table><tr><td>Name</td><td>E-mail</td><td>Liaison for (Program)</td></tr>' + liaison_info + '</table><br>We look forward to working with you!<br>Best,<br>The Eduventures Member Services team<br><br>' +
				'This email was sent to: ' + newUser.email + '</p>';
				
			}
			else if (newUser.AccountId != '0013000000G3Y0S')
			{
				emailBody = '<p>Dear ' + newUser.Firstname + ',<br><br>' +
				'Welcome to Eduventures! We are pleased to have ' + newUser.Account.Name + ' as a member of the ' + newUser.Membership_Access__c + ' Learning Collaborative' + multiLC + 
				' (' + newUser.Membership_Access_Abbreviations__c  + '); you now have access to the many online resources membership affords. Your username and password are below:<br><br>' + 
				'<b>Username: ' + newUser.Website_Username__c + '<br>' +
				'Password: ' + newUser.Website_Password__c + '</b><br><br>' +
				'website url: www.eduventures.com<br><br>' +		
				'To view your institution\'s seatholders, login to the website and browse the <a href="http://www.eduventures.com/private/sh-management/seathmanagement">Your Account</a> tab<br><br>' + 	
				' Periodically, you will receive newsletters and invitations to attend Member Roundtable webinars (past webinars are archived on the Web site). ' +
				'As your campus liaison, you will also receive communications from our research staff regarding Collaborative and Custom Research. ' +
				'We encourage you to participate in ' + newUser.Membership_Access_Abbreviations__c + ' activities whenever possible and to share this information with your team.<br><br>' +   
				'Should you have any questions regarding your membership, how to best use our services, or extending access to colleagues, please contact clientservices@eduventures.com.<br><br>' +
				'We look forward to working with you!<br>Best,<br>The Eduventures Member Services team<br><br>' +
				'This email was sent to: ' + newUser.email + '</p>';
			}
			else
			{
				emailBody = '<p>Dear ' + newUser.Firstname + ',<br><br>' +
				'Welcome to Eduventures! As a staff member, you have access to the following programs: ' + 
				' (' + newUser.Membership_Access_Abbreviations__c  + ');<br><br>' + 
				'Your username and password are below:<br><br>' + 
				'<b>Username: ' + newUser.Website_Username__c + '<br>' +
				'Password: ' + newUser.Website_Password__c + '</b><br><br>' +
				'website url: www.eduventures.com</p>';		
			}			
			mail.setHtmlBody(emailBody);
			emailsToSend.add(mail);
  		}	
		// Send the email you have created.
		try { 
				if(URL.getSalesforceBaseUrl().getHost().substring(0,1) == 'n')
				{
					Messaging.sendEmail(emailsToSend);
				}	    
	    } catch (System.EmailException e) {
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		   String[] toAddresses = new String[] {'adellicicchi@eduventures.com'};
		   mail.setToAddresses(toAddresses);
		   mail.setSubject('Error notifying new contacts of website access!');
		   mail.setPlainTextBody
		   ('ERROR MESSAGE: ' + e.getMessage() + '\n\nContact Ids' +  userIDs);
		   Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
			
  	}
  	
  	//asynchronous method is declared using the keyword '@future' - this relaxes the limits on the number of 
	//SQL requests we cna do, because salesforce.com can process the messages when it's resources are free 
	@future (callout=true)
  	public static void notifyExistingUsers(List<Id> contactIds) {	
  		
   		//create a copy of the new user
  		List<Contact> existingUsers = [select Id, Liaision__c, AccountId, Account.Name, Account.Active_Engagements__c, FirstName, 
  										LastName, Email, Website_Username__c, Seat_Holder__c, Website_Password__c, Membership_Access__c, 
  										Membership_Access_Abbreviations__c,
  											(SELECT Subject, Id FROM ActivityHistories WHERE 
  												(Subject LIKE '%Reminder: you have access to%' OR Subject LIKE '%Username and Password for Eduventures Web site%' )
  												 and CreatedDate = TODAY) 
  										from Contact where Id IN :contactIds];
  										
  		Messaging.SingleEmailMessage[] emailsToSend = new Messaging.SingleEmailMessage[]{};
  		
  		for(Contact c : existingUsers)
  		{
		  	if(c.ActivityHistories.size() == 0)
		  	{
		  		// Create a new single email message object for each contact
				// that will send out a single email to the addresses in the To, CC & BCC list.
				Messaging.SingleEmailMessage mailer = new Messaging.SingleEmailMessage();
				
				// Strings to hold the email addresses to which you are sending the email.
				String[] toAddresses = new String[] {c.email}; 
				
				// Assign the addresses for the To and CC lists to the mail object.
				//mail.setToAddresses(toAddresses);
				// Specify the name used as the display name.
				// mail.setSenderDisplayName('Eduventures Website');
				// The email address of the user executing the Apex Code will be used.
				mailer.setTargetObjectId(c.Id);
				mailer.setSubject('Reminder: you have access to Eduventures\' online resources');
				mailer.setBccSender(true);
				mailer.setSaveAsActivity(true);
				mailer.setUseSignature(false);
				string emailBody = '<p><img src="http://www.eduventures.com/logo.jpg" /></p><p>This is a reminder that you have been granted access to the <b>' +
				c.Membership_Access__c + '</b> Learning Collaborative resources available at www.eduventures.com.<br /> <br /> Your credentials are below:<br /> <br />Username:  <b>' + 
				c.Website_Username__c + '</b><br />Password:  (For security reasons, we do not email passwords. Please visit the website and click ' + 
				'on \"Forgot your password?\" at the top of the screen if you need to reset it)<br /> <br /> Please feel free to contact us with any questions. The Member Support ' + 
				' page at www.eduventures.com/private/support has names, phone numbers and email addresses of Learning Collaborative staff, as well as '+ 
				'an online help request form.<br /><br />Sincerely, Eduventures Member Services<br /><br /><br /><br />' +
				'This email was sent to ' + c.email + ' because website access was granted (or renewed)</p>';
				mailer.setHtmlBody(emailBody);
		
				string ptemailBody = 'This is a reminder that you have been granted access to the' +
				c.Membership_Access__c + ' Learning Collaborative resources available at www.eduventures.com.\n\nYour credentials are below:\n\nUsername:  ' + 
				c.Website_Username__c + '\n\nPassword:  (For security reasons, we do not email passwords. Please visit the website and click ' + 
				'on \"Forgot your password?\" at the top of the screen if you need to reset it.)\n\n Please feel free to contact us with any questions.\n\nThe Member Support ' + 
				' page at www.eduventures.com/private/support has names, phone numbers and email addresses of Learning Collaborative staff, as well as '+ 
				'an online help request form.\n\nSincerely, Eduventures Member Services\n\n\n\n' +
				'This email was sent to ' + c.email + ' because website access was granted (or renewed)</p>';
				mailer.setPlainTextBody(ptemailBody);
				emailsToSend.add(mailer);		  		
		  	}	
  		}	
		// Send the email you have created.
		try { 
				if(URL.getSalesforceBaseUrl().getHost().substring(0,1) == 'n')
				{
					Messaging.sendEmail(emailsToSend);
				}	    
		} catch (System.EmailException e) {
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		   String[] toAddresses = new String[] {'adellicicchi@eduventures.com'};
		   mail.setToAddresses(toAddresses);
		   mail.setSubject('Error notifying existing contacts of website access!');
		   mail.setPlainTextBody
		   ('ERROR MESSAGE: ' + e.getMessage() + '\n\nContact Ids' +  contactIds);
		   Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
  	}
  	
  	static testMethod void testwebsiteEmailers() {
		List<Id> testContactIds = new List<Id>();
		for(Contact c :  [Select Id, AccountId, Seat_Holder__c, email from Contact where AccountId = '0013000000K2fUX' 
																			and email like 'web%' and Seat_Holder__c != 'XXX'])
		{
			testContactIds.add(c.Id);
		}
		websiteEmailer.inviteNewUsers(testContactIds);
		websiteEmailer.notifyExistingUsers(testContactIds);		
	}

}