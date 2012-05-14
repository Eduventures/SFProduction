@isTest
private class compileAndTest { 

    public static testmethod void t1() {
    
    Account testAcct = new Account( 
        Name = 'TEST',
        Active_Engagements__c = 'XXX',
        BillingState = 'MA');
    insert testAcct; 
    
    Case salesCase = new Case(
        RecordTypeId = '01230000000DxP0',
        Status = 'New', 
        Number_of_Packets__c = 2,
        Program__c = 'CPE',  
        ContactId = '0033000000LPQRo');
    insert salesCase; 
     
    salesCase.Status = 'Closed';
    update salesCase;    
    
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
        
    o.StageName = 'Qualified';
    o.Qualifying_Criterion_Actionable_Other__c = 'test';
    o.Purchasing_Process__c = 'test';
    o.Close_Date_New__c = system.today().addDays(9);
    o.description += o.description + 'test 2 ';
    o.budget__c = 'Yes';
    o.Follow_up_date__c = system.today().addDays(9);
    o.Purchasing_Process__c = 'test';
    update o;
           
    LOA__c l = [select Id from LOA__c where Id = 'a0830000000o0up'];
    l.Salesperson__c = 'Done';
    update l; 

    List<LOA__c> testloas1 = new List<LOA__c>();    
    List<LOA__c> testloas2 = new List<LOA__c>();
        
    LOA__c l1 = new LOA__c(
        Name = 'TEST1', 
        Account__c = testAcct.Id,
        Agreement_Date__c = System.Today(),
        Start_Date__c = System.Today().addDays(2),
        End_Date__c = System.Today().addDays(367),
        Type__c = 'New',
        Company_Contact__c = '0033000000LPQRo',
        RecordTypeId = '01230000000DMbx',
        Division_LOA__c = 'LC',
        Program__c = 'ACL',
        Amount__c = 25000.00,
        Opportunity__c = o.id           
        );
    
    //insert l1;
    testloas1.add(l1);
    
        LOA__c l2 = new LOA__c(
        Name = 'TEST2', 
        Account__c = '0013000000G3ZjT',
        Agreement_Date__c = System.Today(),
        Start_Date__c = System.Today().addDays(2),
        End_Date__c = System.Today().addDays(367),
        Type__c = 'New',
        Company_Contact__c = '0033000000LPQRo',
        RecordTypeId = '01230000000DMbx',
        Division_LOA__c = 'LC',
        Program__c = 'CPE',
        Amount__c = 25000.00,
        Opportunity__c = o.id           
        );  
        
    //insert l2;
    testloas1.add(l2);      
    
        LOA__c l3 = new LOA__c(
        Name = 'TEST3', 
        Account__c = testAcct.Id,
        Agreement_Date__c = System.Today(),
        Start_Date__c = System.Today().addDays(2),
        End_Date__c = System.Today().addDays(367),
        Type__c = 'New',
        Company_Contact__c = '0033000000LPQRo',
        RecordTypeId = '01230000000DMbx',
        Division_LOA__c = 'LC',
        Program__c = 'DEV',
        Amount__c = 25000.00,
        Opportunity__c = o.id           
        );  

    //insert l3;
    testloas2.add(l3);
     
        LOA__c l4 = new LOA__c(
        Name = 'TEST4', 
        Account__c = '0013000000G3ZjT',
        Agreement_Date__c = System.Today(),
        Start_Date__c = System.Today().addDays(2),
        End_Date__c = System.Today().addDays(367),
        Type__c = 'New',
        Company_Contact__c = '0033000000LPQRo',
        RecordTypeId = '01230000000DMbx',
        Division_LOA__c = 'LC',
        Program__c = 'ENM',
        Amount__c = 25000.00,
        Opportunity__c = o.id           
        );  
         
    //insert l4;
    testloas2.add(l4);
    
        LOA__c l5 = new LOA__c(
        Name = 'TEST5', 
        Account__c = '0013000000GmUMN',
        Agreement_Date__c = System.Today(),
        Start_Date__c = System.Today().addDays(2),
        End_Date__c = System.Today().addDays(367),
        Type__c = 'New',
        Company_Contact__c = '0033000000LPQRo',
        RecordTypeId = '01230000000DMbx',
        Division_LOA__c = 'LC',
        Program__c = 'OHE',
        Amount__c = 25000.00,
        Opportunity__c = o.id           
        );  

    //insert l5;
    testloas2.add(l5);
            

        LOA__c l7 = new LOA__c(
        Name = 'TEST7', 
        Account__c = '0013000000L6WB9',
        Agreement_Date__c = System.Today(),
        Start_Date__c = System.Today().addDays(2),
        End_Date__c = System.Today().addDays(367),
        Type__c = 'New',
        Company_Contact__c = '0033000000LPQRo',
        RecordTypeId = '01230000000DMbx',
        Division_LOA__c = 'LC',
        Program__c = 'SOE',
        Amount__c = 25000.00,
        Opportunity__c = o.id           
        );

    //insert l7;
    //testloas2.add(l7);     
     
    //insert testloas1; 
    insert testloas2; 
    
    /*l1.End_date__c = (System.Today()-1);
    update l1;
    l2.End_date__c = (System.Today()-1);
    update l2;
    
    l2.Extension_date__c = (System.Today());
    l2.Extension_Reason__c = 'Budget';
    update l2;*/ 
        
    l2.Extension_date__c = (System.Today()-1);
    
    try {
        delete testAcct;
    }   catch (Exception e) {   }
        
    }

}