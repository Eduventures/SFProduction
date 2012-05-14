global class ContentBatch implements Schedulable, Database.Batchable <sobject> 
{
    
    global List<contentversion> failedContent = new List<contentversion>();
    
    global void execute(SchedulableContext SC) {
        ContentBatch contentBatch = new ContentBatch();
        ID batchprocessid = Database.executeBatch(contentBatch);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT id, recordtype.name
                                      FROM ContentVersion
                                      WHERE isLatest = true
                                      AND recordtype.name != ''
                                      AND content_type_name__c = '']);
    }
    
    global void execute(Database.BatchableContext BC, List<sobject> batch)
    {

        List<contentversion> contentList = (List<contentversion>)batch;
       
        Set<id> recordConnectionIds = new Set<id>();
        for (ContentVersion contentRecord : contentList)
        {
            contentRecord.content_type_name__c = contentRecord.recordtype.name;         
        }
        
        Database.SaveResult[] dbResults = Database.update(contentList,false);
    
        // send failed updates via email to job submitter.
        String emailSubject = 'Content Batch Errors';
        String emailBody = '';
        Boolean sendEmail = false;
         
        for (Database.SaveResult dbResult : dbResults)
        {
            if (!dbResult.isSuccess()) 
            {
                Database.Error err = dbResult.getErrors()[0];
                emailBody += '\n' + 'id=' + dbResult.getId() + ' Error: ' + err.getMessage();
                sendEmail = true;
            }
        }
         
        if (sendEmail)
        {
          
            AsyncApexJob apexJob = [Select Id, Status, NumberOfErrors, JobItemsProcessed,
                                TotalJobItems, CreatedBy.Email
                               from AsyncApexJob where Id =:BC.getJobId()];
            // send an email out with results.
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {apexJob.CreatedBy.Email};
            mail.setToAddresses(toAddresses);
            mail.setSubject(emailSubject);
            mail.setPlainTextBody(emailBody);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
          
        } 
    }
    
    global void finish(Database.BatchableContext BC) {
    }
    
    @isTest
    public static void testBatch() 
    {
        ContentBatch testContentBatch = new ContentBatch();
        Database.executeBatch(testContentBatch);
       
        // Schedule the batch for hourly run
        String sch = '0 0 * * * ?';
        system.schedule('Content Hourly batch',sch,testContentBatch);
     
    }
}