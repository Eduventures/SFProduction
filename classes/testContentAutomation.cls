@isTest
private class testContentAutomation { 
    public static testMethod void testingContentAutomation () {
    	Projects__c testProject = [ SELECT Id, LOA__c, Account__c, Programs__c, Stage__c, RecordTypeId FROM Projects__c 
    								WHERE LOA__c != null and Account__c != null and RecordTypeId = '01230000000DMZcAAO' LIMIT 1 ];
 		ContentVersion testInsert = new ContentVersion(
 			ContentUrl = 'www.eduventures.com',
 			RecordTypeId = '01280000000HfBCAA0', //'research deliverable'  content type
 			Title = 'test insert',
 			OwnerId = '00530000000vxt9',  // User : Alfred Dellicicchi
 			FirstPublishLocationID = '05880000000TQUC',
 			Project__c = testProject.Id
 		);		
 		           
	    try
	    {    
	    	//insert testInsert;
        	Database.Saveresult insertsaveResult = Database.insert(testInsert, false);
 			System.assert(insertsaveResult.getId() != null, 'Failed to insert ContentVersion test.');
 			ContentVersion insertedContent = [SELECT Id from ContentVersion where Id = :insertsaveResult.getId()];
 			insertedContent.Account__c = null;
 			insertedContent.LOA__c = null;
 			insertedContent.Primary_Author__c = null;
 			update insertedContent;
	    }
	    catch (System.DmlException e) 
	    {
	    	System.debug('Failed to run testingContentAutomation: '+ e.getMessage());
	    } 
	       
    } 

}