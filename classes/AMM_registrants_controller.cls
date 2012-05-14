public without sharing class AMM_registrants_controller{
    public String myJSONObject {get;set;}
    Integer attendeeGoal {get;set;}
    Integer nonContacts {get;set;}
    String queryid {get;set;}
        
    List<CampaignMember> registered {get;set;}
    Map<Id, CampaignMember> campaignMemberMap {get;set;}
    List<Id> registeredContactIds {get;set;}
    List<Contact> registeredContacts {get;set;}  
    Map<String, Set<Id>> registeredMembersMap {get;set;} 
    Map<String, Integer> memberCountMap {get;set;} 
    Map<String, Integer> percentMembershipRegisteredMap {get;set;}
    Map<String, Integer> overallCountMap {get;set;}   
    Map<String, Integer> percentOverallRegisteredMap {get;set;}
    
    Map<String,List<Contact>> registeredContactsMap {get;set;}
    Map<String,List<Account>> registeredAccountsMap {get;set;}
        
    public AMM_registrants_controller() {
        queryid = '';
        if( ApexPages.currentPage().getParameters().containsKey('qid'))
        {
            queryid  = ApexPages.currentPage().getParameters().get('qid');
        }
        myJSONObject = '';
        attendeeGoal = 300;
        nonContacts = 0;
        registered = new List<CampaignMember>();
        campaignMemberMap = new Map<Id, CampaignMember>();
        registeredContactIds = new List<Id>();
        registeredMembersMap = new Map<String, Set<Id>>();
        memberCountMap  = new Map<String, Integer>();
        percentMembershipRegisteredMap  = new Map<String, Integer>();
        overallCountMap = new Map<String, Integer>();
        percentOverallRegisteredMap  = new Map<String, Integer>();
        registeredContactsMap = new Map<String,List<Contact>>();
        registeredAccountsMap = new Map<String,List<Account>>(); 

        
        for(CampaignMember cm: [SELECT CampaignId, Id, ContactId, CreatedDate, IsDeleted, LeadId, Status 
                        FROM CampaignMember where CampaignId = '70180000000TBkS'])
        {
            registered.add(cm);
            
            if(cm.ContactId != null)
            {
                campaignMemberMap.put(cm.ContactId, cm);
                registeredContactIds.add(cm.ContactId);
                
                if(overallCountMap.containsKey(cm.Status))
                {
                    overallCountMap.put(cm.Status, overallCountMap.get(cm.Status)+1);
                } 
                else
                {
                    overallCountMap.put(cm.Status,1);
                    percentOverallRegisteredMap.put(cm.Status,0);  
                }
                
            } else if (cm.LeadId != null)
            {
                nonContacts = nonContacts+1;
            }
           
        }
        
        for(Contact c: [SELECT Id, name, AccountId, email, Seat_Holder__c, Membership_Role__c FROM Contact where Id in :registeredContactIds])
        {
            
            if( !registeredMembersMap.containsKey(campaignMemberMap.get(c.Id).Status) )
            {
                Set<Id> tempSet = new Set<Id>();
                tempSet.add(c.AccountId);
                registeredMembersMap.put(campaignMemberMap.get(c.Id).Status,tempSet);
                memberCountMap.put(campaignMemberMap.get(c.Id).Status,1);
                percentMembershipRegisteredMap.put(campaignMemberMap.get(c.Id).Status,0);
                
                List<Contact> tempContactList = new List<Contact>();
                tempContactList.add(c);
                registeredContactsMap.put(campaignMemberMap.get(c.Id).Status,tempContactList);

                List<Account> tempAccountList = new List<Account>();                
                registeredAccountsMap.put(campaignMemberMap.get(c.Id).Status,tempAccountList);
                                    
            } else 
            {
                if( !registeredMembersMap.get(campaignMemberMap.get(c.Id).Status).contains(c.AccountId))
                {
                    registeredMembersMap.get(campaignMemberMap.get(c.Id).Status).add(c.AccountId);
                    memberCountMap.put(campaignMemberMap.get(c.Id).Status,memberCountMap.get(campaignMemberMap.get(c.Id).Status)+1);
                }
                registeredContactsMap.get(campaignMemberMap.get(c.Id).Status).add(c);

            }            
        }   
        
        for(String lcName: percentMembershipRegisteredMap.keySet())
        {
            List<Account> activeMembers = [ SELECT Id, Active_Engagements__c, Name FROM Account WHERE Active_Engagements__c INCLUDES (:lcName)];
            System.debug('for ' + lcName + ' there were ' + memberCountMap.get(lcName) + ' registered accounts out of a total of ' + activeMembers.size());
            percentMembershipRegisteredMap.put( lcName, (decimal.valueOf(memberCountMap.get(lcName)) / activeMembers.size()*100).intValue() );
        }
                
        for(String lcName: percentOverallRegisteredMap.keySet())
        {
            percentOverallRegisteredMap.put( lcName , (decimal.valueOf(overallCountMap.get(lcName)) / registeredContactIds.size()*100).intValue() );
        }
        
        for(String lcName: registeredMembersMap.keySet())
        {
            for(Account regAcct : [ SELECT Id, Active_Engagements__c, Name FROM Account WHERE Active_Engagements__c INCLUDES (:lcName) and Id in :registeredMembersMap.get(lcName) ])
            {
                registeredAccountsMap.get(lcName).add(regAcct);
            }
        }
        
        myJSONObject = '{ "regcount": ' + registeredContactIds.size() + ',';
        myJSONObject = myJSONObject + ' "lcs" : [ ';
        List<String> orderedlcs = new List<String>();
        for(String lcName: percentMembershipRegisteredMap.keySet())
        {
            orderedlcs.add(lcName);
        }
        orderedlcs.sort();
        for(String lcName: orderedlcs)
        {
                myJSONObject = myJSONObject + '{ "name" : "' + lcName + '", "count": ' + percentMembershipRegisteredMap.get(lcName) + '},';  
        }
        myJSONObject = myJSONObject.substring(0,myJSONObject.length()-1);
        myJSONObject = myJSONObject + ']  }';
        String jsoncb = ApexPages.currentPage().getParameters().get('jsoncallback');
        myJSONObject = jsoncb + '(' + myJSONObject + ');';         
                        
    }
    
    public static testMethod void testAMMregistrants() {
    	PageReference ammRef = new PageReference('/apex/amm_registrants');
        Test.setCurrentPage(ammRef);          
		AMM_registrants_controller proto = new AMM_registrants_controller();
    	
    }

}