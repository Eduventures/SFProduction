global class cases implements Messaging.InboundEmailHandler {

global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, 
                                                  Messaging.InboundEnvelope env){

	// Create an inboundEmailResult object for returning 
	// the result of the Force.com Email Service
	Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
	
	String myPlainText = '';
	String caseNo = '';
	String fromN = '';
	String fromA = '';
	String contactMethod = ''; 
	String newStatus = '';
	
	// Add the email plain text into the local variable 

	try
	{
		caseNo = email.plainTextBody.substring(email.plainTextBody.indexOf('CaseId:')+7, email.plainTextBody.indexOf('<caseid>'));  
		Case caseToUpdate = [ select id, status, subject, description, Contact_Method__c,Met_Target_Response_Time__c, CreatedDate  from Case where Id = :caseNo limit 1];
		fromN = email.fromName;
		fromA = email.fromAddress;		
		if(email.plainTextBody.contains('@@'))
		{
			myPlainText = email.plainTextBody.substring(0, email.plainTextBody.indexOf('@@'));
		    System.debug(myPlainText);
		    newStatus = email.plainTextBody.substring(email.plainTextBody.indexOf('@@')+2,email.plainTextBody.indexOf('@@') + 3 );
		    System.debug(newStatus);
		    contactMethod =  email.plainTextBody.substring(email.plainTextBody.indexOf('@@')+ 3,email.plainTextBody.indexOf('@@')+ 4 );
		    System.debug(contactMethod);
		
		      
		    if(newStatus == 'H')
			{
				caseToUpdate.status = 'On Hold';
			}
			else if(newStatus == 'C' )
			{
				caseToUpdate.status = 'Closed';	
			}
			else if(newStatus == 'O' )
			{
				caseToUpdate.status = 'Open';	
			}
					
			if( (System.now().getTime()- caseToUpdate.CreatedDate.getTime()) /60000 > 90.0)
			{
				caseToUpdate.Met_Target_Response_Time__c = 'No';
			}
			else
			{
				caseToUpdate.Met_Target_Response_Time__c = 'Yes';	
			}
			
			if(contactMethod =='I')
			{
				caseToUpdate.Contact_Method__c = 'In Person';
			}
			else if(contactMethod =='P' )
			{
				caseToUpdate.Contact_Method__c = 'Phone';
			}
			else if(contactMethod =='E' )
			{
				caseToUpdate.Contact_Method__c = 'E-mail';
			}
			else if(contactMethod =='V' )
			{
				caseToUpdate.Contact_Method__c = 'Left Voicemail';
			}
			else if( contactMethod =='N')
			{
				caseToUpdate.Contact_Method__c = 'Left Note';
			}
			if(newStatus == 'H')
			{
				caseToUpdate.status = 'On Hold';
			}
			else if(newStatus == 'C' )
			{
				caseToUpdate.status = 'Closed';	
			}
			else if(newStatus == 'O' )
			{
				caseToUpdate.status = 'Open';	
			}
				
			if(  caseToUpdate.Met_Target_Response_Time__c != '' && (System.now().getTime()- caseToUpdate.CreatedDate.getTime()) /60000 > 90.0)
			{
				caseToUpdate.Met_Target_Response_Time__c = 'No';
			}
			else
			{
				caseToUpdate.Met_Target_Response_Time__c = 'Yes';	
			}
				
			if(contactMethod =='I')
			{
				caseToUpdate.Contact_Method__c = 'In Person';
			}
			else if(contactMethod =='P' )
			{
				caseToUpdate.Contact_Method__c = 'Phone';
			}
			else if(contactMethod =='E' )
			{
				caseToUpdate.Contact_Method__c = 'E-mail';
			}
			else if(contactMethod =='V' )
			{
				caseToUpdate.Contact_Method__c = 'Left Voicemail';
			}
			else if( contactMethod =='N')
			{
				caseToUpdate.Contact_Method__c = 'Left Note';
			}
			update caseToUpdate;
		} 
	
		if(email.plainTextBody.length() > 0)
		{
			CaseComment c = new CaseComment();
			c.ParentId = caseNo;
			String replyText = email.plainTextBody;
			if(email.plainTextBody.contains('Original Message'))
			{
				replyText = email.plainTextBody.substring(0, email.plainTextBody.indexOf('Original Message'));
			}
			c.CommentBody = 'Email received from ' + fromN + ' (' + fromA + ') '+ 
				'Case Status is: ' + caseToUpdate.status + '\nEmail Body: '   + replyText;
			Database.DMLOptions dlo = new Database.DMLOptions();
			dlo.EmailHeader.triggerUserEmail = true;
			database.insert(c, dlo);
		}
	
	
			/*
			// new Task object to be created
			
			Task[] newTask = new Task[0];
			
			    // Try to lookup any contacts based on the email from address
			    // If there is more than 1 contact with the same email address
			    // an exception will be thrown and the catch statement will be called
			try {
			       Contact vCon = [Select Id, Name, Email
			       From Contact  
			       Where Email = :email.fromAddress
			       Limit 1];
			
			// Add a new Task to the contact record we just found above
			 newTask.add(new Task(Description = myPlainText,
			     Priority = 'Normal',
			     Status = 'Inbound Email',
			     Subject = email.subject,
			     IsReminderSet = true,
			     ReminderDateTime = System.now()+1,
			     WhoId = vCon.Id));
			
			// Insert the new Task and it will be created and appended to the contact record
			     insert newTask;
			
			System.debug('New Task Object: ' + newTask );
			}
			   // If there is an exception with the query looking up
			   // the contact this QueryException will be called.
			   // and the exception will be written to the Apex Debug logs
			
			   catch (System.QueryException e) {
			   System.debug('Query Issue: ' + e);
			}*/ 
			      
	}
	catch (Exception e) 
    {
    	System.debug('Failed to insert Case: ' + e);
    	String errorMessage = e.getDmlMessage(0);
    	e.setMessage( 'Failed to update Case. <body>' + myPlainText + '</body> ' + errorMessage);
    	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			
		// Strings to hold the email addresses to which you are sending the email.
		String[] toAddresses = new String[] {'adellicicchi@eduventures.com'}; 

		mail.setTargetObjectId('0033000000LPQRo');
			
		// Specify the name used as the display name.
		mail.setSenderDisplayName('EV Cases');
			
		// Specify the subject line for your email address.
		mail.setSubject('There was an error updating a salesforce Case');
			
		// Optionally append the salesforce.com email signature to the email.
		// The email address of the user executing the Apex Code will be used.
		mail.setUseSignature(false);

		mail.setPlainTextBody(myPlainText + ' ***Error Message***: ' + errorMessage);
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });	    
    	
    }


	// Set the result to true, no need to send an email back to the user
	// with an error message

	result.success = true;

	// Return the result for the Force.com Email Service
	return result;
}

