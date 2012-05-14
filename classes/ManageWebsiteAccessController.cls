public class ManageWebsiteAccessController {

    public Account acct {get;set;}
    public Boolean isDirty {get;set;}
    String acctid {get;set;}
    public Set<Id> selectedIds {get;set;}
    public List<cContact> accountStaff;
    public List<String> activeEngagements;
    public String programToAdd {get;set;}
    public List<String> ActivePrograms;
    public String message {get;set;}
    public List<Integer> problemSaveResults {get;set;}

    public ManageWebsiteAccessController(ApexPages.StandardController controller ) {
        isDirty = false;
        message = '';
        acctid = '';
        activeEngagements = new List<String>();
        selectedIds = new Set<id>();
        if(ApexPages.currentPage().getParameters().containsKey('id') )
        {
            acctid = ApexPages.currentPage().getParameters().get('id');
            acct = [SELECT Id, Name, Active_Engagements__c from Account where Id = :acctid ];
            init();
        } else 
        {
            acctid = '[null]';
            acct = new Account();
            message = 'No account id was specified in your request, please check your link.';
        }
    }

    // This is our wrapper/container class. A container class is a class, a data structure, or an abstract data type whose instances are collections of other objects. In this example a wrapper class contains both the standard salesforce object Contact and a Boolean value
    public class cContact {
        public Contact con {get; set;}
        public Boolean selected {get; set;}
 
        //This is the contructor method. When we create a new cContact object we pass a Contact that is set to the con property. We also set the selected value to false
       public cContact(Contact c) {
           con = c;
           selected = false;
       }
    }
        
    private void init() {

        for(String prog : acct.Active_Engagements__c.split(';',0))
        {
            if(prog != 'XXX' && prog != 'ECS' && !prog.contains('-ASV'))
            {
                activeEngagements.add(prog.replace('SEM','ENM').replace('-RL',''));
            }
        }
        if(acct.Id == '0013000000K2fUX')
        {
        	activeEngagements.addAll(new List<String>{'ACL','AIE','CPE','DEV','ENM','OHE','SOE'});
        }
        else if(activeEngagements == null || activeEngagements.size() == 0)
        {
            message = message + 'This Account has no active memberships to provide website acces for!';
        }

    }


    public PageReference toggleSelected() {
        String itemId = Apexpages.currentPage().getParameters().get('cid');
        String isSelected = Apexpages.currentPage().getParameters().get('status');
        if(isSelected == 'true')
        {
			selectedIds.add(itemId);
           	this.isDirty = true;            			 
        } else
        {
            selectedIds.remove(itemId);
            if(selectedIds.size() == 0)
            {
                this.isDirty = false;
            }
        }
        return null;
    }
    
    public List<cContact> getaccountStaff() 
    {
        accountStaff = new List<cContact>();
        if([SELECT count() FROM Contact WHERE AccountId = :acct.Id] != 0)
        {
            for(Contact c: [SELECT Id, Name, Email, AccountId, Membership_Role__c, Status__c, LastModifiedDate, 
                                                     Membership_History__c, website_username__c, seat_holder__c 
                                                     FROM Contact WHERE AccountId = :acct.Id ORDER BY LastName])
            {
                accountStaff.add(new cContact(c));   
            }                                                                             
        } else 
        {
            message = message + '<br />There are no Contacts under this account to edit!';
        }
        return accountStaff;
    }
    
    public List<SelectOption> getActivePrograms()
    {
        List<SelectOption> optionList = new List<SelectOption>();
        optionList.add(new SelectOption('','-pick one-'));
        for(String optionValue : activeEngagements)
        {
            optionList.add(new SelectOption(optionValue,optionValue));
        }
        return optionList;
    }
    
    public List<String> getactiveEngagements(){
        return activeEngagements;
    }
    
    public PageReference cancel(){
        return null;
    }

    public PageReference clearEdits(){
        return null;
    }
       
    public PageReference save()
    {
        List<Contact> updateList = new List<Contact>();
        if(programToAdd == null)
        {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Please Choose a Program to provide access to'));
        } else
        {
            for(cContact cc: accountStaff)
            {
                if(cc.selected)
                {
                    if(!cc.con.seat_holder__c.contains(programToAdd))
                    {
                        cc.con.seat_holder__c = cc.con.seat_holder__c + ';' + programToAdd + ';';
                        updateList.add(cc.con);
                    }                    
                }
            }
        
        }
        Database.Saveresult[] saveResults = Database.update(updateList, false);
        for (Database.SaveResult sResult : saveResults) 
        {
            if(!sResult.isSuccess())
            {
                //ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'there was an error ' ));
                Database.Error errMsg = sResult.getErrors()[0];
                ApexPages.addMessage(
                   new ApexPages.Message( ApexPages.Severity.ERROR,errMsg.getMessage()));
            }
        }

        isDirty = false;        
        return null;
    }

    
}