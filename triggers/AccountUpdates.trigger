trigger AccountUpdates on Account (before update, after update) {
    if(Trigger.IsBefore)
    {     
        Set<Id> acctIds = new Set<Id>();
        Set<Id> parentIds = new Set<Id>();
        Map<Id,String> parentAccts = new Map <Id,String>();
        Map<Id,String> loaMap = new Map <Id,String>();
        Map<String,Id> CSAtoContactMap = new Map<String,Id>();
                
        for (Account acct : Trigger.new)
        {
            acctIds.add(acct.Id);
            if(acct.ParentId != null)
            {
                parentIds.add(acct.ParentId);   
            }
        }

        // we list any clients with active ECS Projects as ECS clients (our best indicator, since contract end dates aren't managed)) 
        List<Projects__c> activeECSprojects = [ select Id, Product__c, Divisions__c, LOA__r.Program__c, Account__c, Programs__c, Active__c, RecordTypeId 
												from Projects__c where Divisions__c = 'Learning Collaborative' and Programs__c = 'ECS' 
												and RecordTypeId = '01230000000DMZh' and Active__c = true and LOA__r.Program__c != null ];	
		List<Id> activeECSloas = new List<Id>();
		for(Projects__c p : activeECSprojects)
		{
			activeECSloas.add(p.LOA__c);
		}
		
		// find active LC contracts, or ECS retainers
        for(LOA__c l: [SELECT Id, Name, Program__c, Status__c, Account__c From LOA__c where 
        																	( Status__c in ( 'Active', 'Extended') 
        																		and RecordTypeId = '01230000000DMbx' and Program__c != 'RPT' 
        																		and Account__c in :acctIds)
        																	or 
        																	(  RecordTypeId = '01230000000DMc7' and Start_Date__c <= TODAY 
        																	and End_Date__c >= TODAY)
        																	or
        																	(Id in :activeECSloas)
        																	or
        																	( Status__c in ( 'Active', 'Extended') 
        																		and RecordTypeId = '01230000000DMmq' and Program__c != 'RPT' 
        																		and Account__c in :acctIds) ])	
        {
            if(loaMap.containsKey(l.Account__c))
            {
            	if(!loaMap.get(l.Account__c).contains(l.Program__c))
            	{
            		loaMap.put(l.Account__c, loaMap.get(l.Account__c)+';'+l.Program__c);
            	}
            } else
            {
                loaMap.put(l.Account__c, l.Program__c);
            }
        }     							
              
        
        for(Account parentAcct : [ SELECT Id, Name, Active_Engagements__c from Account where Id in :parentIds])
        {
            parentAccts.put(parentAcct.Id, parentAcct.Active_Engagements__c);
        }   
       
        //loop through all trigger elements and then loop through all LOAs for the given trigger Account Id 
        for(Integer i = 0; i < Trigger.new.size(); i++)
        {
        	if(Trigger.new[i].Id != '0013000000G3Y0S')
            {
	            Account updatedAccount = Trigger.new[i];
	            Account oldAccount = Trigger.old[i];                        
	    
	            if(oldAccount.website_update__c == true)
	            {
	                updatedAccount.website_action__c = 'U'; 
	            }
	            
	            //if there are any active LOAs for this account, then we can set the Active Engagements field...
	            if(loaMap.containsKey(updatedAccount.Id))
	            {
	                updatedAccount.Active_Engagements__c = loaMap.get(updatedAccount.Id);
	
	                // if this acocunt does have a parent, aggregate the Active Engagements without duplicating values
	                if (loaMap.containsKey(updatedAccount.Id) && updatedAccount.ParentID != null)
	                {
	                    //load the parent account's active LOAs 
	                    List<String> parentPrograms = parentAccts.get(updatedAccount.ParentID).replace('XXX','').split(';',0);
	                    for(String testValue: parentPrograms)
	                    {
	                        if(!updatedAccount.Active_Engagements__c.contains(testValue))
	                        {
	                            updatedAccount.Active_Engagements__c = updatedAccount.Active_Engagements__c + ';' + testValue;
	                        }
	                    }   
	                }
	            } else if(updatedAccount.ParentID != null)
	            {
	                updatedAccount.Active_Engagements__c = parentAccts.get(updatedAccount.ParentID);
	            }
	            //...if this isn't a child account, then Active Enganements is blank (xxx)
	            else if (updatedAccount.ParentID == null)
	            {
	                updatedAccount.Active_Engagements__c = 'XXX';   
	            }
	
				//if the 'Client Service Advisor' changes, we need to synchronize the 'Client Services Advisor (contact)' field that the website uses
				//to display the right staff member on the clients' "Support" page(www.eduventures.com/private/support) 
				if(oldAccount.Client_Services_Advisor__c != updatedAccount.Client_Services_Advisor__c)
				{
					User CSA = [ Select Email FROM User WHERE Id = :updatedAccount.Client_Services_Advisor__c];
					Contact CSAcontact = [ Select Id, Email FROM Contact WHERE Email = :CSA.Email];
					updatedAccount.Client_Services_Advisor_Contact__c = CSAcontact.Id; 
				}
				
	            //if the active engagements are changing, we need to update the website
	            if(oldAccount.Active_Engagements__c != updatedAccount.Active_Engagements__c )
	            { 
	                updatedAccount.website_update__c = true;
	            }  
	            //if the account has previously been added to the website, then we need to keep the Site synchronized for changes in critical info (name, address, directory listing, etc)
	            else if(updatedAccount.website_action__c == 'U')
	            {
	                if ( (oldAccount.Name != updatedAccount.Name) || (oldAccount.BillingStreet != updatedAccount.BillingStreet) || (oldAccount.BillingCity != updatedAccount.BillingCity) || (oldAccount.BillingState != updatedAccount.BillingState) || (oldAccount.BillingPostalCode != updatedAccount.BillingPostalCode) || (oldAccount.Client_Services_Advisor__c != updatedAccount.Client_Services_Advisor__c) )
	                { 
	                    updatedAccount.website_update__c = true;
	                }
	                else if ( oldAccount.Not_Listed_on_Member_Directory__c != updatedAccount.Not_Listed_on_Member_Directory__c   )
	                { 
	                    updatedAccount.website_update__c = true;
	                }  else
		            {   
		                updatedAccount.website_update__c = false; 
		            }                 
	            } else
	            {   
	                updatedAccount.website_update__c = false; 
	            }
            }
        }
    
    }
    if(Trigger.IsAfter)
    {   
        List<Task> followupTasks = new List<Task>();
        Set<Id> acctIds = new Set<Id>();
        Map<Id,List<Contact>> contactMap = new Map <Id,List<Contact>>();
        for (Account acct : Trigger.new)
        {
            acctIds.add(acct.Id);
        }
                            
        for(Integer i = 0; i < Trigger.new.size(); i++)
        {
            if(Trigger.new[i].Id != '0013000000G3Y0S')
            {
	            Account updatedAccount = Trigger.new[i];
	            Account oldAccount = Trigger.old[i]; 
	            String expiredPrograms = '';
	                         
	            //log changes to Active Engagements
	            if(oldAccount.Active_Engagements__c != updatedAccount.Active_Engagements__c)
	            {
	                Task task = new Task(
	                        OwnerId = '00530000000vxt9',
	                        WhatId = updatedAccount.Id,
	                        ActivityDate = System.today(), 
	                        Description = 'Active Engagements has changed from ' + oldAccount.Active_Engagements__c  + ' to ' + updatedAccount.Active_Engagements__c, 
	                        Priority = 'High', 
	                        ReminderDateTime = System.now(), 
	                        Status = 'Completed',
	                        Type = 'Profile Change', 
	                        Subject = 'Active Engagements changed');
	                followupTasks.add(task); 
	                
	                //test if the account lost program access. If so, track the Acct Id so we can go back and remove website access from the contacts
	                for(String programValue: oldAccount.Active_Engagements__c.Split(';',0))
	                {
	                	programValue = programValue.replace('SEM','ENM').substring(0,3);
	                    if(programValue != 'XXX' && !updatedAccount.Active_Engagements__c.replace('SEM','ENM').contains(programValue))
	                    {
	                        if(expiredPrograms == '')
	                        {
	                        	expiredPrograms = programValue+';';
	                        } else 
	                        {
	                        	expiredPrograms = expiredPrograms + programValue+';';
	                        }
	                    }
	                }
	                
	                if(expiredPrograms != '')
	                {
						AccountAsyncUpdate.removeContactAccess(updatedAccount.Id,expiredPrograms);
	                }
	            }    
	
	                                
	            if(oldAccount.Name != updatedAccount.Name)
	            {
	                Task task = new Task(
	                        OwnerId = '00530000000vxt9',
	                        WhatId = updatedAccount.Id,
	                        ActivityDate = System.today(), 
	                        Description = 'If applicable, this Account Name change was also sent to the Member Directory on Eduventures\'s website. \nOld name: ' + oldAccount.Name + ' \nNew account name: ' + updatedAccount.Name, 
	                        Priority = 'High', 
	                        ReminderDateTime = System.now(), 
	                        Status = 'Completed',
	                        Type = 'Profile Change', 
	                        Subject = 'Name changed from '+ oldAccount.Name + ' to ' + updatedAccount.Name);
	                followupTasks.add(task);  
	            }
	            
	            if( oldAccount.Not_Listed_on_Member_Directory__c != updatedAccount.Not_Listed_on_Member_Directory__c )
	            {
	                String action = '';
	                if(updatedAccount.Not_Listed_on_Member_Directory__c == true )
	                {action = 'Removal';}
	                else
	                {action = 'Addition';}
	
	                Task task = new Task(
	                        OwnerId = '00530000000vxt9',
	                        WhatId = updatedAccount.Id,
	                        ActivityDate = System.today(), 
	                        Description = 'The \'Listed on member directory\' status was changed from ' + oldAccount.Not_Listed_on_Member_Directory__c + ' to ' + updatedAccount.Not_Listed_on_Member_Directory__c, 
	                        Priority = 'High', 
	                        ReminderDateTime = System.now(), 
	                        Status = 'Not Started',
	                        Type = 'Website Related', 
	                        Subject = 'Change to Member Directory listing: '+ action);
	                followupTasks.add(task); 
	            }
            }            
        }
        
        if(followupTasks != null) 
        {
            insert followupTasks;   
        }
        
    }
}