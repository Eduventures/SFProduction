@isTest
private class TestContactDelete 
{
	public static testmethod void testMethod1()
    {        
		Account acc = new Account();
		acc.Name = 'TesterAcc';
		acc.BillingState = 'CA';
		insert acc; 
		
        Contact cont = new Contact();
        cont.LastName = 'Tester';
        cont.AccountId = acc.Id;
        cont.Website_username__c = 'TestUsername';
        Database.SaveResult lsrCont = Database.insert(cont, false);                
        
        try { delete cont; } 
        catch (Exception e) {
    		// Generic exception handling code here 
    		system.debug(e.getMessage());
    		 //cont.addError('You can not delete a former seat holder or Liaison!'); 
		}    
    }
}