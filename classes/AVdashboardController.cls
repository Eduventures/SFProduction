public class AVdashboardController {

    //available years list (best if we compile this list on the fly by querying the Contract Year records for distinct years)
    public List<Integer> availableYears {get; set;}
    public Set<Integer> possibleYears {get; set;}
    //Default to display the current year
    public Integer displayYear {get;set;}   
    //allow searching by a range of dates 
	public Integer comparisonyear {get;set;}
	public String  compyear {get;set;}
    
    //availble programs to filter by
    public List<String> availablePrograms {get;set;}
    //the actual program filter list
    public List<String> programFilter {get;set;}    
    //selected program to filter by (if present)
    public String selectedProgram {get;set;} 
    
    //availble programs to filter by
    public List<String> availableDivisions {get;set;}
    //the actual program filter list
    public String selectedDivision {get;set;}

    public AggregateYear currentyear {get;set;}
    public AggregateYear reportyear {get;set;}
    //list of aggregate years
    public List<AggregateYear> reportyears {get;set;}   

    
	public List<SelectOption> getavailableYearsOptions() {
        List<SelectOption> optionList = new List<SelectOption>();
        for(Integer y: availableYears)
        {
            optionList.add(new SelectOption(y.format(),y.format()));
        }
        return optionList;
    } 
    
	public List<SelectOption> getavailableDivisionsOptions() {
        List<SelectOption> optionList = new List<SelectOption>();
        for(String s: availableDivisions)
        {
            optionList.add(new SelectOption(s,s));
        }
        return optionList;
    } 

	public List<SelectOption> getavailableProgramsOptions() {
        List<SelectOption> optionList = new List<SelectOption>();
        for(String s: availablePrograms)
        {
            optionList.add(new SelectOption(s,s));
        }
        return optionList;
    } 
        
        
    public AVdashboardController(){  
    	availableYears = new List<Integer>{2010,2011,2012};
    	/*
    	possibleYears = new Set<Integer>();
    	for(AggregateResult ar : [ SELECT Calendar_Year(Recognition_Date__c) year FROM Contract_Year__c GROUP BY Calendar_Year(Recognition_Date__c)])
    	{
    		possibleYears.add((Integer)ar.get('year'));
    	}
    	for(AggregateResult ar : [ SELECT Calendar_Year(End_Date__c) year FROM Contract_Year__c GROUP BY Calendar_Year(End_Date__c)])
    	{
    		possibleYears.add((Integer)ar.get('year'));
    	}
    	availableYears.addAll(possibleYears);
    	availableYears.sort();
    	*/
    	
    	//Default to display the current year
    	displayYear  = system.Today().year();
    	comparisonyear = displayYear;
    	compyear = comparisonyear.format();
    	
    	availablePrograms = new List<String>{'All','Academic','Admin','ACL','AIE','CPE','DEV','ECS','ENM','OHE','RPT','SOE','Sponsorship'};
        selectedProgram = 'All';

    	availableDivisions = new List<String>{ 'All','LC','ECS','Other'};
    	selectedDivision = 'All';
    	runReport();
    }  
     
	public void runReport(){
        if(ApexPages.currentPage().getParameters().containsKey('compyear') )
        {
            compyear = ApexPages.currentPage().getParameters().get('compyear');
            comparisonyear = Integer.valueOf(compyear); 
        }
        
        if(ApexPages.currentPage().getParameters().containsKey('selectedDivision') )
        {
            selectedDivision = ApexPages.currentPage().getParameters().get('selectedDivision');
        }

		if(ApexPages.currentPage().getParameters().containsKey('selectedProgram') )
        {
          	selectedProgram = ApexPages.currentPage().getParameters().get('selectedProgram');
        }         
		if(selectedProgram == 'All')
        {
        	programFilter = availablePrograms;
        } else if (selectedProgram == 'Academic')
        {
        	programFilter = new List<String>{'CPE','OHE','SOE'};
        }  else if (selectedProgram == 'Admin')
        {
        	programFilter = new List<String>{'ACL','AIE','DEV','ENM'};
        } else
        {
        	programFilter = new List<String>{selectedProgram};
        }
        currentyear = new AggregateYear(displayYear,programFilter,selectedDivision);
        if(displayYear != comparisonyear)
        {
        	reportyear = new AggregateYear(comparisonyear,programFilter,selectedDivision);
        	reportyears = new List<AggregateYear>{currentyear,reportyear};
        } else 
        {
        	reportyears = new List<AggregateYear>{currentyear};
        }


	}
	
    public static testmethod void testAVdashboardController() {
        
        PageReference pageRefSSC = new PageReference('/apex/AVdashboard');
        Test.setCurrentPage(pageRefSSC);
        AVdashboardController ssc = new AVdashboardController();

    }
    
    
    public class ProgramMonth{
        public List<Contract_year__c> avlist {get;set;} 
        public List<Contract_year__c> newsaleslist {get;set;} 
        public List<Contract_year__c> renewalsaleslist {get;set;}  
        public String Name {get;set;}
        public Decimal difference {get;set;}
        public Decimal newdifference {get;set;}
        public Decimal renewaldifference {get;set;}
        public Decimal av {get;set;}
        public Integer renewalsales {get;set;}
        public Integer renewalpercent {get;set;}       
        public Integer newsales {get;set;}
        public Integer totalactual {get;set;}
        public Decimal prioractual {get;set;}        
        public Integer yoy {get;set;}
        public Integer newplan {get;set;}
        public Integer renewalplan {get;set;}
        public Integer totalplan {get;set;}
        public Integer pscore {get;set;}
        
        public ProgramMonth(String Monthname, Integer nplan, Integer rplan, List<Contract_Year__c> avcylist, List<Contract_Year__c> newcylist, List<Contract_Year__c> renewcylist,  Decimal prior) {
            Name = Monthname;
            av = 0;
            newsales = 0;
            renewalsales = 0;
           	newplan = nplan;  
           	avlist = new List<Contract_year__c>();
           	newsaleslist = new List<Contract_year__c>();           
            renewalsaleslist = new List<Contract_year__c>(); 
            for(Contract_Year__c c: avcylist)
            {
                av = av + c.AV__c;    
            }            
            for(Contract_Year__c c: newcylist)
            {
                newsales = newsales + c.AV__c.intValue();    
            }
            renewalplan = rplan;
            for(Contract_Year__c c: renewcylist)
            {
                renewalsales = renewalsales + c.AV__c.intValue();    
            }
        	renewalpercent = 0;              
        	totalactual = newsales + renewalsales;
        	totalplan = newplan + renewalplan;
            difference = 0;
            newdifference = newsales - newplan;
        	renewaldifference = renewalsales - renewalplan;            
        	yoy = 0;
        	prioractual = prior;
            pscore = 0;
            difference = totalactual - totalplan;
        	if( av != 0)
    		{
	        	renewalpercent = ((renewalsales / av)*100).round().intValue();
    		}
    		if(prioractual != 0)
    		{
    			yoy = (((totalactual/prioractual)-1)*100).round().intValue();
    		} 
			if( totalplan!= 0)
    		{
				pscore = ((difference/totalplan)*100).round().intValue();
    		}            
            avlist.addAll(avcylist.deepClone());
            newsaleslist.addAll(newcylist.deepClone());
            renewalsaleslist.addAll(renewcylist.deepClone());
            
        }
         
    }

	public class companyMonth {
        public String Name {get;set;}		
        public Integer totalsales {get;set;}
        public Integer plan {get;set;}
        public Decimal difference {get;set;}
        public Integer pscore {get;set;}
        public companyMonth(String Monthname, Integer theplan, Integer sales){
            plan = 0;
            totalsales = 0;
            difference = 0;
            pscore = 0;
            Name = Monthname;
            totalsales = sales; 
            plan = theplan;
            difference = totalsales - plan;
            if(plan > 0)
            {
                pscore = ((difference/plan)*100).round().intValue();                
            }
        } 
	}
	
    public class Month{
        public String Name {get;set;}
        public List<Contract_year__c> saleslist {get;set;}      
        public Integer totalsales {get;set;}
        public Integer plan {get;set;}
        public Decimal difference {get;set;}
        public Integer pscore {get;set;}
        
        public Month(String division, String Monthname, Integer theplan, List<Contract_Year__c> cylist){
            totalsales = 0;
            plan = 0;
            pscore = 0;
            difference = 0;
            Name = Monthname;
            saleslist = cylist;
            for(Contract_Year__c c: saleslist)
            {
                totalsales = totalsales + c.AV__c.intValue(); 
            }

            plan = theplan;
            difference = totalsales - plan;
            if(plan > 0)
            {
                pscore = ((difference/plan)*100).round().intValue();                
            }
        }  
    }
        
    public class ProgramQuarter{
        public List<ProgramMonth> monthsList {get;set;}
        public String Name {get;set;}
        public Decimal difference {get;set;}
        public Decimal newdifference {get;set;}
        public Decimal renewaldifference {get;set;}
        public Decimal av {get;set;}
        public Integer renewalsales {get;set;}
        public Integer renewalpercent {get;set;}       
        public Integer newsales {get;set;}
        public Integer totalactual {get;set;}
        public Decimal prioractual {get;set;}
        public Integer yoy {get;set;}
        public Integer newplan {get;set;}
        public Integer renewalplan {get;set;}
        public Integer totalplan {get;set;}
        public Integer pscore {get;set;}        
 
        public ProgramQuarter(Integer q, List<ProgramMonth> themonths){
        	monthsList = new List<ProgramMonth>();
            for(ProgramMonth m:themonths)
            {
            	monthsList.add(m);
            }
			Name = 'Q'+q;
            av = 0;            
            newplan = 0;
            newsales = 0;
            renewalplan = 0;
           	renewalsales = 0;
        	renewalpercent = 0;              
        	totalactual = 0;
        	prioractual = 0;
            difference = 0;
        	yoy = 0;
            pscore = 0;

        	for(ProgramMonth month: monthsList)
        	{
    			av = av + + month.av;
    			newplan = newplan + month.newplan;
    			newsales = newsales + month.newsales;
        		renewalplan = renewalplan + month.renewalplan;     
    			renewalsales = renewalsales + month.renewalsales; 
    			totalactual = totalactual + month.totalactual;
    			prioractual = prioractual + month.prioractual;    			
        	}
        	totalplan = newplan + renewalplan;
            newdifference = newsales - newplan;
        	renewaldifference = renewalsales - renewalplan;    
        	difference = totalactual - totalplan;
        	if( av != 0)
    		{
	        	renewalpercent = ((renewalsales / av)*100).round().intValue();
    		}
    		if(prioractual != 0)
    		{
    			yoy = (((totalactual/prioractual)-1)*100).round().intValue();
    		} 
			if( totalplan!= 0)
    		{
				pscore = ((difference/totalplan)*100).round().intValue();
    		}
        }

    }
    
    public class Quarter{
        public List<Month> months  {get;set;}
        public String Name  {get;set;}     
        public Integer totalsales  {get;set;}
        public Integer plan {get;set;}
        public Decimal difference {get;set;}
        public Integer pscore  {get;set;}
        
        public Quarter(String division, Integer q, List<Month> themonths){
            months = new List<Month>();
            for(Month m:themonths)
            {
            	months.add(m);
            }
            Name = 'Q'+q;
            totalsales = 0;
            plan = 0;
            pscore = 0;
            for(Month m: themonths)
            {
                totalsales = totalsales + m.totalsales;
                plan = plan + m.plan; 
            }

            difference = totalsales - plan;
            if(plan > 0)
            {
                pscore = ((difference/plan)*100).round().intValue();            
            }
            
        }
    }
      
    public class ProgramYear{
    	public List<String> programFilter {get;set;}
        public String Name {get;set;}
        public List<ProgramQuarter> quarters {get;set;}
        public Decimal av {get;set;}
        public Integer renewal {get;set;}
        public Integer renewalpercent {get;set;}        
        public Integer newsales {get;set;}
        public Integer totalactual {get;set;}
        public Decimal prioractual {get;set;}        
        public Integer yoy {get;set;} 
        public Integer newplan {get;set;} 
        public Integer renewalplan {get;set;} 
        public Integer totalplan {get;set;}         
        public Integer pscore {get;set;} 
        public Decimal difference {get;set;}
        public Decimal newdifference {get;set;}
        public Decimal renewaldifference {get;set;}
        public Map<Integer,List<Contract_Year__c>> avMonthMap  {get;set;}
        public Map<Integer,List<Contract_Year__c>> newMonthMap  {get;set;}
        public Map<Integer,List<Contract_Year__c>> renewalMonthMap  {get;set;}
        public Map<Integer,Decimal> priorMap  {get;set;}
        public Map<Integer,Integer> newPlanMap {get;set;}
        public Map<Integer,Integer> renealPlanMap {get;set;}
           
        public ProgramYear(Integer yr, List<String> filterList, String division){
        	programFilter = filterList; 
        	av = 0;
        	renewal = 0;
        	renewalpercent = 0;      
        	newsales = 0;
        	totalactual = 0;
        	prioractual = 0;        	
        	yoy = 0;
        	newplan = 0;
        	renewalplan = 0;
            totalplan = 0;
            pscore = 0;          
            difference = 0;
            priorMap = new Map<Integer,Decimal>();             
			newPlanMap = new Map<Integer,Integer>();  
			renealPlanMap = new Map<Integer,Integer>(); 
            List<String> months = new List<String>{'blank', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'};
            Map<Integer,Integer> quarterMap = new map<Integer,Integer>{ 1=> 1, 2=> 1, 3=> 1, 4=> 2, 5=> 2, 6=> 2, 7=> 3, 8=> 3, 9=>3, 10=> 4, 11=>4, 12=>4};
            
            quarters = new List<ProgramQuarter>();
			avMonthMap = new Map<Integer,List<Contract_Year__c>>();
            newMonthMap = new Map<Integer,List<Contract_Year__c>>();
            renewalMonthMap = new Map<Integer,List<Contract_Year__c>>();
            
            for(Integer i=1; i<13; i++)
            {
            	List<Contract_Year__c> tempAvCYs = new List<Contract_Year__c>();
                List<Contract_Year__c> tempNewCYs = new List<Contract_Year__c>();
                List<Contract_Year__c> tempRenewCYs = new List<Contract_Year__c>();
                avMonthMap.put(i,tempAvCYs);
                newMonthMap.put(i,tempNewCYs);
                renewalMonthMap.put(i,tempRenewCYs);
                newPlanMap.put(i,0);
                renealPlanMap.put(i,0);
                priorMap.put(i,0);
            }

            Integer priorYr = yr -1;
            for(AggregateResult pcy: [SELECT SUM(AV__c) total, CALENDAR_MONTH(Recognition_Date__c) saleDate FROM Contract_Year__c 
                                      WHERE CALENDAR_YEAR(Recognition_Date__c) = :priorYr AND Division__c = 'LC' and Program_Family__c in :programFilter
                                      GROUP BY CALENDAR_MONTH(Recognition_Date__c) ORDER BY CALENDAR_MONTH(Recognition_Date__c) ])
            {
            	Integer monthNumber = (Integer)pcy.get('saleDate');
            	priorMap.put(monthNumber, priorMap.get(monthNumber) + (Decimal)pcy.get('total'));
            }
            
        	for(Contract_Year__c cy: [SELECT AV__c, Name, Division__c, LOA__c, LOA__r.Name, Program_Family__c, 
                                        Recognition_Date__c, Id, Type__c FROM Contract_Year__c 
                                      WHERE CALENDAR_YEAR(Recognition_Date__c) = :yr AND Division__c = :division and Program_Family__c in :programFilter
                                      ORDER BY Recognition_Date__c])
            {
            	if(cy.Type__c == 'New')
            	{
					newMonthMap.get(cy.Recognition_Date__c.month()).add(cy);
            	} else 
            	{
					renewalMonthMap.get(cy.Recognition_Date__c.month()).add(cy);
            	}
            } 
                                 
            for(Monthly_Plan__c planNumber: [Select Year__c, Program_Family__c, Name, Month__c, Id, Division__c, 
            										Business_Type__c, Amount__c From Monthly_Plan__c
													WHERE Division__c = :division AND Year__c = :yr 
													and Program_Family__c in :programFilter])
			{
				Integer monthNumber = planNumber.Month__c.intValue();
				if(planNumber.Business_Type__c == 'New')
            	{
					newPlanMap.put(monthNumber, newPlanMap.get(monthNumber) + planNumber.Amount__c.intValue());
            	} else 
            	{
					renealPlanMap.put(monthNumber, renealPlanMap.get(monthNumber) + planNumber.Amount__c.intValue());
            	}
			}
	            
            for(Contract_Year__c cy: [SELECT AV__c, Name, Division__c, End_Date__c, LOA__c, LOA__r.Name, Program_Family__c, 
                                        Id,  Type__c FROM Contract_Year__c 
                                      WHERE CALENDAR_YEAR(End_Date__c) = :yr AND Division__c = :division and Program_Family__c in :programFilter
                                      ORDER BY Program_Family__c,End_Date__c])
            {
				avMonthMap.get(cy.End_Date__c.month()).add(cy);
            } 
            
            List<ProgramMonth> tempMonths = new List<ProgramMonth>();
            List<ProgramQuarter> tempQuarters = new List<ProgramQuarter>();
            for(Integer i=1; i<13; i++)
            {
                ProgramMonth tempMonth = new ProgramMonth( months[i], newPlanMap.get(i), renealPlanMap.get(i), avMonthMap.get(i), newMonthMap.get(i), renewalMonthMap.get(i), priorMap.get(i));      
                tempMonths.add(tempMonth);
                if(math.mod(i,3)==0)
                {
                    ProgramQuarter tempQuarter = new ProgramQuarter(quarterMap.get(i), tempMonths);
                    tempQuarters.add(tempQuarter);
                    tempMonths.clear();
                }
            }   
			quarters = tempQuarters;
            Name = 'LC';
            for(ProgramQuarter q: quarters)
            {
	        	av = av + q.AV.intValue();
        		renewal = renewal + q.renewalsales;   
	        	newsales = newsales + q.newsales;
	        	totalactual = totalactual + q.totalactual;
	        	prioractual = prioractual + q.prioractual;	        	
	        	newplan = newplan + q.newplan;
	        	renewalplan = renewalplan + q.renewalplan;
            }
            newdifference = newsales - newplan;
        	renewaldifference = renewal - renewalplan;    
            totalplan = newplan + renewalplan;
            difference = totalactual - totalplan;
        	if(av != 0)
    		{	
    			renewalpercent = ((renewal / av)*100).round().intValue();         
    		}          
    		if(prioractual != 0)
    		{
    			yoy = (((totalactual/prioractual)-1)*100).round().intValue();
    		}     		 
            if(totalplan > 0)
            {
                pscore = ((difference/totalplan)*100).round().intValue();            
            }          
        }               
    }

    public class Year{
        public Map<Integer,Integer> planMap {get;set;}   
        public String Name  {get;set;}
        public List<String> programFilter {get;set;}
        public List<Quarter> quarters  {get;set;}      
        public Decimal totalsales {get;set;}
        public Integer plan {get;set;}
        public Decimal difference {get;set;}
        public Integer pscore  {get;set;}
        
        public Year(Integer yr, List<String> filterList, String division){
            programFilter = filterList;
            totalsales = 0;
            plan = 0;
            pscore = 0;
            planMap = new Map<Integer,Integer>();
            List<String> months = new List<String>{'blank', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'};
            Map<Integer,Integer> quarterMap = new map<Integer,Integer>{ 1=> 1, 2=> 1, 3=> 1, 4=> 2, 5=> 2, 6=> 2, 7=> 3, 8=> 3, 9=>3, 10=> 4, 11=>4, 12=>4};

            Map <Integer,List<Contract_Year__c>> monthMap = new Map<Integer,List<Contract_Year__c>>();
            for(Integer i=1; i<13; i++)
            {
                List<Contract_Year__c> tempCYs = new List<Contract_Year__c>();
                monthMap.put(i,tempCYs);
                planMap.put(i,0); 
            }
            
            for(Contract_Year__c cy: [SELECT AV__c, Name, Division__c, End_Date__c, LOA__c, LOA__r.Name, Program__c, Program_Family__c, 
                                        Recognition_Date__c, Id, Start_Date__c, Type__c FROM Contract_Year__c 
                                      WHERE CALENDAR_YEAR(Recognition_Date__c) = :yr AND Division__c = :division and Program__c in :programFilter
                                      ORDER BY Recognition_Date__c])
            {
                  monthMap.get(cy.Recognition_Date__c.month()).add(cy);
            }   
                     
            List<Month> tempMonths = new List<Month>();
            List<Quarter> tempQuarters = new List<Quarter>();
            
            for(Monthly_Plan__c planNumber: [Select Year__c, Program_Family__c, Name, Month__c, Id, Division__c, 
            										Business_Type__c, Amount__c From Monthly_Plan__c
													WHERE Division__c = :division AND Year__c = :yr
													and Program_Family__c in :programFilter ])
			{
				planMap.put(planNumber.Month__c.intValue(), planNumber.Amount__c.intValue());
			}

            for(Integer i=1; i<13; i++)
            {
                Month tempMonth = new Month(division, months[i], planMap.get(i), monthMap.get(i));      
                tempMonths.add(tempMonth);
                if(tempMonths.size()==3)
                {
                    Quarter tempQuarter = new Quarter(division, quarterMap.get(i) , tempMonths);
                    tempQuarters.add(tempQuarter); 
                    tempMonths.clear();
                }
            }
            quarters = tempQuarters;
            Name = division;
            for(Quarter q: quarters)
            {
                totalsales = totalsales + q.totalsales;
                plan = plan + q.plan;

            }          
            difference = totalsales - plan;
            if(plan > 0)
            {
                pscore = ((difference/plan)*100).round().intValue();            
            }        
		}         
    }

    public class AggregateYear{
    	List<String> months = new List<String>{'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'};
        public ProgramYear lcyear {get;set;}
        public List<List<companyMonth>> qList {get;set;}
        public List<companyMonth> q1List {get;set;}
        public List<companyMonth> q2List {get;set;}
        public List<companyMonth> q3List {get;set;}
        public List<companyMonth> q4List {get;set;}
        public Map<String,List<companyMonth>> quarterMap {get;set;}
        public Year ecsyear {get;set;}
        public Year otheryear {get;set;}
        public String Name {get;set;}
        public Integer Q1actuals {get;set;}
        public Integer Q1plan {get;set;}
        public Decimal Q1difference {get;set;}
        public Integer Q1pscore {get;set;}
        public Integer Q2actuals {get;set;}
        public Integer Q2plan {get;set;}
        public Decimal Q2difference {get;set;}
        public Integer Q2pscore {get;set;}                  
        public Integer Q3actuals {get;set;}
        public Integer Q3plan {get;set;}
        public Decimal Q3difference {get;set;}
        public Integer Q3pscore {get;set;}  
        public Integer Q4actuals {get;set;}
        public Integer Q4plan {get;set;}
        public Decimal Q4difference {get;set;}
        public Integer Q4pscore {get;set;}
        public Integer actuals {get;set;}
        public Decimal difference {get;set;}
        public Integer plan {get;set;}
        public Integer pscore {get;set;}
              
        public AggregateYear(Integer yr4digit, List<String> pgfilter, String divisionFilter){
        	q1List = new List<companyMonth>();
            q2List = new List<companyMonth>();
            q3List = new List<companyMonth>();
            q4List = new List<companyMonth>();
			Q1difference = 0;
			Q2difference = 0;
			Q3difference = 0;
			Q4difference = 0;
			difference = 0;
            if(divisionFilter == 'All')
            {
		        lcyear = new ProgramYear(yr4digit, pgfilter,'LC');
            	ecsyear = new Year(yr4digit, pgfilter,'ECS');
            	otheryear = new Year(yr4digit, pgfilter,'Other');	
            } else if (divisionFilter == 'LC')
            {
		        lcyear = new ProgramYear(yr4digit, pgfilter, 'LC');
            	ecsyear = new Year(yr4digit, pgfilter,'');
            	otheryear = new Year(yr4digit, pgfilter,'');	
            }
             else if (divisionFilter == 'ECS')
            {
		        lcyear = new ProgramYear(yr4digit, pgfilter, '');
            	ecsyear = new Year(yr4digit, pgfilter, 'ECS');
            	otheryear = new Year(yr4digit, pgfilter, '');	
            }  else if (divisionFilter == 'Other')
            {
		        lcyear = new ProgramYear(yr4digit, pgfilter, '');
            	ecsyear = new Year(yr4digit, pgfilter,'');
            	otheryear = new Year(yr4digit, pgfilter, 'Other');	
            }
            
            if(yr4digit == system.Today().year())
            {
            	Name = 'CURRENT YEAR';
            } else 
            {
            	Name = 'YEAR ' + yr4digit;
            }

            Q1actuals = lcyear.quarters[0].totalactual + ecsyear.quarters[0].totalsales + otheryear.quarters[0].totalsales;
            Q1plan = lcyear.quarters[0].totalplan + ecsyear.quarters[0].plan + otheryear.quarters[0].plan;
            Q1difference  = Q1actuals - Q1plan;
            if(Q1plan != 0)
            {
            	Q1pscore =  ((Q1difference / Q1plan) * 100).round().intValue();
            }
            
            Q2actuals= lcyear.quarters[1].totalactual + ecsyear.quarters[1].totalsales + otheryear.quarters[1].totalsales;
            Q2plan= lcyear.quarters[1].totalplan + ecsyear.quarters[1].plan + otheryear.quarters[1].plan;
            Q2difference = Q2actuals - Q2plan;
            if(Q2plan != 0)
            {
            	Q2pscore =  ((Q2difference / Q2plan) * 100).round().intValue();
            }             
            Q3actuals= lcyear.quarters[2].totalactual + ecsyear.quarters[2].totalsales + otheryear.quarters[2].totalsales;
            Q3plan= lcyear.quarters[2].totalplan + ecsyear.quarters[2].plan + otheryear.quarters[2].plan;
            Q3difference = Q3actuals - Q3plan;
            if(Q3plan != 0)
            {
            	Q3pscore =  ((Q3difference / Q3plan) * 100).round().intValue();
            }    
            Q4actuals= lcyear.quarters[3].totalactual + ecsyear.quarters[3].totalsales + otheryear.quarters[3].totalsales;
            Q4plan= lcyear.quarters[3].totalplan + ecsyear.quarters[3].plan + otheryear.quarters[3].plan;
            Q4difference = Q4actuals - Q4plan;
            if(Q4plan != 0)
            {
            	Q4pscore =  ((Q4difference / Q4plan) * 100).round().intValue();
            }      
            actuals =  Q1actuals + Q2actuals + Q3actuals + Q4actuals;
            plan = Q1plan + Q2plan + Q3plan + Q4plan;
            difference = actuals - plan;
            if(plan != 0)
            {
            	pscore =  ((difference / plan) * 100).round().intValue();
            }
         	Integer mCount = 0; 
            for(Integer q=0;q<4;q++)
            {
            	List<companyMonth> monthsList = new List<companyMonth>();
            	for(Integer m=0;m<3;m++)
            	{    
            		Integer mtotalSales = lcyear.quarters[q].monthsList[m].totalactual + ecsyear.quarters[q].months[m].totalsales + otheryear.quarters[q].months[m].totalsales ;
            		Integer mtotalPlan = lcyear.quarters[q].monthsList[m].totalplan + ecsyear.quarters[q].months[m].plan + otheryear.quarters[q].months[m].plan ;
            		companyMonth tempMonth  = new companyMonth( months[mCount], mtotalPlan, mtotalSales);
            		monthsList.add(tempMonth);
	            	mCount = mCount + 1;
            	}
            	if(q==0)
            	{
            		q1List = monthsList;
            	} else if (q==1)
            	{
            		q2List = monthsList;
            	} else if (q==2)
            	{
            		q3List = monthsList;
            	} else
            	{
            		q4List = monthsList;
            	}	
            }

        }                 
    }   
   
}