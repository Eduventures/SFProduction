trigger CaseInsertMemberSupport on Case (before insert) {

    for (Case c : Trigger.new)
    {
        if(c.RecordTypeId == '01280000000F3fB' && c.Topic__c != 'Website Access Request')
        {

			try
			{
				Contact tempC = [Select Id, AccountId, email from Contact where email = :c.SuppliedEmail LIMIT 1]; 
	        	Account theAccount = [ Select Client_Services_Advisor__c FROM Account WHERE Id = :tempC.AccountId];
	        	Id theOwner = null; 
				if(theAccount.Client_Services_Advisor__c == null)
				{ 
					theOwner = '00580000003E9sS';
				} else 
				{
					theOwner = theAccount.Client_Services_Advisor__c;
				}

				database.DMLOptions dmo = new database.DMLOptions();
				dmo.AssignmentRuleHeader.UseDefaultRule= false;
				dmo.EmailHeader.triggerUserEmail = true;
				dmo.EmailHeader.triggerAutoResponseEmail = false;
				c.setOptions(dmo);
				c.OwnerId = theOwner;
			}catch (System.Exception e) 
		    {
		    	String errorMessage = e.getMessage();
		    	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
				String[] toAddresses = new String[] {'adellicicchi@eduventures.com','mtierney@eduventures.com'}; 
				mail.setToAddresses(toAddresses);
				mail.setTargetObjectId(c.Id);
				mail.setSenderDisplayName('Eduventures Website');
				mail.setSubject('There was an error assigning a salesforce Case to a Research Account Manager');
				mail.setSaveAsActivity(true);
				mail.setUseSignature(false);
				mail.setPlainTextBody('Case details as follows: Supplied Name ' + c.SuppliedName+ ' Description = \'' + c.Description + 
					'\' Supplied Phone: '+ c.SuppliedPhone + ' Supplied Email ' + c.SuppliedEmail + ' Program__c ='+ c.Program__c +
					 '***Error Message***: ' + errorMessage);
				Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });	    
		    	
		    }
        }		
    }
}