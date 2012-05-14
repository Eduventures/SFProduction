public class MemberActivityProjectsViewController {

    public String selectedAcctId{get;set;} 
    public String projecttype {get;set;}
    public String program {get;set;}
    public Integer days {get;set;}
    public Date searchDate {get;set;}
    public List<String> researchProjectTypes; 
    public List<String> participationProjectTypes; 
    public List<String> projectProducts;
    public List<String> openProjectStages;
    public List<String> programOptions {get;set;}
    public List<ProjectContainer> projectsList;
    public ProjectContainer selectedProject;
    public String pageparameters;
    public List<Projects__c> results {get;set;}
    public class hoursSummaryClass
    {
        public Decimal totalHours { get;set; }
        public String fullName { get;set; }
    
        public hoursSummaryClass(String name,Decimal hours)
        {
            totalHours = hours;
            fullName = name;
        }
    }
    public class ProjectContainer{
        public Decimal total_new_hours{get;set;} 
        public Projects__c theProjec {get;set;} 
        public Map<String,Decimal> userHours {get;set;}
        public List<String> userList {get;set;}
        public List<hoursSummaryClass> projectHours;
        public Projects__c theProject {get;set;}
        
        public ProjectContainer(Projects__c p) {
            userHours= new Map<String,Decimal> ();
            userList = new List<String>();
            theProject = p;
            total_new_hours = 0;
            projectHours = new List<hoursSummaryClass>(); 
            for(TimeSheetLine__c t: p.Time_Sheet_Entry__r)
            {
                if(userHours.containsKey(t.UserId__r.Name))
                {
                    Decimal temp = userHours.get(t.UserId__r.Name) + t.Hour__c; 
                    userHours.put(t.UserId__r.Name, temp );
                }else
                {
                	userList.add(t.UserId__r.Name);
                    userHours.put(t.UserId__r.Name, t.Hour__c);
                }                                    
            }
            
            for(String name : userList)
            {
            	projectHours.add(new hoursSummaryClass(name,userHours.get(name)));
            	total_new_hours = total_new_hours + userHours.get(name);
            }
        }
        
        public List<hoursSummaryClass> getprojectHours()
        {
        	return projectHours; 
        }
                
    }
    
    public MemberActivityProjectsViewController () {
        init();        
    }
    
    public void init() {
        programOptions = new List<String>();
        selectedAcctId = '';
        projecttype = '';
        researchProjectTypes = new List<String>{'ACCT MGMT','CHK-IN CALL','CA','CI','CRI','CRR','CV','Q&A','RB','SS'};
        participationProjectTypes = new List<String>{'AMM','CA-p','CRT','MR','MYC','OBC'};
        openProjectStages  = new List<String>{'Prospect','Outreach','Scoping','Approval','Research','In Progress','Analysis & Writing','Scheduled'};
        selectedAcctId = ApexPages.currentPage().getParameters().get('selectedacctid');
        projecttype = ApexPages.currentPage().getParameters().get('projecttype');
        program = ApexPages.currentPage().getParameters().get('program').substring(0,3);
        programOptions.add(program);
        programOptions.add(program +'-RL');
        days = integer.valueof(ApexPages.currentPage().getParameters().get('days'));
        searchDate = System.today() - days;
        projectsList = new List<ProjectContainer>();
		String queryAdd = '';
		
        if(projecttype == 'participation')
        {
            projectProducts = participationProjectTypes;
        }
        else if (projecttype == 'research'){ 
             projectProducts = researchProjectTypes;
        }
       
        results = [Select p.Name, p.Product__c, p.CreatedDate, p.End_Date__c, p.Account__c, p.Programs__c, 
                            p.Stage__c, p.Actual_Delivery_Date__c, p.Master_Project__r.Actual_Delivery_Date__c, 
                            p.LastModifiedDate, p.Project_Score__c, p.Total_Hours_Calc__c, p.LOA__c,
                                 (Select Date__c, Hour__c, Description__c, ProjectId__c, TaskType__c, UserId__r.Name From Time_Sheet_Entry__r where Date__c >= :searchDate ORDER BY UserId__r.Name) 
                            From Projects__c p where p.Account__c = :selectedAcctId and p.Programs__c in :programOptions  and 
                            (
                                (p.Stage__c not in ('Abandoned','Completed','Delivered','On Hold') and (p.Product__c not in :participationProjectTypes)) or
                                (
                                    ((p.Stage__c = 'Delivered') and (p.Actual_Delivery_Date__c >= :searchDate )) 
                                    or 
                                    ((p.Stage__c = 'Completed') and (p.End_Date__c >= :searchDate))
                                )
                            ) and p.Product__c in :projectProducts ORDER BY p.Product__c, p.LastModifiedDate DESC];
                             
        for(Projects__c result: results)
        {
            projectsList.add(new ProjectContainer(result));            
        }

    }
    
    public void setselectedProject( ProjectContainer temp) 
    {
        selectedProject = temp;
    }
    public ProjectContainer getselectedProject() 
    {
        return selectedProject;
    }   
    public PageReference selectP() {
        String selectedProjectId = ApexPages.currentPage().getParameters().get('pid');
        for(ProjectContainer pc: projectsList)
        {
            if(pc.theProject.Id == selectedProjectId )
            {
                selectedProject = pc;
            }
        } 
        return null;
    }
    
    public List<ProjectContainer> getprojectsList() {
        return projectsList;
    }
    
    public void setprojectsList(List<ProjectContainer> plist) {
        projectsList = plist;
    }
        
    public String getpageparameters() {
        Map <String,String> params = ApexPages.currentPage().getParameters();
        pageparameters = '( ';
        for(String s: params.keySet())
        {
            if(!'AJAXREQUEST,com.salesforce.visualforce.ViewStateCSRF'.contains(s))
            {
                pageparameters = pageparameters + s + ':' + params.get(s)+ '; ' ; 
            }
        }  
        pageparameters = pageparameters + ')';
        return pageparameters;
    }

}