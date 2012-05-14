trigger CaseUpdate on Case (after update) {

	for(Integer i = 0; i < Trigger.new.size(); i++)
	{
		Case nw = Trigger.new[i];
		
		if(nw.RecordTypeId == '01230000000DxP0')
		{
			if(nw.Status =='Closed' )
			{
				string requestor = [select Name from User where Id = :nw.CreatedById ].name;  
				string closedBy = [select Name from User where Id = :nw.LastModifiedById].name;
				string cName = [select Name from Contact where Id = :nw.ContactId ].name; 
				Task salesNote = new Task(
						OwnerId = nw.CreatedById ,
						WhatId = nw.Id,
						WhoId = nw.ContactId, 
						ActivityDate = System.today(), 
						Description = nw.Program__c + ' sales packet was sent to ' + cName 
							+ ' by ' +  closedBy , 
					    Priority = 'Normal', 
					    Status = 'Completed',
					    Type = 'Sales Packet Sent', 
					    Subject = nw.Program__c + ' sales packet sent per ' + requestor + '\'s request');
					    
				insert salesNote;	
			}
			
		}
	}
}