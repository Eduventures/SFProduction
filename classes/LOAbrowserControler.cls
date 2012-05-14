public class LOAbrowserControler {

    public Integer yearToSearch;
    public Boolean showMissing;
    public Boolean isTest;
    private List<Integer> yearsForLoas = new List<Integer>();
    private List<LOA__c> loasMissingFiles = new List<LOA__c>();
    private List<LOA__c> loasWithFiles = new List<LOA__c>();

    public LOAbrowserControler ()
    {
    	isTest = false;
        init();
    }
    
    public LOAbrowserControler (String s)
    {
    	if(s == 'testmethod')
    	{
    		isTest = true;
    		init();
    	}
    }
        
    public void init()
    {
    	Integer thisYear = System.today().year();
        yearToSearch = thisYear;
        for(integer i = thisYear; i >= 2006; i--)
        {
        	yearsForLoas.add(i);
        }
        showMissing = true;
        updateLOAlists();
    }
    
    
    public void updateLOAlists()
    {
        loasMissingFiles.clear();
        loasWithFiles.clear();
        Map<ID, LOA__c> loaMap = new Map<ID, LOA__c>();
        Set<ID> loaAttachmentSet = new Set<ID>();
        
        List<LOA__C> tempLOAlist = new List<LOA__c>();
        if(isTest)
        {
        	tempLOAlist = [ select Id, Name, Program__c, Account__c, 
        		(Select Id, ParentId, ContentType From Attachments) from LOA__c WHERE CALENDAR_YEAR(CreatedDate) = :yearToSearch and Account__c != '0013000000G3Y0S' LIMIT 100];
        }
        else
        {
        	tempLOAlist = [ select Id, Name, Program__c, Account__c, 
        		(Select Id, ParentId, ContentType From Attachments)from LOA__c WHERE CALENDAR_YEAR(CreatedDate) = :yearToSearch and Account__c != '0013000000G3Y0S' ];
        }
		
        for(LOA__c l: tempLOAlist )
        {
			if(l.Attachments.isEmpty())
			{
				loasMissingFiles.add(l);
			}
			else
			{
				loasWithFiles.add(l);
			}
        }        
    }
    
    public List<SelectOption> getYears()
    {
        List<SelectOption> optionList = new List<SelectOption>();
            
        for(Integer i:yearsForLoas)
        {
            String y = String.valueOf(i);
            optionList.add(new SelectOption(y,y));
        }
        return optionList;
    }
    
    public void setyearToSearch(Integer i)
    {
        yearToSearch = i;
        updateLOAlists();
    }
    
    public String getyearToSearch()
    {
        return yearToSearch.format();
    }
    
    public Integer getLOAcount()
    {
        Integer temp = 0;
        if(showMissing)
        {
            temp = temp + loasMissingFiles.size();
        }
        else
        {
            temp = temp + loasWithFiles.size();
        }
        return temp;
    }
        
    public Boolean getshowMissing()
    {
        return showMissing;
    }
    
    public void setshowMissing(Boolean b)
    {
        showMissing = b;
    }
    
    public List<LOA__c> getloasMissingFiles()
    {
        return loasMissingFiles;
    }
    
    
    public List<LOA__c> getloasWithFiles()
    {
        return loasWithFiles;
    }
    
    public static testMethod void testLOAbrowserControler() {

        LOAbrowserControler controllerTest = new LOAbrowserControler('testmethod');
    
        try
        {
            controllerTest.getYears();
            controllerTest.getyearToSearch();
            controllerTest.getshowMissing();
            controllerTest.setshowMissing(false);
            controllerTest.getloasWithFiles();
            controllerTest.getloasMissingFiles();   
        }
        catch (System.DmlException e) 
        {
            System.debug('Failed to insert Case: ' + e);
        }
        
    } 
    

}