public class ProjectsDashboardController {

    public List<Projects__c> projectList;
    public List<Projects__c> projectsToUpdate {get;set;}
    public List<User> staffList;
    public Date weekStart {get;set;}
    public Date weekEnd {get;set;}
    public Projects__c dummyProject;
    public List<StaffUtilizationData> weeksData;
    public String message {get;set;}
    public Integer projIndex;
    public Integer pageNumber {get;set;}         
    public Boolean refresh;
    public ProjectsDashboardController() {
        init();
    }
    
    public void init() {
        pageNumber = 1;
        refresh = false;
        weekStart = System.today().toStartOfWeek() + 1;
        weekEnd = System.today().toStartOfWeek() + 5;
        projectList = new List<Projects__c>();
        projectsToUpdate = new List<Projects__c>();
        projIndex = 0;
        runProjectList();
        staffList = new List<User>();
        weeksData = new List<StaffUtilizationData>();
        runStaffData();
    }
    
    public class StaffUtilizationData {
    
        public User staffMember {get; set;}
        Date wStart;
        Date wEnd;
        public List<Project_Milestone__c> milestones {get;set;}
        public Decimal budgetedHours {get; set;}
        public Decimal bookedHours {get; set;}
        public Decimal percentTimeBudgeted {get; set;}
    
        public Boolean isWorkDay(Date d){
            Integer daycount = d.toStartOfWeek().daysBetween(d);
            if( daycount == 0 || daycount == 6)
            {
                return false;
            }
            return true;
        }
        
        public StaffUtilizationData(User u, Date startW, Date endW){
            staffMember = u;
            wStart = startW;
            wEnd = endW;  
            budgetedHours = 0;
            percentTimeBudgeted  = 0.00;
            milestones = new List<Project_Milestone__c>();
            System.debug(staffMember.Name + ' milestone count = ' + staffMember.Project_Milestones__r);
            if(staffMember.Work_Week_hours__c != null && staffMember.Work_Week_hours__c != 0) 
            {
	            for(Project_Milestone__c pm: staffMember.Project_Milestones__r)
	            {
	                Decimal calculatedWorkDays = pm.Work_Days__c;
	                Decimal tempBudgetedhours = 0.00;
	                
	                milestones.add(pm);
	
	                if(wStart <= pm.Start__c && pm.End__c <= wEnd )
	                {
	                    //if the milestone is started & ended within the week, 
	                    //count all hours towards the weekly budget
	                    tempBudgetedhours = pm.Estimated_Hours__c;
	                    
	                }else if ( pm.Start__c < wStart && wEnd < pm.End__c)
	                {
	                    //if the milestone starts before the week and
	                    //continues after it, just take 5 days worth of 'smoothed hours' (e.g. avg hours)
	                    tempBudgetedhours =  5*pm.Average_Daily_Hours__c;
	                    
	                }else
	                {
	                    //if milestone started before this week, figure 
	                    //out how many work days  were already spent
	                    if(pm.Start__c < wStart)
	                    {
	                        for(Integer i = 0; i < pm.Start__c.daysBetween(wStart) ; i++)
	                        {
	                            if( isWorkDay(pm.Start__c + i))
	                            {
	                                calculatedWorkDays = calculatedWorkDays-1;     
	                            }
	                        }  
	                    }
	                    
	                    //if milestone ended after this week, figure 
	                    //out how many work days don't figure into this week
	                    if(wEnd < pm.End__c )
	                    {
	                        for(Integer i = 1; i < wEnd.daysBetween(pm.End__c) ; i++)
	                        {
	                            if( isWorkDay(wEnd + i))
	                            {
	                                calculatedWorkDays = calculatedWorkDays-1;     
	                            }
	                        }  
	                    }
	                    
	                    tempBudgetedhours = calculatedWorkDays*pm.Average_Daily_Hours__c;  
	                
	                }
	                budgetedHours = budgetedHours + tempBudgetedhours;
	            }
	            
	            percentTimeBudgeted = budgetedHours.divide(staffMember.Work_Week_hours__c, 2, System.RoundingMode.UP); 
            }
        }
    }
    
    private void runStaffData() {
        //find all staff whose profile is 'consulting'
        staffList = [Select u.ProfileId, u.Name, u.IsActive, u.Billing_Rate__c, u.Work_Week_Hours__c,
            //include subquery for timesheet line entries here
            (Select Name, Project__c, Project__r.name, Assigned_To__c, Estimated_Hours__c,
                Booked_Hours__c, Status__c, Start__c, End__c, 
                Preceeding_Milestone__c, Work_Days__c, Average_Daily_Hours__c 
                From Project_Milestones__r
                where Start__c <= :weekEnd and  End__c >= :weekStart order by Start__c, End__c
            ) 
             From User u where u.ProfileId = '00e30000000nDXP' ORDER BY u.Name];
        weeksData.clear();     
        for(User u: staffList)
        {
            weeksData.add(new StaffUtilizationData(u,weekStart,weekEnd));
        }
    
    }
    
