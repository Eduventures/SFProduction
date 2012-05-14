trigger contentAutomation on ContentVersion (before insert, before update) {

	List<Id> projectIds;
	Map<ID, Projects__c> projMap;
	List<Id> ownerIds;
	List<String> ownerEmails;
	Map<String, Id> emailsToUsersMap;
	Map<Id, Id> userToContactMap;
	
	List<Id> recordtypeIds;
	Map<ID, RecordType> rtMap;
	
	if(Trigger.isBefore)
	{
		if(Trigger.isInsert)
		{
			projectIds = new List<Id>();
			ownerIds = new List<Id>();
			ownerEmails = new List<String>();
			emailsToUsersMap = new Map<String, Id>();
			userToContactMap  = new Map<Id, Id>();
			//In order to handle bulk processing, we do our querying in batches. 
			//To do so, we need to make a list of the Ids for all the projects and recordtypes that we'll be querying for more info on
			for(ContentVersion cv : Trigger.new)
			{
				if(cv.Project__c != null)
				{
					projectIds.add(cv.Project__c);
				}
				ownerIds.add(cv.OwnerId);
			}
			//make a map of all the project and recordtype info (for easier access further on)
			projMap = new Map<ID, Projects__c>([select Id, Account__c, LOA__c from Projects__c where Id in :projectIds]);

			for(User u: [SELECT Id, Email FROM User where Id in :ownerIds])
			{
				ownerEmails.add(u.Email);
				emailsToUsersMap.put(u.Email, u.Id);
			}		
			for(Contact c: [select Id, Email from Contact where Email in :ownerEmails])
			{
				userToContactMap.put(emailsToUsersMap.get(c.Email),c.Id);
			}
			//now process the new items being inserted
			for(ContentVersion cv : Trigger.new)
			{
				if(cv.Project__c != null)
				{
					//if the Project field is not empty, update Account and LOA info
					if(cv.Account__c == null)
					{
						cv.Account__c = projMap.get(cv.Project__c).Account__c;
					}
					if(cv.LOA__c == null)
					{
						cv.LOA__c = projMap.get(cv.Project__c).LOA__c;
					}					
				}
				//if the primary author field is empty, use the matching Contact record for the document creator 
				if(cv.Primary_Author__c == null)
				{
					if(userToContactMap.containsKey(cv.OwnerId))
					{
						cv.Primary_Author__c = userToContactMap.get(cv.OwnerId);
					}
				}
			}
		} else if (Trigger.isUpdate)
		{
			projectIds = new List<Id>();
			ownerIds = new List<Id>();
			ownerEmails = new List<String>();
			emailsToUsersMap = new Map<String, Id>();
			userToContactMap  = new Map<Id, Id>();
			
			recordtypeIds = new List<Id>();

			//In order to handle bulk processing, we do our querying in batches. 
			//To do so, we need to make a list of the Ids for all the projects and recordtypes that we'll be querying for more info on
			for(ContentVersion cv : Trigger.new)
			{
				recordtypeIds.add(cv.RecordTypeId);
				if(cv.Project__c != null)
				{
					projectIds.add(cv.Project__c);
				}
				ownerIds.add(cv.OwnerId);
			}
			//make a map of all the project and recordtype info (for easier access further on)
			rtMap = new Map<ID, RecordType>([ SELECT DeveloperName, Name, Id, SobjectType FROM RecordType where Id in :recordtypeIds]);
			projMap = new Map<ID, Projects__c>([select Id, Account__c, LOA__c from Projects__c where Id in :projectIds]);
			for(User u: [SELECT Id, Email FROM User where Id in :ownerIds])
			{
				ownerEmails.add(u.Email);
				emailsToUsersMap.put(u.Email, u.Id);
			}		
			for(Contact c: [select Id, Email from Contact where Email in :ownerEmails])
			{
				userToContactMap.put(emailsToUsersMap.get(c.Email),c.Id);
			}
			//now process the new items being inserted
			for(ContentVersion cv : Trigger.new)
			{
				if(cv.Project__c != null)
				{
					//if the Project field is not empty, update Account and LOA info
					if(cv.Account__c == null)
					{
						cv.Account__c = projMap.get(cv.Project__c).Account__c;
					}
					if(cv.LOA__c == null)
					{
						cv.LOA__c = projMap.get(cv.Project__c).LOA__c;
					}					
				}
				//if the primary author field is empty, use the matching Contact record for the document creator 
				if(cv.Primary_Author__c == null)
				{
					if(userToContactMap.containsKey(cv.OwnerId))
					{
						cv.Primary_Author__c = userToContactMap.get(cv.OwnerId);
					}
				}
				//fill in the 'content type name' field. This is just a duplication of the Content Type (i.e. the ContentVersion's Record Type)
				//that can be used in filtering documents (record type data is not currently exposed as a filter option in the Content tab  AJD 06/13/2011)
				if(cv.Content_Type_Name__c == null)
				{
					if(cv.RecordTypeId != null)
					{
						cv.Content_Type_Name__c = rtMap.get(cv.RecordTypeId).Name;	
					}
				}				
			}
		}
	}
}