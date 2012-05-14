public class CaseControllerExtension {
    
    public Case newCase {get;set;}
    public String selectedType = '';
    public Boolean continueTest = false;  
    
    public CaseControllerExtension (Case c)
    {
        newCase = c;
        init();
    }
        
    public CaseControllerExtension (ApexPages.StandardController stdController) {
        this.newCase = (Case)stdController.getRecord();
        init();  
    }
    
    private void init()
    {
        newCase.Status = 'New';
        newCase.Priority = 'Medium';
        newCase.Origin = 'Web';
    }

    public PageReference initialize() {
        
        if(newCase.RecordTypeId == null)
        {
            Map<String, String> params = ApexPages.currentPage().getParameters();
            String paramString = '/500/e?nooverride=1';
            
            for(String key: params.keySet())
            {
               paramString = paramString + '&' + key + '=' +  params.get(key);
            }             
            return new PageReference(paramString);
        }
        else if(newCase.RecordTypeId != '01230000000DMGk')
        {
            Map<String, String> params = ApexPages.currentPage().getParameters();
            String paramString = '/500/e?nooverride=1&RecordType=' + newCase.RecordTypeId;

            if(params.containsKey('sfdc.override'))
            {
                params.remove('sfdc.override');
            }
            
            if(params.containsKey('save_new'))
            {
                params.remove('save_new');
            }

            if(params.containsKey('save_new_url'))
            {
                params.remove('save_new_url');
            }

            for(String key: params.keySet())
            {
               paramString = paramString + '&' + key + '=' +  params.get(key);
            }        
            return new PageReference(paramString);
        }


        User u = [select Id,Email from User where Id = :UserInfo.getUserId()]; 
        if([select count() from Contact where Email = :u.Email] != 0)
        {
            Contact c = [select Id, Email from Contact where Email = :u.Email];  
            newCase.ContactId = c.Id;
        }
                        
        if(getCountOutstandingIssues() == 0 )
        {
            continueTest = true;
        }
        for (Case outstandingIssue: [Select Id, Subject, Systemwide_Issue__c,Systemwide_Issue_Message__c, Status from Case where Systemwide_Issue__c = true])
        {
            if(outstandingIssue.Systemwide_Issue_Message__c != null)
            {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO, outstandingIssue.Systemwide_Issue_Message__c);
                ApexPages.addMessage(myMsg);
            }
        }
        return null;
    }
    
    public Boolean getcontinueTest() {
        return continueTest;
    } 

    public PageReference continueForm() {
        continueTest = true;
        return null;
    }
    
    public Integer getCountOutstandingIssues() {
        return [Select count() from Case where Systemwide_Issue__c = true];
    }
    
    public PageReference save()
    {
        
        //Logical actions
       database.DMLOptions dmo = new database.DMLOptions();
       dmo.AssignmentRuleHeader.useDefaultRule = true;
       dmo.EmailHeader.triggerUserEmail = true; 
       dmo.EmailHeader.triggerAutoResponseEmail = true;
       newCase.setOptions(dmo);
       
       Database.SaveResult MySaveResult = Database.Insert(newCase, false);
       return new PageReference( '/cases/casesavedjump.jsp');
    }
    
    public static testMethod void testCaseControllerExtension() {


        PageReference pageRef = new PageReference('/apex/New_Helpdesk_Case?cas7=Open');
        Test.setCurrentPage(pageRef);          
        //test Recordtype is null
        Case tempNullCase =   new Case( Subject = 'Generic Case');
        CaseControllerExtension controllerNull = new CaseControllerExtension (tempNullCase );
        controllerNull.initialize();

        //test Recordtype not helpdesk
        Case tempMScase =   new Case( RecordTypeId = '01280000000F3fB', Subject = 'Member Services Case'); 
        CaseControllerExtension controllerNotHelpdesk = new CaseControllerExtension (tempMScase );
        controllerNotHelpdesk.initialize();
        
    
        try
        {
            Contact temp = [ select id, name from Contact where email = 'adellicicchi@eduventures.com'];
        
            Case newSWMcase = new Case(Description = 'This is a system alert',
             Priority = 'Medium',
             Status = 'New',
             Subject = 'Systemwdie Issue!',
             Systemwide_Issue__c = true,
             Systemwide_Issue_Message__c = 'A test message',
             RecordTypeId = '01230000000DMGk',
             ContactId = temp.Id);
             insert newSWMcase;
        
        }
        catch (System.DmlException e) 
        {
            System.debug('Failed to insert Case: ' + e);
        }
        
        //test Recordtype not helpdesk
        Case tempHelpdeskCase =   new Case( RecordTypeId = '01230000000DMGk', Subject = 'Helpdesk Case'); 
        CaseControllerExtension controller = new CaseControllerExtension (tempHelpdeskCase );      
        controller.initialize();
        controller.getcontinueTest();
        controller.continueForm();
        controller.newCase.Type = 'Other';
        controller.newCase.Description = 'TEST';
        controller.newCase.Subject = 'TESTING CASE CONTROLLER EXTENSION';
        PageReference nextPage = controller.save();

        // Verify that the success page displays  
    
        System.assertEquals('/cases/casesavedjump.jsp', nextPage.getUrl());
        Case[] cases = [select id, Subject from Case where Subject = 'TESTING CASE CONTROLLER EXTENSION'];
        System.assert(!cases.isEmpty(), 'Case not created');
    } 

}