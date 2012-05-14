@isTest
private class compileAndTest4 {

    public static testmethod void t1() {  
    	
	    Account acct = [Select Id, Website_action__c, ParentId, Do_Not_Publish__c, Not_Listed_on_Member_Directory__c  from Account where Id = '0013000000GmUMN'];
	    acct.Website_action__c = 'N';
	    update acct;
	    acct.ParentId = '0013000000K2fUXAAZ';
	    acct.Not_Listed_on_Member_Directory__c = true;
	    update acct;  
	    acct.ParentId = '0013000000G3YzHAAV';
	    acct.Not_Listed_on_Member_Directory__c = false;    
	    update acct; 
	    acct.ParentId = null;
	    acct.Do_Not_Publish__c = true; 
	    update acct; 
	        
	    List<Contact> contacts = new List<Contact> ();
	    List<Contact> testContacts = new List<Contact> ();	    
	    
	    Contact c = new Contact(LastName='Tester',  AccountId = '0013000000G3YBO', Seat_Holder__c ='XXX', Membership_Role__c='CPE Liaision;DEV Liaision Assistant;', email='skiffer57@aol.com', phone ='6175326026' );
	    Contact c2 = new Contact(LastName='Tester', AccountId = '0013000000G3YBO', Seat_Holder__c ='XXX', Membership_Role__c='CPE Liaision Assistant;DEV Liaision', email='dellicicchi2@rcn.com', InterestedIn__c ='DEV' );    
	    Contact c3 = new Contact(LastName='Tester', AccountId = '0013000000G3YBO', Seat_Holder__c ='XXX', Membership_Role__c='DEV Contract Processor', email='dellicicchi3@rcn.com', InterestedIn__c ='CPE' );        
	    Contact c4 = new Contact(LastName='Tester', Seat_Holder__c ='XXX', Membership_Role__c='XXX', email='del@rcn.com', InterestedIn__c ='' );
	    Contact c5 = new Contact(LastName='Tester', AccountId = '0013000000G3YBO', Seat_Holder__c ='CPE', email='dellicicchi5@rcn.com', phone ='6175326026');    
		
	    contacts.add(c); 
	    contacts.add(c2);
	    contacts.add(c3); 
	    contacts.add(c4);   
		insert contacts;         

	     try {
	    		insert c5;
	    } catch (System.DmlException e) {

	        }
	    
	    c4.Email = 'b@b.com';
	    c4.Phone = '6175325266'; 
	    c4.AccountId = '0013000000G3YBO';
	    update contacts;
	    
	    Contact tester1 = [select Id, AccountId, FirstName, LastName, Email, Phone, Status__c, seat_holder__c, Membership_Role__c, Liaision__c, password_reset__c, Website_Username__c, Website_Password__c, Membership_Access__c, Membership_Access_Abbreviations__c from Contact where Id = '0033000000SirGy'];
	    
	    tester1.seat_holder__c = 'XXX;CPE;DEV;';	    
	    update tester1;	    
	    
	    tester1.password_reset__c = true;
	    tester1.Status__c = 'No longer with the firm';	    
	    update tester1;
	    
	    tester1.AccountId = '0013000000L6WB9';
	    tester1.Email = 'a@b.com';
	    tester1.Phone = '6175325266';
	    update tester1; 
	    //testContacts.add(tester1);	
	    
	    Contact tester2 = [select Id, AccountId, FirstName, LastName, Email, Phone, Status__c, seat_holder__c, Membership_Role__c, Liaision__c, password_reset__c, Website_Username__c, Website_Password__c, Membership_Access__c, Membership_Access_Abbreviations__c from Contact where Id = '0033000000LPQSo'];    
	    tester2.Status__c = 'Active';
	    tester2.seat_holder__c = 'XXX;CPE;DEV;';
	    tester2.Membership_Role__c='CPE Liaision;DEV Liaision Assistant;';
	    update tester2;
	    //testContacts.add(tester2);	    
	
	    Contact tester3 = [select Id, AccountId, FirstName, LastName, Email, Phone, Status__c, seat_holder__c, Membership_Role__c, Liaision__c, password_reset__c, Website_Username__c, Website_Password__c, Membership_Access__c, Membership_Access_Abbreviations__c from Contact where Id = '0033000000Sjhg2'];   
	    tester3.seat_holder__c = 'CPE;DEV;';
	   // tester3.Website_Username__c = 'tmweissma-'; 
	    //tester3.Website_Password__c = '123abc';
	    tester3.Status__c = 'Active';	    
	    update tester3;
	    //testContacts.add(tester3); 		    
		
		//update testContacts;  */ 
		
		delete c4; 
		     
	    /*try {
	                c.Email ='adellicicchi1@eduventures.com';
	                update c;
	                
	        } catch (System.DmlException e) {
	            System.assert(e.getNumDml() == 1);
	            System.assert(e.getDmlIndex(0) == 0);
	            System.assert(e.getDmlFields(0).size() == 1);
	            //System.assert(e.getDmlFields(0)[0] == 'Email');
	            System.assert(e.getDmlMessage(0).indexOf('A contact with this email address already exists.') > -1);
	        }*/
    }
}