public class renewalsChartController {

    private String chartData;

    public String getChartData()
    {
     return chartData;
    }
 
    public renewalsChartController()
    {

        //where chart data should be stored.
        List<ChartDataItem> items = new List<ChartDataItem>();
        String currMonth = '%' + Date.today().month();
        
        Decimal totalCount = [select count() from LOA__c where (End_Date__c = THIS_MONTH) or ( (Anniversary_Month__c LIKE :currMonth ) and Start_Date__c < THIS_MONTH and End_Date__c > THIS_MONTH  ) ];
        if (totalCount > 0)
        {
            Integer expiredCount = [select count() from LOA__c where End_Date__c = THIS_MONTH and Status__c = 'Expired'];
            if(expiredCount != 0) 
            {
                items.add(new ChartDataItem('Expired ' + (expiredCount/totalCount).setScale(2)  + '%',expiredCount.format())); 
            } 
            Integer activeCount = [select count() from LOA__c where End_Date__c = THIS_MONTH and Status__c = 'Active'];
            if(activeCount != 0) 
            {
               items.add(new ChartDataItem('Pending Renewal ' + (activeCount/totalCount).setScale(2)  + '%',activeCount.format() )); 
            }
            Integer extendedCount = [select count() from LOA__c where End_Date__c = THIS_MONTH and Status__c = 'Extended'];           
            if(extendedCount != 0) 
            {
               items.add(new ChartDataItem('Extended ' + (extendedCount/totalCount).setScale(2)  + '%',extendedCount.format() )); 
            }
            Double multiYearCount = totalCount  - (expiredCount + activeCount + extendedCount  );
            if(multiYearCount != 0) 
            {
               items.add(new ChartDataItem('Auto Renewal [multiyear] ' + (multiYearCount/totalCount).setScale(2)  + '%',multiYearCount.format() )); 
            }            

        }
        
         //Prepare the chart URL
         String chartPath = 'http://chart.apis.google.com/chart?chs=700x200&cht=p3';
         chartData = chartPath +  getChartData(items);
    }
       
    private String getChartData(List<ChartDataItem> items)
    {
        String chd = ''; //23,34,56
        String chl = ''; //Hello|World
    
        for(ChartDataItem citem : items)
        {
            chd += citem.ItemValue + ',';
            chl += citem.Label + '|';
        }
         //remove the last comma or pipe
         chd = chd.substring(0, chd.length() -1);
         chl = chl.substring(0, chl.length() -1);
        
         String result = '&chd=t:' + chd + '&chl=' + chl;
         return result;
    }
    
    public class ChartDataItem
    {
        public String ItemValue
        {
            get;
            set;
        }
    
         public String Label
         {
            get;
            set;
         }
        
         public ChartDataItem(String Label, String Value)
         {
            this.Label = Label;
            this.ItemValue = Value;
         }
    }
    
    public static testmethod void testOverrideEventButton() {
    	renewalsChartController rc = new renewalsChartController();
    }

}