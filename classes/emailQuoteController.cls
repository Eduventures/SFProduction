public class emailQuoteController {
    public Map<string,string> savedparams {get;set;}
    public Contact signatory { get; set;}
    public String toAddr { get; set;}
    public String ccAddr { get; set;}
    public String subject { get; set;}
    public String body { get; set;}

    public EVQuote__c theQuote { get; set;}
    public Boolean sendEnabled { get; set;}
    public Integer step { get; set;}
    public Boolean sendSuccess { get; set;}
    
    public emailQuoteController (ApexPages.StandardController stdController){
    	theQuote = (EVQuote__c)stdController.getRecord();
        init();
    }
    
    public void init() {
        savedparams = ApexPages.currentPage().getParameters();
        signatory = new Contact();
        sendEnabled = false;
        sendSuccess = false;
        toAddr  = '';
        subject = '';
        body = '';
        Id userId = UserInfo.getUserId();
        User currentUser = [ SELECT Email FROM User WHERE Id = :userId];
        ccAddr = currentUser.Email;
        step = 1;
        if(savedparams.containsKey('id'))
        {
            String qid = savedparams.get('id'); 
            //theQuote = [ SELECT Id, Status__c, Primary_Contact__c, Product_Group__c FROM EVQuote__c WHERE Id = :qid];
            signatory  = [ SELECT Email, Name FROM Contact WHERE Id = :theQuote.Primary_Contact__c ];   
            toAddr = signatory.Email;
            if(theQuote.Status__c != 'Approved')
            {
                                  
            }    
        } else {
        	ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'No quote ID was detected, please make '
        	+ 'sure you reached this page using the \'email quote button\' on the Quote page.' ));
            step = 0;   
        }
    }
    
    public PageReference nextStep(){
        step = step + 1;
        if(step == 3)
        {
           sendEnabled = true;
        } 
        return null;   
    }

    public PageReference backStep(){
        step = step - 1;
        return null;   
    }
    
    public PageReference send() {
        Messaging.SingleEmailMessage theMessage = new Messaging.SingleEmailMessage();
        theMessage.setWhatId(theQuote.Id);
        theMessage.setTargetObjectId(signatory.Id);    
        PageReference pdf = Page.QuoteToPDF;
        pdf.getParameters().put('id', theQuote.Id);
        pdf.setRedirect(true);
        // Take the PDF content
        try
        {
            // Create the email attachment
            Blob b = pdf.getContent();
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setFileName('quote_for_Eduventures_' + theQuote.Product_Group__c.replace(';','_') + 'service.pdf');
            efa.setBody(b);
            //List<String> toAddresses = new List<String>();
            //toAddresses.add(toAddr);         
            //theMessage.setToAddresses(toAddresses);
            if(ccAddr.trim().length() > 0 )
            {
            	String[] ccAddresses = ccAddr.split(',', 0);
   	            theMessage.setCcAddresses(ccAddresses); 
            }
            theMessage.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
            theMessage.setSubject(subject);
            theMessage.setHtmlBody(body);
            // Sends the email
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {theMessage}); 
            if(r[0].isSuccess())
            {
            	sendSuccess = true;
            	step = 4;
            	ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.INFO, 'Message Sent Successfully!'));
            }
        } catch(emailException e) {			
			    for (Integer i = 0; i < e.getNumDml(); i++) {
			        ApexPages.addMessage( new ApexPages.Message(
    				ApexPages.Severity.ERROR  ,'Send an email failed.' +e.getDmlMessage(i)));
			    }
				ApexPages.addMessage( new ApexPages.Message(
    			ApexPages.Severity.WARNING  ,'The email was not sent.'));
		}
        return null;
    }
    
    public static testmethod void testEmailingQuote(){

		//grab an exsiting quote
		EVQuote__c testQuote = [ SELECT Id FROM EVQuote__c WHERE Id = 'a008000000GetxQ'];
		PageReference pageRef = Page.emailQuote;
        Test.setCurrentPage(pageRef);
		//instantiate the standard controller as well as our cusotm controller
		ApexPages.StandardController std = new ApexPages.StandardController(testQuote);
		emailQuoteController eqController = new emailQuoteController(std);
		eqController.init();
		eqController.nextStep();
		eqController.subject = 'this is a test email from the system';
		eqController.body = 'this is just a test to verify our quote emailing system works';
		eqController.nextStep();    	
		eqController.send();
    }

	
}