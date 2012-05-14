@isTest
private class testMemberActivityReports { 
	
    public static testMethod void testCaseControllerExtension() {
        /*Account acc = new Account();
        acc.Name = 'testAcc1';
        acc.BillingState = 'NY';
        Database.SaveResult lsrAcc = Database.insert(acc, false);*/
        Account lsrAcc = [ select Id from Account where Name like 'AJs Test Account'];
 
        Contact cont = new Contact();
        cont.FirstName = 'Test';
        cont.LastName = 'Contact';
        cont.AccountId = lsrAcc.Id;                
        Database.SaveResult lsrCont = Database.insert(cont, false);
         
        LOA__c loa = new LOA__c();
        loa.Program__c = 'ACL';
        loa.Name = 'testLoa';
        loa.Agreement_Date__c = System.today();
        loa.Start_Date__c = System.today();
        loa.End_Date__c  = System.today() + 365;   
        loa.Company_Contact__c = lsrCont.getId(); 
        loa.Account__c = lsrAcc.Id;
        loa.Research_Account_Manager__c = '00530000000w05K';
        Database.SaveResult lsrloa = Database.insert(loa, false);

        list<Projects__c> lsPrj = new list <Projects__c>();
        Projects__c prj1 = new Projects__c();
        prj1.Name = 'testProjResearch';
        prj1.LOA__c = lsrloa.getId() ;
        prj1.Data_Collection_Start_Date__c = System.today();   
        prj1.Divisions__c = 'Learning Collaborative';
        prj1.Programs__c = loa.Program__c;
        prj1.Product__c = 'CRR';        
        prj1.Account__c = lsrAcc.Id;  
                    
        Projects__c prj2 = new Projects__c();
        prj2.Name = 'testProjParticipation';
        prj2.LOA__c = lsrloa.getId() ;
        prj2.Data_Collection_Start_Date__c = System.today();
        prj2.Divisions__c = 'Learning Collaborative';
        prj2.Programs__c = loa.Program__c;
        prj2.Product__c = 'AMM';        
        prj2.Account__c = lsrAcc.Id;    
        prj2.Stage__c = 'Completed';       
        lsPrj.add(prj1);
        lsPrj.add(prj2);       
        Database.SaveResult[] lsr1 = Database.insert(lsPrj, false);
        
        TimeSheet__c ts1 = new TimeSheet__c();
        ts1.Name = System.today().format();
        ts1.Week_Commencing__c = System.today();
        ts1.Status__c = 'Work in progress';
        Database.SaveResult ts = Database.insert(ts1, false);
        
        list<TimeSheetLine__c> lsTse = new list<TimeSheetLine__c>();
         
        TimeSheetLine__c tse1 = new TimeSheetLine__c();
        tse1.Timesheet__c = ts.Id;
        tse1.ProjectId__c = lsr1[0].getId();
        tse1.Hour__c = 1;
        lsTse.add(tse1);
        
        TimeSheetLine__c tse2 = new TimeSheetLine__c();
        tse2.Timesheet__c = ts.Id;
        tse2.ProjectId__c = lsr1[0].getId();
        tse2.Hour__c = 2;
        lsTse.add(tse2);
        
        insert lsTse;
        
        PageReference pageRefMA = new PageReference('/apex/MemberActivity');
        Test.setCurrentPage(pageRefMA);          
        MemberActivityController controllerMA = new MemberActivityController();
        controllerMA.init();   
         

    try
    {
        controllerMA.getpageparameters();
        controllerMA.prototype.Approval_Date__c = System.today();
        controllerMA.setselectedProgram(loa.Program__c);
        controllerMA.populateDataPointslist();
        controllerMA.getallProjects();
        controllerMA.getdaysBackToSearch();
        controllerMA.getselectedProgram();
        controllerMA.getcurrentPrograms();
        ApexPages.currentPage().getParameters().put('filterfield','Research Account Manager');
        ApexPages.currentPage().getParameters().put('filtervalue','Kristen D. Fox');
        controllerMA.filterTable();
        controllerMA.clearFilter();
        ApexPages.currentPage().getParameters().put('filterfield','Program');
        ApexPages.currentPage().getParameters().put('filtervalue',loa.Program__c);
        controllerMA.filterTable();
        controllerMA.clearFilter();
        ApexPages.currentPage().getParameters().put('filterfield','Renewal Risk');
        ApexPages.currentPage().getParameters().put('filtervalue','(missing)');
        controllerMA.filterTable();
        
        ApexPages.currentPage().getParameters().put('sortfunction','string');
        ApexPages.currentPage().getParameters().put('sortfieldname','AcctName');
        controllerMA.sortTable();
        ApexPages.currentPage().getParameters().put('sortfunction','string');
        ApexPages.currentPage().getParameters().put('sortfieldname','Program');
        controllerMA.sortTable(); 
        ApexPages.currentPage().getParameters().put('sortfunction','string');
        ApexPages.currentPage().getParameters().put('sortfieldname','RenewalRisk');
        controllerMA.sortTable(); 
        ApexPages.currentPage().getParameters().put('sortfunction','string');
        ApexPages.currentPage().getParameters().put('sortfieldname','ResearchManager');
        controllerMA.sortTable(); 

        ApexPages.currentPage().getParameters().put('sortfunction','date');
        ApexPages.currentPage().getParameters().put('sortfieldname','renewalDate');
        controllerMA.sortTable();
        controllerMA.sortTable();                        
        ApexPages.currentPage().getParameters().put('sortfunction','decimal');
        ApexPages.currentPage().getParameters().put('sortfieldname','Total New Hours');        
        controllerMA.sortTable();

        controllerMA.editRR();
        controllerMA.saveRR();
        controllerMA.cancelRR();
        controllerMA.editRM();
        controllerMA.saveRM();
        controllerMA.cancelRM();
        
        PageReference pageRefPV = new PageReference('/apex/MemberActivityProjectsView');
        Test.setCurrentPage(pageRefPV);          
        ApexPages.currentPage().getParameters().put('selectedacctid',loa.Account__c);
        ApexPages.currentPage().getParameters().put('projecttype','research');
        ApexPages.currentPage().getParameters().put('program',loa.Program__c);
        Integer daysBack = controllerMA.prototype.Approval_Date__c.daysBetween(System.today());
        ApexPages.currentPage().getParameters().put('days',String.valueOf(daysBack));
        MemberActivityProjectsViewController controllerPV = new MemberActivityProjectsViewController ();
        controllerPV.init();         
    }
    catch (System.DmlException e) 
      {
        System.debug('Failed to run MemberActivityController for: ' + loa.Program__c + ': '+ e);
      }
      
        PageReference pageRefPV = new PageReference('/apex/MemberActivityProjectsView');
        Test.setCurrentPage(pageRefPV);          
        ApexPages.currentPage().getParameters().put('selectedacctid',loa.Account__c);
        ApexPages.currentPage().getParameters().put('projecttype','research');
        ApexPages.currentPage().getParameters().put('program',loa.Program__c);
        Integer daysBack = controllerMA.prototype.Approval_Date__c.daysBetween(System.today());
        ApexPages.currentPage().getParameters().put('days',String.valueOf(daysBack));
        MemberActivityProjectsViewController controllerPV = new MemberActivityProjectsViewController ();
        controllerPV.init();   
        controllerPV.getprojectsList();
        controllerPV.getpageparameters();
        System.debug('# of research projects found = ' + controllerPV.getprojectsList().size());
        ApexPages.currentPage().getParameters().put('projecttype','participation');
        controllerPV.init();   
        controllerPV.getprojectsList();
        controllerPV.getpageparameters(); 
        System.debug('# of participation projects found = ' + controllerPV.getprojectsList().size());
        
        controllerPV.setselectedProject(controllerPV.projectsList[0]);
        ApexPages.currentPage().getParameters().put('pid',controllerPV.projectsList[0].theProject.Id);
        controllerPV.selectP();
        controllerPV.getselectedProject();
        
    } 

}