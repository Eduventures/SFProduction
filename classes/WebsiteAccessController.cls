public class WebsiteAccessController {

    public Account acct {get;set;}
    public List<Contact> accountStaff {get;set;}
    public List<String> activeEngagements;
    public String message {get;set;}

    
    public WebsiteAccessController() {
        String tempId = '';
        if(ApexPages.currentPage().getParameters().containsKey('acctid') )
        {
            tempId = ApexPages.currentPage().getParameters().get('acctid');
            acct = [SELECT Id, Name, Active_Engagements__c from Account where Id = :tempId ];
            init();
            message = '';
        } else 
        {
            tempId = '[null]';
            acct = new Account();
            message = 'No account id was specified in your request, please check your link.';
            activeEngagements = new List<String>();
        }
    }
    
    private void init() {
        accountStaff = new List<Contact>();
        accountStaff = [ SELECT Id, Name, Email, AccountId, Membership_Role__c, Membership_History__c, 
                             website_username__c, seat_holder__c FROM Contact WHERE AccountId = :acct.Id];
        activeEngagements = acct.Active_Engagements__c.split(';',0);
    }
    
    
}