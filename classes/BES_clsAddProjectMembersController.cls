public with sharing class BES_clsAddProjectMembersController
{
    public static testmethod void testMethod1()
    {
        BES_clsAddProjectMembersController obj = new BES_clsAddProjectMembersController();
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
        
        Projects__c prj = new Projects__c();
        prj.Name = 'testProj1';
		prj.LOA__c = lsrloa.getId() ;
        prj.Data_Collection_Start_Date__c = Date.newInstance(2008,8,1);
        prj.End_Date__c = Date.newInstance(2008,9,1);        
        prj.Divisions__c = 'Learning Collaborative';
        prj.Programs__c = 'CPE';
        prj.Product__c = 'General - LC';        
        prj.Account__c = lsrAcc.getId();              
        Database.SaveResult lsr1 = Database.insert(prj, false); 
        System.debug('*********************************************lsr1111' + lsr1);
        obj.projectId = prj.Id;
        String temp = obj.projectId;
        Projects__c objP = prj;
        Projects__c strTemp = objP;
        
        System.assertEquals([Select a.Name from Projects__c a where a.Id = : obj.projectId limit 1].Name, 'testProj1' );
        
    }
    
    
    public BES_clsAddProjectMembersController()
    {
        try
        {
            projectId = System.currentPageReference().getParameters().get('id');
        }
        catch(Exception ex)
        {
            // DO NOTHING
        }
    }
     
    public string projectId
    {
        set
        {
           projectId = value;
           projectRec = [SELECT Id, Name FROM Projects__c WHERE id =: projectId LIMIT 1];
        }
        get
        {
           return projectId; 
        }
    }
    public Projects__c projectRec
    {
        set
        {
           projectRec = value;
        }
        get
        {
           return projectRec; 
        }
     }
     
}