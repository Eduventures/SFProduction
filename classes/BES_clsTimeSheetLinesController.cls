public with sharing class BES_clsTimeSheetLinesController
{
    public static testmethod void testMethod1()
    {
        
        BES_clsTimeSheetLinesController obj = new BES_clsTimeSheetLinesController();
         
        list<Projects__c> lsPrj = new list <Projects__c>();
        Account acc = new Account();
        acc.Name = 'testAcc1';
        acc.BillingState = 'NY';
        Database.SaveResult lsrAcc = Database.insert(acc, false);
        System.debug('==============' + lsrAcc);
        Contact cont = new Contact();
        cont.LastName = 'testAcc1';
        cont.AccountId = lsrAcc.getId();                
        Database.SaveResult lsrCont = Database.insert(cont, false);
        
        LOA__c loa = new LOA__c();
        loa.Name = 'testLoa1';
        loa.Start_Date__c = Date.newInstance(2008,8,1);
		loa.End_Date__c	= Date.newInstance(2008,8,2);			
		loa.Agreement_Date__c = Date.newInstance(2008,8,3);
		loa.Company_Contact__c = lsrCont.getId(); 
		loa.Account__c = lsrAcc.getId();
        Database.SaveResult lsrloa = Database.insert(loa, false);
        
        Projects__c prj1 = new Projects__c();
        prj1.Name = 'testProj1';
		prj1.LOA__c = lsrloa.getId() ;
        prj1.Data_Collection_Start_Date__c = Date.newInstance(2008,8,1);
        prj1.End_Date__c = Date.newInstance(2008,9,1);        
        prj1.Divisions__c = 'Learning Collaborative';
        prj1.Programs__c = 'CPE';
        prj1.Product__c = 'General - LC';        
        prj1.Account__c = lsrAcc.getId();  
                    
        Projects__c prj2 = new Projects__c();
        prj2.Name = 'testProj1';
		prj2.LOA__c = lsrloa.getId() ;
        prj2.Data_Collection_Start_Date__c = Date.newInstance(2008,8,1);
        prj2.End_Date__c = Date.newInstance(2008,9,1);        
        prj2.Divisions__c = 'Learning Collaborative';
        prj2.Programs__c = 'CPE';
        prj2.Product__c = 'General - LC';        
        prj2.Account__c = lsrAcc.getId();              
        lsPrj.add(prj1);
        lsPrj.add(prj2);
        
        Database.SaveResult[] lsr1 = Database.insert(lsPrj, false);
        
        
        TimeSheet__c ts = new TimeSheet__c();
        ts.Name = '9/6/2008';
        ts.Week_Commencing__c = Date.newInstance(2008,9,6);
        ts.Status__c = 'Work in progress';
        Database.SaveResult lsr3 = Database.insert(ts, false);
        obj.timeSheetId = lsr3.getId();
        string temp = obj.timeSheetId;

        System.assertEquals([Select a.Name from TimeSheet__c a where a.Id = : lsr3.getId() limit 1].Name, '9/6/2008' );
        
        list<TimeSheetLine__c> lsTse = new list<TimeSheetLine__c>(); 
        TimeSheetLine__c tse1 = new TimeSheetLine__c();
        tse1.Timesheet__c = obj.timeSheetId;
        tse1.ProjectId__c = lsr1[0].getId();
        tse1.Hour__c = 1;
        lsTse.add(tse1);
        TimeSheetLine__c tse2 = new TimeSheetLine__c();
        tse2.Timesheet__c = obj.timeSheetId;
        tse2.ProjectId__c = lsr1[0].getId();
        tse2.Hour__c = 2;
        lsTse.add(tse2);
        TimeSheetLine__c tse3 = new TimeSheetLine__c();
        tse3.Timesheet__c = obj.timeSheetId;
        tse3.ProjectId__c = lsr1[1].getId();
        tse3.Hour__c = 3;
        lsTse.add(tse3);
        insert lsTse;
        
        obj.getProjects();
        
        
    }
    
    public BES_clsTimeSheetLinesController()
    {
        try
        {
            timeSheetId = String.escapeSingleQuotes(System.currentPageReference().getParameters().get('id'));
        }
        catch(Exception Ex)
        {
            //DO NOTHING
        }
    }
    
    public string timeSheetId
    {
        set
        {
           timeSheetId= value;
        }
        get
        {
           return timeSheetId; 
        }
    }
    public list <TimeSheetLine__c> getProjects()
    {
        list <TimeSheetLine__c> tsl = new list <TimeSheetLine__c> ();
        set <id> st = new set<id>();
        tsl = [SELECT Hour__c, ProjectId__c, ProjectId__r.Name, ProjectId__r.Account__c FROM TimeSheetLine__c WHERE Timesheet__c =: timeSheetId ORDER BY ProjectId__r.Name ASC];
        list <TimeSheetLine__c> tsl1 = new list <TimeSheetLine__c> ();
        
        set <Id> AccountIdSet = new Set<Id>();
        for(Integer j = 0; j < tsl.size(); j++)
        {
            AccountIdSet.add(tsl[j].ProjectId__r.Account__c);
        }
        
        list<Account> lstAccount = new list<Account>();
        lstAccount = [select Id, Name from Account where id in : AccountIdSet order by Name ASC];
              
        for(Integer k = 0; k < lstAccount.size(); k++)
        {        
            for(integer i = 0; i < tsl.size(); i++)
            {
               if(lstAccount[k].Id == tsl[i].ProjectId__r.Account__c)
               { 
                   if(st.add(tsl[i].ProjectId__c))
                   {
                        TimeSheetLine__c obj = new TimeSheetLine__c();
                        obj.ProjectId__c = tsl[i].ProjectId__c;
                        obj.Name = tsl[i].ProjectId__r.Name;
                        
                        obj.Description__c = lstAccount[k].Name;
                        obj.Hour__c = tsl[i].Hour__c;
                        tsl1.add(obj); 
                   }
                   else
                   {
                       for(integer j = 0; j < tsl1.size(); j++)
                       {
                           if(tsl[i].ProjectId__c == tsl1[j].ProjectId__c)
                           {
                               tsl1[j].Hour__c += tsl[i].Hour__c;
                               break;
                           }
                       } 
                   } 
               }    
            }
        }
        return tsl1; 
    }    
}