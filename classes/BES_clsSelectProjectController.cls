public with sharing class BES_clsSelectProjectController
{ 
    public String queryModifier;
    
    public static testmethod void testMethod1()
    {
        BES_clsSelectProjectController obj = new BES_clsSelectProjectController();
        obj.getProjects();
        obj.setqueryModifier('weeks');
        obj.getProjects();
        obj.setqueryModifier('month');
        obj.getProjects();
        obj.setqueryModifier('all');
        obj.getProjects();        
        obj.getqueryModifier();
        obj.getItems();
        
        System.assert(true);
    }
    
    public BES_clsSelectProjectController()
    {
         queryModifier = 'open';   
    }
        
    public String getqueryModifier()
    {
        return queryModifier;
    }
    
    public void setqueryModifier(String s)
    {
        queryModifier = s;
    }
    
    public List<SelectOption> getItems() {List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('open','Not yet Completed/Delivered'));
        options.add(new SelectOption('weeks','Completed/Delivered within past 2 weeks'));
        options.add(new SelectOption('month','Completed/Delivered within past month'));
        options.add(new SelectOption('all','All Completed/Delivered projects'));
        return options;
    }

    
    public list <ProjectMember__c> getProjects()
    {
        list <ProjectMember__c> projectList = new list <ProjectMember__c> ();
        String projectQuery ='';
        
        if(queryModifier == 'open')
        {
            projectList = [SELECT ProjectId__c, ProjectId__r.Name, UserId__c FROM ProjectMember__c WHERE UserId__c=: userinfo.getuserid() and ProjectId__r.Can_Log_Time__c = true and ProjectId__r.Stage__c NOT IN ('Completed', 'Delivered', 'Abandoned') ORDER BY ProjectId__r.Name ASC]; 
        
        }
        else if ( queryModifier == 'weeks') 
        {
             projectList = [SELECT ProjectId__c, ProjectId__r.Name, UserId__c FROM ProjectMember__c WHERE UserId__c=: userinfo.getuserid() and ProjectId__r.Can_Log_Time__c = true and ProjectId__r.Stage__c IN ('Completed', 'Delivered') and (ProjectId__r.Actual_Delivery_Date__c = LAST_N_DAYS:14 or ProjectId__r.End_Date__c = LAST_N_DAYS:14) ORDER BY ProjectId__r.Name ASC];
        }
        else if (queryModifier  == 'month' ) 
        {
            projectList = [SELECT ProjectId__c, ProjectId__r.Name, UserId__c FROM ProjectMember__c WHERE UserId__c=: userinfo.getuserid() and ProjectId__r.Can_Log_Time__c = true and ProjectId__r.Stage__c IN ('Completed', 'Delivered') and (ProjectId__r.Actual_Delivery_Date__c = LAST_MONTH or ProjectId__r.End_Date__c =  LAST_MONTH) ORDER BY ProjectId__r.Name ASC];
        } 
        else if (queryModifier  == 'all')
        {
            projectList = [SELECT ProjectId__c, ProjectId__r.Name, UserId__c FROM ProjectMember__c WHERE UserId__c=: userinfo.getuserid() and ProjectId__r.Can_Log_Time__c = true and ProjectId__r.Stage__c IN ('Completed', 'Delivered') ORDER BY ProjectId__r.Name ASC]; 
        }

        return projectList;   
    }
    
    
}