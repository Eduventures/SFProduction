/**
 * Email services are automated processes that use Apex classes
 * to process the contents, headers, and attachments of inbound
 * email.
 */
global class websiteAccessRequest implements Messaging.InboundEmailHandler {

	global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) 
	{

		// Create an inboundEmailResult object for returning 
		// the result of the Force.com Email Service
		Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
		
		String myPlainText = '';
		
		// Initialize the Contact ID, so if no Contact is found, a case is still created
		ID requestorsID;
		ID acctID;
		String caseLCs = '';
		Account acct = new Account(); 
		
		// Add the email plain text into the local variable
		
		try
		{
			acctID = email.plainTextBody.substring(email.plainTextBody.indexOf('Account Id: ')+12, email.plainTextBody.indexOf('Account Id: ')+30);
		    caseLCs = email.plainTextBody.substring(email.plainTextBody.indexOf('Learning Collaboratives:')+24, email.plainTextBody.indexOf('for these people'));
		    requestorsID = email.plainTextBody.substring(email.plainTextBody.indexOf('(')+1, email.plainTextBody.indexOf(')'));
		    myPlainText = email.plainTextBody;
		}
		catch (System.StringException e)
		{
		     myPlainText = email.plainTextBody;
		     System.debug('Missing Required field!!' + e);
		}
		
		try
	    {
	    	System.debug('Account ID was ' + acctID);
	    	acct = [select ID, name, Client_Services_Advisor__c from Account where ID = :acctID];
	    }
	    catch (System.QueryException e) 
	    {
	    	acct = [select ID, name from Account where ID = '0013000000G3Y0SAAV'];	
	    	System.debug('Query Issue: ' + e);
	    }
			
		// new Case object to be created
		List<String> lcs = caseLCs.Split(';',0);
		for(integer i=0; i < lcs.size(); i++)
		{
			String temp = lcs[i].trim();
			if(temp.length() > 3)
			{
				lcs[i] = temp.substring(0,3);
			} else
			{
				lcs[i] = temp;
			}
		}
	
		database.DMLOptions dmo = new database.DMLOptions();
		dmo.AssignmentRuleHeader.UseDefaultRule= false;
		dmo.EmailHeader.triggerUserEmail = true;
		dmo.EmailHeader.triggerAutoResponseEmail = false;
		
		try
		{	
		   	Id theOwner = null; 
			if(acct.Client_Services_Advisor__c == null)
			{ 
				theOwner = '00580000003E9sS';
			} else 
			{
				theOwner = acct.Client_Services_Advisor__c;
			}
			Case newCase = 	new Case(Description = myPlainText,
			     Priority = 'Medium',
			     Status = 'New',
			     Subject = email.subject,
			     Topic__c = 'Website Access Request',
			     RecordTypeId = '01280000000F3fB',
			     Program__c = lcs.get(0),
			     Programs__c = caseLCs,
			     Account = acct,
			     ContactId = requestorsID);
			 newCase.setOptions(dmo);
			 insert newCase;
			 newCase.OwnerId = theOwner;
			 update newCase;
			 
		}
		catch (System.DmlException e) 
	    {
	    	System.debug('Failed to insert Case: ' + e);
	    	String errorMessage = e.getDmlMessage(0);
	    	e.setMessage( 'Failed to insert Case. <body>' + myPlainText + '</body> ' + errorMessage);
	    	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
				
			// Strings to hold the email addresses to which you are sending the email.
			String[] toAddresses = new String[] {'adellicicchi@eduventures.com'}; 
	
			mail.setTargetObjectId('0033000000LPQRo');
				
			// Specify the name used as the display name.
			mail.setSenderDisplayName('Eduventures Website');
				
			// Specify the subject line for your email address.
			mail.setSubject('There was an error creating a salesforce Case for a client\'s Wesite Request');
				
			// Set to True if you want to BCC yourself on the email.
			mail.setSaveAsActivity(true);
				
			// Optionally append the salesforce.com email signature to the email.
			// The email address of the user executing the Apex Code will be used.
			mail.setUseSignature(false);
			
			// Specify the text content of the email.
			mail.setPlainTextBody(myPlainText + ' ***Error Message***: ' + errorMessage);
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });	    
	    	
	    }
		// Set the result to true, no need to send an email back to the user
		// with an error message
			
		result.success = true;
			
		// Return the result for the Force.com Email Service
		return result;
		
	}
		
	static testMethod void testWebsiteAccess() 
	{
		
		// Create a new email and envelope object
		   Messaging.InboundEmail email = new Messaging.InboundEmail();
		   Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
		
		// Create the plainTextBody and fromAddres for the test
		    email.plainTextBody = 'User: Dellicicchi with  Salesforce ID (0033000000LPQRo) Account Id: 0013000000G3Y0SAAV ' + 
		    'requested access for these Learning Collaboratives: CPE;OHE ';
		    email.fromAddress ='techsupport@eduventureswebsite.com';
		
		websiteAccessRequest caseObj = new websiteAccessRequest();
		caseObj.handleInboundEmail(email, envelope);
	} 

}