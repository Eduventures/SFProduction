public with sharing class BES_clsEditTimeSheetController
{
    public static testmethod void testMethod1()
    {
        BES_clsEditTimeSheetController obj = new BES_clsEditTimeSheetController();
        
        list<TimeSheet__c> lsTs = new list<TimeSheet__c>();
        TimeSheet__c ts1 = new TimeSheet__c();
        ts1.Name = '9/7/2008';
        ts1.Week_Commencing__c = Date.newInstance(2008,9,7);
        ts1.Status__c = 'Work in progress';
        lsTs.add(ts1);
        TimeSheet__c ts2 = new TimeSheet__c();
        ts2.Name = '9/14/2008';
        ts2.Week_Commencing__c = Date.newInstance(2008,9,14);
        ts2.Status__c = 'Rejected';
        lsTs.add(ts2);
        TimeSheet__c ts3 = new TimeSheet__c();
        ts3.Name = '9/21/2008';
        ts3.Week_Commencing__c = Date.newInstance(2008,9,21);
        ts3.Status__c = 'Submitted';
        lsTs.add(ts3);
        Database.SaveResult[] lsr1 = Database.insert(lsTs, false);
        
        obj.timeSheetId = lsr1[0].getId();
        obj.timeSheetId = lsr1[1].getId();
        obj.timeSheetId = lsr1[2].getId();
        
        System.assertEquals([Select a.Name from TimeSheet__c a where a.Id = : lsr1[0].getId() limit 1].Name, '9/7/2008' );
        System.assertEquals([Select a.Name from TimeSheet__c a where a.Id = : lsr1[1].getId() limit 1].Name, '9/14/2008' );
        System.assertEquals([Select a.Name from TimeSheet__c a where a.Id = : lsr1[2].getId() limit 1].Name, '9/21/2008' );
        
        obj.getTaskTypes();
        
        string strTemp = obj.timeSheetId;
        strTemp = obj.weekStartString;
        strTemp = obj.operation;
        strTemp = obj.uId;
        boolean boolTemp = obj.allowEdit;
        Timesheet__c tempRec = obj.timeSheetRec;
        
        obj.startDateString = '9/28/2008';
        strTemp = obj.startDateString ; 
        obj.endDateString = '9/28/2008';
        strTemp = obj.endDateString ;   
        
    }
    
    public string startDateString
    {
        set
        {
           startDateString= value;
        }
        get
        {
           return startDateString; 
        }
     }
     public string endDateString
     {
        set
        {
           endDateString = value;
        }
        get
        {
           return endDateString ; 
        }
     }
    public BES_clsEditTimeSheetController()
    {
        try
        {
            timeSheetId = String.escapeSingleQuotes(System.currentPageReference().getParameters().get('id'));
            startDateString = String.escapeSingleQuotes(System.currentPageReference().getParameters().get('from'));
            endDateString =  String.escapeSingleQuotes(System.currentPageReference().getParameters().get('to'));
        }
        catch(Exception Ex)
        {
                // DO NOTHING
        }
    }
    
    public String timeSheetId 
    {
        set
        {
           timeSheetId = String.escapeSingleQuotes(value);
           timeSheetRec = [SELECT Id, Name, OwnerId, Related_Projetcts__c, Status__c, Total_Hours__c, NoOfRows__c, Week_Commencing__c FROM Timesheet__c WHERE Id=:timeSheetId LIMIT 1];
           Date dt =  timeSheetRec.Week_Commencing__c;
           weekStartString =  dt.month().format()+'/'+dt.day().format()+'/'+dt.year();  
           uId = UserInfo.getUserId();
           if(timeSheetRec.Status__c == 'Work in progress' || timeSheetRec.Status__c == 'Rejected')
           {
               allowEdit = false;
               operation = 'Edit';
           }
           else
           {
               allowEdit = true;
               operation = 'View';
           }
        }
        get
        {
           return timeSheetId ; 
        }
    }  
    
    public Timesheet__c timeSheetRec
    {
        set
        {
           timeSheetRec = value;

        }
        get
        {
           return timeSheetRec; 
        }
    }
    public boolean allowEdit
    {
        set
        {
           allowEdit = value;
        }
        get
        {
           return allowEdit; 
        }
    }
    public string weekStartString
    {
        set
        {
           weekStartString = value;
        }
        get
        {
           return weekStartString; 
        }
    }
    public String uId 
    {
        set
        {
           uId = UserInfo.getUserId();

        }
        get
        {
           return uId ; 
        }
    }  
    public String operation
    {
        set
        {
           operation = value;

        }
        get
        {
           return operation; 
        } 
    }
    
    public List<SelectOption> getTaskTypes()
    {
        //This code is the backup for making the Task type picklist in alphabetical order for billable and nonbillable
        /*List<SelectOption> options = new List<SelectOption>();
        List<BESTS__TaskType__c> taskTypes = [SELECT Id, Name, BESTS__Billable__c FROM BESTS__TaskType__c ORDER BY BESTS__Billable__c DESC];
        options.add(new SelectOption('', '------ Billable ------' ));
        
        boolean isNonBillableAdded = false;
        for(integer i = 0; i < taskTypes.size(); i++)
        {
             if(!taskTypes[i].BESTS__Billable__c && !isNonBillableAdded)
             {
                 options.add(new SelectOption('', '----- Non Billable -----' ));
                 isNonBillableAdded = true;
             }
             options.add(new SelectOption(taskTypes[i].Id , taskTypes[i].Name));
        }
        return options;*/ 
		////////////////////////////////Srinivas code begins//////////////////////////////
        List<SelectOption> options = new List<SelectOption>();
        List<TaskType__c> taskTypes = [SELECT Id, Name, Billable__c FROM TaskType__c where Billable__c = true ORDER BY Name];
        options.add(new SelectOption('', '------ Billable ------' ));
        for(integer i = 0; i < taskTypes.size(); i++)
        {
            options.add(new SelectOption(taskTypes[i].Id , taskTypes[i].Name));
        }
        taskTypes = [SELECT Id, Name, Billable__c FROM TaskType__c where Billable__c = false ORDER BY Name];
        options.add(new SelectOption('', '----- Non Billable -----' )); 
        for(integer i = 0; i < taskTypes.size(); i++)
        {
            options.add(new SelectOption(taskTypes[i].Id , taskTypes[i].Name));
        }
        return options; 
		///////////////////////////////////Srinivas code ends////////////////////////////////////
    }  
    
}