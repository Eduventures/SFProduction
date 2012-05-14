public with sharing class LOAaccountMgmtController {
    LOA__c currentLOA;
    public Decimal editindex;
    public Contact editContact { get; set; }
    String membershipRoles = '';
    String MRQuery;
    String noMRQuery;
    String editedContactName;   
    
    public LOAaccountMgmtController(ApexPages.StandardController controller) {
        this.currentLOA = (LOA__c)controller.getRecord();
        init(); 
    } 
    
    //alternate constructor, should only be used for Test Cases
    public LOAaccountMgmtController(String loaId) 
    {       
        try{
            this.currentLOA = [select l.Id, l.Program__c, l.Account__c, l.Account__r.Name from LOA__c l where Id = :loaId];
        }
        catch (Exception e) 
        {
            System.debug('Failed to find LOA by ID: ' + e);
        }
        init();
    } 

    public void init() {
        Schema.DescribeFieldResult mrField = Contact.Membership_Role__c.getDescribe();
        List<Schema.PicklistEntry> mrValues = mrField.getPicklistValues();
		String tempProg = currentLOA.Program__c.substring(0,3)+ ' ';
		if(currentLOA.Program__c == 'SEM')
		{
			tempProg = 'ENM';
		}
        for(PicklistEntry p : mrValues)
        {
            if(p.getLabel().contains(tempProg))
            {
                if(membershipRoles != '')
                {
                    membershipRoles = membershipRoles + ',\'' + p.getLabel() + '\'';
                }
                else
                {
                    membershipRoles = '\'' + p.getLabel() + '\'';
                }
                
            }
        }
        
        MRQuery   = 'SELECT Id, Name, FirstName, LastName, Membership_Role__c FROM Contact WHERE AccountId = \'' + currentLOA.Account__c + '\' AND Membership_Role__c INCLUDES (' + membershipRoles + ') ORDER BY LastName, FirstName';
        
        noMRquery = 'SELECT Id, Name, FirstName, LastName, Membership_Role__c FROM Contact WHERE AccountId = \'' + currentLOA.Account__c + '\' AND Membership_Role__c EXCLUDES (' + membershipRoles + ') ORDER BY LastName, FirstName';  
        editindex = -1.0;    
    }
    
    public List<Contact> getcontactsWithRoles () {
        List<Contact> results = Database.query(MRQuery);   
        return results;
    }    
     
    public List<Contact> getcontactsWithoutRoles() {
        List<Contact> noMRresults = Database.query(noMRquery);   
        return noMRresults;   
    }
    
    public String getComputedSearchTerm() {
        return currentLOA.Program__c.substring(0,3) + ' Liaison';
    }
    

    public String getmembershipRoles() {
         return membershipRoles;
    }     

    public PageReference removeInline()
    {
        PageReference temp = ApexPages.currentPage();
        temp.getParameters().put('inline', '0');
        return null;
    }
        
    public PageReference getEditUrl(){
        string contactParam = apexpages.currentpage().getparameters().get('contactParam');
        PageReference temp = new PageReference('/'+ contactParam +'/e?retURL=/'+currentLOA.id);
        return temp;
    }

    
    public PageReference addNew()
    {
        editContact = null;
        editindex = -1.0;
        PageReference temp = Page.addNewMembershipRole;
        temp.getParameters().put('acctid', currentLOA.Account__c);
        return temp;
        //PageReference temp2 = new PageReference('/003?rlid=RelatedContactList&id=' + currentLOA.Account__c);
        //return temp2;
    }
    
    public String getNewContactUrl()
    {
        String url =  '/003/e?retURL=/' + currentLOA.Id + '&accid=' + currentLOA.Account__c;
        return url; 
    }

    public String getParam(String name) {
        return ApexPages.currentPage().getParameters().get(name);   
    }

    public PageReference cancelEdit() {
        editContact = null;
        editindex = -1.0;
        return null;
    }
    
    public PageReference saveEdit() {
        try {
            UPDATE editContact;
            editedContactName = editContact.Name;
            editContact = null;
        } catch (Exception e) {
            ApexPages.addMessages(e);
        }
        return null;
    }

    public String geteditedContactName() {
        String temp = editedContactName;
        editedContactName = '';
        return temp;
    }
    
    public PageReference edit() {
        String editid = getParam('editid');
        editindex = Decimal.valueOf(getParam('editindex'));
        editContact = [SELECT Name, Membership_Role__c FROM Contact WHERE Id=:editid];
        return null;
    }
    
    public Decimal geteditindex(){
        return editindex;
    }
    
    public Boolean getEditRights(){
        if (Schema.sObjectType.Contact.fields.Membership_Role__c.isUpdateable())
        {
              return true;
        }
        else
        {
            return false;
        }    
    }     
        
    public PageReference goBack()
    {
        editContact = null;
        editindex = -1.0;
        PageReference temp = new PageReference('/'+ currentLOA.id);
        temp.getParameters().put('inline', '0');
        return temp;
    }

    public static testMethod void testLOAaccountMgmtController() {
	
		try
		{
        	//test using AJs TEst Account's active LOA
        	LOAaccountMgmtController controller = new LOAaccountMgmtController ('a088000000AtPtq');
        	PageReference pageRef = new PageReference('/apex/LOAaccountMgmt?editid=0033000000LPQRo&editindex=0.0');
            Test.setCurrentPage(pageRef); 
        	controller.getComputedSearchTerm();
	        controller.getmembershipRoles();
	        controller.getcontactsWithRoles();
	        controller.getcontactsWithoutRoles();
	        controller.removeInline();
	        controller.getEditUrl();  
	        controller.addNew();
	        controller.getNewContactUrl();
	        controller.cancelEdit();     
	        controller.saveEdit();
	        controller.geteditedContactName();
	        controller.edit();        
	        controller.geteditindex();   
	        controller.goBack();     
		
		}
		catch (System.DmlException e) 
    	{
    		System.debug('Failed to create controller for LOAacctMgmt: ' + e);
    	}
    	
       
    } 
}