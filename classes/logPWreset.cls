/**
 * Email services are automated processes that use Apex classes
 * to process the contents, headers, and attachments of inbound
 * email.
 */
global class logPWreset implements Messaging.InboundEmailHandler {

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {

    // Create an inboundEmailResult object for returning 
    // the result of the Force.com Email Service
    Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
    String addr = '';
    String username = '';
    
    try
    {
        addr = email.plainTextBody.substring(email.plainTextBody.indexOf('<email>')+7, email.plainTextBody.indexOf('</email>'));
        
        Contact vCon = [Select Id, Name, Seat_Holder__c, AccountId, Email From Contact Where Email = :addr Limit 1];
  
        // Add a new Task to the contact record we just found above.
        Task temptask = new Task(
          Priority = 'Normal',
          ActivityDate = System.today(),          
          Status = 'Completed',
          Subject = email.subject,
          Description =  email.plainTextBody,
          Type = 'Website Related',
          WhatId = vCon.AccountId,
          Program__c = vCon.Seat_Holder__c,
          WhoId =  vCon.Id);

        insert temptask;
    }
    catch (System.StringException e)
    {
         System.debug('Email came from a user not in Salesforce.com!!' + e);
    }
            
    result.success = true;
        
    // Return the result for the Force.com Email Service
    return result;
    
    }
    
    static testMethod void testlogPWreset() {
    
    // Create a new email and envelope object
       Messaging.InboundEmail email = new Messaging.InboundEmail();
       Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
    
    // Create the plainTextBody and fromAddres for the test
        email.plainTextBody = 'Password was reset for adellicicchi <email>adellicicchi@eduventures.com</email>';
        email.fromAddress ='techsupport@eduventureswebsite.com';
        email.Subject = 'Password was Reset';
    
    logPWreset logObj = new logPWreset();
    logObj.handleInboundEmail(email, envelope);
    } 

}