trigger forceSystemwideMessage on Case (before insert, before update) {
	
	for(Case c: Trigger.new)
	{	
		if(c.Systemwide_Issue__c == true &&  c.Systemwide_Issue_Message__c == null)
		{
			c.Systemwide_Issue_Message__c.addError('If this is a systemwide issue, you need to provide a message for the staff!');
		}
	}
	
}