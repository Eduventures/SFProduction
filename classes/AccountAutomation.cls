public with sharing class AccountAutomation { 

    public static void process() {
    	
    	List<Id> acctIds = new List<Id>();
    	Set<Id> membershipsToUpdateIds = new Set<Id>();
	    List<Membership__c> membershipsToUpdate = new List<Membership__c>(); 
    	List<Account> acctsToUpdate = new List<Account>();
    	List<Opportunity> oppsToUpdate = new List<Opportunity>();
    	List<Projects__c> projectsToUpdate = new List<Projects__c>();
    	
		/*find accounts with LOAs that either
			a) go active today
			b) expired yesterday
			c) passeed their extension date	
			
			any of these conditions will require synchronization to occur (between account, contacts, loa and the renewal opportunity)	
		*/
		for (LOA__c l: [Select Program__c, Status__c, Account__c, Membership__c, 
							(Select Name, Original_LOA_Status__c from RenewalOpportunities__r ), 
							(Select Id, Product__c, Stage__c from Deliverables__r where Product__c IN ('ACCT MGMT','CLIENT SVCS') ) 
						From LOA__c 
						where  Account__c != '0013000000G3Y0S' AND ((Start_Date__c = TODAY) OR (End_Date__c = YESTERDAY OR Extension_Date__c = YESTERDAY))])
		{
			if(l.Membership__c != null)
			{
				membershipsToUpdateIds.add(l.Membership__c);
			} else 
			{
				//add the account id to a list for updating for 
				acctIds.add(l.Account__c);
			}

			//loop through ACCT MGMT project(s) for these LOAs
			for(Projects__c acctMgmtProject : l.Deliverables__r)
			{
				if(l.Status__c == 'Active' || l.Status__c == 'Extended')
				{
					acctMgmtProject.Stage__c = 'In Progress';
				} else 
				{
					acctMgmtProject.Stage__c = 'Completed';
				}
				projectsToUpdate.add(acctMgmtProject);
			}
			//loop through renewal opps for these LOAs
			for(Opportunity renewalOpp: l.RenewalOpportunities__r)
			{
				//update the 'original LOA status' field 
				//(it's either gone from Pending->Active; Active->Expired; Active->Renewed, Extended->Expired; or Extended->Renewed)
				renewalOpp.Original_LOA_Status__c = l.Status__c;
				//add the renewal opportunity to a list for updating
				oppsToUpdate.add(renewalOpp);
			}
			
		}
		
		List<Projects__c> activeECSprojects = [ select Id, Product__c, Divisions__c, Account__c, Programs__c, Active__c, RecordTypeId 
												from Projects__c where Divisions__c = 'Learning Collaborative' and Programs__c = 'ECS' 
												and RecordTypeId = '01230000000DMZh' and Active__c = true ];
												
		List<LOA__c> activeECSretainers = [ select Id, Name, Account__c, Program__c, RecordTypeId, Start_Date__c, End_Date__c  
											from LOA__c where RecordTypeId = '01230000000DMc7' and Start_Date__c <= TODAY and End_Date__c >= TODAY];
		
		for(Projects__c activeECSproj : activeECSprojects)	
		{
			acctIds.add(activeECSproj.Account__c);
		}
		
		for(LOA__c activeECSretainer : activeECSretainers)	
		{
			acctIds.add(activeECSretainer.Account__c);
		}

		if(!acctIds.isEmpty())
		{
			//go get the actual Accounts to update
			acctsToUpdate = [ SELECT Id, Name, Active_Engagements__c from Account where Id in :acctIds ];
			
			//invoke the Account update trigger to handle the Active Engagements synch, as well as website access removal for expired contacts
			update acctsToUpdate;			
		}
		
		if(!membershipsToUpdateIds.isEmpty())
		{
			for(Membership__c m: [ Select Id FROM Membership__c where Id in :membershipsToUpdateIds])
			{
				membershipsToUpdate.add(m); 
			}
			update membershipsToUpdate;	
		}		

		//update the opportunties whose LOA status has changed
		update oppsToUpdate;

		//update the acct mgmt projects
		update projectsToUpdate;
		
		List<Account> childAccounts = [select Id, Name, Active_Engagements__c, ParentId from Account where ParentId in :acctIds];
		update childAccounts;
										
    }
    
    static testMethod void testAccountAutomation() {
        
        AccountAutomation.process(); 
    }    
}