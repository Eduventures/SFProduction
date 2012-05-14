public class Contact_tools {

	@future (callout=true)
  	public static void addToCampaign(string campID, string conId) {
  	
  	Schema.DescribeFieldResult shField = Contact.Seat_Holder__c.getDescribe();
    List<Schema.PicklistEntry> shValues = shField.getPicklistValues();
	CampaignMember newEntry = new CampaignMember(
		ContactId = conId,
		CampaignId = campID	
	);
	
		try { 
				insert newEntry;	    
	    } catch (System.Exception e) {
        }
  	}
  	
  	static testMethod void testContact_tools() {
		
	Contact_tools.addToCampaign( '70180000000BqJT','00530000000vxt9AAA');  //pass it a test LOA and AJ's id. This ID will have to be changed if AJ ever leaves the company.
		
	}
}