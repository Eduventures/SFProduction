global class ContactReset {

// The WebService keyword makes this a public
// WebService method. WebService methods must
// always be static, and must also be contained
// in a global class.
WebService static String reset(String Id)
{
	Contact c = [select Id, AccountId, LastName, website_update__c, website_action__c, seat_holder__c, website_account_reset__c, Membership_Access__c, Membership_Access_Abbreviations__c from Contact where Id = :Id];
	c.website_account_reset__c = true;
	c.seat_holder__c = 'XXX';
	c.Membership_Access__c = ''; 
	c.Membership_Access_Abbreviations__c = '';
	c.website_action__c = 'N';
	c.website_update__c = false;
	try { update c; } catch (Exception e) { return 'ERROR: ' + e.getTypeName() + ' ' + e.getMessage(); }
	
	//User u = [ select Id, Name from User where Id = :c.LastModifiedById];
	Task changeNote = new Task( 
						  OwnerId = '00530000000vxt9', 
						  WhoId = c.Id,
						  WhatId = c.AccountId,
						  ActivityDate = System.today(),
						  Description = 'Website Access was reset (see the \'Created By\' field of this note to see who requested the reset)',  
						  Priority = 'High', 
						  ReminderDateTime = System.now(), 
						  Status = 'Completed', 
						  Type = 'Change Log',
						  Subject = 'Website Access was reset');
	insert changeNote;					  
	return 'Contact ' + c.LastName + ' was successfully reset, you may now tag them as a Seat Holder again. Please do not change their username and password as the Contact has already received one email with this information';
}
// The following is a simple unit test for the
// sayHelloWorld method. Unit test methods take
// no arguments, commit no data to the database,
// and are flagged with the testMethod keyword
// in the definition.
static testMethod void test() {
reset('0033000000SirGy');
}
}