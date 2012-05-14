trigger LoaInsertAfter on LOA__c (after insert) { 
 
    List<Projects__c> followupProjects = new List<Projects__c>();
    List<Projects__c> updateProjects = new List<Projects__c>();
    List<Membership__c> membershipsToUpdate =  new List<Membership__c>();
    	
	Map<String, LOA__c> loasMap = new Map<String, LOA__c>();
    for (LOA__C l : Trigger.new)
    {
        if(!loasMap.containsKey(l.Account__c))
        {
        	loasMap.put(l.Account__c , l); 
        }
    }

	//Query the Account data for this LOA for later updating, must query the value for any fields that we use or update (even if we just assign a value) 
	Map<Id,Account> acctsMap = new Map<Id,Account>();
	
	for(Account a: [Select Id, name, AIEMemberDt__c, AIEAnniversaryDate__c, ALMemberDt__c, ALAnniversaryDt__c, CPEMemberDt__c, CPEAnniversary_Date__c,
						DEVMemberDt__c, DEVAnniversaryDate__c, EMMemberDt__c, EMAnniversaryDate__c,
						ECSMemberDt__c, OHEMemberDt__c, OHEAnniversaryDate__c, SOEMemberDt__c, SOEAnniversaryDt__c
						from Account  where Id in :loasMap.KeySet()])
	{
		acctsMap.put(a.Id, a);
	}					
	
	/*
	create a map that lists the memberships for each account: the map's initial key is the account Id, which retrieves a second map
	the second map's key values are program family abbreviations. This map is needed because we could be updating multiple memberships 
	for the same account within an LOA update trigger, and we can't afford to do SOQL queries within the trigger For loop to select the correct one at run time
	*/
	 
	Map<Id,Map<String,Membership__c>> membershipMap = new Map<Id,Map<String,Membership__c>>();					
	for(Membership__c m: [Select Website_Access__c, CreatedDate, Strategy_Session_Access__c, Status__c, Program_Family__c, Name, Member_Roundtable_Access__c, 
								Last_Renewal_Date__c, Join_Date__c, Expiration_Date__c, Custom_Analysis_Limit__c, Account__c, AMM_Pass_Count__c 
								FROM Membership__c WHERE Account__c IN :acctsMap.KeySet() ])
	{
		if(membershipMap.containsKey(m.Account__c))
		{
			membershipMap.get(m.Account__c).put(m.Program_Family__c,m);
		} else 
		{
			Map<String,Membership__c> tempMap = new Map<String,Membership__c>();
			tempMap.put(m.Program_Family__c,m);
			membershipMap.put(m.Account__c,tempMap);
		}
		
	}							
	//setup lists to handle update Child Accounts & their contacts
	Map<Id, List<Account>> childAcctsMap = new Map<Id, List<Account>>();
	
	for(Account child: [Select Id, name, ParentId, Active_Engagements__c from Account where ParentId in :loasMap.KeySet()])
	{
		if(childAcctsMap.containsKey(child.ParentId))
		{
			childAcctsMap.get(child.ParentId).add(child);
		} else
		{
			List<Account> temp = new List<Account>();
			temp.add(child);
			childAcctsMap.put(child.ParentId, temp);
		}
	}
	
	List<Account> updateChildAccts = new List<Account>();
	List<Contract_Year__c> CYstoInsert = new List<Contract_Year__c>();
						
	for(Integer n = 0; n < Trigger.new.size(); n++)  
	{	 			
		LOA__c newloa = Trigger.new[n];	
						
		Account mainAccount = acctsMap.get(newloa.Account__c);

		//initialize variables to populate the renewal opportunity that we create along with all new membership LOAs 
		String Owner = '';
		String shortProgram = newloa.Program__c.substring(0,3);
		//run through program list and set Account Membership Date (if it's blank), Anniversary Date. Also set owner and product info for the renewal opportunity
		if(shortProgram =='ACL')
		{
			if( mainAccount.ALMemberDt__c == null)
			{
				mainAccount.ALMemberDt__c = newloa.Start_Date__c;
			} 
			Owner = '00580000003FJy9'; //Tracey Liptack
			mainAccount.ALAnniversaryDt__c = newloa.End_Date__c;		 
		}
		else if(shortProgram =='AIE')
		{
			if( mainAccount.AIEMemberDt__c == null)
			{
				mainAccount.AIEMemberDt__c = newloa.Start_Date__c;
			} 
			Owner = '00580000003FJy9'; //Tracey Liptack
			mainAccount.AIEAnniversaryDate__c = newloa.End_Date__c;		 
		}		
		else if(shortProgram =='CPE')
		{				
			if(mainAccount.CPEMemberDt__c == null)
			{
				mainAccount.CPEMemberDt__c = newloa.Start_Date__c;
			}
			Owner = '00530000000w05R'; //Lesley Nelson
			mainAccount.CPEAnniversary_Date__c = newloa.End_Date__c;
		}
		else if(shortProgram =='DEV')
		{
			if(mainAccount.DEVMemberDt__c == null)
			{
				mainAccount.DEVMemberDt__c = newloa.Start_Date__c;
			}
			Owner = '00530000000w056'; //Jen Zaslow
			mainAccount.DEVAnniversaryDate__c = newloa.End_Date__c;
		}
		else if(shortProgram =='ENM')
		{
			if(mainAccount.EMMemberDt__c == null)
			{
				mainAccount.EMMemberDt__c = newloa.Start_Date__c;
			}
			Owner = '00580000003FJy9'; //Tracey Liptack
			 mainAccount.EMAnniversaryDate__c = newloa.End_Date__c;	
		}
		else if(shortProgram =='ECS')
		{
			if(mainAccount.ECSMemberDt__c == null)
			{
				mainAccount.ECSMemberDt__c = newloa.Start_Date__c;
			}
		}
		else if(shortProgram =='OHE') 
		{
			if( mainAccount.OHEMemberDt__c == null)
			{
				mainAccount.OHEMemberDt__c = newloa.Start_Date__c;
			}
			Owner = '00530000000w05R'; //Lesley Nelson
			mainAccount.OHEAnniversaryDate__c = newloa.End_Date__c;
		}
		else if(shortProgram =='SOE')
		{
			if(mainAccount.SOEMemberDt__c == null)
			{
				mainAccount.SOEMemberDt__c = newloa.Start_Date__c;
			}
			Owner = '00580000003EbAm'; //Mary Kaye Pepperman
			mainAccount.SOEAnniversaryDt__c = newloa.End_Date__c;
		}					
		else if(shortProgram =='SEM')
		{
			if(mainAccount.EMMemberDt__c == null)
			{
				mainAccount.EMMemberDt__c = newloa.Start_Date__c;
			}
			Owner = '00580000003EbAm'; //Mary Kaye Pepperman
			mainAccount.EMMemberDt__c = newloa.End_Date__c;
		}
				
		//Create a renewal opportunity if this is NOT a Consulting engagement
		if(newloa.RecordTypeId == '01230000000DMbx' && newloa.Program__c != 'RPT')
		{ 
			//BEGIN membership synchronization section
			Membership__c theMembership = new Membership__c();
			if(membershipMap.containsKey(newloa.Account__c))
			{
				if(membershipMap.get(newloa.Account__c).KeySet().contains(newloa.Program_Family__c))
				{
					theMembership = membershipMap.get(newloa.Account__c).get(newloa.Program_Family__c);
					if(date.valueOf(theMembership.CreatedDate) != system.today())
					{
						//now update the basic membership details
						theMembership.Last_Renewal_Date__c = newloa.Agreement_Date__c; 
						theMembership.Expiration_Date__c = newloa.End_Date__c; 
						//if the LOA is starting today (or backdated), then update the memebrship details
						//otherwise, we will persist the current ones and update wit hthe new details with a nightly batch (when this LOA actually starts)
						if(newloa.Start_Date__c <= system.today() && newloa.End_Date__c >= system.today() )
						{
							theMembership.Website_Access__c = newloa.Website_Access__c; 
							theMembership.Strategy_Session_Access__c = newloa.Strategy_Session_Access__c; 
							theMembership.Custom_Analysis_Limit__c = newloa.Custom_Analysis_Limit__c; 
							theMembership.AMM_Pass_Count__c = newloa.AMM_Pass_Count__c;
							theMembership.Status__c = newloa.Status__c;
						}
						membershipsToUpdate.add(theMembership);
					}
				}
			}
			//END membership synchronization section
			
			Opportunity renewalopp = new Opportunity(
			   	Name = mainAccount.name + '-' + newloa.Program__c + '-' + newloa.End_Date__c.month() + '/' + newloa.End_Date__c.day() + '/' + newloa.End_Date__c.year(),
				AccountId = mainAccount.Id,
				Amount = newloa.Amount__c,
				OwnerId = Owner,
				RecordTypeId = '01230000000DMio', 
				Type = 'Renewal Business', 
				Class__c = 'LC',
				Product_Group__c = newloa.Program__c,
				StageName = 'Upside',
				Description = 'This is a Renewal Opportunity automatically created by the system.',
				Goals__c = '',
				Challenges__c = '',
				Peers_Competitors__c = '',
				Research_Needs__c = '',
				Original_LOA_Status__c = newloa.status__c,
				Original_LOA__c = newloa.Id, 
				Original_LOA_Expiration_Date__c = newloa.End_Date__c,
				CloseDate = Date.valueOf('1900-01-01 00:00:00'),
				Close_Date_New__c = newloa.End_Date__c,
				Membership__c = newloa.Membership__c);
			insert renewalopp;
			
			//add a person into the Opportunity's Contact Role, use the Main COntact for the LOA 
			if(newloa.Company_Contact__c != null)
			{
				OpportunityContactRole oppRole = new OpportunityContactRole(
					OpportunityId = renewalopp.id,
					ContactId = newloa.Company_Contact__c,
					Role = 'Other'); 
				insert oppRole;
			}
			
			//refresh the Main Accounts' 'do not publish' field based on the most recent contract
			mainAccount.Do_not_publish__c = newloa.Do_not_publish__c;
			//update the main account
			update mainAccount;
			
			String modifiedProgramValue = newloa.Program__c;
			if(modifiedProgramValue == 'SEM')
			{
				modifiedProgramValue = 'ENM';
			}		
			
			if(newloa.Contract_Length__c >0.5)
			{
				for(Integer i=0; i<(newloa.Contract_Length__c - .5);i++)
				{ 
					Projects__c midYearCall = new Projects__c(
					   	Name = newloa.Program__c + '-MYC'+(i+1)+'-' + mainAccount.name,
						Account__c = mainAccount.Id,
						Default_Call_Date__c = newloa.Start_Date__c + 180 + (i*365),
						RecordTypeId = '01280000000EKNA', 
						LOA__c = newloa.id,
						Programs__c = modifiedProgramValue,
						Product__c = 'MYC',
						Active__c = true,
						Stage__c = 'Not Started',
						Description__c = 'This is a Mid Year Call that is automatically created by the system when an LOA is created.',
						Membership__c = newloa.Membership__c);
					followupProjects.add(midYearCall);				
				}
			}

			String projStage = 'Not Started';
			if(newloa.Start_Date__c <= system.today())
			{
				projStage = 'In Progress';
			}
			if(!newloa.Program__c.contains('-ASV'))
			{
				Projects__c onBoardCall = new Projects__c(
				   	Name = newloa.Program__c + '-OBC-' + mainAccount.name,
					Account__c = mainAccount.Id,
					//Project_Manager__c = Owner,
					RecordTypeId = '01280000000EKNA', 
					LOA__c = newloa.id,
					Programs__c = modifiedProgramValue,
					Product__c = 'OBC',
					Active__c = true,
					//Contact__c = maincontact,
					Stage__c = 'Not Started',
					Description__c = 'This is an On Board Call that is automatically created by the system when an LOA is created.',
					Membership__c = newloa.Membership__c);
				followupProjects.add(onBoardCall);
				
				//if([SELECT count() FROM Projects__c WHERE Product__c = 'ACCT MGMT' AND Membership__c = :newloa.Membership__c] == 0)
				//{
					Projects__c accountManagement = new Projects__c(
					   	Name = newloa.Program__c + '-ACCT MGMT-' + mainAccount.name,
						Account__c = mainAccount.Id,
						RecordTypeId = '01230000000DMZc', 
						LOA__c = newloa.id,
						Programs__c = modifiedProgramValue,
						Product__c = 'ACCT MGMT',
						Active__c = true, 
						Stage__c = projStage,
						Description__c = 'This is an Account Management project that is automatically created by the system when an LOA is created.',
						Membership__c = newloa.Membership__c);
					followupProjects.add(accountManagement);			
				//} else 
				//{
				/*	for(Projects__c acctMgmtProject : [SELECT Stage__c FROM Projects__c WHERE Product__c = 'ACCT MGMT' 
															AND Membership__c = :newloa.Membership__c AND Stage__c != 'In Progress'
															 ORDER BY CreatedDate DESC LIMIT 1])
					{
						acctMgmtProject.Stage__c = projStage;
						updateProjects.add(acctMgmtProject);
					}
				*/															
				//}
													
			}
			//if([SELECT count() FROM Projects__c WHERE Product__c = 'CLIENT SVCS' AND Membership__c = :newloa.Membership__c] == 0)
			//{
				Projects__c clientServices = new Projects__c(
				   	Name = newloa.Program__c + '-CLIENT SVCS-' + mainAccount.name,
					Account__c = mainAccount.Id,
					RecordTypeId = '01280000000HgcZ', 
					LOA__c = newloa.id,
					Programs__c = modifiedProgramValue,
					Product__c = 'CLIENT SVCS',
					Active__c = true, 
					Stage__c = projStage,
					Description__c = 'This is a CLIENT SVCS project that is automatically created by the system when an LOA is created.',
					Membership__c = newloa.Membership__c);
				followupProjects.add(clientServices);					
			//} else 
			//{
			/*	for(Projects__c clientSvcsProject : [SELECT Stage__c FROM Projects__c WHERE Product__c = 'CLIENT SVCS' 
														AND Membership__c = :newloa.Membership__c AND Stage__c != 'In Progress'
														 ORDER BY CreatedDate DESC LIMIT 1])
				{
					clientSvcsProject.Stage__c = projStage;
					updateProjects.add(clientSvcsProject);
				}
			*/											
			//}

			//if this is a renewal LOA and the old LOA is not 60 days past expired yet, we should go back and update the original LOA.
			//Setting the Renewed checkbox to true and copying the newest LOA # back to the original LOA
			
			//we need to expand the program value to reflect anything in the program family,
			// in case renewals happen accross programs (Full to RL, ENM to SEM, etc) 
			List<String> modifiedProgramValues = new List<String>();
			if( newloa.Program__c != null) 
			{
				//for SEM, we need to look for 
				if(newloa.Program__c == 'SEM' || newloa.Program__c == 'ENM')
				{
					modifiedProgramValues.add('ENM');
					modifiedProgramValues.add('ENM-RL');
					modifiedProgramValues.add('SEM');
				} else 
				{
					modifiedProgramValues.add(newloa.Program__c.substring(0,3));
					modifiedProgramValues.add(newloa.Program__c.substring(0,3) + '-RL');
				}	
			}
			
			if( (newloa.Type__c =='Renewal') && ([select count() from LOA__c where Account__c = :newloa.Account__c and Program__c IN :modifiedProgramValues 
				and Id != :newloa.Id and ( (status__c in ('Active', 'Extended')) or (End_Date__c = LAST_N_DAYS:60) )] != 0) )
			{
				LOA__c oldLOA = [select Id, Renewed__c, Renewal_LOA__c, Account__c, End_Date__c, Research_Account_Manager__c from LOA__c 
				where Account__c = :newloa.Account__c and Program__c IN :modifiedProgramValues 
				and Id != :newloa.Id and ( (status__c in ('Active', 'Extended')) or (End_Date__c = LAST_N_DAYS:60) )];
	
	            LOA_tools.renewLOA(oldLOA.Id, newloa.Id );
						
				if(oldLOA.Research_Account_Manager__c != null)
				{
					if([select count() from User where Id = :oldLOA.Research_Account_Manager__c and IsActive = true] == 1)
					{
						LOA_tools.updateResearchMgr(newloa.Id, oldLOA.Research_Account_Manager__c);
					}
				}
				
				if(newloa.Website_Access__c == true)
				{
					//Now locate any contacts who lost acces when this LOA lapsed. We do it by relying on the fact I log a task to Contact history whenever 
					//Website access, email or phone number changes. 
					List<Task> findContactsByTask = [SELECT WhoId, Description, Subject FROM Task 
														WHERE  Subject = 'Website Access Removed' AND CreatedDate > :oldLOA.End_Date__c 
														AND WhatId = :oldLOA.Account__c];
					List<Id> contactidsToReinstate = new List<Id>();
					List<Contact> contactsToReinstate = new List<Contact>();
					for(Task t : findContactsByTask)
					{
						//just to be sure - make sure the body of the Task notes they had this program access removed, because sometimes 2 LOAs expire on the same day and 
						//not all contacts had access to both programs. (i.e. we don't want to 'reinstate' CPE access to an old SOE website user just because the 
						//SOE and CPE contracts expired together and the CPE subsequently renewed)
						if(t.Description.contains(modifiedProgramValues[0]))
						{
							contactidsToReinstate.add(t.WhoId);
						}
					}
					Map<String,String> membershipRolesMap = new Map<String,String>();
					membershipRolesMap.put('Former ' + modifiedProgramValues[0] + ' Liaison', modifiedProgramValues[0] + ' Liaison');
					membershipRolesMap.put('Former ' + modifiedProgramValues[0] + ' Liaison 2', modifiedProgramValues[0] + ' Liaison 2');
					membershipRolesMap.put('Former ' + modifiedProgramValues[0] + ' Decision Maker', modifiedProgramValues[0] + ' Decision Maker');
					membershipRolesMap.put('Former ' + modifiedProgramValues[0] + ' Liaison Assitant', modifiedProgramValues[0] + ' Liaison Assitant');
					membershipRolesMap.put('Former ' + modifiedProgramValues[0] + ' Decision Maker Assitant', modifiedProgramValues[0] + ' Decision Maker Assitant');
					membershipRolesMap.put('Former ' + modifiedProgramValues[0] + ' Q&A Survey Recipient', modifiedProgramValues[0] + ' Q&A Survey Recipient');				
								
					//loop through contacts and ....							
					for(Contact c : [SELECT Id, Seat_Holder__c, Membership_History__c, Membership_Role__c FROM Contact where Id in :contactidsToReinstate])
					{
						// 1) provide website access back	
						if(c.Seat_Holder__c != null && (!c.Seat_Holder__c.contains(modifiedProgramValues[0])) )
						{
							c.Seat_Holder__c = c.Seat_Holder__c + ';' + modifiedProgramValues[0];
						} else 
						{
							c.Seat_Holder__c = modifiedProgramValues[0];
						}
						
						// 2) if applicable, replace any lost Membership Role tags 
						if(c.Membership_History__c != null && c.Membership_History__c.contains(modifiedProgramValues[0]))
						{
							//loop through the old MR values to find any that were for the same program as this LOA being inserted
							for(String oldRole: c.Membership_History__c.split(';',0))
							{
								if(oldRole.contains(modifiedProgramValues[0]))
								{
									//if a match is found, add the Membership role back
									// FYI - the Contact Update trigger (ContactProcedures.tgr) should handle the cleanup of the Membership History Field
									if(c.Membership_Role__c != null)
									{
										c.Membership_Role__c  = c.Membership_Role__c + ';' + membershipRolesMap.get(oldRole);
									} else 
									{
										c.Membership_Role__c  = membershipRolesMap.get(oldRole);
									}
								}
							}				
						}
						contactsToReinstate.add(c);			
					}			
					//update contacts
					update contactsToReinstate;				
				}							 							
			}
		} else if (newloa.RecordTypeId == '01230000000DMc7' && newloa.Program__c == 'ECS')
		{
			Projects__c ecsProject = new Projects__c(
			   	Name = 'Default Project for LOA: ' + newloa.Name,
				Account__c = mainAccount.Id,
				RecordTypeId = '01230000000DMZh', 
				LOA__c = newloa.id, 
				//Estimated_End_Date__c = newloa.Start_Date__c + 90, 
				Programs__c = newloa.Program__c,
				Product__c = 'Consulting - General',
				Active__c = true,
				Stage__c = 'Not Started',
				Description__c = 'This is a default project created by the system when the LOA was booked. Please fill in/update the relevant information (project title, manager, etc) when available.');
			followupProjects.add(ecsProject);		
		}		
		
		if(newloa.Amount__c > 0)
		{
			
			/*01/05/2012 AJD New code to handle Inserting "Contract Year" objects. 
			first we determine if the contract is 
				1) standard (contract months are multiple of 12)
				2) a 'partial' contract that is double counted (in cases where contract_months/12 has a remainder >= 5) 
				3) partial contract that does not have contract year for its last portion (because it is under 6 months)
				4) under a year
			*/
			//round contract length up if it's more than half a year (18-23 months, 30-35 months, etc) so we make an additional, partial, contract year 
			Integer NumberofContractYears = 0;
			if(newloa.Contract_Length__c != null)
			{
				NumberofContractYears = math.round(newloa.Contract_Length__c);
			}
			Boolean partialContractYear = false;
			/*
			//set a flag to know if this is a non-round contract (might be useful if we want to try to determine proportional values for each CY)
			if( math.floor(newloa.Contract_Length__c) != NumberofContractYears)
			{
				partialContractYear = true;
			}
			*/
			if(NumberofContractYears == 0)
			{
				NumberofContractYears = 1;
			}
			//make a contract year for each "year" of the LOA (providing a "contract Year" for partial years >= 6 months)
			for(integer loopCount=0; loopCount<NumberofContractYears; loopCount++)
			{
				//make the basic CY shell
				Contract_Year__c CYtoInsert = new Contract_Year__c(
					LOA__c = newloa.Id,
					Program__c = newloa.Program__c,
					Program_Family__c = newloa.Program_Family__c,
					Name = 	mainAccount.Name + '-' + newloa.Program__c + '-' 
				);
				
				//need to branch the OCntract Year creation logic depending if the sale is a consulting/sponsorship/RPT sale  OR an LC sale
				if(newloa.RecordTypeId == '01230000000DMc7' || newloa.RecordTypeId == '01230000000DMc2' || newloa.Program__c == 'RPT')
				{
					if(newloa.Program__c == 'ECS')
					{
						CYtoInsert.Division__c = 'ECS';
					} else 
					{
						CYtoInsert.Division__c = 'Other';
					}
					CYtoInsert.Type__c = 'New';
					CYtoInsert.AV__c = newloa.Amount__c;
					CYtoInsert.Recognition_Date__c = newloa.Recognition_Date__c;
					CYtoInsert.Start_Date__c = newloa.Recognition_Date__c;
					CYtoInsert.End_Date__c = newloa.Recognition_Date__c;
					CYtoInsert.Name = CYtoInsert.Name + newloa.Recognition_Date__c.month() + '/' + newloa.Recognition_Date__c.year();	
				} else
				{
					CYtoInsert.Division__c = 'LC';
					// - Renewal Types are most common type, so set that as default
					CYtoInsert.Type__c = 'Renewal';
					// - the best approximation of value is the 'average yearly contract value: Amount / Length' (except in cases where we round the contract
					// length up or down, in which case our total CY value would be too little or too much - but we adjust for this below)
					 //note: every CY end date is recognized in 12 month increments based on the original Start Date, with some handling for partials at the end            		
					if(newloa.Contract_Length__c < 1)
					{
						CYtoInsert.AV__c = newloa.Amount__c;
					} else 
					{
						CYtoInsert.AV__c = newloa.Amount__c / newloa.Contract_Length__c;
					}
					if(loopCount == 0)		
					{
						//if this is the first year of a "New" type sale, we count the Contract value as "new" - goes in the "New" column of the AV dashboard)
						if(newloa.Type__c == 'New')
						{
							CYtoInsert.Type__c = 'New';
						}
						//name of the first year CY contains the original recognition date
						CYtoInsert.Name = CYtoInsert.Name + newloa.Recognition_Date__c.month() + '/' + newloa.Recognition_Date__c.year();
						//dates are all pretty straight forward on Year 1
						CYtoInsert.Recognition_Date__c = newloa.Recognition_Date__c;
						CYtoInsert.Start_Date__c = newloa.Start_date__c;
						CYtoInsert.End_Date__c = newloa.Start_Date__c.addYears(1);									 
					} else
					{
						CYtoInsert.Recognition_Date__c = newloa.Start_date__c.addYears(loopCount);
						CYtoInsert.Start_Date__c = newloa.Start_date__c.addYears(loopCount);
						CYtoInsert.End_Date__c = newloa.Start_Date__c.addYears(loopCount+1);
						//the name contains the CY 'recognition date', which is based on the LOA start date 
						CYtoInsert.Name = CYtoInsert.Name + newloa.Start_date__c.addYears(loopCount).month() + '/' + newloa.Start_date__c.addYears(loopCount).year();
					}
					//for the last CY of all LOAs, we need to adjust 2 things to account for discrepancies w/partial year LOAs 
					if(loopCount == NumberofContractYears - 1)
					{
						//make sure we 1) shorten the End Date on partial LOAs that were rounded up, or 
						//2) extend the End Date on LOAs rounded down, or 
						//3) if the contract was less than a year
						CYtoInsert.End_Date__c = newloa.End_date__c;
						//make sure we attribute the prorated LOA value in the last year for partial LOAs that were rounded up
						if(newloa.Contract_Length__c > 1 && newloa.Contract_Length__c  < NumberofContractYears)
						{
							//2.5 yrs @ 20,000 => (3 Contract Years)  
							//YR1: 8,000
							//YR2: 8,000
							//YR3: (20,000 - (8,000*2))= 4,000
							CYtoInsert.AV__c = ( newloa.Amount__c - (CYtoInsert.AV__c * loopCount));
						} else if (newloa.Contract_Length__c > 1)
						{
							CYtoInsert.AV__c = CYtoInsert.AV__c + ( newloa.Amount__c - (CYtoInsert.AV__c * NumberofContractYears));
						}
					}
				}
				CYstoInsert.add(CYtoInsert); 
			}
		}					
	}
	
	if(!updateChildAccts.isEmpty())
	{
		update updateChildAccts;	
	}	

    if(!followupProjects.isEmpty()) 
    {
        insert followupProjects;   
    }	
    
    if(!updateProjects.isEmpty()) 
    {
        update updateProjects;   
    }	

    if(!membershipsToUpdate.isEmpty()) 
    {
        update membershipsToUpdate;   
    }

    if(!CYstoInsert.isEmpty())
	{
		insert CYstoInsert;
		for(Contract_Year__c cy: CYstoInsert)
		{
			if(cy.Division__c == 'LC')
			{
				Contract_Year_tools.linkCY(cy.id);
			}
		}			
	}		        		
}