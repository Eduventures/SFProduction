public class AccountAsyncUpdate {
	
	@future (callout=true)
  	public static void updateAccount(string accountID) {
  		Account acctToUpdate = [ select Id, Name, Active_Engagements__c from Account where Id = :accountID];
  		if(acctToUpdate != null)
  		{
  			System.debug('acctToUpdate = ' + acctToUpdate.Name);
  			update 	acctToUpdate;
  		}
  	}
  	
	//@future (callout=true)
  	public static void removeContactAccess(Id accountID, string programs) {
  		Account acctToUpdate = [ select Id, 
  									(Select Id, Seat_Holder__c, Membership_Role__c, Membership_History__c, Website_update__c from Contacts) 
  								 from Account where Id = :accountID];
  								 
  		List<Contact> contactsToUpdate = new List<Contact>();
  		system.debug('Programs to remove = ' + programs);						 
  		if(acctToUpdate != null)
  		{
  			for(Contact c: acctToUpdate.Contacts)
  			{
  				Boolean updateContact = false;
			 	try{
			 		
					for(string program: programs.split(';',0))
					{	
						if(c.Seat_Holder__c.contains(program))
						{
							String sh = c.Seat_Holder__c;
							c.Website_update__c = true;
							List<String> shValues = sh.Split(';',0);//creates a string list of programs
							for(integer i = 0; i < shValues.size(); i++)
							{
								if(shValues[i].contains(program))
								{											
									shValues.remove(i);									
									i = shValues.size();
								}
							}
							system.debug('shValues = ' + shValues);					
							if(shValues.isEmpty())
							{
								c.Seat_Holder__c = 'XXX';
							}
							else
							{
								sh = shValues[0];
								for(Integer i=1; i<shValues.Size();i++)
								{
									sh = sh +';'+ shValues[i];	
								}
								c.Seat_Holder__c = sh;
							}
							updateContact = true;
						}
		
						if(c.Membership_Role__c != '' && c.Membership_Role__c != null && c.Membership_Role__c.contains(program))
						{
							String mr = c.Membership_Role__c;
							List<String> testMr = mr.Split(';',0);//creates a string list of member roles for the contact
							mr = '';
							
							for(integer j = 0; j < testMr.size(); j++)
							{
								if(!(testMr[j].contains(program)&&(testMr[j].contains('Liaison') || testMr[j].contains('Decision Maker') || testMr[j].contains('Recipient'))) )
								{									 							
									if(mr.length() == 0)
									{
										mr = testMr[j];
									}
									else
									{
										mr = mr + ';' + testMr[j] ;	
									}	
								}
							}				
							c.Membership_Role__c = mr;
							updateContact = true;
						}
					}
					if(updateContact)
					{
						contactsToUpdate.add(c);
					}																	
				}catch (Exception e) {}
  			}
  		}
  		if(!contactsToUpdate.isEmpty())
  		{
  			update contactsToUpdate;		
  		}
  	}
  	  	
  	static testMethod void testupdateAccount() {
		
		AccountAsyncUpdate.updateAccount( '0013000000K2fUX');
		AccountAsyncUpdate.removeContactAccess('0013000000K2fUX', 'CPE');
		
	}
  		

}