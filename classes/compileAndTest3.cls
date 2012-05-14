@isTest
private class compileAndTest3 {
public static testmethod void t1() {
      
	Opportunity o = new Opportunity(
    	Name = 'OHE test',
		AccountId = '0013000000G3YV0',
		OwnerId = '00530000000vxt9',   
		Type = 'New Business', 
		Class__c = 'LC',
		Product_Group__c = 'OHE',
		StageName = 'Qualification Meeting Scheduled',
		Attendees__c = 'test',
		Background__c = 'test',
		Challenges__c = 'test',
		Closing_Criterion_Interest_Objections__c = 'test',
		Closing_Criterion_Timeframe__c = 'test',
		Description = 'test opportunity.',
		Goals__c = 'test',
		Implementation_Timeline__c = 'test',
		Next_Steps__c = 'test',
		Peers_Competitors__c = 'test',
		Purchasing_Process__c = 'test',
		Qualifying_Criterion_Actionable_Other__c = 'test',
		Research_Needs__c = 'test',
		Initial_Meeting_Date__c = system.today().addDays(2),		
		CloseDate = system.today().addDays(90));
	insert o;   // add to list
 	
    List<LOA__c> testloas4 = new List<LOA__c>();

	    	
	LOA__c l15 = new LOA__c(
	Name = 'TEST7', 
	Account__c = '0013000000GmUMN',
	Agreement_Date__c = System.Today(),
	Start_Date__c = System.Today().addDays(2),
	End_Date__c = System.Today().addDays(367),
	Type__c = 'New',
	Company_Contact__c = '0033000000LPQRo',
	RecordTypeId = '01230000000DMbx',
	Division_LOA__c = 'LC',
	Program__c = 'SOE-RL',
	Amount__c = 25000.00,
	Opportunity__c = o.id    		
	);

	testloas4.add(l15);
	    	

    insert testloas4; 
    
    LOA__c l10 = new LOA__c(
	Name = 'TEST2', 
	Account__c = '0013000000GmUMN',
	Agreement_Date__c = System.Today(),
	Start_Date__c = System.Today().addDays(2),
	End_Date__c = System.Today().addDays(367),
	Type__c = 'New',
	Company_Contact__c = '0033000000LPQRo',
	RecordTypeId = '01230000000DMbx',
	Division_LOA__c = 'LC',
	Program__c = 'CPE-RL',
	Amount__c = 25000.00,
	Opportunity__c = o.id    		
	);	
	insert l10;

    
    l10.Extension_date__c = (System.Today());
    l10.Extension_Reason__c = 'Budget';
    update l10; 
        
    l10.Extension_date__c = (System.Today()-1);
    update l10;
	
	Projects__c testOBC = [ select Id, Name, Call_Scheduled_Time__c, Product__c, LOA__c from Projects__c where Stage__c = 'Not Started' 
		and LOA__c = :l10.Id and Call_Scheduled_Time__c = null LIMIT 1];
	testOBC.Call_Scheduled_Time__c = (System.Now()+1);
	update testOBC;
	testOBC.Call_Scheduled_Time__c = (System.Now()+2); 
	update testOBC;
		
	Projects__c testMYC = [ select Id, Name, Call_Scheduled_Time__c, Product__c, LOA__c  from Projects__c where Stage__c = 'Not Started' 
		and LOA__c = :l10.Id and Call_Scheduled_Time__c = null LIMIT 1];
	testMYC.Call_Scheduled_Time__c = (System.Now()+1);
	update testMYC;
	testMYC.Call_Scheduled_Time__c = (System.Now()+2);
	update testMYC;
	}
}