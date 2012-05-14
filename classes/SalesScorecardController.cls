public class SalesScorecardController {
    public class monthResult { 
        public Integer rCount { get; set; }
        public Integer avTotal { get; set; }
        public String month { get; set; }
        public List<SObject> theRecords  { get; set; }
        public monthResult() {
            month = '';
            rCount = 0;
            avTotal = 0;
            theRecords = new List<SObject>();
        }
        public monthResult(String n, Integer i, Integer av) {
            month = n;
            rCount = i;
            avTotal = av;
            theRecords = new List<SObject>();
        }
        
        public monthResult(String n, Integer i) {
            month = n;
            rCount = i;
            avTotal = 0;
            theRecords = new List<SObject>();
        }
        
        public String getMonthShort () {
            return month.substring(3);
        }
   
    }

	public Integer thisMonthInt;
	public Integer nextMonthInt;
	public String thisMonth;
	public String nextMonth;
	private String salesStaffFilter;    
    public List<User> salesStaff { get; set; }
    public List<Id> selectedSalesids { get; set; }
    public Map<Id,String> salesMap  { get; set; }
    public String salesUser;
    public Boolean renderPanel { get; set; }
    public String goalNewMeetings { get; set; }
    public Integer goalFollowupMeetings { get; set; }
    public Integer goalUpsideOpportunities { get; set; }
    public Integer goalQualifiedOpportunities { get; set; }
    public Integer goalClosableOpportunities { get; set; }
    public Integer goalClosedWonOpportunities { get; set; } 

    public List<String> oppStages { get; set; }
    public Map<String, List<monthResult>> oppSnapshotResultsMap { get; set; }
    public Map<String, List<monthResult>> currentOpsResultsMap { get; set; }

    public List<String> mtgClasses { get; set; }
	public List<List<String>> mtgTypes { get; set; }
    public Map<String, List<monthResult>> mtgSnapshotResultsMap { get; set; }
    public Map<String, List<monthResult>> currentMtgResultsMap { get; set; }
        
   public SalesScorecardController (){
   		thisMonthInt = System.today().month();
   		nextMonthInt = System.today().addMonths(1).month();
   		thisMonth = engMonth(thisMonthInt);
   		nextMonth = engMonth(nextMonthInt);
        selectedSalesids = new List<Id>();
        salesStaff = new List<User>();
        salesMap = new Map<Id,String>();
        if([SELECT count() FROM User u WHERE u.UserRole.Name = 'New Sales' AND u.IsActive = true ] != 0 )
        {
            salesStaff = [SELECT u.Name, u.IsActive FROM User u WHERE u.UserRole.Name = 'New Sales' AND u.IsActive = true 
                            ORDER BY u.Name];               
        }
        for(User u: salesStaff)
        {
            salesMap.put(u.Id, u.Name );
        }
        salesStaffFilter = '';
        renderPanel = false;

        goalNewMeetings = '8';
        goalFollowupMeetings = 7;
        goalUpsideOpportunities = 20;
        goalQualifiedOpportunities = 7;
        goalClosableOpportunities = 4;
        goalClosedWonOpportunities = 2;
        oppStages = new String[]{'Upside','Qualified','Closeable','Closed Won'};
        oppSnapshotResultsMap = new Map<String, List<monthResult>>();
        currentOpsResultsMap = new Map<String, List<monthResult>>();
        for(Integer j = 0; j< oppStages.size(); j++)
        {
            List<monthResult> tempMR = new List<monthResult>();
            oppSnapshotResultsMap.put(oppStages[j], tempMR );
            currentOpsResultsMap.put(oppStages[j], tempMR );
        }   
        
        mtgClasses = new String[]{'New Meeting','Follow up Meeting'};
        mtgTypes = new List<List<String>> ();
        mtgTypes.add( new String[]{'Onsite Meeting','Conference Call'});
        mtgTypes.add( new String[]{'Follow up Conference Call','Follow up Onsite Meeting'});
        mtgSnapshotResultsMap = new Map<String, List<monthResult>>();
        currentMtgResultsMap = new Map<String, List<monthResult>>();
        for(Integer j = 0; j< mtgClasses.size(); j++)
        {
            List<monthResult> tempMR = new List<monthResult>();
            mtgSnapshotResultsMap.put(mtgClasses[j], tempMR );
            currentMtgResultsMap.put(mtgClasses[j], tempMR );
        }

   }
        
    public List<SelectOption> getsalesStaffOptions() {
        List<SelectOption> optionList = new List<SelectOption>();
        optionList.add(new SelectOption('', 'All Staff'));
        for(User u: salesStaff)
        {
            optionList.add(new SelectOption(u.Id,u.Name));
        }
        return optionList;
    }  

    public String getsalesUser() {  
        return salesUser;           
    } 

    public void setsalesUser(String s) {        
        salesUser = s;
        setsalesStaffFilter(salesUser);
    }
    
    private void setsalesStaffFilter(String sid) {          
        selectedSalesids.clear();
        if(sid == null)
        {
            for(User sales : salesStaff)
            {
                selectedSalesids.add(sales.Id); 
            }       
        } else 
        {
            selectedSalesids.add(sid);  
        }   
    }  
    
	public Boolean getviewingOneUser() {
		if(!selectedSalesids.isEmpty()){
			if(selectedSalesids.size() == 1)
			{
				return true;
			}
		}
		return false;
	}
	    
    public String engMonth(Integer i){
        if(i == 1) { return '01 January'; } 
        else if (i == 2) { return '02 February';}
        else if (i == 3) { return '03 March';}
        else if (i == 4) { return '04 April';}
        else if (i == 5) { return '05 May';}
        else if (i == 6) { return '06 June';}
        else if (i == 7) { return '07 July';}
        else if (i == 8) { return '08 August';}
        else if (i == 9) { return '09 September';}
        else if (i == 10) { return '10 October';}
        else if (i == 11) { return '11 November';}
        else if (i == 12) { return '12 December';}
        else { return 'undefined';}
    }

   public void RunQuery(){   
   		       
     	/*Date twoMonthsPrior = date.newinstance(System.Today().year(), System.Today().addMonths(10).month(),1);
     	if(System.Today().month() < 3)
     	{
     		twoMonthsPrior.year = twoMonthsPrior.year()-1;
     	}*/
        //Populate Opportunity data
        for(Integer i=0; i < oppStages.size();i++)
        {
            Integer currentMonth = 0;
            Integer nextOpMonth;
            Set<String> requiredMonths =  new Set<String>{thisMonth,nextMonth};
            Integer monthlyAVtotal = 0;
            
            /* START Logic to compile Snapshot Data */
            List<Analytic_Snapshot_Opp_Scorecard__c> tempOppSnapshotList = new List<Analytic_Snapshot_Opp_Scorecard__c>();
            List<monthResult> tempMonthResults = new List<monthResult>();
            for(Analytic_Snapshot_Opp_Scorecard__c oSnap : [SELECT Stage__c, Close_Date__c, Type__c, Product_Group__c, Product_Family__c,
                                                            Opportunity__c, Opportunity__r.Annualized_Value__c ,Opportunity_Owner__c, Name, Id, Close_Probability__c, 
                                                            Amount__c, Account__c
                                                            FROM Analytic_Snapshot_Opp_Scorecard__c 
                                                            WHERE CreatedDate = THIS_MONTH AND 
                                                                Opportunity_Owner__c IN :selectedSalesIds 
                                                                AND Stage__c = :oppStages[i]
                                                                AND Product_Family__c in ('ACL','AIE','CPE','DEV','ENM','OHE','SOE')
                                                            ORDER BY Close_Date__c, Product_Group__c, Opportunity__c])
            {
                nextOpMonth = oSnap.Close_Date__c.month();
                if(currentMonth == 0)
                {
                    currentMonth = nextOpMonth;
                    if(oSnap.Opportunity__r.Annualized_Value__c != null)
                    {
                    	monthlyAVtotal = oSnap.Opportunity__r.Annualized_Value__c.intValue();
                    }
                    tempOppSnapshotList.add(oSnap);
                } else if (currentMonth == nextOpMonth)
                {
                	if(oSnap.Opportunity__r.Annualized_Value__c != null)
                    {
                    	monthlyAVtotal = monthlyAVtotal + oSnap.Opportunity__r.Annualized_Value__c.intValue();
                    }	
                    tempOppSnapshotList.add(oSnap);
                } else 
                {
                    monthResult tempMRsnap = new monthResult(engMonth(currentMonth), tempOppSnapshotList.size(), monthlyAVtotal);
                    List<Analytic_Snapshot_Opp_Scorecard__c> tempOppSnaps = tempOppSnapshotList.deepClone();
                    tempMRsnap.theRecords = tempOppSnaps;
                    tempMonthResults.add(tempMRsnap);
                    requiredMonths.remove(engMonth(currentMonth));  
                    currentMonth = nextOpMonth; 
                    tempOppSnapshotList.clear();
                    if(oSnap.Opportunity__r.Annualized_Value__c != null)
                    {
                    	monthlyAVtotal = oSnap.Opportunity__r.Annualized_Value__c.intValue();
                    } else 
                    {
                    	monthlyAVtotal = 0;
                    }
                    tempOppSnapshotList.add(oSnap);
                }               
            }
            if(!tempOppSnapshotList.isEmpty())
            {
            	monthResult tempMRsnap = new monthResult(engMonth(currentMonth), tempOppSnapshotList.size(), monthlyAVtotal);
	            List<Analytic_Snapshot_Opp_Scorecard__c> tempOppSnaps = tempOppSnapshotList.deepClone();
	            tempMRsnap.theRecords = tempOppSnaps;
	            tempMonthResults.add(tempMRsnap);
	            tempOppSnapshotList.clear();	            
	            requiredMonths.remove(engMonth(currentMonth)); 
	            for(String missing: requiredMonths)
	            {
	            	tempMonthResults.add(new monthResult(missing, 0));
	            } 
	            oppSnapshotResultsMap.put(oppStages[i], tempMonthResults);
            } else 
            {
            	List<monthResult> missingMonths = new List<monthResult>();
        		missingMonths.add( new monthResult(thisMonth, 0));
        		missingMonths.add( new monthResult(nextMonth, 0));
        		oppSnapshotResultsMap.put(oppStages[i], missingMonths);
            }
            /* END Logic to compile Snapshot Data */
            currentMonth = 0;
            monthlyAVtotal = 0; 
            requiredMonths =  new Set<String>{thisMonth,nextMonth};
            /* START Logic to compile 'Month to Date' Data */
            List<Opportunity> tempOppsList = new List<Opportunity>();
            List<monthResult> tempOpMonthResults = new List<monthResult>();            
            for(Opportunity opp : [SELECT StageName, Close_Date_New__c, Type, Product_Group__c, Product_Family__c,
                                                            OwnerId, Name, Id, Close_Probability__c, Annualized_Value__c,
                                                            Amount, AccountId
                                                            FROM Opportunity 
                                                            WHERE ( (Close_Date_New__c <= NEXT_MONTH AND StageName in ('Upside', 'Qualified', 'Closeable')) 
                                                            		OR 
                                                            		(Close_Date_New__c >= THIS_MONTH AND Close_Date_New__c <= NEXT_MONTH AND StageName = 'Closed Won' ) 
                                                            	  ) AND 
                                                                OwnerId IN :selectedSalesIds 
                                                                AND Type = 'New Business'
                                                                AND Product_Family__c in ('ACL','AIE','CPE','DEV','ENM','OHE','SOE')
                                                                AND StageName = :oppStages[i]
                                                            ORDER BY Close_Date_New__c, Product_Group__c, Id ])
            {
                nextOpMonth = opp.Close_Date_New__c.month();
                if(currentMonth == 0)
                {
                	if(opp.Annualized_Value__c != null)
                	{
                		monthlyAVtotal = opp.Annualized_Value__c.intValue();
                	}
                    currentMonth = nextOpMonth;
                    tempOppsList.add(opp);
                } else if (currentMonth == nextOpMonth)
                {
                	if(opp.Annualized_Value__c != null)
                	{
                		monthlyAVtotal = monthlyAVtotal + opp.Annualized_Value__c.intValue();
                	}
                    tempOppsList.add(opp);
                } else 
                {
                    monthResult tempMRopp = new monthResult(engMonth(currentMonth), tempOppsList.size(), monthlyAVtotal);
                    List<Opportunity> tempOpps = tempOppsList.deepClone();
                    tempMRopp.theRecords = tempOpps;
                    tempOpMonthResults.add(tempMRopp);
                    requiredMonths.remove(engMonth(currentMonth)); 
                    currentMonth = nextOpMonth; 
                    tempOppsList.clear();
                    if(opp.Annualized_Value__c != null)
                    {
                    	monthlyAVtotal = opp.Annualized_Value__c.intValue();
                    } else 
                    {
                    	monthlyAVtotal = 0;
                    }
                    tempOppsList.add(opp);
                }               
            }
			if(!tempOppsList.isEmpty())
			{
	            monthResult tempMRopp = new monthResult(engMonth(currentMonth), tempOppsList.size(), monthlyAVtotal);
	            List<Opportunity> tempOpps = tempOppsList.deepClone();
	            tempMRopp.theRecords = tempOpps;
	            tempOpMonthResults.add(tempMRopp); 
	            monthlyAVtotal = 0;
	            tempOppsList.clear();
	            requiredMonths.remove(engMonth(currentMonth)); 
	            for(String missing: requiredMonths)
	            {
	            	tempOpMonthResults.add(new monthResult(missing, 0));
	            }	  
	            currentOpsResultsMap.put(oppStages[i], tempOpMonthResults);            
			}  else 
            {
            	List<monthResult> missingMonths = new List<monthResult>();
        		missingMonths.add( new monthResult(thisMonth, 0));
        		missingMonths.add( new monthResult(nextMonth, 0));
        		currentOpsResultsMap.put(oppStages[i], missingMonths);
            }
            
            /* END Logic to compile Current Data */         
        }

        List<String> selectedStaffNames = new List<String>();
        for(Id selectedId : selectedSalesIds)
        {
            selectedStaffNames.add(salesMap.get(selectedId));
        }
        //Populate Meeting data
        for(Integer i=0; i < mtgClasses.size();i++)
        {
            Integer currentMonth = 0;
            Integer nextOpMonth;
            Set<String> requiredMonths =  new Set<String>{thisMonth,nextMonth};
            
            /* START Logic to compile Snapshot Data */
            List<Analytic_Snapshot_Meeting_Scorecard__c> tempMeetingSnapshotList = new List<Analytic_Snapshot_Meeting_Scorecard__c>();
            List<monthResult> tempMonthResults = new List<monthResult>();
            for(Analytic_Snapshot_Meeting_Scorecard__c mSnap : [SELECT Opportunity_Stage__c, Opportunity_Name__c, Name, Meeting_Type__c, Product_Group__c, 
                                                                Product_Family__c, Date__c, CreatedDate, Assigned_To__c, Activity_Type__c, Account_Name__c 
                                                                FROM Analytic_Snapshot_Meeting_Scorecard__c 
                                                                WHERE CreatedDate = THIS_MONTH    
                                                                AND Assigned_To__c IN :selectedStaffNames 
                                                                AND Meeting_Type__c = :mtgClasses[i]
                                                            ORDER BY Date__c, Opportunity_Name__c  ])      
            {
                nextOpMonth = mSnap.Date__c.month();
                if(currentMonth == 0)
                {
                    currentMonth = nextOpMonth;
                    tempMeetingSnapshotList.add(mSnap);
                } else if (currentMonth == nextOpMonth)
                {
                    tempMeetingSnapshotList.add(mSnap);
                } else 
                {
                    monthResult tempMR = new monthResult(engMonth(currentMonth), tempMeetingSnapshotList.size(), 0);
                    List<Analytic_Snapshot_Meeting_Scorecard__c> tempMtgSnaps = tempMeetingSnapshotList.deepClone();
                    tempMR.theRecords = tempMtgSnaps;
                    tempMonthResults.add(tempMR);
                    requiredMonths.remove(engMonth(currentMonth)); 
                    currentMonth = nextOpMonth;  
                    tempMeetingSnapshotList.clear();
                    tempMeetingSnapshotList.add(mSnap);
                }               
            }
            if(!tempMeetingSnapshotList.isEmpty())
            {
            	monthResult tempMR = new monthResult(engMonth(currentMonth), tempMeetingSnapshotList.size(), 0);
	            List<Analytic_Snapshot_Meeting_Scorecard__c> tempMtgSnaps = tempMeetingSnapshotList.deepClone();
	            tempMR.theRecords = tempMtgSnaps;
	            tempMonthResults.add(tempMR); 
	            requiredMonths.remove(engMonth(currentMonth)); 
	            for(String missing: requiredMonths)
	            {
	            	tempMonthResults.add(new monthResult(missing, 0, 0));
	            }	             
	            tempMeetingSnapshotList.clear();
	            mtgSnapshotResultsMap.put(mtgClasses[i], tempMonthResults);

            } else 
            {
            	List<monthResult> missingMonths = new List<monthResult>();
        		missingMonths.add( new monthResult(thisMonth, 0));
        		missingMonths.add( new monthResult(nextMonth, 0));
        		mtgSnapshotResultsMap.put(mtgClasses[i], missingMonths);
            }
            /* END Logic to compile Snapshot Data */
            currentMonth = 0;
            requiredMonths =  new Set<String>{thisMonth,nextMonth};
            /* START Logic to compile 'Month to Date' Data */
            List<Event> tempMeetingList = new List<Event>();
            List<monthResult> tempMtgMonthResults = new List<monthResult>();
            for(Event e : [SELECT WhoId, WhatId, What.Name, Type, StartDateTime, RecordTypeId, Program__c, OwnerId, ActivityDateTime, ActivityDate, AccountId 
                                                                FROM Event 
                                                                WHERE ActivityDate >= THIS_MONTH AND ActivityDate <= NEXT_MONTH      
                                                                AND OwnerId IN :selectedSalesIds 
                                                                AND Type IN :mtgTypes[i]
                                                            ORDER BY ActivityDate, What.Name ])      
            {
                nextOpMonth = e.ActivityDate.month();
                if(currentMonth == 0)
                {
                    currentMonth = nextOpMonth;
                    tempMeetingList.add(e);
                } else if (currentMonth == nextOpMonth)
                {
                    tempMeetingList.add(e);
                } else 
                {
                    monthResult tempMRmtg = new monthResult(engMonth(currentMonth), tempMeetingList.size());
                    List<Event> tempMtgs = tempMeetingList.deepClone();
                    tempMRmtg.theRecords = tempMtgs;
                    tempMtgMonthResults.add(tempMRmtg);
                    requiredMonths.remove(engMonth(currentMonth));  
                    currentMonth = nextOpMonth;  
                    tempMeetingList.clear();
                    tempMeetingList.add(e);
                }               
            }
            if(!tempMeetingList.isEmpty())
            {
	            monthResult tempMRmtg = new monthResult(engMonth(currentMonth), tempMeetingList.size());
	            List<Event> tempMtgs = tempMeetingList.deepClone();
	            tempMRmtg.theRecords = tempMtgs;
	            tempMtgMonthResults.add(tempMRmtg);
	            requiredMonths.remove(engMonth(currentMonth)); 
	            for(String missing: requiredMonths)
	            {
	            	tempMtgMonthResults.add(new monthResult(missing, 0));
	            }	  
	            tempMeetingList.clear();
	            currentMtgResultsMap.put(mtgClasses[i], tempMtgMonthResults);
            } else 
            {
            	List<monthResult> missingMonths = new List<monthResult>();
        		missingMonths.add( new monthResult(thisMonth, 0));
        		missingMonths.add( new monthResult(nextMonth, 0));
        		currentMtgResultsMap.put(mtgClasses[i], missingMonths);
            }

            /* END Logic to compile 'Month to Date' Data */
        }
        renderPanel = true;       
         
   } 

    public static testmethod void testSalesScorecard() {
        
        PageReference pageRefSSC = new PageReference('/apex/sales_scorecard');
        Test.setCurrentPage(pageRefSSC);
        SalesScorecardController ssc = new SalesScorecardController();
        ssc.getsalesStaffOptions();
        ssc.setsalesUser(ssc.salesStaff[0].Id);
        ssc.setsalesStaffFilter(ssc.salesStaff[0].Id);
        ssc.getsalesUser();
        ssc.RunQuery();
		ssc.getviewingOneUser();
		ssc.engMonth(1);
    }

}