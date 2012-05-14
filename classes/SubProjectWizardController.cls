public class SubProjectWizardController {

    Projects__c master = [Select Id, Name, Programs__c, Product__c, Stage__c, Divisions__c from Projects__c where Id =:System.currentPageReference().getParameters().get('master')];
    String projectName ='';
    String masterProgram = master.Programs__c;
         
    /**/RecordType rType= new RecordType (
    	Id='01230000000DUNy', 
    	Name = 'Sub Projects');
     
    Id selectedProject = master.Id;
    String[] desel = new String[]{};
    String[] sel = new String[]{};

    List<Account> selectedAccts = new List<Account>();
    List<LOA__c> assocaitedLOAs = new List <LOA__c>();
    List<Projects__c> newSubProjects = new List<Projects__c>();        
        
    public List<SelectOption> getMemberOptions(){ 
    	
    	//until the projects are updated with 3 letter abbreviations, make sure you handle AL, EM, SA
	    if(master.Programs__c == 'AL')
	    {
	    	masterProgram = 'ACL';
	    }
	    else if(master.Programs__c == 'EM')
	    {
	    	masterProgram = 'ENM';
	    }
	    else if (master.Programs__c == 'SA' )
	    {
	    	masterProgram = 'STA';
	    }

        List<SelectOption> mOptions = new List<SelectOption>();
        
        for(Account member: getMembers())
        {
            mOptions.add(new SelectOption(member.Id, member.Name));        
        }
        return mOptions;
        
    }
    
    /**/public List<SelectOption> getRecordTypeOptions(){
    
        List<SelectOption> rtOptions = new List<SelectOption>();

		//rtOptions.add(new SelectOption('01230000000DUNy', 'Sub Projects'));  
        rtOptions.add(new SelectOption(rType.Id, rType.Name));        

        return rtOptions;
        
    }
        
    public List<Account> getSelectedAccts () {
         
         //do a simple Bubble Sort to arrange Accounts in order by Name
		
		  for (integer i = 0; i < selectedAccts.size(); i++) 
		  {
		    for (integer j = 0; j < selectedAccts.size()-1; j++) 
		    {
		      if ( selectedAccts[j].Name.compareTo(selectedAccts[j + 1].Name) > 0 ) 
		      {
		         Account temporaryAccountHolder = selectedAccts[j];   //used to swap values of two array entries
		        selectedAccts[j] = selectedAccts[j + 1];
		        selectedAccts[j + 1] = temporaryAccountHolder;
		      }
		    }
		  }
  		
        return selectedAccts;
    }
    
    public integer getSelectedAcctsSize () {
    	
    	return selectedAccts.size();	
    }     
    
    public Id getSelectedProject () {
        return selectedProject;
    }
    
    public List<Projects__c> getNewSubProjects () {
        return newSubProjects;
    }  
    
    public void setNewSubProjects (List<Projects__c> newSubProjects) {
        this.newSubProjects = newSubProjects;
    }

    public void setSelectedAccts (List<Account> SelectedAccts ) {
        this.SelectedAccts = SelectedAccts;
    }

    public String[] getsel() {
            return sel;
    }

    public void setsel(String[] sel){
        this.sel = sel;
        if(sel != null)
        {
            selectedAccts = [SELECT Id, Name, Active_Engagements__c FROM Account where Id in :sel];
        }
    }
         
   public Projects__c getMaster() {
      if(master == null) master = new Projects__c();
      return master;
   }
   

   public RecordType getrType() {
      if(rType == null) rType= new RecordType();
      return rType;
   }        
   
   public List<Account> getMembers() {
   		//get active LOAs for the program that the master project is for
   		String tempmasterProgram = masterProgram + '%';
   		
   		List<LOA__c> activeLOAs = [SELECT Id, Program__c, End_Date__c, Renewed__c, Account__c, Account__r.Name, Account__r.Active_Engagements__c, Name, Status__c from LOA__c 
   			where Program__c LIKE :tempmasterProgram and ( (Renewed__c = true and End_Date__c >= TODAY) or (Status__c in ('Active','Extended')) ) ORDER BY Account__r.Name];
		
		//get the related account #'s from Active LOAs
  		Set<Id> acctIds = new Set<Id>();   				
    	for (LOA__c l : activeLOAs)
    	{
    		//put them in a set
    		acctIds.add(l.Account__c); 
    	}
		//create the account List to populate the Select box - this will not display any "child" accounts as they have no LOA themselves
  		List<Account> activeAccts = [SELECT Id, Name, Active_Engagements__c FROM Account Where Id in :acctIds ORDER BY Name];
    	return activeAccts;
    }
    
   public PageReference page1() {
      return Page.SubProjectWizard;
   }

   public PageReference page2() {
   	
   	return Page.SubProjectWizardPage2;
   	
   	/*String test = '';
   	try {
    		return Page.SubProjectWizardPage2;
	} 
	catch (System.DmlException e) 
	{
        test = 'Error: '+ e.getCause();        
    }
    System.debug(test);
    

    	return Page.SubProjectWizardPage2;*/
 
   }
   
   public PageReference page3() {
      return Page.SubProjectWizardPage3;
   }   
   

    public PageReference invokeService() {
        Id id = System.currentPageReference().getParameters().get('projectid');
        selectedProject = id; 
        return null;
    }
   
    /*public PageReference checkMaster() {
	  	PageReference p = null;
	    String masterParam = System.currentPageReference().getParameters().get('master');           
	    if (masterParam == null) {
	        p = Page.failure;
	        p.getParameters().put('error', 'noParam');
	        return p;
	    } 
	    else
	    {
	    	return null;	
	    }
    }*/
   
   public PageReference save() {
        
        //System.debug(sel);
        //selectedAccts = [SELECT Id, Name, Active_Engagements__c FROM Account where Id in :sel];
        
        assocaitedLOAs = [SELECT Id, Program__c, Account__c, Account__r.Name, Renewed__c, Status__c, Name from LOA__c where Account__c in :sel AND Program__c LIKE :masterProgram and ( (Renewed__c = true and End_Date__c >= TODAY) or (Status__c in ('Active','Extended')) ) ORDER BY Account__r.Name];
           
        for(Account a: selectedAccts )
       {
            for(LOA__c l : assocaitedLOAs)
            {
                if(l.Account__c == a.Id)
                {                
                  Projects__c p = new Projects__c(
                    Name = master.Name + ' - ' + a.Name,
                    Account__c = a.Id,
                    LOA__c = l.Id,
                    Master_Project__c = master.Id,
                    Stage__c = master.Stage__c,
                    Product__c = master.Product__c,
                    Programs__c = masterProgram,
                    Divisions__c = master.Divisions__c,
                    RecordTypeId = '01230000000DUNy');
                    //RecordTypeId = rType.id);
                
                  newSubProjects.add(p);
                }
            }
       }
       
       insert newSubProjects;
        
       return Page.SubProjectWizardPage3;
    }
    
    public PageReference finish() { 
        PageReference redirectToMaster = new PageReference('/' + master.id);
        redirectToMaster.setRedirect(true);
        
        return redirectToMaster;
      
    } 
    
    public PageReference  viewDetail () {
        // Send the user to the detail page for the new account.
        Id subproject = System.currentPageReference().getParameters().get('subproject');
        PageReference subprojectPage = new PageReference('/' + subproject);
        subprojectPage.setRedirect(true);

    return subprojectPage; 
        
    }

    static testMethod void testSubProjectWizard() {
        
        List <String> selected = new List <String> {'0013000000G3Yln', '0013000000G3ZVy'} ;

        PageReference testWizardPage = new PageReference(Page.SubProjectWizard + '?master=a063000000185yS');
        Test.setCurrentPage(testWizardPage);
      
        SubProjectWizardController controller = new SubProjectWizardController();
        String nextPage = testWizardPage.getUrl();

		//String nextPage = testWizardPage.checkMaster().getUrl();
        // Verify that page fails without parameters
        //System.assertEquals('/apex/failure?error=noParam', nextPage);

        //controller.getRType();
        
        // Add parameters to page URL
        ApexPages.currentPage().getParameters().put('master','a063000000185yS');
        ApexPages.currentPage().getParameters().put('projectid','a063000000185yS');
        ApexPages.currentPage().getParameters().put('subproject','a063000000185yS');
        
        // Instantiate a new controller with all parameters in the page
        controller = new SubProjectWizardController(); 
        controller.setsel(selected);
        nextPage = controller.save().getUrl();
        //controller.save();

        // Verify that the success page displays
        System.assertEquals('/apex/subprojectwizardpage3', nextPage);
        Projects__c[] subProjects = [select id, Master_Project__c, CreatedDate from Projects__c where Master_Project__c = 'a063000000185yS' and CreatedDate = TODAY];
        //System.assert(subProjects.size() == 2);
        //System.assert(subProjects.size() >= selected.size(), 'New Projects not created');
       
        controller.getMembers();  
        controller.getMemberOptions();   
        controller.getRecordTypeOptions();
        controller.getrType();
        //controller.getSelectedAccts();
        controller.getSelectedProject();
        controller.getNewSubProjects();
        controller.getMaster();
        controller.page1();
        controller.page2();        
        controller.page3();
        controller.invokeService();
        controller.finish();
        controller.viewDetail();
        controller.getsel();
        }   
 
}