static testMethod void testCases() {

// Create a new email and envelope object
   Messaging.InboundEmail email1 = new Messaging.InboundEmail();
   Messaging.InboundEnvelope env1 = new Messaging.InboundEnvelope();

// Create the plainTextBody and fromAddres for the test
	email1.plainTextBody = 'Here is my plainText body of the email\nThis case should be held, AJ @@HPCaseId:50030000003ebD3<caseid>';
	email1.fromAddress ='adellicicchi@salesforce.com';
	email1.fromName = 'AJ';
	
// Create a new email and envelope object
   Messaging.InboundEmail email2 = new Messaging.InboundEmail();
   Messaging.InboundEnvelope env2 = new Messaging.InboundEnvelope();

// Create the plainTextBody and fromAddres for the test
	email2.plainTextBody = 'Here is my plainText body of the email\nThis case should be open, AJ @@OVCaseId:50030000003ebD3<caseid>';
	email2.fromAddress ='adellicicchi@salesforce.com';
	email2.fromName = 'AJ';
	
	// Create a new email and envelope object
   Messaging.InboundEmail email3 = new Messaging.InboundEmail();
   Messaging.InboundEnvelope env3 = new Messaging.InboundEnvelope();

// Create the plainTextBody and fromAddres for the test
	email3.plainTextBody = 'Here is my plainText body of the email\nThis case should be closed, AJ @@CECaseId:50030000003ebD3<caseid>';
	email3.fromAddress ='adellicicchi@salesforce.com';
	email3.fromName = 'AJ';
	

Cases caseObj = new Cases();
caseObj.handleInboundEmail(email1, env1);
caseObj.handleInboundEmail(email2, env2);
caseObj.handleInboundEmail(email3, env3);
}

}