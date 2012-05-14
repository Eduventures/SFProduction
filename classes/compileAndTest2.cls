@isTest
private class compileAndTest2 {
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
	
    List<LOA__c> testloas3 = new List<LOA__c>();

        
   	LOA__c l9 = new LOA__c(
	Name = 'TEST1', 
	Account__c = '0013000000GmUMN',
	Agreement_Date__c = System.Today(),
	Start_Date__c = System.Today().addDays(2),
	End_Date__c = System.Today().addDays(367),
	Type__c = 'New',
	Company_Contact__c = '0033000000LPQRo',
	RecordTypeId = '01230000000DMbx',
	Division_LOA__c = 'LC',
	Program__c = 'ACL-RL',
	Amount__c = 25000.00,
	Opportunity__c = o.id    		
	);
    
    testloas3.add(l9);
    
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
    	
	testloas3.add(l10);    	
    
	LOA__c l1l = new LOA__c(
	Name = 'TEST3', 
	Account__c = '0013000000GmUMN',
	Agreement_Date__c = System.Today(),
	Start_Date__c = System.Today().addDays(2),
	End_Date__c = System.Today().addDays(367),
	Type__c = 'New',
	Company_Contact__c = '0033000000LPQRo',
	RecordTypeId = '01230000000DMbx',
	Division_LOA__c = 'LC',
	Program__c = 'DEV-RL',
	Amount__c = 25000.00,
	Opportunity__c = o.id    		
	);	

    testloas3.add(l1l);
    
	LOA__c l12 = new LOA__c( 
	Name = 'TEST4', 
	Account__c = '0013000000GmUMN',
	Agreement_Date__c = System.Today(),
	Start_Date__c = System.Today().addDays(2),
	End_Date__c = System.Today().addDays(367),
	Type__c = 'New',
	Company_Contact__c = '0033000000LPQRo',
	RecordTypeId = '01230000000DMbx',
	Division_LOA__c = 'LC',
	Program__c = 'ENM-RL',
	Amount__c = 25000.00,
	Opportunity__c = o.id    		
	);	
    	 
	testloas3.add(l12);
	
	LOA__c l13 = new LOA__c(
	Name = 'TEST5', 
	Account__c = '0013000000GmUMN',
	Agreement_Date__c = System.Today(),
	Start_Date__c = System.Today().addDays(2),
	End_Date__c = System.Today().addDays(367),
	Type__c = 'New',
	Company_Contact__c = '0033000000LPQRo',
	RecordTypeId = '01230000000DMbx',
	Division_LOA__c = 'LC',
	Program__c = 'OHE-RL',
	Amount__c = 25000.00,
	Opportunity__c = o.id    		
	);	

	testloas3.add(l13);
	    	
	/*
	List<LOA__c> testloas4 = new List<LOA__c>();
	    
	LOA__c l14 = new LOA__c(
	Name = 'TEST6', 
	Account__c = '0013000000GmUMN',
	Agreement_Date__c = System.Today(),
	Start_Date__c = System.Today().addDays(2),
	End_Date__c = System.Today().addDays(367),
	Type__c = 'New',
	Company_Contact__c = '0033000000LPQRo',
	RecordTypeId = '01230000000DMbx',
	Division_LOA__c = 'LC',
	Program__c = 'STA-RL',
	Amount__c = 25000.00,
	Opportunity__c = o.id    		
	);	
 
	testloas4.add(l14);
	    	
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
	//archive_access_included__c = 'Yes',
	//archive_access__c = 'CPE;OHE',
	Program__c = 'SOE-RL',
	Amount__c = 25000.00,
	Opportunity__c = o.id    		
	);

	testloas4.add(l15);
	    	
	LOA__c l16 = new LOA__c(
	Name = 'TEST8',  
	Account__c = '0013000000GmUMN',
	Agreement_Date__c = System.Today(),
	Start_Date__c = System.Today().addDays(2),
	End_Date__c = System.Today().addDays(367),
	Type__c = 'New',
	Company_Contact__c = '0033000000LPQRo',
	RecordTypeId = '01230000000DMbx',
	Division_LOA__c = 'LC',
	Program__c = 'SUM-RL',
	archive_access_included__c = 'Yes',
	archive_access__c = 'CPE',
	Amount__c = 25000.00,
	Opportunity__c = o.id    		
    	);

	testloas4.add(l16);

    insert testloas4;*/ 
    insert testloas3; 
    
    	Opportunity o1 = new Opportunity(
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
		Original_LOA__c  = l9.Id,
		Implementation_Timeline__c = 'test',
		Next_Steps__c = 'test',
		Peers_Competitors__c = 'test',
		Purchasing_Process__c = 'test',
		Qualifying_Criterion_Actionable_Other__c = 'test',
		Research_Needs__c = 'test',		
        Initial_Meeting_Date__c = system.today().addDays(2), 		
		CloseDate = system.today().addDays(90));
	insert o1;   // add to list
	
    for(integer k = 0; k < 1; k ++) 
    {
    	testloas3[k].End_date__c = (System.Today()-1);
    } 
    
    testloas3[0].Replaced__c = true;
    update  testloas3;
    
    l10.Extension_date__c = (System.Today());
    l10.Extension_Reason__c = 'Budget';
    update l10; 
        
	

	}
}