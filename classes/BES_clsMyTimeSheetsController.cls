public with sharing class BES_clsMyTimeSheetsController 
{
    public static testmethod void testMethod1()
    {
        BES_clsMyTimeSheetsController obj = new BES_clsMyTimeSheetsController();
        
        TimeSheet__c ts = new TimeSheet__c();
        ts.Name = '9/7/2008';
        ts.Week_Commencing__c = Date.newInstance(2008,9,7);
        ts.Status__c = 'Work in progress';
        insert ts;
        
        obj.getMyTimeSheets();
                
        obj.startDateString = '8/31/2008';
        obj.endDateString = '9/28/2008';
        obj.searchTimeSheets();
        
        obj.startDateString = 'liveman';
        obj.endDateString = 'deadman';
        obj.searchTimeSheets();
        
        obj.startDateString = '1/1/2009';
        obj.endDateString = '12/1/2009';
        obj.searchTimeSheets();
        
        obj.startDateString = '12/1/2009';
        obj.endDateString = '12/1/2008';
        obj.searchTimeSheets();
        
        string strTemp = obj.thisWeekStartString; 
        strTemp = obj.uId;
        strTemp = obj.thisMonthStartString;
        
        System.assertEquals([Select a.Name from TimeSheet__c a where a.Id = : ts.Id limit 1].Name, '9/7/2008' );
        
    }
    
    list<Date> lsWeekStarts ;
    Date firstWeekStart;
    Date lastWeekStart;
    
     
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
     public string thisWeekStartString
     {
        set
        {
           thisWeekStartString = value;
        }
        get
        {
           return thisWeekStartString; 
        }
     } 
     public string thisMonthStartString
     {
        set
        {
           thisMonthStartString= value;
        }
        get
        {
           return thisMonthStartString; 
        }
     } 
    public BES_clsMyTimeSheetsController()
    {
        uId = String.escapeSingleQuotes(UserInfo.getUserId());
        remindersOn = [SELECT Receive_Timesheet_Reminders__c FROM User WHERE id= : uId].Receive_Timesheet_Reminders__c;
        lsWeekStarts = new list<Date>();
        boolean isFirstLoad = false;
        
        Date thisDate = Date.today();
        Date thisWeekStart = thisDate.toStartOfWeek(); 
        thisWeekStartString = thisWeekStart.month().format()+'/'+thisWeekStart.day().format()+'/'+thisWeekStart.year();
        Date firstDay = thisDate.toStartOfMonth();
        thisMonthStartString = firstDay.month().format()+'/'+firstDay.day().format()+'/'+firstDay.year();
        try
        {
            startDateString = String.escapeSingleQuotes(System.currentPageReference().getParameters().get('from'));
            endDateString = String.escapeSingleQuotes(System.currentPageReference().getParameters().get('to'));
            
            if(startDateString == '' || startDateString == null || endDateString == '' || endDateString == null)
            {
                isFirstLoad = true;
            }
            else
            {
                searchTimeSheets();
            }
            
        }
        catch(Exception ex)
        {
           isFirstLoad = true; 
        }
        if(isFirstLoad)
        {
            
            firstWeekStart = firstDay.toStartOfWeek();
            lsWeekStarts.add(firstWeekStart);
            startDateString =  firstWeekStart.month().format()+'/'+firstWeekStart.day().format()+'/'+firstWeekStart.year();
            integer counter = 1;
            while(true)
            {
                Date dt = firstWeekStart.addDays(7*counter);
                if(dt.month() != thisDate.month())
                {
                    break;
                }
                lsWeekStarts.add(dt);
                endDateString =  dt.month().format()+'/'+dt.day().format()+'/'+dt.year();
                lastWeekStart = dt;
                counter++; 
            }
        }
        
        
        
    }
    public pageReference searchTimeSheets()
    {
        
        try
        {
            list <string> str1 = startDateString.split('/',0);
            string d1 = str1.get(1); 
            if(d1.length() == 1)
            {
               d1 = '0' + d1; 
            }
            string m1 = str1.get(0); 
            if(m1.length() == 1)
            {
               m1 = '0' + m1; 
            }
            string y1 = str1.get(2);
             
            
            list <string> str2 = endDateString.split('/',0);
            string d2 = str2.get(1);
            if(d2.length() == 1)
            {
               d2 = '0' + d2; 
            } 
            string m2 = str2.get(0);
            if(m2.length() == 1)
            {
               m2 = '0' + m2; 
            } 
            string y2 = str2.get(2);
            
            Date date1 = Date.valueOf(y1+'-'+m1+'-'+d1+' 00:00:00');
            Date date2 = Date.valueOf(y2+'-'+m2+'-'+d2+' 00:00:00');
            if(date1.daysBetween(date2) < 0)
            {
                return null;
            }
            lsWeekStarts = new list<Date>();
            
            firstWeekStart = date1.toStartOfWeek();
            lsWeekStarts.add(firstWeekStart);
            startDateString =  firstWeekStart.month().format()+'/'+firstWeekStart.day().format()+'/'+firstWeekStart.year();
            
            integer counter = 1;
            while(true)
            {
                Date dt = firstWeekStart.addDays(7*counter);
                if(dt.daysBetween(date2)< 0)
                {
                    break;
                }
                lsWeekStarts.add(dt);
                endDateString =  dt.month().format()+'/'+dt.day().format()+'/'+dt.year();
                lastWeekStart = dt;
                counter++; 
            }
            
             
        }
        catch(Exception ex)
        { 
           //DO NOTHING
        }
        
        return null;
    }
    public list<TimeSheet__c> getMyTimeSheets()
    {
        list <TimeSheet__c> ts = new list<TimeSheet__c> ();
        for(integer i = 0; i < lsWeekStarts.size(); i++ )
        {
            TimeSheet__c newTs = new TimeSheet__c();
            newTs.Status__c  = 'Not Started';
            newTs.Name = lsWeekStarts[i].month().format()+'/'+lsWeekStarts[i].day().format()+'/'+lsWeekStarts[i].year();
            newTs.Week_Commencing__c = lsWeekStarts[i];
            ts.add(newTs); 
        }
        
        list <TimeSheet__c> ts1 = [SELECT  Id, Name,  Status__c, Total_Hours__c, Week_Commencing__c FROM Timesheet__c WHERE OwnerId = : userinfo.getuserid() AND Week_Commencing__c in : lsWeekStarts ORDER BY Week_Commencing__c ASC];
        
        for(Integer i = 0; i< ts.size(); i++)
        {
            for(Integer j = 0; j< ts1.size(); j++)
            {
                if(ts[i].Week_Commencing__c.isSameDay(ts1[j].Week_Commencing__c))
                {
                    ts[i] = ts1[j];
                }
            }
        }     
       
        return ts;  
    }
    
    public boolean remindersOn
    {
         set
        {
           remindersOn = value;

        }
        get
        {
           return remindersOn; 
        }
    }
    
        
     public String uId 
     {
        set
        {
           uId = value;

        }
        get
        {
           return uId ; 
        }
     }
      
      
}