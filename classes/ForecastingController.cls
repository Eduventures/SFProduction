public with sharing class ForecastingController {
	public String baseurl {get;set;}
	public static Integer thisYear = system.Today().year();
	public static List<String> monthNames = new List<String>{'blank','January','February','March','April','May','June','July','August','September','October','November','December'};
    public static Map<Integer,Integer> quarterMap = new map<Integer,Integer>{1 =>1, 2 => 1,3 => 1, 4 => 2, 5 => 2, 6 => 2, 7 => 3,8 => 3,9 => 3, 10 => 4, 11 => 4, 12 => 4};
	public List<QuarterWrapper> quarters {get;set;}
    public Decimal LCPlan {get;set;}
    public Decimal ECSPlan {get;set;}
    public Decimal OtherPlan {get;set;}
    public Decimal totalPlan {get;set;}    
    public Decimal Plan {get;set;}
	public Decimal newLCSales {get;set;}
	public Decimal renewalLCSales {get;set;}
	public Decimal ECSSales {get;set;}
	public Decimal OtherSales {get;set;}
	public Decimal totalLCSales {get;set;}
	public Decimal totalLCSalesWF {get;set;}
    public Decimal totalECSSales {get;set;}
    public Decimal totalOtherSales {get;set;}	
    public Decimal totalActualSales {get;set;}	
    public Decimal totalSales {get;set;}	
	public Decimal forecastedLCNew {get;set;}
	public Decimal forecastedLCRenewal {get;set;}
	public Decimal forecastedLC {get;set;}
	public Decimal forecastedECS {get;set;}	
	public Decimal forecastedOther {get;set;}	
	public Integer pValue {get;set;}           	

	public List<Monthly_Plan__c> mpList {get;set;}
	public List<List<Contract_Year__c>> newLCSalesList {get;set;}
	public List<List<Contract_Year__c>> renewalLCSalesList {get;set;}
	public List<List<Contract_Year__c>> ECSSalesList {get;set;}
	public List<List<Contract_Year__c>> OtherSalesList {get;set;}	
			
	public List<List<Opportunity>> forecastedLCNewList {get;set;}
	public List<List<Opportunity>> forecastedLCRenewalList {get;set;}
	public List<List<Opportunity>> forecastedECSList {get;set;}	
	public List<List<Opportunity>> forecastedOtherList {get;set;}		


	public ForecastingController(){
		baseurl = URL.getSalesforceBaseUrl().toExternalForm();
		LCPlan = 0;
		ECSPlan = 0;
		OtherPlan = 0;
		totalPlan = 0;	
		newLCSales = 0;
		renewalLCSales = 0;
		ECSSales = 0;
		OtherSales = 0;
		totalLCSales = 0;
		totalLCSalesWF = 0;
   		totalECSSales = 0;
   		totalOtherSales = 0;
   		totalActualSales = 0;	
   		totalSales = 0;		
		forecastedLCNew = 0;
		forecastedLCRenewal = 0;
		forecastedLC = 0;
		forecastedECS = 0;
		forecastedOther = 0;
		pValue = 0;       
		quarters = new List<QuarterWrapper>();
		List<MonthWrapper> tempMonths = new List<MonthWrapper>();
		newLCSalesList = new List<List<Contract_Year__c>>();
		renewalLCSalesList = new List<List<Contract_Year__c>>();
		ECSSalesList = new List<List<Contract_Year__c>>();
		OtherSalesList = new List<List<Contract_Year__c>>();
		forecastedLCNewList = new List<List<Opportunity>>();
		forecastedLCRenewalList = new List<List<Opportunity>>();
		forecastedECSList = new List<List<Opportunity>>();
		forecastedOtherList = new List<List<Opportunity>>();
		mpList = new List<Monthly_Plan__c>();
		for(Integer i=1; i<13; i++)
        {
            MonthWrapper tempMonth = new MonthWrapper(monthNames[i]);
			
	        for(Monthly_Plan__c mp: [Select Division__c, Business_Type__c, Amount__c From Monthly_Plan__c
													WHERE Year__c = :thisYear and Month__c = :i])
			{
				if(mp.Division__c == 'LC')
				{
					mpList.add(mp);
					tempMonth.LCPlan = tempMonth.LCPlan + mp.Amount__c;
				} else if (mp.Division__c == 'ECS')
				{
					tempMonth.ECSPlan = tempMonth.ECSPlan + mp.Amount__c;
				} else {
					tempMonth.OtherPlan = tempMonth.OtherPlan + mp.Amount__c;
				}
			}

        	List<Contract_Year__c> tempCYs = new List<Contract_Year__c>();                            	
			newLCSalesList.add(tempCYs.deepClone()); 
			renewalLCSalesList.add(tempCYs.deepClone());  
			ECSSalesList.add(tempCYs.deepClone());  
			OtherSalesList.add(tempCYs.deepClone());  
				
	    	for(Contract_Year__c cy: [SELECT AV__c, Name, Division__c, LOA__c, LOA__r.Name, Program_Family__c, 
	                                    Recognition_Date__c, Id, Type__c, LOA__r.Agreement_Date__c FROM Contract_Year__c 
	                                  WHERE CALENDAR_YEAR(Recognition_Date__c) = :thisYear 
	                                  and CALENDAR_MONTH(Recognition_Date__c) = :i
	                                  ORDER BY Recognition_Date__c])
	        {
				if(cy.Division__c == 'LC')
				{
		        	if(cy.Type__c == 'New')
		        	{
						newLCSalesList[i-1].add(cy);
						tempMonth.newLCSales = tempMonth.newLCSales + cy.AV__c;
		        	} else 
		        	{
						renewalLCSalesList[i-1].add(cy);
						tempMonth.renewalLCSales = tempMonth.renewalLCSales + cy.AV__c;
		        	}
				} else if (cy.Division__c == 'ECS')
				{
					ECSSalesList[i-1].add(cy);
					tempMonth.ECSSales = tempMonth.ECSSales + cy.AV__c;
				} else {
					OtherSalesList[i-1].add(cy);
					tempMonth.OtherSales = tempMonth.OtherSales + cy.AV__c;
				}
	        } 
			
            List<Opportunity> tempOpps = new List<Opportunity>();
			forecastedLCNewList.add(tempOpps.deepClone());
			forecastedLCRenewalList.add(tempOpps.deepClone());
			forecastedECSList.add(tempOpps.deepClone());	
			forecastedOtherList.add(tempOpps.deepClone());	

	    	for(Opportunity opp: [SELECT Close_Date_New__c, Type, Annualized_Value__c, Product_Family__c, Product_Group__c, Name,
	    								RecordType.Name, Class__c, Original_LOA_Expiration_Date__c, Amount 
	                                  FROM Opportunity 
	                                  WHERE 
	                                  (
	                                  	(CALENDAR_YEAR(Close_Date_New__c) = :thisYear AND RecordType.Name != 'Member Program Renewals' AND CALENDAR_MONTH(Close_Date_New__c) = :i) 
	                                  	OR 
	                                  	(CALENDAR_YEAR(Original_LOA_Expiration_Date__c) = :thisYear AND RecordType.Name = 'Member Program Renewals' AND CALENDAR_MONTH(Original_LOA_Expiration_Date__c) = :i )
	                                  )
	                                  and StageName = 'Closeable'
	                                  ORDER BY Original_LOA_Expiration_Date__c, Close_Date_New__c])
	        {	        	
				if(opp.RecordType.Name == 'Member Programs')
				{
					forecastedLCNewList[i-1].add(opp);
		        	if(opp.Annualized_Value__c != null)
		        	{
		        		tempMonth.forecastedLCNew = tempMonth.forecastedLCNew + opp.Annualized_Value__c;
		        	}
				}else if (opp.RecordType.Name == 'Member Program Renewals')
				{
					forecastedLCRenewalList[i-1].add(opp);
		        	if(opp.Annualized_Value__c != null)
		        	{
		        		tempMonth.forecastedLCRenewal = tempMonth.forecastedLCRenewal + opp.Annualized_Value__c;
		        	}					
				} else if (opp.RecordType.Name == 'Consulting' && opp.Product_Family__c == 'ECS')
				{
					forecastedECSList[i-1].add(opp);
		        	if(opp.Amount != null)
		        	{
		        		tempMonth.forecastedECS = tempMonth.forecastedECS + opp.Amount;
		        	}
				} else 
				{
					//this should catch sponsorships, as well as RPTs (which are Consutling Record Type but Product Family = 'RPT' ) and 
					//possibly any other one-off types of opps we come up with in the future
					forecastedOtherList[i-1].add(opp);
		        	if(opp.Amount != null)
		        	{
		        		tempMonth.forecastedOther = tempMonth.forecastedOther + opp.Amount;
		        	}					
				}
	        } 
			tempMonth.calculateGrandTotals();
			tempMonths.add(tempMonth);
			if(Math.mod(i,3) == 0)
			{
				//make a quarter object
				QuarterWrapper tempQuarter = new QuarterWrapper('Q' + quarterMap.get(i), tempMonths);
				//add quarter to list of quarters
				quarters.add(tempQuarter);
				//clear tempMonths list
				tempMonths.clear();
			}
        }
        for(QuarterWrapper qr: quarters)
        {
			LCPlan = LCPlan + qr.LCPlan;
			ECSPlan = ECSPlan + qr.ECSPlan;
			OtherPlan = OtherPlan + qr.OtherPlan;
			totalPlan = totalPlan + qr.totalPlan;
			newLCSales = newLCSales + qr.newLCSales;
			renewalLCSales = renewalLCSales + qr.renewalLCSales;
			ECSSales = ECSSales + qr.ECSSales;
			OtherSales = OtherSales + qr.OtherSales;
			totalLCSales = totalLCSales + qr.totalLCSales;
			totalLCSalesWF = totalLCSalesWF + qr.totalLCSalesWF;
    		totalECSSales = totalECSSales + qr.totalECSSales;
	    	totalOtherSales = totalOtherSales + qr.totalOtherSales;
	    	totalActualSales = totalActualSales + qr.totalActualSales;			       
    		totalSales = totalSales + qr.totalSales;			
			forecastedLCNew = forecastedLCNew + qr.forecastedLCNew;
			forecastedLCRenewal = forecastedLCRenewal + qr.forecastedLCRenewal;
			forecastedLC = forecastedLC + qr.forecastedLC;
			forecastedECS = forecastedECS + qr.forecastedECS;
			forecastedOther = forecastedOther + qr.forecastedOther;
        }
        if(totalPlan != 0)
        {
        	pValue = (((totalSales - totalPlan) / totalPlan)*100).round().intValue();
        }                           
		
	}

    public PageReference export() {
      return Page.forecastingExport; 
    }
    
	public class MonthWrapper{
		public String name {get;set;}
		public Decimal LCPlan {get;set;}
		public Decimal ECSPlan {get;set;}
		public Decimal OtherPlan {get;set;}
	    public Decimal totalPlan {get;set;}		
		public Decimal newLCSales {get;set;}
		public Decimal renewalLCSales {get;set;}
		public Decimal ECSSales {get;set;}
		public Decimal OtherSales {get;set;}
		public Decimal totalLCSales {get;set;}
		public Decimal totalLCSalesWF {get;set;}
	    public Decimal totalECSSales {get;set;}
	    public Decimal totalOtherSales {get;set;}
	    public Decimal totalActualSales {get;set;}	 			    
	    public Decimal totalSales {get;set;}			
		public Decimal forecastedLCNew {get;set;}
		public Decimal forecastedLCRenewal {get;set;}
		public Decimal forecastedLC {get;set;}		
		public Decimal forecastedECS {get;set;}	
		public Decimal forecastedOther {get;set;}	
		public Integer pValue {get;set;}     
		public MonthWrapper(String s){
			name = s;
			LCPlan = 0;
			ECSPlan = 0;
			OtherPlan = 0;	
			totalPlan = 0;	
			newLCSales = 0;
			renewalLCSales = 0;
			ECSSales = 0;
			OtherSales = 0;
			totalLCSales = 0;
			totalLCSalesWF = 0;
    		totalECSSales = 0;
    		totalOtherSales = 0;
    		totalActualSales = 0;	
    		totalSales = 0;					
			forecastedLCNew = 0;
			forecastedLCRenewal = 0;
			forecastedLC = 0;
			forecastedECS = 0;
			forecastedOther = 0;
			pValue = 0;    
		}
		
		public void calculateGrandTotals(){
			totalLCSales = newLCSales + renewalLCSales;
			totalLCSalesWF = totalLCSales + forecastedLCNew + forecastedLCRenewal;
			totalECSSales = ECSSales + forecastedECS;
			totalOtherSales = OtherSales + forecastedOther;
			totalActualSales = totalLCSales + ECSSales + OtherSales;
			totalSales = totalLCSalesWF + totalECSSales + totalOtherSales;
	        totalPlan = LCPlan + ECSPlan + OtherPlan;
	        if(totalPlan != 0)
	        {
	        	pValue = (((totalSales - totalPlan) / totalPlan)*100).round().intValue();
	        }
	        forecastedLC = forecastedLCNew + forecastedLCRenewal;  
		}	
	}
	 
	public class QuarterWrapper {
		public String name {get;set;}
		public Decimal LCPlan {get;set;}
		public Decimal ECSPlan {get;set;}
		public Decimal OtherPlan {get;set;}
		public Decimal totalPlan {get;set;}		
		public Decimal newLCSales {get;set;}
		public Decimal renewalLCSales {get;set;}
		public Decimal ECSSales {get;set;}
		public Decimal OtherSales {get;set;}
		public Decimal totalLCSales {get;set;}
		public Decimal totalLCSalesWF {get;set;}
	    public Decimal totalECSSales {get;set;}
	    public Decimal totalOtherSales {get;set;}
	    public Decimal totalActualSales {get;set;}	 				    
	    public Decimal totalSales {get;set;}			
		public Decimal forecastedLCNew {get;set;}
		public Decimal forecastedLCRenewal {get;set;}
		public Decimal forecastedLC {get;set;}
		public Decimal forecastedECS {get;set;}	
		public Decimal forecastedOther {get;set;}
		public Integer pValue {get;set;}    	
		public List<MonthWrapper> months {get;set;}
		
		public QuarterWrapper(){
			months = new List<MonthWrapper>();
		}
			
		public QuarterWrapper(String n, List<MonthWrapper> monthsdata){
			months = new List<MonthWrapper>();
			name = n;
			LCPlan = 0;
			ECSPlan = 0;
			OtherPlan = 0;
			totalPlan = 0;		
			newLCSales = 0;
			renewalLCSales = 0;
			ECSSales = 0;
			OtherSales = 0;
			totalLCSales = 0;
			totalLCSalesWF = 0;
    		totalECSSales = 0;
    		totalOtherSales = 0;
    		totalActualSales = 0;	
    		totalSales = 0;		
			forecastedLCNew = 0;
			forecastedLCRenewal = 0;
			forecastedLC = 0;
			forecastedECS = 0;
			forecastedOther = 0;
			pValue = 0;
			for(MonthWrapper mw: monthsdata)
			{
				LCPlan = LCPlan + mw.LCPlan;
				ECSPlan = ECSPlan + mw.ECSPlan;
				OtherPlan = OtherPlan + mw.OtherPlan;
				totalPlan = totalPlan + mw.totalPlan;
				newLCSales = newLCSales + mw.newLCSales;
				renewalLCSales = renewalLCSales + mw.renewalLCSales;
				ECSSales = ECSSales + mw.ECSSales;
				OtherSales = OtherSales + mw.OtherSales;
				totalLCSales = totalLCSales + mw.totalLCSales;
				totalLCSalesWF = totalLCSalesWF + mw.totalLCSalesWF;
    			totalECSSales = totalECSSales + mw.totalECSSales;
    			totalOtherSales = totalOtherSales + mw.totalOtherSales;
    			totalActualSales = totalActualSales + mw.totalActualSales;
    			totalSales = totalSales + mw.totalSales;						
				forecastedLCNew = forecastedLCNew + mw.forecastedLCNew;
				forecastedLCRenewal = forecastedLCRenewal + mw.forecastedLCRenewal;
				forecastedLC = forecastedLC + mw.forecastedLC;
				forecastedECS = forecastedECS + mw.forecastedECS;
				forecastedOther = forecastedOther + mw.forecastedOther;
				months.add(mw);
			}
	        if(totalPlan != 0)
	        {
	        	pValue = (((totalSales - totalPlan) / totalPlan)*100).round().intValue();
	        }  	
		}		
	}
	
    public static testMethod void testForecastsPage() {
        PageReference forecastRef = Page.forecasting;
        Test.setCurrentPage(forecastRef);          
		ForecastingController FCcontroller = new ForecastingController();
    } 

}