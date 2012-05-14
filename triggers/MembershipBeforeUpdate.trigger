trigger MembershipBeforeUpdate on Membership__c (before update) {

    //collect all the current LOA data in one place by mapping each membership to it's program and the current active LOA
    //mapping by Membership Id
    Map<Id,LOA__c> membershipMap = new Map<Id,LOA__c> ();
    Map<Id,Decimal > membershipLengthMap = new Map<Id,Decimal> ();
    
    LOA__c blankLOA = new LOA__c(); 
      
    for(Membership__c m : [SELECT Id, Status__c, Account__c,
    							( SELECT Id, Name, Status__c, Website_Access__c, Strategy_Session_Access__c, 
    							    Start_Date__c, Program__c, Member_Roundtable_Access__c, End_Date__c, 
    							    Custom_Analysis_Limit__c, AMM_Pass_Count__c, Contract_Length__c
    								FROM LOAs__r 
    							WHERE Status__c in ('Active','Extended','Pending') 
    							order by Status__c, Start_Date__c DESC LIMIT 1)
							FROM Membership__c WHERE Id in :Trigger.newMap.keySet()])
	{
		if(m.LOAs__r.isEmpty())
		{
			membershipMap.put(m.Id, blankLOA);
		} else
		{
			membershipMap.put(m.Id, m.LOAs__r[0]);
		}
	}
	
	Decimal totalMembershipLength = 0;
    for(Membership__c m2 : [SELECT Id, Status__c, Account__c,
    							( SELECT Id, Name, Status__c, Website_Access__c, Strategy_Session_Access__c, 
    							    Start_Date__c, Program__c, Member_Roundtable_Access__c, End_Date__c, 
    							    Custom_Analysis_Limit__c, AMM_Pass_Count__c, Contract_Length__c
    								FROM LOAs__r 
    							WHERE RecordTypeId = '01230000000DMbx' AND Start_Date__c < TODAY 
    							order by Start_Date__c DESC )
							FROM Membership__c WHERE Id in :Trigger.newMap.keySet()])
	{
		totalMembershipLength = 0;
		if(m2.LOAs__r.isEmpty())
		{
			membershipLengthMap.put(m2.Id, 0);
		} else
		{
			for(LOA__c temp: m2.LOAs__r)
			{ 
				if(temp.End_Date__c < system.Today())
				{
					totalMembershipLength = totalMembershipLength + temp.Contract_Length__c;
				} else 
				{
					Decimal tempused = 0.00;
					tempused = temp.Start_Date__c.daysBetween(system.today()) / 365.0;
					totalMembershipLength = totalMembershipLength + tempused;	
				}
			}
			membershipLengthMap.put(m2.Id, totalMembershipLength);
		}
	}	
	
    for (Integer i = 0; i < Trigger.new.size(); i++)
    {
    	Membership__c m = Trigger.new[i];
    	Membership__c old = Trigger.old[i];
    	
        if(membershipMap.get(m.Id).Id == null)
        {
        	m.Status__c = 'Expired';
        } else 
        {
        	m.Status__c = membershipMap.get(m.Id).Status__c;
        	m.Website_Access__c = membershipMap.get(m.Id).Website_Access__c;
        	m.Strategy_Session_Access__c = membershipMap.get(m.Id).Strategy_Session_Access__c;
        	m.Member_Roundtable_Access__c = membershipMap.get(m.Id).Member_Roundtable_Access__c;
        	m.Custom_Analysis_Limit__c = membershipMap.get(m.Id).Custom_Analysis_Limit__c;
        	m.AMM_Pass_Count__c = membershipMap.get(m.Id).AMM_Pass_Count__c;
        }
        m.Membership_Length_to_date__c = membershipLengthMap.get(m.Id);       
    }  	
    
}