    private void runProjectList() {
        refresh = true;
        projectList = (List<Projects__c>) setCon.getRecords();
    }
    
    public List<Projects__c> getProjectList (){
        return projectList;
    }

    public List<User> getStaffList (){
        return staffList;
    }

    public List<StaffUtilizationData> getWeeksData() {
        return weeksData;
    }
     
    public ApexPages.StandardSetController setCon {
        get {
            if(setCon == null || refresh == true) {
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(
                      [Select p.Variance__c, p.Total_Hours_Calc__c, p.Programs__c, p.Name, p.Stage__c,  
                p.Milestone_Hours__c, p.Estimated_End_Date__c, p.Active__c, p.Account__c, p.Billable_Hours__c, 
                p.LastModifiedDate, p.CreatedDate, p.Complete_by_hours__c, p.Approval_Date__c, p.Estimated_Hours__c, 
                (Select Name, Project__c, Assigned_To__c, Estimated_Hours__c, Booked_Hours__c, Status__c, Start__c, End__c, 
                Preceeding_Milestone__c, Project__r.name, Work_Days__c, Average_Daily_Hours__c 
                From Project_Milestones__r order by Start__c, End__c )
                 From Projects__c p where p.Programs__c = 'ECS' and p.Active__c = true ORDER BY p.Estimated_End_Date__c DESC]));
                refresh = false;
                setCon.setPageSize(10);
                setCon.setPageNumber(pageNumber); 
            }
            return setCon;
        }
        set;
    }

    // Initialize setCon and return a list of records  
    
    public List<Projects__c> getActiveProjects() {
        projectList = (List<Projects__c>) setCon.getRecords();
        return projectList; 
        //return (List<Projects__c>) setCon.getRecords();
    }
    
    public PageReference nextWeek(){
        weekStart = weekStart + 7;
        weekEnd = weekEnd + 7;
        runStaffData();
        return null;
    }

    public PageReference previousWeek(){
        weekStart = weekStart - 7;
        weekEnd = weekEnd - 7;
        runStaffData();
        return null;
    }    
    
    public PageReference next() {
        if(projectsToUpdate.isEmpty())
        {
            Integer p = setCon.getPageNumber();
            
            if(hasNext) {
                setCon.setPageNumber(p+1);
                pageNumber = setCon.getPageNumber();
            }        
        } else
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'You did not save your changes to the projects: please hit either <b>Save</b> or <b>Cancel.</b>');
            Apexpages.addMessage(myMsg);
        }

        
        return null;
    }
    
    public PageReference previous() {
                
        Integer p = setCon.getPageNumber();
        
        if(hasPrevious) {
            setCon.setPageNumber(p-1);
            pageNumber = setCon.getPageNumber();
        }
        
        return null;
    }

    public Integer getprojIndex()
    {
        return projIndex;
    }
        
    public void setprojIndex(Integer i)
    {
        projIndex = i;
    }
    
    public Boolean hasPrevious {
        get {
            return setCon.getHasPrevious();
        }
    }
    
    public Boolean hasNext {
        get {
            return setCon.getHasNext();
        }
    } 
    
    public PageReference addProjectForUpdate() {
        projIndex = Integer.valueOf(Apexpages.currentPage().getParameters().get('projIndex'));
        projIndex = projIndex-1;
        System.debug('projIndex = ' + projIndex);
        Boolean inList = false;
        Projects__c temp = projectList[projIndex];
        for(Projects__c added: projectsToUpdate)
        {
            if(added.Id == temp.Id)
            {
                inList = true;
                return null;
            }
        }
        projectsToUpdate.add(temp);
        return null;
    }

    public PageReference cancel(){
        projectsToUpdate.clear();
        runProjectList();
        return null;
    }
    
        
    public PageReference save(){
    
      try {
            System.debug('projectsToUpdate size is ' + projectsToUpdate.size());
            for(Projects__c temp: projectsToUpdate)
            {
                update temp;
                System.debug('Saved project ' + temp.name);
                ApexPages.Message saveOk = new ApexPages.Message(ApexPages.Severity.INFO, 'Projects Updated Successfully');
                Apexpages.addMessage(saveOk);
            }
            projectsToUpdate.clear();
            System.debug('projectsToUpdate.size = ' + projectsToUpdate.size());
            pageNumber = 1;
            runProjectList();
            return null; 
        }
        catch(Exception e) {
            ApexPages.Message saveFail = new ApexPages.Message(ApexPages.Severity.ERROR, 'There was a problem saving your edits! Save not committed.');
            Apexpages.addMessage(saveFail);
            message = 'An Error Occurred! Save not committed.' + e.getMessage();
            return null;    
        }
    }
    
}