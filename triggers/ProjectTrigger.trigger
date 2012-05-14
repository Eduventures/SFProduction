trigger ProjectTrigger on Projects__c (after update) {
	if(Trigger.isAfter)
	{		
		//Make a set of Project Ids from the trigger
		Map<String, Projects__c> projectsMap = new Map<String, Projects__c>();
    	
    	//set a flag to indicate if any of the subprojects need to be updated (start false)
    	boolean test = false;
    	
    	//create a map of all Projects being updated, in order to make the query for subprojects more efficient (one query instead of a loop)
    	for (Projects__c p : Trigger.new)
        projectsMap.put(p.Id, p);
        
        //get all the possible subprojects that could need to be updated, store them in a list
        List <Projects__c> subProjects = [select Id, Stage__c, Master_Project__c from Projects__c where Master_Project__c in :projectsMap.KeySet()];
        List <Projects__c> subProjectsToUpdate = new List <Projects__c> ();
        
        //create a list for storing Opportunities we might need to update (if we're changing project call dates
        List <Opportunity> renewalOpportunities = new List <Opportunity> ();
        
        List <ProjectMember__c> projectMembersToInsert = new List <ProjectMember__c> ();
        
        //loop through all the projects being updated
		for(Integer i = 0; i < Trigger.new.size(); i++)
    	{
    		Projects__c newProject = Trigger.new[i];    		
    		Projects__c oldProject = Trigger.old[i];
    		
    		//this section tests if the project being updated is a Call type. If so, we'll need to update the Renewal Opportunity
    		//if the call date is being set or changed
    		
    		//First: check for a call type
    		if(newProject.Product__c == 'OBC' || newProject.Product__c == 'MYC')
    		{
    			//then see if the call date was changed from Blank to something
    			if(oldProject.Call_Scheduled_Time__c == null && newProject.Call_Scheduled_Time__c != null)
    			{
    				//see if there are any renewal opps associated with this Project's LOA
    				if( [ select count() from Opportunity where Original_LOA__c = :newProject.LOA__c] != 0)
    				{
    					//if there is an Opportnity for this Project's LOA, then set the Date field according to what type this project is
    					Opportunity currentOpp = [select On_Board_Call__c, 	Mid_Year_Call__c from Opportunity where Original_LOA__c = :newProject.LOA__c];
    					
    					//if this project is an On Board call - refresh the "on Board Call" field of the Opportunity
    					if(newProject.Product__c == 'OBC')
    					{
    						currentOpp.On_Board_Call__c = newProject.Call_Scheduled_Time__c;
    						renewalOpportunities.add(currentOpp);
    					}
    					//if this project is an Mid Year call - refresh the "MYC Call" field of the Opportunity
    					else if(newProject.Product__c == 'MYC')
    					{
    						currentOpp.Mid_Year_Call__c = newProject.Call_Scheduled_Time__c;
    						renewalOpportunities.add(currentOpp);
    					}
    				}
    			}
    			//and check if the date was set but changed to a new date 
    			else if ( (oldProject.Call_Scheduled_Time__c != null) && (oldProject.Call_Scheduled_Time__c != newProject.Call_Scheduled_Time__c) )
    			{
    				//see if there are any renewal opps associated with this Project's LOA
    				if( [ select count() from Opportunity where Original_LOA__c = :newProject.LOA__c] != 0)
    				{
    					//if there is an Opportnity for this Project's LOA, then set the Date field according to what type this project is
    					Opportunity currentOpp = [select On_Board_Call__c, 	Mid_Year_Call__c from Opportunity where Original_LOA__c = :newProject.LOA__c];
    					
    					//if this project is an On Board call - refresh the "on Board Call" field of the Opportunity
    					if(newProject.Product__c == 'OBC')
    					{
    						currentOpp.On_Board_Call__c = newProject.Call_Scheduled_Time__c;
    						renewalOpportunities.add(currentOpp);
    					}
    					//if this project is an Mid Year call - refresh the "MYC Call" field of the Opportunity
    					else if(newProject.Product__c == 'MYC')
    					{
    						currentOpp.Mid_Year_Call__c = newProject.Call_Scheduled_Time__c;
    						renewalOpportunities.add(currentOpp);
    					}
    				}    				
    			}
    			
    		}
    		
    		//Code to make sure new Project Managers can book hours to a project without adding themselves as a memebr
    		//added 10/19/2011 by AJD on Cara Quackenbush's request
    		if(oldProject.Project_Manager__c != newProject.Project_Manager__c)
    		{
    			if( [SELECT count() FROM ProjectMember__c WHERE UserId__c = :newProject.Project_Manager__c AND ProjectId__c = :newProject.Id] == 0)
    			{
					for(User usr :[ SELECT Id, Name, Email, Phone from User WHERE Id = :newProject.Project_Manager__c])
					{
		                ProjectMember__c projMem = new ProjectMember__c();
	                    projMem.UserId__c = usr.Id;
	                    projMem.Name = usr.Name;
	                    projMem.ProjectId__c = newProject.Id;
	                    projectMembersToInsert.add(projMem);							
					}							
    			}    			
    		}
    		
    	}
    	
    	//Code to synchronize the stage of master projects and their subprojects
	    integer subProjArraySize = subProjects.size();
    	for(Integer j=0; j<subProjArraySize; j++)
    	{
    		Projects__c tempMaster = projectsMap.get(subProjects[j].Master_Project__c);
			if(subProjects[j].Stage__c != tempMaster.Stage__c)
			{
				test = true;
				subProjects[j].Stage__c = tempMaster.Stage__c;
				subProjectsToUpdate.add(subProjects[j]);
			}	
    	}
    	if(subProjectsToUpdate != null && test == true  )
    	{
    		update subProjectsToUpdate;
    	}
    	
    	if (renewalOpportunities != null)
    	{
	    	update renewalOpportunities;    		
    	}

	    if( projectMembersToInsert != null)
	    {
	    	insert projectMembersToInsert;
	    }
	}

}