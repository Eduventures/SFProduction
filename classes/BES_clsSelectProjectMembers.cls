public with sharing class BES_clsSelectProjectMembers 
{
    public static testmethod void testMethod1()
    {
        BES_clsSelectProjectMembers obj = new BES_clsSelectProjectMembers();
         
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
       
        
        
        User usr  = [SELECT Id FROM User LIMIT 1];
        ProjectMember__c projMem = new ProjectMember__c();
        projMem.UserId__c = usr.Id;
        projMem.ProjectId__c = lsr1.getId();
        Database.SaveResult lsr2 = Database.insert(projMem, false);
        
        obj.projectId = lsr1.getId();
        
        obj.getUsers();
        obj.likeString = 'b';
        obj.getUsers();
        obj.searchUsers();
        String strTemp = obj.likeString;
        strTemp = obj.projectId;
        
        System.assertEquals([Select a.Name from Projects__c a where a.Id = :obj.projectId limit 1].Name, 'testProj1' );
    }
    
    
    public BES_clsSelectProjectMembers()
    {
        try
        {
            projectId = String.escapeSingleQuotes(System.currentPageReference().getParameters().get('id'));
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
           String strTemp = projectId;
           list<ProjectMember__c> lsMembers = [SELECT UserId__c FROM ProjectMember__c WHERE ProjectId__c = :strTemp];
           
           for(integer i = 0; i < lsMembers.size(); i++)
           {
               lsExistingMembers.add(lsMembers[i].UserId__c); 
           }
           
        }
        get
        {
           return projectId; 
        }
    }
    set <Id> lsExistingMembers = new set <Id>();
   
    list <User> lsUser = new list<User>();
    public string likeString
    {
        set
        {
           likeString = value;
        }
        get
        {
           return likeString ; 
        }
    }
    
    public list<User> getUsers()
    {
        
        if(likeString =='' || likeString ==null)
        {
            lsUser = [SELECT Id, FirstName, LastName, UserRole.Name, Profile.Name FROM User WHERE Id NOT IN :lsExistingMembers ORDER BY Name ASC LIMIT 50];
        }
        else
        {
             string likeString1 =  '%'+String.escapeSingleQuotes(likeString) +'%';
             lsUser = [SELECT Id, FirstName, LastName, UserRole.Name, Profile.Name FROM User WHERE Name LIKE : likeString1 AND Id NOT IN :lsExistingMembers ORDER BY Name ASC LIMIT 50];
        }
        return lsUser ;
    }
     public PageReference searchUsers()
     {
        getUsers();
        return null;
     }

}