trigger LoaUpdateBefore on LOA__c (before update) {

    List<Task> followupTasks = new List<Task>(); // build list in memory
     						
	for(Integer n = 0; n < Trigger.new.size(); n++)  
	{
		//name the new item, for ease of use
		LOA__c newloa = Trigger.new[n];
		LOA__c oldloa = Trigger.old[n];
		
		//begin logic for Before Update trigger

				if(Trigger.IsUpdate && Trigger.IsBefore && newloa.RecordTypeId == '01230000000DMbx')
				{
					String currenttime = (System.today()).format();
					if( (oldloa.Extension_Date__c == null) && (newloa.Extension_Date__c != oldloa.Extension_Date__c))
					{
						Task task = new Task(
							OwnerId = '00530000000vxt9',
							WhatId = newloa.Id,
							ActivityDate = System.today(), 
							Description = '\'Extension Date\' set to ' + newloa.Extension_Date__c.format(), 
						    Priority = 'High', 
						    ReminderDateTime = System.now(), 
						    Status = 'Completed',
						    Type = 'Other', 
						    Subject = ' Extenstion Date set');
						    
						    followupTasks.add(task);	
					}
					else if( (oldloa.Extension_Date__c != null) && (newloa.Extension_Date__c != oldloa.Extension_Date__c))
					{
	    					String newExpDate ='';
	    					//add a note to say extension was extended again
							String previoustime = (oldloa.Extension_Date__c).format();
							if(newloa.Extension_Date__c != null)
							{
								newExpDate = newloa.Extension_Date__c.format();
							}
							else
							{
								newExpDate = 'blank (deleted)';	
							}

							Task task = new Task(
								OwnerId = '00530000000vxt9',
								WhatId = newloa.Id,
								ActivityDate = System.today(), 
								Description = 'Changed the \'Extension Date\' from: ' + previoustime + ' to ' + newExpDate, 
							    Priority = 'High', 
							    ReminderDateTime = System.now(), 
							    Status = 'Completed',
							    Type = 'Other', 
							    Subject = ' Extenstion Date changed');
							    
							    followupTasks.add(task);	
					}

					newloa.time_workflow_switch__c = false; 
				}	
	}
	
	
	if(followupTasks != null) 
    {
        insert followupTasks;   
    }

}