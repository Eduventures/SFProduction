public class MemberActivityController {

    public List<MemberData> dataPoints {get;set;}
    public MemberData selectedDataPoint {get;set;}
    public String pageparameters;
    public Boolean reverseSort {get;set;}
    public String filterfield {get;set;}
    public String filtervalue {get;set;}
    public String sortfieldname {get;set;}
    public String sortfunction {get;set;}
    public List<String> currentPrograms;
    public String researchProjectTypes {get;set;}
    public String participationProjectTypes {get;set;}
	public List<String> participationProjectTypesList;    
    public String selectedProgram;
    public Projects__c prototype {get;set;} 
    public Map<Id,Integer> acctsMap; 
    public List<Id> allMemberIds {get;set;}
    public Map<Id, Map<Id, List<TimeSheetLine__c>>> allProjectTimeEntries {get;set;}
    public Integer allProjectTimeEntriesSize {get;set;}
    public String selectedAcct {get;set;} 
    public String projecttype {get;set;} 
    public Map<Id,List<Projects__c>> allProjects;
    public Integer daysBackToSearch;
    public String renewalDateSelected;
    private String renewalDateFilter;
    public Integer currentQuarter {get;set;}
    public List<String> renewalDateFilterOptions;
    public Integer membersWithInteraction {get;set;}
    public Integer percentWithInteraction {get;set;}
     
    
    public class MemberData {
        public Boolean filtered {get;set;}
        public Boolean editingRM {get;set;}
        public Boolean editingRR {get;set;}
        public LOA__c contract  {get;set;}
        public Integer researchCount {get;set;}
        public Integer participationCount  {get;set;}        
        public String Program {get;set;}
        public List<Projects__c> research_requests {get;set;}
        public List<Projects__c> participation {get;set;}
        public Opportunity renewalOpp {get;set;}
        public Integer total_interaction_count {get;set;}  
        public Decimal total_new_hours {get;set;}
        public Map<Id,List<TimeSheetLine__c>> projectTimeEntries;
        public Integer timeEntriesCount {get;set;}
        //public String researchProjectnames;  //debugging info 
        //public String participationProjectnames;     //debugging info 

        //constructors 
        public MemberData(LOA__c l) {
            total_new_hours = 0;
            timeEntriesCount = 0;
            editingRM  = false;
            editingRR  = false;
            filtered = false;
            contract = l;
            Program = l.Program__c;
            projectTimeEntries = new Map<Id,List<TimeSheetLine__c>>();
        }
        
        //debugging info 
        /*public String getresearchProjectnames() {
            String s = '';
            for(Projects__c p: research_requests)
            {
                s = s + p.Name+ ';';
            }
            return s;
        }*/
        
        //debugging info
        /*public String getparticipationProjectnames() {
            String s = '';
            for(Projects__c p: participation)
            {
                s = s + p.Name+ ';';
            }
            return s;
        }*/
        
        public void setprojectTimeEntries(Map<Id,List<TimeSheetLine__c>> entriesmap) {
            for(String keyvalue: entriesmap.keySet())
            {
                for(TimeSheetLine__c lineItem: entriesmap.get(keyvalue))
                {
                    total_new_hours = total_new_hours + lineItem.Hour__c;
                    timeEntriesCount = timeEntriesCount + 1;
                } 
            }
        }
                         
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
    
    public MemberActivityController() {
        init();
        system.debug('time string = ' + System.today().format());        
    }
    
    public void init() {
        allProjects = new Map<Id,List<Projects__c>>();
        daysBackToSearch = 0;
        selectedAcct = '';
        projecttype = '';
        acctsMap = new Map<Id,Integer>();
        dataPoints = new List<MemberData> ();
        allMemberIds = new List<Id>();
        prototype = new Projects__c();
        prototype.Approval_Date__c = System.today()-30;
        reverseSort = false;
        filterfield = '';
        filtervalue = '';
        sortfunction = '';
        sortfieldname = '';
        currentPrograms = new List<String>{'AIE','ACL','CPE','DEV','ENM','OHE','SOE'};
        researchProjectTypes = 'ACCT MGMT;CHK-IN CALL;CA;CI;CRI;CRR;CV;Q&A;RB;SS;';
        participationProjectTypes = 'AMM;CA-p;CRT;MR;MYC;OBC;';
        participationProjectTypesList = participationProjectTypes.split(';');
        selectedProgram = '';
        renewalDateFilter = '';
        populateRenewalDateFilter();
        allProjectTimeEntries = new Map<Id, Map<Id, List<TimeSheetLine__c>>>();
        membersWithInteraction = 0;      
        percentWithInteraction = 0;       
    }
    
    public Integer getdaysBackToSearch () {
        return daysBackToSearch;
    }
    
    public void setdaysBackToSearch () {
        daysBackToSearch  = prototype.Approval_Date__c.daysBetween(System.today()); 
    }
    
    public Map<Id,List<Projects__c>> getallProjects() {
        return allProjects;
    }
    
	public void populateRenewalDateFilter() {		
        integer currentMonth = System.today().month();
        currentQuarter = integer.valueOf(1 + currentMonth/4);
        renewalDateFilterOptions = new List<String>{ 'No filter (show all) '};
        for(integer i=0;i<5;i++)
		{
			String tempValue = '';
        	if(currentQuarter + i < 5)
        	{
        		renewalDateFilterOptions.add('Q' + (currentQuarter + i) + ' ' + System.today().year());
        	} else
        	{
        		renewalDateFilterOptions.add('Q' + (currentQuarter + i - 4) + ' ' + (System.today().year() + 1));
        	}
        }
	}   

    public String getrenewalDateSelected() {
		return renewalDateSelected;	   	 	
    } 

    public void setrenewalDateSelected(String s) {   	   	
		renewalDateSelected = s;
		setrenewalDateFilter(renewalDateSelected);
    }
   
    private String getrenewalDateFilter() {
		return renewalDateFilter;	   	 	
    } 

    private void setrenewalDateFilter(String s) {   	   	
    	if(s != 'No filter (show all) ')
    	{
    		Integer quarter = integer.valueOf(s.substring(1,2));
    		String year =  s.substring(3,7);
    		if(quarter == 1)
    		{
    			renewalDateFilter = 'l.End_Date__c >= ' + year + '-01-01 and l.End_Date__c <= ' + year + '-03-31 and ';
       		} else if(quarter == 2)
    		{
    			renewalDateFilter = 'l.End_Date__c >= ' + year + '-04-01 and l.End_Date__c <= ' + year + '-06-30 and ';
       		} else if(quarter == 3)
    		{
    			renewalDateFilter = 'l.End_Date__c >= ' + year + '-07-01 and l.End_Date__c <= ' + year + '-09-30 and ';
       		} else if(quarter == 4)
    		{
    			renewalDateFilter = 'l.End_Date__c >= ' + year + '-10-01 and l.End_Date__c <= ' + year + '-12-31 and ';
    		}
     	} else 
     	{
     		renewalDateFilter = '';
     	} 	
    }   
	 
    public void populateDataPointslist() {
        dataPoints.clear();
        acctsMap.clear();
        allMemberIds.clear();
        allProjects.clear();
        allProjectTimeEntries.clear();
        allProjectTimeEntriesSize = 0;
        membersWithInteraction = 0;
        percentWithInteraction= 0;
        acctsMap.put('0013000000G3Y0S',-1);
        List<String> programOptions = new List<String> ();
        if(selectedProgram == 'ENM')
        {
        	programOptions.add('SEM');
        }
        programOptions.add(selectedProgram);
        programOptions.add(selectedProgram +'-RL');
        setdaysBackToSearch();
        String myQuery;
        if(renewalDateFilter == '')
        {
        	myQuery = 'Select l.Type__c, l.Account__r.Active_Engagements__c, l.First_Year_Member__c, l.Account__r.Name, l.Research_Account_Manager__r.Name, l.Start_Date__c, l.End_Date__c, l.Status__c, l.Renewal_Risk__c, l.Renewed__c, l.Program__c, l.Name, l.Id, l.Account__c, (Select o.StageName From RenewalOpportunities__r o where o.StageName not in (\'Closed Won\',\'Closed Lost\',\'Remarket\',\'Replaced\') LIMIT 1) From LOA__c l where l.Program__c in :programOptions and l.Status__c in (\'Active\',\'Extended\',\'Pending\') and l.Account__c != \'0013000000G3Y0S\' ORDER BY l.Account__r.Name';
        }  else
        {
        	myQuery = 'Select l.Type__c, l.Account__r.Active_Engagements__c, l.First_Year_Member__c, l.Account__r.Name, l.Research_Account_Manager__r.Name, l.Start_Date__c, l.End_Date__c, l.Status__c, l.Renewal_Risk__c, l.Renewed__c, l.Program__c, l.Name, l.Id, l.Account__c, (Select o.StageName From RenewalOpportunities__r o where o.StageName not in (\'Closed Won\',\'Closed Lost\',\'Remarket\',\'Replaced\') LIMIT 1) From LOA__c l where ' + renewalDateFilter + ' l.Program__c in :programOptions and l.Status__c in (\'Active\',\'Extended\',\'Pending\') and l.Account__c != \'0013000000G3Y0S\' ORDER BY l.End_Date__c';
        } 
        List<LOA__c> members = Database.query(myQuery);      
        System.debug(' members.size() = ' +   members.size()); 
        Map<Id, Id> memberAccountMap = new Map<Id, Id>();
        for(LOA__c l: members)
        {  
            if(!memberAccountMap.containsKey(l.Account__c))
            {
                 allMemberIds.add(l.Account__c);
            }   
        }
		system.debug('Programoptions = ' + programOptions);
        //QUERY FOR LOOP: for select project (and timesheetentries) where LOAId is in 'members' list         
        for(Projects__c proj: [Select p.Name, p.Account__c, p.Product__c, p.CreatedDate, p.End_Date__c, p.Stage__c, 
                                p.Actual_Delivery_Date__c, p.Master_Project__r.Actual_Delivery_Date__c, p.LastModifiedDate, 
                                p.Project_Score__c, p.Total_Hours_Calc__c, p.LOA__c,
                                (Select Date__c, Hour__c, Description__c, ProjectId__c, TaskType__c 
                                    From Time_Sheet_Entry__r where Date__c >= :prototype.Approval_Date__c )
                    From Projects__c p where p.Account__c in :allMemberIds and p.Programs__c in :programOptions and 
                    (
                        (p.Stage__c not in ('Not Started','Abandoned','Completed','Delivered','On Hold') and (p.Product__c not in :participationProjectTypesList))  or  
                        (
                            ((p.Stage__c = 'Delivered') and (p.Actual_Delivery_Date__c >= :prototype.Approval_Date__c)) 
                            or 
                            ((p.Stage__c = 'Completed') and (p.End_Date__c >= :prototype.Approval_Date__c))
                        )
                    )])  
        {
            
            if(allProjects.containsKey(proj.Account__c))
            {
                allProjects.get(proj.Account__c).add(proj);
            }
            else 
            {
                allProjects.put(proj.Account__c, new List<Projects__c>());
                allProjects.get(proj.Account__c).add(proj);
            }
            //add the project's TimesheetLines to a map containing <LOAid, Map<ProjectId, List<TimeSheetLine>> >
            if(allProjectTimeEntries.get(proj.Account__c) == null)
            {
                allProjectTimeEntries.put(proj.Account__c, new Map<Id,List<TimeSheetLine__c>>());
                allProjectTimeEntries.get(proj.Account__c).put(proj.Id, proj.Time_Sheet_Entry__r);
            }else
            {
                allProjectTimeEntries.get(proj.Account__c).put(proj.Id, proj.Time_Sheet_Entry__r);
            }  
        }
        allProjectTimeEntriesSize = allProjectTimeEntries.size();
        //then when looping through members, add the map of the projectIds and thier related entries to the MemberData
        // by matching on LOAid [contract.Id]

        for(LOA__c currentMember : members )
		{
        	List<Projects__c> tempRR = new List<Projects__c> ();
            List<Projects__c> tempPP = new List<Projects__c> ();
            Opportunity tempRenewalOpp = new Opportunity ();
		    if(allProjects.containsKey(currentMember.Account__c))
			{
	        	for(Projects__c memProject: allProjects.get(currentMember.Account__c))
	            { 
	            	if( researchProjectTypes.contains(memProject.Product__c))
	                {
	                	tempRR.add(memProject);                        
	                }else if (participationProjectTypes.contains(memProject.Product__c))
	                {
	                	tempPP.add(memProject);
	                }
	                    
	            }					
			}

            if(!currentMember.RenewalOpportunities__r.isEmpty())
            {
                tempRenewalOpp = currentMember.RenewalOpportunities__r[0];
            }
            
            if(acctsMap.get(currentMember.Account__c)== null)
            { 
                MemberData tempMD = new MemberData(currentMember);
                tempMD.research_requests = tempRR;
                tempMD.participation = tempPP;
                if(!currentMember.Renewed__c)
                {
                    tempMD.renewalOpp = tempRenewalOpp;
                }
                if(allProjectTimeEntries.containsKey(currentMember.Account__c))
                {
                    tempMD.setprojectTimeEntries(allProjectTimeEntries.get(currentMember.Account__c));
                }
                else
                {
                     tempMD.setprojectTimeEntries(new Map<Id,List<TimeSheetLine__c>>());
                     //tempMD.setprojectTimeEntries(allProjectTimeEntries.get(currentMember.Id));
                }
                Integer index = dataPoints.size();
                dataPoints.add(tempMD);
                acctsMap.put(currentMember.Account__c,index);
            }
            else
            {
                Integer listIndex = acctsMap.get(currentMember.Account__c);
                dataPoints[listIndex].research_requests.addAll(tempRR);
                dataPoints[listIndex].participation.addAll(tempPP);
                //dataPoints[listIndex].projectTimeEntries.addAll(allProjectTimeEntries.get(currentMember.Id));
                if(!currentMember.Renewed__c)
                {
                   dataPoints[listIndex].renewalOpp = tempRenewalOpp;
                   dataPoints[listIndex].contract = currentMember;
                }
            }
        }     
    	for(MemberData md: dataPoints)
    	{
            Integer returnValue =  md.research_requests.size();
            for(Projects__c p: md.research_requests)
            {
                if(p.Product__c == ('ACCT MGMT'))
                {
                    returnValue--;
                }
            }
            md.researchCount = returnValue;
            md.participationCount = md.participation.size();
    		md.total_interaction_count = md.researchCount + md.participationCount;
    		
    		if(md.total_interaction_count > 0)
    		{
    			membersWithInteraction =  membersWithInteraction+1;
    		}
    	}
    	if(!dataPoints.isEmpty())
		{
			percentWithInteraction = (decimal.valueOf(membersWithInteraction) / dataPoints.size()*100).intValue();
		}
    }
          
    public void setselectedProgram(String s) {
        selectedProgram = s;
        reverseSort = false;
        filterfield = '';
        ApexPages.currentPage().getParameters().remove('filterfield');
        filtervalue = '';
        ApexPages.currentPage().getParameters().remove('filtervalue');
        /*sortfunction = 'string';
        ApexPages.currentPage().getParameters().put('sortfunction','string');
        sortfieldname = 'AcctName';
        ApexPages.currentPage().getParameters().put('sortfieldname','AcctName');*/
        sortfunction = '';
        sortfieldname = '';
       //populateDataPointslist();
    }

    public String getselectedProgram() {
        return selectedProgram;
    }
    
    public List<SelectOption> getcurrentPrograms() {
        List<SelectOption> optionList = new List<SelectOption>();
        optionList.add(new SelectOption('','--Select One--'));    
        for(String s:currentPrograms)
        {
            optionList.add(new SelectOption(s,s));
        }
        return optionList;
    }

    public List<SelectOption> getrenewalDateFilterOptions() {
        List<SelectOption> optionList = new List<SelectOption>();

        for(String s: renewalDateFilterOptions)
        {
            optionList.add(new SelectOption(s,s));
        }
        return optionList;
    }         
       
    public PageReference filterTable() {
        filterfield = ApexPages.currentPage().getParameters().get('filterfield');
        filtervalue = ApexPages.currentPage().getParameters().get('filtervalue');
        
        if(filterfield == 'Program')
        {
            filterDataPointProgram(filtervalue);
        }
        else if(filterfield == 'Research Account Manager')
        {
            filterDataPointManager(filtervalue);
        }
        else if(filterfield == 'Renewal Risk')
        {
            filterDataPointRisk(filtervalue);
        }return null;
    }
    
    public PageReference clearFilter() {
        filterfield = '';
        ApexPages.currentPage().getParameters().remove('filterfield');
        filtervalue = '';
        ApexPages.currentPage().getParameters().remove('filtervalue');
        for(MemberData m: dataPoints)
        {
             m.filtered = false;
        }
        return null;
    }
    
    private void filterDataPointManager(String fv) {
        if(fv == '(missing)')
        {
            fv = null;
        }
        for(MemberData m: dataPoints)
        {
            if(m.contract.Research_Account_Manager__r.Name != fv)
            {
                m.filtered = true;
            }
        }
    }
    private void filterDataPointRisk (String fv) {
        if(fv == '(missing)')
        {
            fv = null;
        }
        for(MemberData m: dataPoints)
        {
            if(m.contract.Renewal_Risk__c != fv)
            {
                m.filtered = true;
            }
        }
    }
    private void filterDataPointProgram(String fv) {
        for(MemberData m: dataPoints)
        {
            if(m.Program != fv)
            {
                m.filtered = true;
            }
        }
    }
    
    public PageReference editRM() {
        String datapointId = ApexPages.currentPage().getParameters().get('editrow');
        for(MemberData md:dataPoints) 
        {
            if(md.contract.id == datapointId)
            {
                md.editingRM = true;
            }
            else
            {
                md.editingRM = false;
            }
        } 
        return null;
    }
    
    public PageReference cancelRM() {
        for(MemberData md:dataPoints) 
        {
            md.editingRM = false;
        }
        return null;
    }
    
    public PageReference saveRM() {
        String datapointId = ApexPages.currentPage().getParameters().get('saverow');
        for(MemberData md:dataPoints) 
        {
            if(md.contract.id == datapointId)
            {
                try {
                    UPDATE md.contract;
                    md.editingRM = false;
                } catch (Exception e) {
                    ApexPages.addMessages(e);
                }
            }
        } 

        return null;
    }
    
    public PageReference editRR() {
        String datapointId = ApexPages.currentPage().getParameters().get('editrow');
        for(MemberData md:dataPoints) 
        {
            if(md.contract.id == datapointId)
            {
                md.editingRR = true;
            }
            else
            {
                md.editingRR = false;
            }
        } 
        return null;
    }
    
    public PageReference cancelRR() {
        for(MemberData md:dataPoints) 
        {
            md.editingRR = false;
        }
        return null;
    }
    
    public PageReference saveRR() {
        String datapointId = ApexPages.currentPage().getParameters().get('saverow');
        for(MemberData md:dataPoints) 
        {
            if(md.contract.id == datapointId)
            {
                try {
                    UPDATE md.contract;
                    md.editingRR = false;
                } catch (Exception e) {
                    ApexPages.addMessages(e);
                }
            }
        } 

        return null;
    }
        
    public PageReference sortTable() {
        sortfunction = ApexPages.currentPage().getParameters().get('sortfunction');
        String sortfieldnametemp = ApexPages.currentPage().getParameters().get('sortfieldname');
        
        if(sortfieldname != sortfieldnametemp)
        {
            reverseSort = false;
            sortfieldname = sortfieldnametemp;
        }
        else
        {
            reverseSort = !reverseSort ;
        }

        if(sortfunction == 'string')
        {
            dataPoints = sortStringField(sortfieldname);
        }
        else if(sortfunction == 'date')
        {
            dataPoints = sortDateField(sortfieldname);
        }
        else if(sortfunction == 'decimal')
        {
            dataPoints = sortDecimalField(sortfieldname);
        }
        return null;
    }


    /* Sort the collection of opportunities using the standard collection sort method. */
    private List<MemberData> sortDecimalField(String fieldName) {
        
        List<MemberData> resultList = new List<MemberData>();
    
        /* Create a map of amount to MemberData collection */
        Map<Decimal, List<MemberData>> mdMap = new Map<Decimal, List<MemberData>>();
        
        if(fieldName == 'Total New Hours')
        {
            for(MemberData md:dataPoints) {
                if(mdMap.get(md.total_new_hours) == null) { mdMap.put(md.total_new_hours, new List<MemberData>()); }
                mdMap.get(md.total_new_hours).add(md);
            }
        }

        List<Decimal> keys = new List<Decimal>(mdMap.keySet());
        
        /* Leverage the standard, primitive collection sort method */
        keys.sort();
        if(reverseSort)
        {
            List<Decimal> tempKeys = new List<Decimal>();
            for(Integer i = keys.size()-1; i >=0 ; i--)
            {
                tempKeys.add(keys[i]);
            }
            keys = tempKeys;
        }
        for(Decimal key:keys) { resultList.addAll(mdMap.get(key)); }
        
        return resultList;
    }
    
    /* Sort the collection of opportunities using the standard collection sort method. */
    private List<MemberData> sortDateField(String fieldName) {
        
        List<MemberData> resultList = new List<MemberData>();
    
        /* Create a map of amount to MemberData collection */
        Map<Date, List<MemberData>> mdMap = new Map<Date, List<MemberData>>();
        
        if(fieldName == 'renewalDate')
        {
            for(MemberData md:dataPoints) {
                if(mdMap.get(md.contract.End_Date__c) == null) { mdMap.put(md.contract.End_Date__c, new List<MemberData>()); }
                mdMap.get(md.contract.End_Date__c).add(md);
            }
        }

        List<Date> keys = new List<Date>(mdMap.keySet());
        
        /* Leverage the standard, primitive collection sort method */
        keys.sort();
        if(reverseSort)
        {
            List<Date> tempKeys = new List<Date>();
            for(Integer i = keys.size()-1; i >=0 ; i--)
            {
                tempKeys.add(keys[i]);
            }
            keys = tempKeys;
        }
        for(Date key:keys) { resultList.addAll(mdMap.get(key)); }
        
        return resultList;
    }
        
    /* Sort the collection of opportunities using the standard collection sort method. */
    private List<MemberData> sortStringField(String fieldName) {
        
        List<MemberData> resultList = new List<MemberData>();
    
        /* Create a map of amount to MemberData collection */
        Map<String, List<MemberData>> mdMap = new Map<String, List<MemberData>>();
        
        if(fieldName == 'AcctName')
        {
            for(MemberData md:dataPoints) {
                if(mdMap.get(md.contract.Account__r.Name) == null) { mdMap.put(md.contract.Account__r.Name, new List<MemberData>()); }
                mdMap.get(md.contract.Account__r.Name).add(md);
            }
        }
        else if(fieldName == 'Program')
        {
            for(MemberData md:dataPoints) {
                if(mdMap.get(md.Program) == null) { mdMap.put(md.Program, new List<MemberData>()); }
                mdMap.get(md.Program).add(md);
            }        
        }
        else if(fieldName == 'RenewalRisk')
        {
            for(MemberData md:dataPoints) {
                if(mdMap.get(md.contract.Renewal_Risk__c) == null) { mdMap.put(md.contract.Renewal_Risk__c, new List<MemberData>()); }
                mdMap.get(md.contract.Renewal_Risk__c).add(md);
            }            
        }
        else if(fieldName == 'ResearchManager')
        {
        	Map<ID,String> usernameMap = new Map<ID,String>();
			for(User u: [SELECT ID, Name from User])
	        {
	        	usernameMap.put(u.Id,u.Name);
	        }
            for(MemberData md:dataPoints) {
                if(mdMap.get(md.contract.Research_Account_Manager__c) == null) { mdMap.put(md.contract.Research_Account_Manager__c, new List<MemberData>()); }
                mdMap.get(md.contract.Research_Account_Manager__c).add(md);
            }            
        }        

        List<String> keys = new List<String>(mdMap.keySet());
        
        /* Leverage the standard, primitive collection sort method */
        keys.sort();
        if(reverseSort)
        {
            List<String> tempKeys = new List<String>();
            for(Integer i = keys.size()-1; i >=0 ; i--)
            {
                tempKeys.add(keys[i]);
            }
            keys = tempKeys;
        }
        for(String key:keys) { resultList.addAll(mdMap.get(key)); }
        
        return resultList;
    }

}