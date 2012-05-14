public with sharing class BES_clsAddTimeSheetController 
{
   public static testmethod void testMethod1()
    {
        BES_clsAddTimeSheetController obj = new BES_clsAddTimeSheetController();
        obj.weekOf = '9/28/2008';
        string strTemp = obj.weekOf;
        strTemp =  obj.uId;
        
        obj.getTaskTypes();
        obj.startDateString = '9/28/2008';
        strTemp = obj.startDateString ; 
        obj.endDateString = '9/28/2008';
        strTemp = obj.endDateString ;   
        
        System.assert(true);
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
    
    
    public BES_clsAddTimeSheetController()
    {
         try
         {
             weekOf = String.escapeSingleQuotes(System.currentPageReference().getParameters().get('week'));
             startDateString = String.escapeSingleQuotes(System.currentPageReference().getParameters().get('from'));
             endDateString =  String.escapeSingleQuotes(System.currentPageReference().getParameters().get('to'));
         }
         catch(Exception ex)
         {
             // DO NOTHING
         }   
    }
    
    public String weekOf
    {
        set
        {
           weekOf = value;
           uId = UserInfo.getUserId();  
        }
        get
        {
           return weekOf ; 
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
     
    public List<SelectOption> getTaskTypes()
    {
        
        //This code is the backup for making the Task type picklist in alphabetical order for billable and nonbillable
        /*List<SelectOption> options = new List<SelectOption>();
        List<BESTS_TaskType__c> taskTypes = [SELECT Id, Name, BESTS_Billable__c FROM BESTS_TaskType__c ORDER BY BESTS_Billable__c DESC];
        options.add(new SelectOption('', '------ Billable ------' ));
        
        boolean isNonBillableAdded = false;
        for(integer i = 0; i < taskTypes.size(); i++)
        {
             if(!taskTypes[i].BESTS_Billable__c && !isNonBillableAdded)
             {
                 options.add(new SelectOption('', '----- Non Billable -----' ));
                 isNonBillableAdded = true;
             }
             options.add(new SelectOption(taskTypes[i].Id , taskTypes[i].Name));
        }
        if(!isNonBillableAdded)
        {
                options.add(new SelectOption('', '----- Non Billable -----' ));                 
        }*/
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