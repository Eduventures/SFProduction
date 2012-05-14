public class RenewalTrackerControllerv2 {
    //utility variables
    public class CYwrapper { 
        
        public LOA__c theLOA {get; set;}
        public Contract_Year__c theCY {get; set;}  
        public Integer renewedAmt {get; set;}
    	public Integer enrichmentAmt {get; set;}
    	public Decimal enrichmentRate {get; set;}
        public CYwrapper(LOA__c l, Contract_Year__c cy){
            theLOA = l;
            theCY = cy;
            renewedAmt = 0;
            if(theCY.Renewal_Contract_Year__c  != null)
            {
            	renewedAmt = Integer.valueOf(theCY.Renewal_Contract_Year__r.AV__c);
            	enrichmentAmt = Integer.valueOf(theCY.Renewal_Contract_Year__r.AV__c) - Integer.valueOf(cy.AV__c);
            	enrichmentRate = ( (enrichmentAmt / cy.AV__c)*100).setScale(1);
            } else {
	            enrichmentAmt = 0;
	            enrichmentRate = 0;            	
            }

        }
    }      
    public static Map<Integer,Integer> quarterMap = new map<Integer,Integer>{1 =>0, 2 => 0,3 => 0, 4 => 1, 5 => 1, 6 => 1, 7 => 2,8 => 2,9 => 2, 10 => 3, 11 => 3, 12 => 3};
    public List<Id> renewalIDsList {get; set;}
    public List<CYwrapper> wrappedCYs  {get; set;} 
    public Map<Id, LOA__c> LOAMap {get; set;}
    public Map<Integer, List<Contract_Year__c>> CYMap {get; set;}   
    public List<Integer>  PlanList {get; set;}
        
    public List< List <MonthWrapper> > calendarGrid {get; set;}
    public List<String> months;
    public List<String> currentPrograms;
    public String selectedProgram;
    public Date yearStart {get; set;}
    public Date yearEnd {get; set;}
    public String selectedYearString {get; set;}
    public static Integer selectedYear; 
    public List<Integer> years;  
    public Long targetRenewalCount {get; set;}
    public String hostUrl {get; set;}
    public Boolean dirty {get; set;}      

    //core data
    public Integer renewableUnits {get; set;}
    public Integer overallRenewalCount {get; set;}
    public Integer overallNonRenewalCount {get; set;}
    public Integer overallAtRiskCount {get; set;}
    public Integer overallNotAtRiskCount {get; set;}

    public Decimal YTDrenewalRate {get; set;}
    public Decimal projectedYTDrenewalRate {get; set;}
    public Decimal NotAtRiskPercentage {get; set;}
    public Decimal AtRiskPercentage {get; set;}
    //core data updated - adding AV
    public Decimal overallAvailableAmt {get; set;}
    public Integer overallRenewedAmt  {get; set;}
    public Integer overallProjectedRenewalAmt  {get; set;}
    public Decimal AV_YTDrenewalRate {get; set;}
    public Decimal AV_projectedYTDrenewalRate {get; set;}      
    public Decimal enrichmentBaseAmt  {get; set;}
    public Integer enrichmentAmt  {get; set;}
    public Decimal enrichmentRate {get; set;}
    public Integer overallPlanAmt  {get; set;}
               
    public class MonthWrapper {
        public String monthName {get;set;}
        public List<CYwrapper> loas {get;set;}
        public Integer availableCount {get;set;}
        public Integer renewedCount {get;set;}
        public Integer projectedCount {get;set;}
        public Integer availableAmt {get;set;}
        public Integer renewedAmt {get;set;}
        public Integer projectedAmt {get;set;}
        public Integer atRiskAmt {get;set;}
        public Integer notAtRiskAmt {get;set;}
        public Integer atRiskCount {get;set;}
        public Integer notatRiskCount {get;set;}
        public Integer nonRenewalCount {get;set;}
        public Integer planAmt {get;set;}
    	public Decimal enrichmentBaseAmt  {get; set;}
    	public Integer enrichmentAmt  {get; set;}
    	public Decimal enrichmentRate {get; set;}        
        
        public void recalculate() {
            availableCount = 0;
            renewedCount = 0;
            projectedCount = 0;
            availableAmt = 0;
            renewedAmt = 0;
            projectedAmt = 0;
            atRiskAmt = 0;
            notAtRiskAmt = 0;
            atRiskCount = 0;
            notatRiskCount = 0; 
            nonRenewalCount = 0;           
            for(CYwrapper wcy : loas)
            {
                if(wcy.theLOA.Replaced__c != true)
                {
                    availableCount = availableCount + 1;
                    Integer cyval = Integer.valueOf(wcy.theCY.AV__c);
                    availableAmt = availableAmt + cyval;
                    if( wcy.renewedAmt != 0)
                    {
                        renewedCount = renewedCount + 1; 
                        renewedAmt = renewedAmt + wcy.renewedAmt;
                    } else if (wcy.theLOA.Renewal_Risk__c == 'Not At Risk' )
                    {
                        notAtRiskAmt = notAtRiskAmt + cyval;
                        notatRiskCount = notatRiskCount + 1;
                    } else if(wcy.theLOA.Renewal_Risk__c == 'Not Renewing')
                    {
                        nonRenewalCount = nonRenewalCount + 1;
                    }
                     else
                    {
                        atRiskCount = atRiskCount + 1;
                        atRiskAmt = atRiskAmt + cyval;
                    }
                    projectedCount = renewedCount + notatRiskCount;
                    projectedAmt = renewedAmt + notAtRiskAmt;
                }   
            }
        }
        
        public MonthWrapper(String name) {
            monthName = name;
            loas = new List<CYwrapper>();
            availableCount = 0;
            renewedCount = 0;
            projectedCount = 0;
            availableAmt = 0;
            renewedAmt = 0;
            projectedAmt = 0;
            atRiskAmt = 0;
            notAtRiskAmt = 0;
            atRiskCount = 0;
            notatRiskCount = 0;
            nonRenewalCount = 0;
            planAmt = 0;
			enrichmentBaseAmt = 0;
	    	enrichmentAmt = 0;
	    	enrichmentRate = 0;              
        }
        
        public MonthWrapper() {
            monthName = '';
            loas = new List<CYwrapper>();
            availableCount = 0;
            renewedCount = 0;
            projectedCount = 0;
            availableAmt = 0;
            renewedAmt = 0;
            projectedAmt = 0;
            atRiskAmt = 0;
            notAtRiskAmt = 0;
            atRiskCount = 0;
            notatRiskCount = 0;
            nonRenewalCount = 0;
            planAmt = 0;
			enrichmentBaseAmt = 0;
	    	enrichmentAmt = 0;
	    	enrichmentRate = 0;              
        }
        
        public MonthWrapper(String name, List<CYwrapper> cylist, Integer p) {
            monthName = name;
            availableCount = 0;
            renewedCount = 0;
            projectedCount = 0;
            availableAmt = 0;
            renewedAmt = 0;
            projectedAmt = 0;
            atRiskAmt = 0;
            notAtRiskAmt = 0;
            atRiskCount = 0;
            notatRiskCount = 0;
            nonRenewalCount = 0;
            planAmt = p;
			enrichmentBaseAmt = 0;
	    	enrichmentAmt = 0;
	    	enrichmentRate = 0;     
            loas = cylist;
            for(CYwrapper wcy : loas)
            {
                if(wcy.theLOA.Replaced__c != true)
                {
                    availableCount = availableCount + 1;
                    Integer cyval = Integer.valueOf(wcy.theCY.AV__c);
                    availableAmt = availableAmt + cyval;
                    if(wcy.renewedAmt != 0)
                    {
                    	enrichmentBaseAmt = enrichmentBaseAmt + Integer.valueOf(wcy.theCY.AV__c);
	    				enrichmentAmt = enrichmentAmt + wcy.enrichmentAmt;
                        renewedCount = renewedCount + 1; 
                        renewedAmt = renewedAmt + wcy.renewedAmt;
                    } else if (wcy.theLOA.Renewal_Risk__c == 'Not At Risk' )
                    {
                        notAtRiskAmt = notAtRiskAmt + cyval;
                        notatRiskCount = notatRiskCount + 1;
                    } else if(wcy.theLOA.Renewal_Risk__c == 'Not Renewing')
                    {
                        nonRenewalCount = nonRenewalCount + 1;
                    }
                    else
                    {
                        atRiskCount = atRiskCount + 1;
                        atRiskAmt = atRiskAmt + cyval;
                    }
                    projectedCount = renewedCount + notatRiskCount;
                    projectedAmt = renewedAmt + notAtRiskAmt;
                }   
            }
            if(enrichmentBaseAmt > 0)
            {
            	enrichmentRate = ( (enrichmentAmt / enrichmentBaseAmt)*100).setScale(1); 
            }
        }
    }
          
    public RenewalTrackerControllerv2(){
        init();
    }    
    
    private void init(){
        system.debug('init run');
        dirty = false;
        hostUrl = 'http://'+ApexPages.currentPage().getHeaders().get('Host')+'/';
        wrappedCYs = new List<CYwrapper>();
        LOAMap = new Map<Id, LOA__c>();
        CYMap = new Map<Integer, List<Contract_Year__c>>();
        PlanList = new List<Integer>();
        months = new List<String>{'January','February','March','April','May','June','July','August','September','October','November','December'};
        currentPrograms = new List<String>{'ACL','AIE','CPE','DEV','ENM','OHE', 'SOE'};
        selectedProgram = 'AIE';
        if(Apexpages.currentPage().getParameters().containsKey('selected'))
        {
            selectedProgram = Apexpages.currentPage().getParameters().get('selected');
            Apexpages.currentPage().getParameters().remove('selected');
        }
        selectedyear = System.today().year();
        selectedYearString = selectedYear.format();
        years = new List<Integer>();
        years.add(2010);
        years.add(2011);
        years.add(2012);
        
        overallRenewalCount = 0;
        overallNonRenewalCount = 0;
        overallAtRiskCount = 0;
        overallNotAtRiskCount = 0; 
        
        overallAvailableAmt  = 0; 
        overallRenewedAmt  = 0; 
        overallProjectedRenewalAmt = 0; 

		enrichmentBaseAmt = 0;
    	enrichmentAmt = 0;
    	enrichmentRate = 0;
      
        YTDrenewalRate = 0;
        projectedYTDrenewalRate = 0;
        AV_YTDrenewalRate = 0;
        AV_projectedYTDrenewalRate = 0;    
        overallPlanAmt = 0; 
      
        yearStart = date.newInstance(selectedYear, 1, 1);
        yearEnd = date.newInstance(selectedYear, 12, 31);
        calendarGrid = new List< List <MonthWrapper> >();
        Integer tempCount = 0;
        for(integer i = 0; i<4; i++)
        {
            calendarGrid.add(new List<MonthWrapper>());
            for(integer j = 0; j<3; j++)
            {
                calendarGrid[i].add(new MonthWrapper(months[tempCount]));
                CYMap.put(tempCount,new List<Contract_Year__c>()); 
                PlanList.add(0);
                tempCount = tempCount + 1;
            }     
        }
        wrapLOAs();
    }
        
    public void wrapLOAs() {
    
         buildLOAlist(true);
         dirty = false;
    }
    
    public PageReference export() {
      return Page.RenewalTrackerPrintXLSv2;
    }

    private void buildLOAlist(Boolean refreshData){
        overallRenewalCount = 0;
        overallNonRenewalCount = 0;
        overallAtRiskCount = 0;
        overallNotAtRiskCount = 0;
        overallAvailableAmt = 0;
        overallRenewedAmt = 0;
        overallProjectedRenewalAmt = 0;
		enrichmentBaseAmt = 0;
    	enrichmentAmt = 0;
    	enrichmentRate = 0;                        
        
        for(integer i = 0; i<4; i++)
        {
            for(integer j = 0; j<3; j++)
            {
                calendarGrid[i][j].loas.clear();
                calendarGrid[i][j].renewedCount = 0;
            }     
        }        
        if(refreshData)
        {
        	for(Monthly_Plan__c mp : [Select Year__c, Program_Family__c, Month__c, Division__c, 
                                                Business_Type__c, Amount__c From Monthly_Plan__c
                                                WHERE Division__c = 'LC' AND Year__c = :selectedYear
                                                and Program_Family__c = :selectedProgram and 
                                                Business_Type__c = 'Renewal'])
	        {
	            PlanList.set(Integer.valueOf(mp.Month__c-1),Integer.valueOf(mp.Amount__c));
	            overallPlanAmt = overallPlanAmt +  Integer.valueOf(mp.Amount__c);         
	        }  
                LOAMap.clear();
                for(Integer i=1;i<13;i++)
            {
                        if(CYMap.get(i) != null)
                        {
                                CYMap.get(i).clear();
                        }       
            }

            for(LOA__c tempLOA : [SELECT Name, Status__c, Renewed__c, Renewal_Risk__c, Renewal_LOA__c, Account__c,
                                                        Multiyear_Contract__c, Replaced__c, End_Date__c FROM LOA__c 
                             WHERE Program_Family__c = :selectedProgram and RecordTypeId = '01230000000DMbx' 
                             and CALENDAR_YEAR(Start_Date__c) <= :selectedYear and CALENDAR_YEAR(End_Date__c) >= :selectedYear])
             {
                LOAMap.put(tempLOA.Id, tempLOA);
             }
                             
            for(Integer month=1;month<13;month++)
            {
                List<Contract_Year__c> tempCYlist = new List<Contract_Year__c>();
                for(Contract_Year__c tempcy : [ SELECT LOA__c, AV__c, End_Date__c, Type__c, Renewal_Contract_Year__c, Renewal_Contract_Year__r.AV__c
                                                    FROM Contract_Year__c WHERE Program_Family__c = :selectedProgram 
                                                        AND CALENDAR_MONTH(End_Date__c) = :month and  CALENDAR_YEAR(End_Date__c) = :selectedYear
                                                    ORDER BY End_Date__c])
                {
                    tempCYlist.add(tempcy);
                }
                CYMap.put( (month),tempCYlist);                   
            }

        } else {

                for(integer i = 0; i<4; i++)
                {
                    for(integer j = 0; j<3; j++)
                    {
                        calendarGrid[i][j].recalculate();
                    }     
                }               
        }
        
        Integer replaceCount = 0;
        Integer totalCYcount = 0;           
        for(Integer month=1;month<13;month++)
        {
            List<CYwrapper> tempWCYlist = new List<CYwrapper>();
            for(Contract_Year__c tempcy : CYMap.get(month))
            {
                LOA__c temploa = LOAMap.get(tempcy.LOA__c); 
                totalCYcount = totalCYcount + 1;
                if(temploa.Status__c == 'Replaced__c')
                {
                    replaceCount = replaceCount + 1;
                }                 
                        
                tempWCYlist.add(new CYwrapper(temploa,tempcy));
            }
            MonthWrapper tempMW = new MonthWrapper(months[month-1],tempWCYlist,PlanList.get(month-1));
            overallRenewalCount = overallRenewalCount + tempMW.renewedCount;
            overallNonRenewalCount = overallNonRenewalCount + tempMW.nonRenewalCount;
            overallAtRiskCount = overallAtRiskCount + tempMW.atRiskCount;
            overallNotAtRiskCount = overallNotAtRiskCount + tempMW.notAtRiskCount;
            overallAvailableAmt = overallAvailableAmt + tempMW.availableAmt;
            overallRenewedAmt = overallRenewedAmt + tempMW.renewedAmt;
            overallProjectedRenewalAmt = overallProjectedRenewalAmt + tempMW.projectedAmt; 
            enrichmentBaseAmt = enrichmentBaseAmt + tempMW.enrichmentBaseAmt;
    		enrichmentAmt = enrichmentAmt + tempMW.enrichmentAmt;
            Integer quarter = quarterMap.get(month);
            Integer themonth =  (month - (quarter*3)) - 1;
            calendarGrid[quarterMap.get(month)][themonth] = tempMW;
        }
        renewableUnits = totalCYcount - replaceCount; 
        if(renewableUnits != 0)
        { 
        	Decimal convertUnitsToDecimal = decimal.valueOf(renewableUnits);
            YTDrenewalRate = ((overallRenewalCount/convertUnitsToDecimal)*100).setScale(1);
            projectedYTDrenewalRate =  (((overallRenewalCount + overallNotAtRiskCount)/convertUnitsToDecimal)*100).setScale(1);
            NotAtRiskPercentage = overallNotAtRiskCount *(100) /renewableUnits;
            AtRiskPercentage = overallAtRiskCount *(100) /renewableUnits;
            targetRenewalCount = (renewableUnits * .82).round(system.roundingMode.UP);   
            AV_YTDrenewalRate = ( (overallRenewedAmt / overallAvailableAmt)*100).setScale(1);
            AV_projectedYTDrenewalRate  =  ( (overallProjectedRenewalAmt / overallAvailableAmt)*100).setScale(1);
            enrichmentRate = ( (enrichmentAmt / enrichmentBaseAmt)*100).setScale(1);
        } else 
        {
        	overallRenewalCount = 0;
            overallNonRenewalCount = 0;
            overallAtRiskCount = 0;
            overallNotAtRiskCount = 0;

            YTDrenewalRate = 0;
            projectedYTDrenewalRate = 0;
            NotAtRiskPercentage = 0;  
            
            AV_YTDrenewalRate = 0;
            AV_projectedYTDrenewalRate = 0;  
         }                             
    }
    
    public List<SelectOption> getcurrentPrograms() {
        List<SelectOption> optionList = new List<SelectOption>();    
        for(String s:currentPrograms)
        {
            optionList.add(new SelectOption(s,s));
        }
        return optionList;
    }  
    
    public List<SelectOption> getyears() {
        List<SelectOption> optionList = new List<SelectOption>();    
        for(Integer s:years)
        {
            optionList.add(new SelectOption(String.valueOf(s),String.valueOf(s)));
        }
        return optionList;
    }  
    
    public PageReference updateLOA (){
        buildLOAlist(false);
        dirty = true;
        return null;   
    }
    
    public void setselectedProgram(String s) {
        selectedProgram = s;
    }
    
    public String getselectedProgram() {
        return selectedProgram;
    }

    public void setselectedYear(Integer s) {
        selectedYear = s;
    }
    
    public Integer getselectedYear() {
        return selectedYear;
    }    
}