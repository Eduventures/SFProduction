trigger ContactProcedures on Contact (before insert, after insert, before update, after update) {
 
    /*
    List<String> SeatholderValues = new List<String>();
    Schema.DescribeFieldResult shField = Contact.Seat_Holder__c.getDescribe();
    List<Schema.PicklistEntry> shValues = shField.getPicklistValues();
    */
    
    List<String> LiaisionValues = new List<String>();
    Schema.DescribeFieldResult LiaisonField = Contact.Liaision__c.getDescribe();
    List<Schema.PicklistEntry> LiaisonValues = LiaisonField.getPicklistValues();
    
    for(Schema.Picklistentry p: LiaisonValues)
    {
        LiaisionValues.add(p.getValue()); 
    }
    
    map <String, String> membershipValues = new map <String, String>();
    //setup array or list to loop through 
    membershipValues.put('ACL','Academic Leadership' );
    membershipValues.put('AIE','Assessment and Institutional Effectiveness' );  
    membershipValues.put('CPE', 'Continuing and Professional Education');
    membershipValues.put('DEV', 'Development');
    membershipValues.put('ENM', 'Enrollment Management');
    membershipValues.put('OHE', 'Online Higher Education');
    membershipValues.put('SOE', 'Schools of Education');
    membershipValues.put('STA', 'Student Affairs');
    membershipValues.put('SUM', 'Summer Sessions');
    membershipValues.put('K12', 'K-12 Solutions');
    membershipValues.put('PSS', 'Postsecondary Solutions');
    
    map <String, String> membershipValuesabbr = new map <String, String>();
    //setup array or list to loop through 
    membershipValuesabbr.put('ACL', 'AL-LC' ); 
    membershipValuesabbr.put('AIE', 'AIE-LC' ); 
    membershipValuesabbr.put('CPE', 'CPE-LC' ); 
    membershipValuesabbr.put('DEV', 'DEV-LC' ); 
    membershipValuesabbr.put('ENM', 'EM-LC' ); 
    membershipValuesabbr.put('OHE', 'OHE-LC' ); 
    membershipValuesabbr.put('SOE', 'SOE-LC' ); 
    membershipValuesabbr.put('STA', 'SA-LC' ); 
    membershipValuesabbr.put('SUM', 'SUM-LC' ); 
    membershipValuesabbr.put('K12', 'K-12');
    membershipValuesabbr.put('PSS', 'PSS');

    List<Id> acctIds = new List<Id>();
    //test to make sure we don't get duplicate email addresses
    /*if this is an insert of multiple contacts,test to see if there are any email dupes in this batch */
    Map<String, Contact> newContactMap = new Map<String, Contact>();
    
    for (Contact contact : System.Trigger.new) 
    { 
        if ((contact.Email != null) && (System.Trigger.isInsert || (contact.Email != System.Trigger.oldMap.get(contact.Id).Email)) )
        {           
            // Make sure another new contact isn't also a duplicate
            if (newContactMap.containsKey(contact.Email)) {
                contact.Email.addError('Another new contact has the same email address as ' + contact.Name);
            } else { 
                newContactMap.put(contact.Email, contact);
            }
        }
        acctIds.add(contact.AccountId);
    }
    
    if(Trigger.isBefore)
    {
        /*find all the existing contacts in the database that have the same email address as any
        of the contacts being inserted */
        for (Contact contact : [SELECT Email, Name FROM contact WHERE Email IN :newContactMap.KeySet()]) {
            Contact newContactWithDup = newContactMap.get(contact.Email);
            newContactWithDup.Email.addError('Duplicate contact error!: A contact with this email address already exists. Please find and merge the ' + 
             'two Contact records. Contact - ' + contact.Name);
        }
    }

    Map<Id, Account> acctsMap = new Map<Id, Account>();
    for(Account a : [select Id,Active_Engagements__c from Account where Id in :acctIds])
    {
        acctsMap.put(a.Id,a);
    }
    
    if(Trigger.isInsert) 
    {   
        if(Trigger.isBefore)
        {       
            
            for (Contact newContact: Trigger.new)  //change Object Name
            {  
                newContact.website_action__c = 'N'; //set website_action == 'New' so Website knows which course of action to take. This is a new website contact.
                newContact.Website_client_admin__c = false;
                
                if(newContact.Seat_Holder__c == null || newContact.Seat_Holder__c == '')
                {
                    newContact.Seat_Holder__c = 'XXX';  
                } else if (newContact.Seat_Holder__c != 'XXX')
                {
                    newContact.Seat_Holder__c = newContact.Seat_Holder__c.replace('XXX','');
                    //make sure any active seat holders have an email address
                    if(newContact.email == null || newContact.email =='')
                    {
                        newContact.Email.addError('An email address is required in order to provide ' + newContact.FirstName + ' ' + newContact.LastName + ' Web site Access.'); 
                    } else
                    { 
	                    //capture the allowed programs for this user based on their Account's 'Active Engagements'
	                    List<String> AElist = acctsMap.get(newContact.AccountId).Active_Engagements__c.replace('SEM','ENM').split(';',0);                   
	                    List<String> websiteAccess = newContact.Seat_Holder__c.split(';',0);
	                    //Modify the Account's 'Active Engagements' field to remove and Survey memebrships (
						// which will not get website Access). I could have stripped them out manually by 
						//hardcoing them but then we'd need to do that for every new Product
						String modifiedAE = '';
                    	for(String AE : AElist)
                    	{
                    		if(!AE.contains('-ASV'))
                    		{
                    			modifiedAE = modifiedAE + ';' + AE;	
                    		}
                    	}
	                    for(String newVal: websiteAccess)
	                    {
	                        if(!modifiedAE.contains(newVal) && newContact.AccountId != '0013000000G3Y0S' && newContact.AccountId != '0013000000K2fUX' && newContact.AccountId != '0013000000GmUMN') 
	                        {
	                            newContact.Seat_Holder__c.addError('Sorry - ' + newContact.FirstName + ' ' + newContact.LastName + '\'s  Account does not have an active membership for the '
	                             + membershipValues.get(newVal) +  ' learning collaborative.');     
	                        }
	                    }
	                    newContact.Membership_Access__c = '';
	                    newContact.Membership_Access_Abbreviations__c = ''; 
	                    newContact.website_update__c = true;
	                    newContact.website_action__c = 'N';
	                    websiteAccess.sort();
	                    String tempSHfield = '';
	                    for(string val : websiteAccess)
	                    {
	                        if(tempSHfield == '')
	                        {
	                            tempSHfield = val + ';';
	                            newContact.Membership_Access__c = membershipValues.get(val);
	                            newContact.Membership_Access_Abbreviations__c = membershipValuesabbr.get(val);                              
	                        } else 
	                        {
	                            tempSHfield = tempSHfield + val + ';';
	                            newContact.Membership_Access__c = newContact.Membership_Access__c + ', ' + membershipValues.get(val);
	                            newContact.Membership_Access_Abbreviations__c = newContact.Membership_Access_Abbreviations__c + ', ' + membershipValuesabbr.get(val);                                
	                        }
	                    }
	                    newContact.Seat_Holder__c = tempSHfield;
	                	//add access
	                	//check if username is blank
	                    if(newContact.Website_Username__c == null)
	                    {           
	                        newContact.email = newContact.email.toLowerCase();
	                        
	                        //if YES, set username to be their email prefix
	                        newContact.Website_Username__c = newContact.email.split('@',2)[0]; 
	                        
	                        //create a list of allowed UN characters
	                        Set<String> allowedChars =new Set<String>{'a', 'b', 'c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0'};
	                        String tempUsername = '';
	                        
	                        //loop through the email prefix and remove any illegal characters
	                        for(integer p = 0; p < newContact.Website_Username__c.length(); p++)
	                        {
	                            if( allowedChars.contains(newContact.Website_Username__c.substring(p, p+1)) )
	                            {
	                                tempUsername = tempUsername + newContact.Website_Username__c.substring(p, p+1);     
	                            } 
	                        }
	                        
	                        newContact.Website_Username__c = tempUsername;
	                                    
	                        for(integer n = 0; newContact.Website_Username__c.length() < 4; n++)
	                        {
	                            newContact.Website_Username__c = newContact.Website_Username__c + 1;
	                        }
	                        
	                        String myValue = '%' + newContact.Website_Username__c + '%';
	                        
	                        //create (SELECT) a list of all the usernames where request UN is in username
	                        List<Contact> contactsWithMatchingUsernames = [select Website_Username__c from Contact where  Website_Username__c LIKE :myValue ORDER BY Website_Username__c ASC ];
	                        
	                        String usernames = '';
	                         
	                        for (Contact c :  contactsWithMatchingUsernames )
	                        {
	                            usernames = usernames + c.Website_Username__c + ';';
	                        } 
	                        
	                        //if no matching usernames are found (hence the List is empty), we can use the UN we have - otherwise....
	                        if(usernames.length() != 0)
	                        {
	                            //...create temp placeholder for username (to avoid any collision problems)
	                            string tempUN = newContact.Website_Username__c;
	                            //set flag for unique UN checking
	                            Boolean unique = false;
	                            
	                            //start a loop & try possible usernames
	                            for( integer j = 1; unique == false ; j ++)
	                            {
	                                if(usernames.contains(tempUN))
	                                {
	                                    //Update the UN: add the loop index to the end of the UN
	                                    tempUN = newContact.Website_Username__c + j;    
	                                } else
	                                {
	                                    newContact.Website_Username__c = tempUN;
	                                    unique = true;
	                                }                                   
	                            }       
	                        }           
	                    }
	                    else if (newContact.Website_Username__c.length() < 4 ) 
	                    {
	                        newContact.Website_Username__c.addError(newContact.FirstName + ' ' + newContact.LastName + '\'s Website username must be at least 4 characters.');
	                    }
	                    else
	                    {   
	                        //create a list of allowed UN characters
	                        Set<String> allowedChars = new Set<String>{'a', 'b', 'c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0'};
	                        Set<String> numbers =  new Set<String>{'1', '2', '3', '4', '5', '6', '7', '8', '9', '0'};
	                        String tempUsername = '';
	                        
	                        //loop through the email prefix and remove any illegal characters
	                        for(integer p = 0; p < newContact.Website_Username__c.length(); p++)
	                        {
	                            if( allowedChars.contains(newContact.Website_Username__c.substring(p, p+1)) )
	                            {
	                                tempUsername = tempUsername + newContact.Website_Username__c.substring(p, p+1);     
	                            } 
	                        }
	                        newContact.Website_Username__c = tempUsername;                      
	                        String myValue = '%' + newContact.Website_Username__c + '%';
	                        
	                        //create (SELECT) a list of all the usernames where request UN is in username
	                        List<Contact> contactsWithMatchingUsernames = [select Website_Username__c from Contact where  Website_Username__c LIKE :myValue ORDER BY Website_Username__c ASC ];
	                        String usernames = '';
	                         
	                        for (Contact c :  contactsWithMatchingUsernames )
	                        {
	                            usernames = usernames + c.Website_Username__c + ';';
	                        } 
	                        
	                        //if no matching usernames are found (hence the List is empty), we can use the UN we have - otherwise....
	                        if(usernames.length() != 0)
	                        {
	                            //...create temp placeholder for username (to avoid any collision problems)
	                            string tempUN = newContact.Website_Username__c;
	                            //set flag for unique UN checking
	                            Boolean unique = false;
	                            
	                            //start a loop & try possible usernames
	                            for( integer j = 1; unique == false ; j ++)
	                            {
	                                if(usernames.contains(tempUN))
	                                {
	                                    //Update the UN: add the loop index to the end of the UN
	                                    tempUN = newContact.Website_Username__c + j;    
	                                } else
	                                {
	                                    newContact.Website_Username__c = tempUN;
	                                    unique = true;
	                                }                                   
	                            }       
	                        }                           
	                    }
	                    
	                    //if password was blank, generate a random password
	                    if( newContact.Website_Password__c == null)
	                    {
	                        //randomly select one number
	                        integer tempNum = (Math.random() * 10).intValue();
	                        
	                        //randomly select 4 characters (from the end of the Contact ID)
	                        string tempPW = 'eduventures' + tempNum;
	                        
	                        //save password 
	                        newContact.Website_Password__c = tempPW;
	                            
	                    }
	                    //if password was not blank, validate
	                    else
	                    {
	                        //must be at least 6 characters long
	                        if(newContact.Website_Password__c.length() >= 6)
	                        {
	                            boolean hasNumber = false;
	                            boolean hasLetter = false;
	                            
	                            Set<String> alphabet = new Set<String>{'a', 'b', 'c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z'};
	                            Set<String> numbers =    new Set<String>{'1', '2', '3', '4', '5', '6', '7', '8', '9', '0'};
	                            
	                            for( integer k = 0; (k < newContact.Website_Password__c.length()) && (hasNumber != true || hasLetter != true) ; k++)
	                            {
	                                if( (hasLetter == false) && (alphabet.contains(newContact.Website_Password__c.substring(k, k+1)))  )
	                                {
	                                    hasLetter = true;   
	                                }
	                                
	                                if( (hasNumber == false) && (numbers.contains(newContact.Website_Password__c.substring(k, k+1))) )
	                                {
	                                    hasNumber = true;   
	                                }                       
	                            }
	                            
	                            if( hasLetter == false)
	                            {
	                                newContact.Website_Password__c.addError(newContact.FirstName + ' ' + newContact.LastName + '\'s Website password must contain at least one letter.');  
	                            }
	                            
	                            if( hasNumber == false)
	                            {
	                                newContact.Website_Password__c.addError(newContact.FirstName + ' ' + newContact.LastName + '\'s Website password must contain at least one number.');  
	                            }               
	                        }
	                        else
	                        {
	                            newContact.Website_Password__c.addError(newContact.FirstName + ' ' + newContact.LastName + '\'s Website password must be at least 6 characters.'); 
	                        }               
	                    }
                    }                  
                }
                
                newContact.liaision__c = 'XXX';         
                if(newContact.Membership_Role__c != null)     //if Membership_Role__c  is not blank, check to see if their
                {                                                   // 'membership role(s)' entitles them to website admin rights for their account
                    newContact.Liaision__c = '';
                    Integer hit = 0;
                    for (Integer i=0; i<LiaisionValues.size(); i++)            //then loop through possible 'liaision' value list & 
                    {                                                           //build Liaision__c field value appropriately
                        String pa = LiaisionValues.get(i);
                        String testValue = pa +' Liaison';

                        if (newContact.membership_role__c.contains(testValue))
                        {
                            if(hit == 0)
                            {
                                newContact.Liaision__c = pa;
                            }
                            else if (! newContact.Liaision__c.contains(pa))
                            {
                                newContact.Liaision__c = newContact.liaision__c + ';' + pa;     
                            }
                            hit++; 
                        }                                                                           
                    }
                                
                    if (hit > 0)
                    {
                        newContact.Website_client_admin__c = true;
                    }                       
                }
            }
        }
        
        if(Trigger.isAfter)
        {
        	List<Id> newWebsiteUsersToNotify = new List<Id>();
            for (Contact newContact: Trigger.new)  //change Object Name
            {
                if(newContact.Seat_Holder__c != 'XXX')
                {      
                	newWebsiteUsersToNotify.add(newContact.Id);          
                    Task shAddNote = new Task(
                      OwnerId = UserInfo.getUserId(), 
                      WhoId = newContact.Id,
                      WhatId = newContact.AccountId,
                      ActivityDate = System.today(),
                      Description = newContact.Seat_Holder__c + ' website access added',  
                      Priority = 'High', 
                      ReminderDateTime = System.now(), 
                      Status = 'Completed', 
                      Type = 'Website Related',
                      Subject = 'Website Access Added');
                    insert shAddNote;
                }  
            }
	        if(!newWebsiteUsersToNotify.isEmpty())
	        {
	        	websiteEmailer.inviteNewUsers(newWebsiteUsersToNotify);
	        } 
        }
    }
        
    if(Trigger.isUpdate) 
    {
        
        if(Trigger.isBefore)
        {   
            List<Task> followupTasksBefore = new List<Task>();
            List<Id> newWebsiteUsersToNotify = new List<Id>();
            List<Id> existingWebsiteUsersToNotify = new List<Id>();
            for(Integer i = 0; i < Trigger.new.size(); i++)
            {               
                Contact oldContact = Trigger.old[i]; 
                Contact updatedContact = Trigger.new[i];           
                
                if(updatedContact.website_account_reset__c != true)
                {

                    if(oldContact.password_reset__c == true)
                    {
                        updatedContact.password_reset__c = false;
                    }
                    
                    //if seat holder was not blank previously, this is an update
                    if(oldContact.Seat_Holder__c != 'XXX')                                                                        
                    {
                        updatedContact.website_action__c = 'U';         
                    }                   
                    
                    if(oldContact.Status__c != updatedContact.Status__c)
                    {
	                    if(updatedContact.Status__c == 'No longer with the firm')
	                    {
	                        updatedContact.HasOptedOutOfEmail = true;
	                        updatedContact.Seat_Holder__c = 'XXX';                      
	                    } else if (updatedContact.Status__c != 'No longer with the firm')
	                    {
	                    	updatedContact.HasOptedOutOfEmail = false; 
	                    }
                    }
                    
                    if(oldContact.website_update__c == true)
                    {
                        updatedContact.website_action__c = 'U';
                        updatedContact.website_update__c = false;
                    }
                    
                        
                    if( (oldContact.AccountId != null ) && (oldContact.AccountId != updatedContact.AccountId) )
                    {
                        Account a = [select ID, name from Account where ID = :oldContact.AccountId];
                        Task task = new Task(
                          OwnerId = UserInfo.getUserId(), 
                          WhoId = updatedContact.Id,
                          WhatId = updatedContact.AccountId,
                          ActivityDate = System.today(),
                          Description = 'Old account: ' + a.Name +' (ID: ' + a.ID+ ' )\nNote: If this was a seat holder, the Contact\'s website access has been removed as well.',  
                          Priority = 'High', 
                          ReminderDateTime = System.now(), 
                          Status = 'Completed', 
                          Type = 'Website Related',
                          Subject = 'Contact\'s Account changed, Old name: ' + a.Name );
                        if(oldContact.Seat_Holder__c != 'XXX')
                        {
                            updatedContact.website_update__c = true;
                        }  
                        updatedContact.Seat_Holder__c ='XXX';
                        updatedContact.Membership_Role__c ='';
                        updatedContact.Membership_Access__c = '';
                        updatedContact.Membership_Access_Abbreviations__c = '';
                        
                        if(oldContact.Status__c == 'No longer with the firm')
                        {
                            updatedContact.Status__c = 'Active';
                            updatedContact.HasOptedOutOfEmail = false;                  
                        }
                        
                        followupTasksBefore.add(task);   // add to list
                        
                        Contact_tools.addToCampaign('70180000000BqJT',updatedContact.Id);
                    }
                    else if(oldContact.AccountId != updatedContact.AccountId)
                    {
                        
                        Task task = new Task(
                          OwnerId = UserInfo.getUserId(),
                          WhoId = Trigger.new[i].Id,
                          WhatId = Trigger.new[i].AccountId,
                          ActivityDate = System.today(),
                          Description = 'Old account: was *blank*\nNote: If this was a seat holder, the Contact\'s website access has been removed as well.',  
                          Priority = 'High', 
                          ReminderDateTime = System.now(), 
                          Status = 'Completed', 
                          Type = 'Website Related',
                          Subject = 'Contact\'s Account changed, not previously associated with an Account ' );
                          
                        updatedContact.Seat_Holder__c ='XXX';
                        updatedContact.Membership_Role__c ='';
                        updatedContact.Membership_Access__c = '';
                        updatedContact.Membership_Access_Abbreviations__c = '';
                        if(oldContact.Seat_Holder__c != 'XXX')
                        {
                            updatedContact.website_update__c = true;
                        }                   
                        followupTasksBefore.add(task);   // add to list
                    }
                    
                     //Has the  membership_role__c field changed?   
                    if (oldContact.Membership_Role__c != updatedContact.Membership_Role__c)                                
                    {
                        //if there was a previous membership role, we need to loop through them to see if any were lost
                        if(oldContact.Membership_Role__c != null)
                        {
                            List<String> oldRoles = oldContact.Membership_Role__c.Split(';',0);
                            //if the new Membership Role is blank, we can just add all the old roles to Membership History...
                                // we need to check which roles might be missing after editing the field.
                            for(String role: oldRoles)
                            {
                                if(updatedContact.Membership_Role__c == null || !updatedContact.Membership_Role__c.contains(role))
                                {
                                    String testString = 'Former ' + role;
                                    if(updatedContact.Membership_History__c == null)
                                    {
                                        updatedContact.Membership_History__c = testString + ';';
                                    }
                                    else
                                    {
                                        if(!updatedContact.Membership_History__c.contains(testString))
                                        {
                                            updatedContact.Membership_History__c = updatedContact.Membership_History__c + ';' +  testString + ';';
                                        }
                                    }
                                }                           
                            }                                   
                        } 
                                    
                        if(updatedContact.Membership_Role__c != null)     //if Membership_Role__c  is not blank, check to see if their
                        {                                                   // 'membership role(s)' entitles them to website admin rights for their account
                            updatedContact.Liaision__c = '';
                            for (Integer j=0; j<LiaisionValues.size(); j++)            //then loop through possible 'liaision' value list & 
                            {                                                           //build Liaision__c field value appropriately
                                String testValue = LiaisionValues.get(j);
                                if(updatedContact.Membership_Role__c.contains(testValue + ' Decision Maker') || updatedContact.Membership_Role__c.contains(testValue + ' Liaison'))
                                {
                                	if(updatedContact.Liaision__c == '')
                                    {
                                        updatedContact.Liaision__c = testValue;
                                    }
                                    else if (! updatedContact.Liaision__c.contains(testValue))
                                    {
                                        updatedContact.Liaision__c = updatedContact.liaision__c + ';' + testValue;     
                                    }
                            	}    
                                if (updatedContact.membership_role__c.contains(testValue))
                                {
                                	if(updatedContact.Membership_History__c != null)
                                    {
			                            String tempMH = '';
			                            List<String> newRoles = updatedContact.Membership_Role__c.Split(';',0);
			                            Set<String> formerRoles = new Set<String>(updatedContact.Membership_History__c.Split(';',0));
			                            //if the new Membership Role is blank, we can just add all the old roles to Membership History...
			                            // we need to check which roles might be missing after editing the field.
			                            Set<String> formerRolesCopy = new Set<String>();
			                            formerRolesCopy.addAll(formerRoles);
			                            for(String role: newRoles)
			                            {
			                            	for(String oldrole: formerRolesCopy)
			                            	{
			                            		if( ('Former ' + role) == oldrole)
				                                {
				                                    formerRoles.remove('Former ' + role);
				                                }
			                            	}                           
			                            }
			                            for(String s:formerRoles)
			                            {
			                            	tempMH = tempMH + ';' + s;
			                            } 
			                            updatedContact.Membership_History__c = tempMH;
                                    }
                                }                                                                           
                            }
                                        
                            if ( updatedContact.Liaision__c == '')
                            {
       	                        updatedContact.liaision__c = 'XXX'; 
                                updatedContact.Website_client_admin__c = false;
                            } else
                            {
                                updatedContact.Website_client_admin__c = true;
                            }                       
                        } else
                        {
                        	updatedContact.liaision__c = 'XXX'; 
                            updatedContact.Website_client_admin__c = false;
                        }
                    }
                    
                    //if the contact was, or is becoming, a Seat Holder then update the website
                    if(oldContact.Seat_Holder__c != updatedContact.Seat_Holder__c )                
                    {           
                        updatedContact.Website_update__c = true;                                    
                        updatedContact.Membership_Access__c = '';
                        updatedContact.Membership_Access_Abbreviations__c = '';
                        String add = '';
                        String remove = ''; 

                        //in case an old seat holder value was ever blank, we set it to the default 
                        //(otherwise the 'null value' error condition will prevent us from updated the Contact)                     
                        String oldsh = 'XXX';
                        if(oldContact.Seat_Holder__c != null)
                        {
                            oldsh = oldContact.Seat_Holder__c.replace('XXX','');
                        }
                        
                        if( updatedContact.Seat_Holder__c == null || updatedContact.Seat_Holder__c == '' || updatedContact.Seat_Holder__c == 'XXX' )
                        {
                            updatedContact.Seat_Holder__c ='XXX'; 
                            for(String oldVal: oldsh.split(';',0))
                            {
                                remove = remove + oldVal + ';';
                                //note former programs in the membership history field                      
                                if(updatedContact.Membership_History__c == null || updatedContact.Membership_History__c =='')
                                {
                                    updatedContact.Membership_History__c = 'Former '+ oldVal + ' Seat Holder ;';
                                }
                                else if(!updatedContact.Membership_History__c.contains('Former '+ oldVal + ' Seat Holder'))
                                {
                                    updatedContact.Membership_History__c  = updatedContact.Membership_History__c  + ';Former '+ oldVal + ' Seat Holder ;';
                                }
                            }                                                                                      
                        }
                        //otherwise, parse the seat holder field to record changes and verify program access
                        else 
                        {   
                            updatedContact.Seat_Holder__c = updatedContact.Seat_Holder__c.replace('XXX','');                    
                            
                            //make sure any active seat holders have an email address
                            if(updatedContact.email == null || updatedContact.email =='')
                            {
                                updatedContact.Email.addError('An email address is required for ' + updatedContact.FirstName + ' ' + updatedContact.LastName + ' in order to provide Web site Access.'); 
                            }
                            if(updatedContact.Status__c == 'No longer with the firm')
                            {
                            	//updatedContact.Status__c.addError(updatedContact.FirstName + ' ' + updatedContact.LastName + ' is listed as \'No Longer With the Firm\', please change their Status to Active before adding website access.'); 
                            }                       
                                                        
                            for(String oldVal: oldsh.replace('XXX','').split(';',0))
                            {
                                if(!updatedContact.Seat_Holder__c.contains(oldVal))
                                {
                                    remove = remove + oldVal + ';';
                                    //note former programs in the membership history field                      
                                    if(updatedContact.Membership_History__c == null || updatedContact.Membership_History__c =='')
                                    {
                                        updatedContact.Membership_History__c = 'Former '+ oldVal + ' Seat Holder ;';
                                    }
                                    else if(!updatedContact.Membership_History__c.contains('Former '+ oldVal + ' Seat Holder'))
                                    {
                                        updatedContact.Membership_History__c  = updatedContact.Membership_History__c  + ';' + 'Former '+ oldVal + ' Seat Holder ;';
                                    }
                                }
                            }
                            
                            //capture the allowed programs for this user based on their Account's 'Active Engagements'
                            List<String> AElist = acctsMap.get(updatedContact.AccountId).Active_Engagements__c.replace('SEM','ENM').split(';',0);                   
                            List<String> websiteAccess = updatedContact.Seat_Holder__c.split(';',0);
                            websiteAccess.sort();
                            String tempSHfield = '';
							//Modify the Account's 'Active Engagements' field to remove and Survey memebrships (
							// which will not get website Access). I could have stripped them out manually by 
							//hardcoing them but then we'd need to do that for every new Product
							String modifiedAE = '';
                        	for(String AE : AElist)
                        	{
                        		if(!AE.contains('-ASV'))
                        		{
                        			modifiedAE = modifiedAE + ';' + AE;	
                        		}
                        	}
                        	for(String newVal: websiteAccess)
                            {
                        		if(!modifiedAE.contains(newVal))
                                {
                                    if(updatedContact.AccountId != '0013000000G3Y0S' && updatedContact.AccountId != '0013000000K2fUX' && updatedContact.AccountId != '0013000000GmUMN') 
                                    {
                                        updatedContact.Seat_Holder__c.addError('Sorry - ' + updatedContact.FirstName + ' ' + updatedContact.LastName + '\'s Account does not have an active membership for the ' 
                                        + membershipValues.get(newVal) +  ' learning collaborative.');  
                                    }           
                                }
                            
                                if(!oldsh.contains(newVal))
                                {
                                    if(updatedContact.Membership_History__c != null)
                                    {
                                        updatedContact.Membership_History__c = updatedContact.Membership_History__c.replace('Former ' + newVal + ' Seat Holder','' );
                                    }
                                    add = add + newVal + ';';
                                }
                                if(tempSHfield == '')
                                {
                                    tempSHfield = newVal + ';';
                                    updatedContact.Membership_Access__c = membershipValues.get(newVal);
                                    updatedContact.Membership_Access_Abbreviations__c = membershipValuesabbr.get(newVal);                               
                                } else 
                                {
                                    tempSHfield = tempSHfield + newVal + ';';
                                    updatedContact.Membership_Access__c = updatedContact.Membership_Access__c + ', ' + membershipValues.get(newVal);
                                    updatedContact.Membership_Access_Abbreviations__c = updatedContact.Membership_Access_Abbreviations__c + ', ' + membershipValuesabbr.get(newVal);                             
                                }                           
                            }   
                            
                            //if there are any programs being added, add a note
                            if(add != '')
                            {
                                Task shAddNote = new Task(
                                  OwnerId = '00530000000vxt9', 
                                  WhoId = updatedContact.Id,
                                  WhatId = updatedContact.AccountId,
                                  ActivityDate = System.today(),
                                  Description = add + ' website access added',  
                                  Priority = 'High', 
                                  ReminderDateTime = System.now(), 
                                  Status = 'Completed', 
                                  Type = 'Website Related',
                                  Subject = 'Website Access Added');
                                //insert shAddNote;  
                                followupTasksBefore.add(shAddNote);   // add to list
                                if ((updatedContact.website_action__c == 'U') && (updatedContact.Website_Username__c != null))
				                {
				                	existingWebsiteUsersToNotify.add(updatedContact.Id);
				                }   
                            }
                        }
                        //if there are any programs being removed, add a note
                        if(remove != '')
                        {
                            Task shRemoveNote = new Task(
                              OwnerId = '00530000000vxt9', 
                              WhoId = Trigger.new[i].Id,
                              WhatId = Trigger.new[i].AccountId,
                              ActivityDate = System.today(),
                              Description = remove + ' website access removed',  
                              Priority = 'High', 
                              ReminderDateTime = System.now(), 
                              Status = 'Completed', 
                              Type = 'Website Related',
                              Subject = 'Website Access Removed ');
                            //insert shRemoveNote;  
                            followupTasksBefore.add(shRemoveNote);   // add to list
    
                        }
                        if( updatedContact.Seat_Holder__c == null || updatedContact.Seat_Holder__c == '')
                        {
                            updatedContact.Seat_Holder__c ='XXX';
                        }                           
                    }
                    //if the contact is no longer, nor are they becoming, a Seat Holder then we don't have to update the web anymore
                    if(( oldContact.Seat_Holder__c == 'XXX')  &&  (updatedContact.Seat_Holder__c == 'XXX'))                
                    {
                        //no longer updating website    
                        updatedContact.Website_update__c = false;                                                           
                    }
                    //if the contact is a seat holder but their main info has not changed, don't bother to update the website
                    else if( (oldContact.Liaision__c != updatedContact.Liaision__c) || (oldContact.email != updatedContact.email) 
                                || (oldContact.Seat_Holder__c != updatedContact.Seat_Holder__c) || (oldContact.FirstName != updatedContact.FirstName) ||
                                 (oldContact.LastName != updatedContact.LastName) || (oldContact.Title != updatedContact.Title) || 
                                 (oldContact.Phone != updatedContact.Phone) )
                    {
                        updatedContact.Website_update__c = true;
                    }
                    
                    if(updatedContact.password_reset__c == true)
                    {
                        updatedContact.website_update__c = true;    
                    }                   
                }
    
                        
                //check if seat holder value has changed and this is a new website account
                //cleanup
                if( (oldContact.Seat_Holder__c == 'XXX') && (updatedContact.Seat_Holder__c != 'XXX') && (updatedContact.website_action__c == 'N') && (oldContact.Website_Username__c == null) && (updatedContact.Email != null) )
                {   
                    //check if username is blank
                    if(updatedContact.Website_Username__c == null)
                    {           
                        updatedContact.email = updatedContact.email.toLowerCase();
                        
                        //if YES, set username to be their email prefix
                        updatedContact.Website_Username__c = updatedContact.email.split('@',2)[0]; 
                        
                        //create a list of allowed UN characters
                        Set<String> allowedChars =new Set<String>{'a', 'b', 'c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0'};
                        String tempUsername = '';
                        
                        //loop through the email prefix and remove any illegal characters
                        for(integer p = 0; p < updatedContact.Website_Username__c.length(); p++)
                        {
                            if( allowedChars.contains(updatedContact.Website_Username__c.substring(p, p+1)) )
                            {
                                tempUsername = tempUsername + updatedContact.Website_Username__c.substring(p, p+1);     
                            } 
                        }
                        
                        updatedContact.Website_Username__c = tempUsername;
                                    
                        for(integer n = 0; updatedContact.Website_Username__c.length() < 4; n++)
                        {
                            updatedContact.Website_Username__c = updatedContact.Website_Username__c + 1;
                        }
                        
                        String myValue = '%' + updatedContact.Website_Username__c + '%';
                        
                        //create (SELECT) a list of all the usernames where request UN is in username
                        List<Contact> contactsWithMatchingUsernames = [select Website_Username__c from Contact where  Website_Username__c LIKE :myValue ORDER BY Website_Username__c ASC ];
                        
                        String usernames = '';
                         
                        for (Contact c :  contactsWithMatchingUsernames )
                        {
                            usernames = usernames + c.Website_Username__c + ';';
                        } 
                        
                        //if no matching usernames are found (hence the List is empty), we can use the UN we have - otherwise....
                        if(usernames.length() != 0)
                        {
                            //...create temp placeholder for username (to avoid any collision problems)
                            string tempUN = updatedContact.Website_Username__c;
                            //set flag for unique UN checking
                            Boolean unique = false;
                            
                            //start a loop & try possible usernames
                            for( integer j = 1; unique == false ; j ++)
                            {
                                if(usernames.contains(tempUN))
                                {
                                    //Update the UN: add the loop index to the end of the UN
                                    tempUN = updatedContact.Website_Username__c + j;    
                                } else
                                {
                                    updatedContact.Website_Username__c = tempUN;
                                    unique = true;
                                }                                   
                            }       
                        }           
                    }
                    else if (updatedContact.Website_Username__c.length() < 4 ) 
                    {
                        updatedContact.Website_Username__c.addError( updatedContact.FirstName + ' ' + updatedContact.LastName + '\'s Website username must be at least 4 characters.');
                    }
                    else
                    {   
                        //create a list of allowed UN characters
                        Set<String> allowedChars = new Set<String>{'a', 'b', 'c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0'};
                        Set<String> numbers =  new Set<String>{'1', '2', '3', '4', '5', '6', '7', '8', '9', '0'};
                        String tempUsername = '';
                        
                        //loop through the email prefix and remove any illegal characters
                        for(integer p = 0; p < updatedContact.Website_Username__c.length(); p++)
                        {
                            if( allowedChars.contains(updatedContact.Website_Username__c.substring(p, p+1)) )
                            {
                                tempUsername = tempUsername + updatedContact.Website_Username__c.substring(p, p+1);     
                            } 
                        }
                        
                        updatedContact.Website_Username__c = tempUsername;
                        String myValue = '%' + updatedContact.Website_Username__c + '%';
                        
                        //create (SELECT) a list of all the usernames where request UN is in username
                        List<Contact> contactsWithMatchingUsernames = [select Website_Username__c from Contact where  Website_Username__c LIKE :myValue ORDER BY Website_Username__c ASC ];
                        
                        String usernames = '';
                         
                        for (Contact c :  contactsWithMatchingUsernames )
                        {
                            usernames = usernames + c.Website_Username__c + ';';
                        } 
                        
                        //if no matching usernames are found (hence the List is empty), we can use the UN we have - otherwise....
                        if(usernames.length() != 0)
                        {
                            //...create temp placeholder for username (to avoid any collision problems)
                            string tempUN = updatedContact.Website_Username__c;
                            //set flag for unique UN checking
                            Boolean unique = false;
                            
                            //start a loop & try possible usernames
                            for( integer j = 1; unique == false ; j ++)
                            {
                                if(usernames.contains(tempUN))
                                {
                                    //Update the UN: add the loop index to the end of the UN
                                    tempUN = updatedContact.Website_Username__c + j;    
                                } else
                                {
                                    updatedContact.Website_Username__c = tempUN;
                                    unique = true;
                                }                                   
                            }       
                        }                          
                    }
                    
                    //if password was blank, generate a random password
                    if( updatedContact.Website_Password__c == null)
                    {
                        //randomly select one number
                        integer tempNum = (Math.random() * 10).intValue();
                        
                        //randomly select 4 characters (from the end of the Contact ID)
                        string tempPW = 'eduventures' + tempNum;
                        
                        //save password 
                        updatedContact.Website_Password__c = tempPW;
                            
                    }
                    //if password was not blank, validate
                    else
                    {
                        //must be at least 6 characters long
                        if(updatedContact.Website_Password__c.length() >= 6)
                        {
                            boolean hasNumber = false;
                            boolean hasLetter = false;
                            
                            Set<String> alphabet = new Set<String>{'a', 'b', 'c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z'};
                            Set<String> numbers =    new Set<String>{'1', '2', '3', '4', '5', '6', '7', '8', '9', '0'};
                            
                            for( integer k = 0; (k < updatedContact.Website_Password__c.length()) && (hasNumber != true || hasLetter != true) ; k++)
                            {
                                if( (hasLetter == false) && (alphabet.contains(updatedContact.Website_Password__c.substring(k, k+1)))  )
                                {
                                    hasLetter = true;   
                                }
                                
                                if( (hasNumber == false) && (numbers.contains(updatedContact.Website_Password__c.substring(k, k+1))) )
                                {
                                    hasNumber = true;   
                                }                       
                            }
                            
                            if( hasLetter == false)
                            {
                                updatedContact.Website_Password__c.addError(updatedContact.FirstName + ' ' + updatedContact.LastName + '\'s Website password must contain at least one letter.');  
                            }
                            
                            if( hasNumber == false)
                            {
                                updatedContact.Website_Password__c.addError(updatedContact.FirstName + ' ' + updatedContact.LastName + '\'s Website password must contain at least one number.');  
                            }               
                        }
                        else
                        {
                            updatedContact.Website_Password__c.addError(updatedContact.FirstName + ' ' + updatedContact.LastName + '\'s Website password must be at least 6 characters.'); 
                        }               
                    }
                    newWebsiteUsersToNotify.add(updatedContact.Id);
                }
            }
            if(followupTasksBefore.isEmpty() == false)
            {
                for(Task t: followupTasksBefore)
                {
                    system.debug('note for '+ t.WhoId + ' has Id = ' + t.Id);
                }
                // insert the task list
                insert followupTasksBefore;
            }           
	        if(!newWebsiteUsersToNotify.isEmpty())
	        {
	        	websiteEmailer.inviteNewUsers(newWebsiteUsersToNotify);
	        }
	        if(!existingWebsiteUsersToNotify.isEmpty())
	        {
	        	websiteEmailer.notifyExistingUsers(existingWebsiteUsersToNotify);
	        }
        }

        if(Trigger.isAfter)
        {
            List<Task> followupTasksAfter = new List<Task>(); // build list in memory 
            
            String emailValueBefore ='';
            String emailValueAfter = '';
            String phoneValueBefore ='';
            String phoneValueAfter = '';            
            
            for(Integer i = 0; i < Trigger.new.size(); i++)
            {
                if(Trigger.new[i].website_account_reset__c != true)
                {
                    // don't let anyone update UN or password once set EXCEPT FOR the website user or AJ
                    if( Trigger.old[i].Website_Username__c != null && Trigger.new[i].LastModifiedById !='00530000000vxt9AAA' && Trigger.new[i].LastModifiedById !='005300000017Y29AAE' &&  (Trigger.new[i].Website_Username__c == null || Trigger.old[i].Website_Username__c != Trigger.new[i].Website_Username__c) )
                    {
                        Trigger.new[i].Website_Username__c.addError('You can not change ' + Trigger.new[i].FirstName + ' ' + Trigger.new[i].LastName + '\'s  username once it is set.');   
                    }
                    
                    if( Trigger.old[i].Website_Password__c != null && Trigger.new[i].LastModifiedById !='00530000000vxt9AAA' && Trigger.new[i].LastModifiedById !='005300000017Y29AAE' &&  (Trigger.new[i].Website_Password__c == null || Trigger.old[i].Website_Password__c != Trigger.new[i].Website_Password__c) )
                    {
                        Trigger.new[i].Website_Password__c.addError('You can not change ' + Trigger.new[i].FirstName + ' ' + Trigger.new[i].LastName + '\'s password once it is set');    
                    }
                    
                    if(Trigger.old[i].email != null)
                    {
                        emailValueBefore =Trigger.old[i].email;
                    }
                    
                    if( Trigger.new[i].email != null)
                    {
                        emailValueAfter = Trigger.new[i].email; 
                    }
                    
                    if(Trigger.old[i].phone != null)
                    {
                        phoneValueBefore =Trigger.old[i].phone;
                    }
                    
                    if( Trigger.new[i].phone != null)
                    {
                        phoneValueAfter = Trigger.new[i].phone; 
                    }
                    
                    if( emailValueBefore != emailValueAfter)
                    {               
                        Task emailChangedNote = new Task( 
                          OwnerId = '00530000000vxt9', 
                          WhoId = Trigger.new[i].Id,
                          WhatId = Trigger.new[i].AccountId,
                          ActivityDate = System.today(),
                          Description = 'Email address changed from ' + emailValueBefore + ' to ' + emailValueAfter,  
                          Priority = 'High', 
                          ReminderDateTime = System.now(), 
                          Status = 'Completed', 
                          Type = 'Change Log',
                          Subject = 'Email Address changed');
                        followupTasksAfter.add(emailChangedNote);   // add to list
                    }
                    
                    if( phoneValueBefore != phoneValueAfter)
                    {               
                        Task phoneNumberChangedNote = new Task(
                          OwnerId = '00530000000vxt9', 
                          WhoId = Trigger.new[i].Id,
                          WhatId = Trigger.new[i].AccountId,
                          ActivityDate = System.today(),
                          Description = 'Phone number changed from ' + phoneValueBefore + ' to ' + phoneValueAfter,  
                          Priority = 'High', 
                          ReminderDateTime = System.now(), 
                          Status = 'Completed', 
                          Type = 'Change Log',
                          Subject = 'Phone Number changed');
                        followupTasksAfter.add(phoneNumberChangedNote);   // add to list
                    }
                }
                else
                {
                    Contact temp = [select Id, website_account_reset__c from Contact where Id = :Trigger.new[i].id];
                    temp.website_account_reset__c = false;  
                    update temp;
                }
                                    
            }
             
            if(followupTasksAfter.isEmpty() == false)
            {
                // insert the task list 
                insert followupTasksAfter;
            }
        }
    }       
}