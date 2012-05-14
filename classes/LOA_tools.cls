public class LOA_tools {

    @future (callout=true)
    public static void clearResearchMgrs(List<Id> loasToWipe) {
        system.debug('check: is loasToWipe array empty? ' + loasToWipe.isEmpty());
        system.debug('size of loasToWipe array = ' + loasToWipe.size());
        List<LOA__c> updatedLOAs = [select Id,Research_Account_Manager__c from LOA__c where Id in :loasToWipe ];
		system.debug('size of updatedLOAs array = ' + updatedLOAs.size());
		
		for(LOA__c l : updatedLOAs )
		{
			l.Research_Account_Manager__c = null;
		} 
        try { 
                update updatedLOAs;       
        } catch (System.Exception e) {
        }
        for(LOA__c l2 : updatedLOAs )
		{
			system.debug('LOA id ' + l2.Id + ' RAM value is ' + l2.Research_Account_Manager__c );
		}
    }
    
    @future (callout=true)
    public static void updateResearchMgr(string loaID, string managerID) {
        LOA__c myloa = [select Id,Research_Account_Manager__c from LOA__c where Id = :loaID ];
        myloa.Research_Account_Manager__c = managerID;

        try { 
                update myloa;       
        } catch (System.Exception e) {
        }
    }

    @future (callout=true)
    public static void renewLOA (string loaID, string replacementLOAname ) {
        LOA__c renewedLOA = [select Id, Renewal_LOA__c, Renewed__c from LOA__c where Id = :loaID ];
        renewedLOA.Renewal_LOA__c = replacementLOAname;
        renewedLOA.Renewed__c = true;

        try { 
                update renewedLOA;      
        } catch (System.Exception e) {
        }
    }
    
    static testMethod void testLOA_tools() {
        
    LOA_tools.updateResearchMgr('a088000000AtPtq','00530000000vxt9AAA');  //pass it a test LOA and AJ's id. This ID will have to be changed if AJ ever leaves the company.
        
    }
}