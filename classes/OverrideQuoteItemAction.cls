public class OverrideQuoteItemAction {

	public Quote_Item__c qi {get;set;}
	
    //Open up the constructor to get the contact records from the current URL
    public OverrideQuoteItemAction(ApexPages.StandardController stdController){
		qi = (Quote_Item__c)stdController.getRecord();
        init();
    }
    
    public PageReference init(){
		String redirectURL = '/apex/EditQuote?id=' + qi.LOA_Quote__c ;
        PageReference goToQuote = new PageReference(redirectURL);
        return goToQuote;
    }
    
    public static testmethod void testOverrideQuoteItemAction() {

        Quote_Item__c anyItem = [ SELECT Id, LOA_Quote__c FROM Quote_Item__c LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.standardController(anyItem);      
        PageReference pageRefQIaction = new PageReference('/apex/overrideQuoteItemAction');
        Test.setCurrentPage(pageRefQIaction);                 
        OverrideQuoteItemAction controllerOQIA = new OverrideQuoteItemAction( sc );

	}
}