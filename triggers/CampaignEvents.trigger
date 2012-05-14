trigger CampaignEvents on Campaign ( before insert, after insert, after update, before delete) {

    List<Event> events2Create = new List<Event>();
    List<Event> events2update = new List<Event>();
    List<Event> events2delete = new List<Event>();
    
    //01280000000HefQ - production RTID
    //012T00000000UfM - sandbox RTID
    //02380000000o01m - marketing Calendar Id       
         
    if(trigger.isInsert)
    {
    	if(trigger.isBefore)
    	{
	        for(Campaign c : trigger.new)
	        {
	        	if(c.Calendar_Name__c == null || c.Calendar_Name__c == '')
	        	{
	        		c.Calendar_Name__c = c.Name;
	        	}
	        }	
    	}
    	
    	if(trigger.isAfter)
    	{
	        for(Campaign c : trigger.new)
	        {
	            if(c.Display_on_Marketing_Calendar__c == true)
	            {
	                if(c.StartDate == null || c.EndDate == null) 
	                {
	                    c.addError('If you wish to display a campaign on the Marketing Calendar,' + 
	                    ' you need to set a Start and End date. And the length of the Campaign can\'t' + 
	                    ' be more than 14 days.');                  
	                } else if ( c.StartDate.daysBetween(c.EndDate) > 14 )
	                {
	                    c.addError('If you wish to display a campaign on the Marketing Calendar,' + 
	                    ' the length of the Campaign can\'t be more than 14 days.');
	                } else 
	                {
	                    String tempDesc = '';
	                    if(c.Description != null)
	                    {
	                        tempDesc = c.Description;
	                    } 
                        String tempSubject = '';
	                    if(c.Program__c != null)
	                    {
	                        tempSubject = c.Program__c + ':'+ c.Type + ':' + c.Calendar_Name__c;
	                    } else
	                    {
	                    	tempSubject = c.Type + ':' + c.Calendar_Name__c;
	                    }                        	                                   
	                    Event temp = new Event ( OwnerId = '02380000000o01m', 
	                                         ShowAs = 'Free',
	                                         WhatId = C.Id,
	                                         IsAllDayEvent = true,
	                                         Subject = tempSubject,
	                                         Description = tempDesc,
	                                         Type = 'Marketing Campaign',
	                                         StartDateTime = c.StartDate, 
	                                         EndDateTime = c.EndDate, 
	                                         RecordTypeId = '01280000000HefQ');
	                    events2Create.add(temp);
	                }
	            }
	        }     		
    	}    	
     
    }
    
    if(trigger.isUpdate)
    {
    	
        Map<Id,Campaign> campaignMapUpdate = new Map<Id,Campaign> ();
        Map<Id,Id> campaignMapDelete = new Map<Id,Id> ();
        List<Event> eventUpdates = new List<Event>();
        List<Event> eventDeletes = new List<Event>();
        
        for(integer i = 0; i <trigger.new.size(); i++)
        {
            Campaign cOld = trigger.old[i]; 
            Campaign cNew = trigger.new[i];
            if(cNew.Display_on_Marketing_Calendar__c == true)
            {
                if(cOld.Display_on_Marketing_Calendar__c == false)    
                {
                    if(cNew.StartDate == null || cNew.EndDate == null) 
                    {
                        cNew.addError('If you wish to display a campaign on the Marketing Calendar,' + 
                        ' you need to set a Start and End date. And the length of the Campaign can\'t' + 
                        ' be more than 14 days.');                  
                    } else if ( cNew.StartDate.daysBetween(cNew.EndDate) > 14 )
                    {
                        cNew.addError('If you wish to display a campaign on the Marketing Calendar,' + 
                        ' the length of the Campaign can\'t be more than 14 days.');
                    } else 
                    {
                        String tempDesc = '';
                        if(cNew.Description != null)
                        {
                            tempDesc = cNew.Description;
                        }  

                        String tempSubject = '';
	                    if(cNew.Program__c != null)
	                    {
	                        tempSubject = cNew.Program__c + ':'+ cNew.Type + ':' + cNew.Calendar_Name__c;
	                    } else
	                    {
	                    	tempSubject = cNew.Type + ':' + cNew.Calendar_Name__c;
	                    }                                   
                        Event temp = new Event ( OwnerId = '02380000000o01m', 
                                             ShowAs = 'Free',
                                             WhatId = cNew.Id,
                                             IsAllDayEvent = true,
                                             Subject = tempSubject,
                                             Description = tempDesc,
                                             Type = 'Marketing Campaign',
                                             StartDateTime = cNew.StartDate, 
                                             EndDateTime = cNew.EndDate, 
                                             RecordTypeId = '01280000000HefQ');
                        events2Create.add(temp);
                    }                   
                } else if ( (cOld.StartDate != cNew.StartDate) || 
                            (cOld.EndDate != cNew.EndDate) || 
                            (cOld.Name != cNew.Name) ||
                            (cOld.Type != cNew.Type) ||
                            (cOld.Calendar_Name__c != cNew.Calendar_Name__c) )
                {
                	if(cNew.StartDate == null || cNew.EndDate == null) 
                    {
                        cNew.addError('If you wish to display a campaign on the Marketing Calendar,' + 
                        ' you need to set a Start and End date. And the length of the Campaign can\'t' + 
                        ' be more than 14 days.');  
                    } else if( cNew.StartDate.daysBetween(cNew.EndDate) > 14 )
                    {
                        cNew.addError('If you wish to display a campaign on the Marketing Calendar,' + 
                        ' the length of the Campaign can\'t be more than 14 days.');
                    } else 
                    {
                		campaignMapUpdate.put(cNew.Id, cNew);
                    }
                }
            } else if ( cOld.Display_on_Marketing_Calendar__c == true)
            {
                //push to delete map
                campaignMapDelete.put(cNew.Id,cNew.Id);                
            }            
        }
        
        //process campaignMapUpdate
        List<Event> updateEvents = [SELECT e.WhatId, e.Type, e.Subject, e.StartDateTime, e.RecordTypeId, 
                                    e.Program__c, e.EndDateTime, e.Description From Event e 
                                    WHERE e.WhatId in :campaignMapUpdate.keySet() and
                                         RecordTypeId = '01280000000HefQ'];
        
        for(Event e: updateEvents)
        {
            Campaign c = campaignMapUpdate.get(e.WhatId);
            e.Type = c.Type;        
            e.Subject = c.Program__c + ':'+ c.Type + ':' + c.Calendar_Name__c; 
            e.StartDateTime = c.StartDate;
            e.Program__c = c.Program__c;
            e.EndDateTime = c.EndDate;
            e.Description = c.Description;
            events2update.add(e);
        }
        //process campaignMapDelete
        List<Event> deleteEvents = [SELECT e.WhatId, e.Type, e.Subject, e.StartDateTime, e.RecordTypeId, 
                                    e.Program__c, e.EndDateTime, e.Description From Event e 
                                    WHERE e.WhatId in :campaignMapDelete.values() and
                                         RecordTypeId = '01280000000HefQ'];
        events2delete.addAll(deleteEvents);  
    }
    
    if(trigger.isDelete)
    {
        Map<Id,Id> campaignDeleteMap = new Map<Id,Id> ();
        for(Campaign c : trigger.old)
        {
            campaignDeleteMap.put(c.Id,c.Id);
        }
        
        List<Event> eventDelete = [ select Id, OwnerId, WhatId from Event where WhatId in :campaignDeleteMap.keySet() 
                                    and OwnerId ='02380000000o01m' and RecordTypeId = '01280000000HefQ'];
        if(!eventDelete.isEmpty())
        {
            events2delete.addAll(eventDelete);
        }                 
    }   

    if(!events2Create.isEmpty())
    {
        insert events2Create;
    }
    if(!events2update.isEmpty())
    {
        update events2update;
    }
    if(!events2delete.isEmpty())
    {
        delete events2delete;
    }
}