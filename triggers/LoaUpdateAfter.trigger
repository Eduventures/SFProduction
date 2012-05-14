trigger LoaUpdateAfter on LOA__c (after update) { 

    List<Task> followupTasks = new List<Task>(); // 
	//List<Account> updatingAccts = new List<Account>();
	List<Id> membershipsToUpdateIds =  new List<Id>();
	List<Membership__c> membershipsToUpdate =  new List<Membership__c>();				
	List<Opportunity> updatingOpps = new List<Opportunity>();
	List<Opportunity> deletingOpps = new List<Opportunity>();	
	Map<String, LOA__c> loasMap = new Map<String, LOA__c>();
    
	List<Id> acctMgrIds = new List<Id>();
    for (LOA__C l : Trigger.new)
    {
    	loasMap.put(l.Account__c , l);
    	if(l.Research_Account_Manager__c != null)
    	{
    		acctMgrIds.add(l.Research_Account_Manager__c);
    	}
    }        
	Map<Id, User> acctMgrsMap = new Map<Id, User>();
	for( User u: [SELECT Id, Name, Email, Phone from User WHERE Id in :acctMgrIds])
	{
		acctMgrsMap.put(u.Id,u);
	}	
    
	//Query the Account data for this LOA for later updating, must query the value for any fields that we use or update (even if we just assign a value) 
	List<Account> accts = new List<Account> ([Select Id, name, Active_Engagements__c, ALMemberDt__c, ALAnniversaryDt__c, CPEMemberDt__c, CPEAnniversary_Date__c,
						DEVMemberDt__c, DEVAnniversaryDate__c, EMMemberDt__c, EMAnniversaryDate__c, Do_not_publish__c, 
						ECSMemberDt__c, OHEMemberDt__c, OHEAnniversaryDate__c, SOEMemberDt__c, SOEAnniversaryDt__c 
						from Account where Id in :loasMap.KeySet()]);  	//loop through each new trigger item
	
	Map<Id, Account> acctMap = new Map<Id, Account>();
    for (Account a : accts)
        acctMap.put(a.Id , a);						
        
	Map<Id, List<Projects__c>> projectsMap = new Map<Id, List<Projects__c>>();	
	//Query the project data for the LOAs if later updating or parsing is required 
	//I'll store them in a sub map, 						
	for(Projects__c p: [SELECT Id, Product__c, Default_Call_Date__c, Account__c, LOA__c, Programs__c, Name, (Select UserId__c From Project_Members__r) from Projects__c 
							WHERE Product__c in ('ACCT MGMT','OBC','MYC') AND LOA__c in :Trigger.newMap.KeySet() order by Product__c,Default_Call_Date__c])
	{
		if(projectsMap.containsKey(p.LOA__c))
		{
			projectsMap.get(p.LOA__c).add(p);
		} else 
		{
			List<Projects__c> tempList = new List<Projects__c>();
			tempList.add(p);
			projectsMap.put(p.LOA__c,tempList);
		}	
	}	
	List <ProjectMember__c> projectMembersToInsert = new List <ProjectMember__c> ();
	List <Projects__c> projectToInsert = new List <Projects__c> ();
	List <Projects__c> projectToUpdate = new List <Projects__c> ();
	List <Projects__c> projectToDelete = new List <Projects__c> ();	
	
	Map<Id, Opportunity> oppsMap = new Map<Id, Opportunity>();
	for(Opportunity opp: [select id, Original_LOA_Expiration_Date__c, Original_LOA__c, Original_LOA_Status__c, NextStep from Opportunity 
                        where Original_LOA__c in :Trigger.newMap.KeySet()])
    {
    	oppsMap.put(opp.Original_LOA__c,opp);
    }		
	for(Integer n = 0; n < Trigger.new.size(); n++)  
	{
		//name the new item, for ease of use
		LOA__c l = Trigger.new[n];
		LOA__c oldLoa = Trigger.old[n];
		
        Account mainAccount = acctMap.get(l.Account__c);
		Boolean updateMainAcct = false;
		
        //begin logic for After Update trigger	
        if(l.RecordTypeId == '01230000000DMbx')
        {    	            
			
            if( l.Research_Account_Manager__c != null && oldLoa.Research_Account_Manager__c  != l.Research_Account_Manager__c )
            {
                User usr = acctMgrsMap.get(l.Research_Account_Manager__c);
                if(projectsMap.containsKey(l.id))
                {
	                for(Projects__c p: projectsMap.get(l.Id))
	                {
	                	Boolean doesntExist = true;
		                for(ProjectMember__c pm : p.Project_Members__r)
		                {
		                	if(pm.UserId__c ==  usr.Id)
		                	{
		                		doesntExist = false;
		                	}
		                }
		                if(doesntExist)
		                {
		                	ProjectMember__c projMem = new ProjectMember__c();
	                    	projMem.UserId__c = usr.Id;
	                    	projMem.Name = usr.Name;
	                    	projMem.ProjectId__c = p.Id;
	                    	projectMembersToInsert.add(projMem);
		                }								
	                }
                }
            }

            //If the LOA is set to "replaced" status then...
            if(Trigger.old[n].Replaced__c == false && l.Replaced__c == true)
            {
                if(oppsMap.containsKey(l.Id))
                {
                	Opportunity temp = oppsMap.get(l.Id);
					deletingOpps.add(temp);
				}	
            }
            
            //begin section to make sure Memebrship data is kept synchronized during LOA updates
            //(in cases where an LOA is input for the wrong dates, or modified later on due to contract changs)
            if(  (l.Start_Date__c != null && (l.Start_Date__c != oldLoa.Start_Date__c)) 
            		|| (l.End_Date__c != null && (l.End_Date__c != oldLoa.End_Date__c))
            		||  (l.Extension_Date__c != oldloa.Extension_Date__c )  )
            {
                membershipsToUpdateIds.add(l.Membership__c);
                String programFamily = l.Program_Family__c;
            	//...see if there are any outstanding renewal opportunities for this LOA...
                if(oppsMap.containsKey(l.Id))
                {        
                	Opportunity temp = oppsMap.get(l.Id);     
                    //..and update them as well, so that Renewal reports based on Opportunities are in sync with LOAs.
                    temp.Original_LOA_Expiration_Date__c = l.End_Date__c;
                    temp.Original_LOA_Status__c = l.status__c;																
                    updatingOpps.add(temp);
				}
	            //if we change the start or end date - the system should automaticlaly add or remove mid year calls as needed,
	            // and reschedule the on boarding/midyear calls accordingly 
	            List<Projects__c> tempProjectList = new List<Projects__c>();
	            if(projectsMap.containsKey(l.Id))
	            {
	            	tempProjectList.addAll(projectsMap.get(l.Id));
	            }
	            if( (l.Start_Date__c != oldLoa.Start_Date__c) || (l.End_Date__c != oldLoa.End_Date__c))
	            {
	            	Double numMYCprojects = math.floor(l.Contract_Length__c);
	            	Integer countMYCprojects = 0;
	            	for(Projects__c p : tempProjectList)
	            	{
	            		if(p.Product__c == 'MYC')
	            		{
	            			//if the start date changes, we should increment the MYC dates by the differnece in days between the old and new start dates
	            			p.Default_Call_Date__c = p.Default_Call_Date__c + oldLoa.Start_Date__c.daysBetween(l.Start_Date__c);
	            			if(p.Default_Call_Date__c > l.End_Date__c)
	            			{
	            				//if bumping the myc projects puts any past the new end date of the LOA, delete them (this covers the case where we modify both the loa start and end date at the same time)
	            				//this check will also catch if any existing MYC projects are beyond the new end date (i.e. if just end date changed), regardless of whether the start date changed
	            				projectToDelete.add(p);
	            			}
	            			countMYCprojects = countMYCprojects +1;
	            		}
	            		if(p.Product__c == 'OBC' && (l.Start_Date__c != oldLoa.Start_Date__c))
	            		{
	            			//if the start date changes we have to update the OBC
	            			p.Default_Call_Date__c = l.Start_Date__c + 30;
	            		}		
	            	}
	            	for(integer i=countMYCprojects;i<(numMYCprojects);i++)
	            	{
	            		//add any missing mid year calls, based on the number of existing MYC projects for this LOA and the total number of MYCs 
	            		//required by the new contract length (if it increased)
						Projects__c midYearCall = new Projects__c(
						   	Name = l.Program__c + '-MYC'+(i+1)+'-' + mainAccount.name,
							Account__c = l.Account__c,
							Default_Call_Date__c = l.Start_Date__c + 180 + (i*365),
							RecordTypeId = '01280000000EKNA', 
							LOA__c = l.id,
							Programs__c = l.Program_Family__c,
							Product__c = 'MYC',
							Active__c = true,
							Stage__c = 'Not Started',
							Description__c = 'This is a Mid Year Call that is automatically created by the system when an LOA is created.',
							Membership__c = l.Membership__c);								
						projectToInsert.add(midYearCall);	
	            	}
	            	projectToUpdate.addAll(tempProjectList);
	                //If the Expiration Date of an LOA changes then...
		            if(l.End_Date__c != null && (l.End_Date__c != oldLoa.End_Date__c) )
		            {		                							
		                //make sure to update the Account anniversary field
		                if(l.Program__c =='ACL' || l.Program__c =='ACL-RL' )
		                {
		                    mainAccount.ALAnniversaryDt__c = l.End_Date__c;				 
		                }
		                else if(l.Program__c =='AIE' || l.Program__c =='AIE-RL' )
		                {
		                    mainAccount.AIEMemberDt__c = l.End_Date__c;				 
		                }
		                else if(l.Program__c =='CPE'  || l.Program__c =='CPE-RL')
		                {
		                    mainAccount.CPEAnniversary_Date__c = l.End_Date__c;
		                }
		                else if(l.Program__c =='DEV'  || l.Program__c =='DEV-RL' )
		                {
		                    mainAccount.DEVAnniversaryDate__c = l.End_Date__c;
		                }
		                else if(l.Program__c =='ENM'  || l.Program__c =='ENM-RL' || l.Program__c =='SEM')
		                {
		                    mainAccount.EMAnniversaryDate__c = l.End_Date__c;					
		                }
		                else if(l.Program__c =='OHE'  || l.Program__c =='OHE-RL')
		                {
		                    mainAccount.OHEAnniversaryDate__c = l.End_Date__c;
		                }
		                else if(l.Program__c =='STA'  || l.Program__c =='STA-RL')
		                {
		                    mainAccount.SAAnniversary_Date__c = l.End_Date__c;
		                }
		                else if(l.Program__c =='SOE'  || l.Program__c =='SOE-RL')
		                {
		                    mainAccount.SOEAnniversaryDt__c = l.End_Date__c;
		                }
		                else if(l.Program__c =='SUM'  || l.Program__c =='SUM-RL')
		                {
		                    mainAccount.SUMAnniversaryDate__c = l.End_Date__c; 
		                }
			            //refresh Account's "do not publish" info if it's changed at the LOA level
			            if(l.Do_not_publish__c != oldloa.Do_not_publish__c)
			            {
			                mainAccount.Do_not_publish__c = l.Do_not_publish__c;
			            }		                         
		            }	            	
	            }
            }
            if(l.Status__c == 'Active' || l.Status__c == 'Pending')
            {
            	if(oldLoa.Status__c != l.Status__c || oldLoa.Website_Access__c != l.Website_Access__c || 
            		oldLoa.Strategy_Session_Access__c != l.Strategy_Session_Access__c || oldLoa.AMM_Pass_Count__c != l.AMM_Pass_Count__c ||
        			oldLoa.Member_Roundtable_Access__c != l.Member_Roundtable_Access__c || oldLoa.Custom_Analysis_Limit__c != l.Custom_Analysis_Limit__c)
	        	{
	        		membershipsToUpdateIds.add(l.Membership__c);	
	        	}
            }	           
        }	
	}

	if(!membershipsToUpdateIds.isEmpty())
	{
		for(Membership__c m: [ Select Id FROM Membership__c where Id in :membershipsToUpdateIds])
		{
			membershipsToUpdate.add(m);
		}
		update membershipsToUpdate;	
	}

	if(!updatingOpps.isEmpty())
	{
		update updatingOpps;	
	}
	if(!deletingOpps.isEmpty())
	{
		delete deletingOpps;	
	}
		
	if(followupTasks != null) 
    {
        insert followupTasks;   
    }
    if( projectMembersToInsert != null)
    {
    	insert projectMembersToInsert;
    }

	if(!projectToInsert.isEmpty()) 
    {
        insert projectToInsert;   
    }
    if(!projectToUpdate.isEmpty()) 
    {
        update projectToUpdate;   
    }
    if(!projectToDelete.isEmpty())
	{
		delete projectToDelete;	
	}			
}