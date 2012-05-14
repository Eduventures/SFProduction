public class PurchaseOrderControllerExtension {
    
    public Map<String, String[]> details = new Map<String, String[]>();
    public final Purchase_Order__c newOrder;
    public Account vendor;
    public Contact clientContact;
    public Contact vendorContact;  
    public Contact newClientContact;
    public Account newVendor;
    public Account client;
    public Boolean isTestingMethod {get;set;}
    public Boolean editMode {get; set;}   
    public Boolean ccEditMode {get; set;}  
    public Boolean shownewClientContactForm;
    public Boolean shownewVendorForm; 
    public Boolean showVendorSearch; 
    public Boolean tooManyResults;
    public String searchTerm; 
    public String searchTerm2; 
    public String queryName;
    public List<Account> foundVendors;
    public Attachment attachment {get;set;}
  

    public PageReference validateSearch() {
        searchTerm = Apexpages.currentPage().getParameters().get('sterm');
        searchVendors();
        return null;
    }
    
    public PurchaseOrderControllerExtension (Purchase_Order__c po)
    {
        newOrder = po;
        init();
    }
     
    public PurchaseOrderControllerExtension (ApexPages.StandardController stdController) {
        this.newOrder = (Purchase_Order__c)stdController.getRecord();
        init();  
    }
    
    public void init()
    {
    	isTestingMethod = false;
        attachment = new Attachment();
        showVendorSearch = true;
        tooManyResults = false;
        setshownewVendorForm(false);
        seteditMode(false);
        ccEditMode = false;
        setshownewClientContactForm(false);
        clientContact = new Contact();
        newClientContact = new Contact();
        newVendor = new Account();
        queryName = '';
        searchTerm = '';
        searchTerm2 = '';
        foundVendors = new List<Account>();
    
    }
    
    public Boolean gettooManyResults() {
        return tooManyResults;
    }
    
    public Boolean getshowVendorSearch() {
        return showVendorSearch;
    }
            
    public String getsearchTerm() {
        return searchTerm;
    }
    
    public void setsearchTerm(String s) {
        searchTerm = s;
        
    }
    
    public PageReference searchVendors(){
        newOrder.Vendor__c = null;
        queryName = '%' + searchTerm + '%';
        
        if(isTestingMethod)
        {
        	foundVendors = [SELECT Id, Name from Account where Type = 'EV Vendor' and Name like 'A%' ORDER BY Name LIMIT 10];
        	tooManyResults = false;
        	return null;
        }
        else
        {
	        Integer resultCount = [select count() from Account where Type = 'EV Vendor' and Name like :queryName LIMIT 1000];
	
	        if(resultCount < 1000)
	        {
	            foundVendors = [SELECT Id, Name from Account where Type = 'EV Vendor' and Name like :queryName ORDER BY Name LIMIT 1000];
	            tooManyResults = false; 
	
	        }else
	        {
	            foundVendors = [SELECT Id, Name from Account where Type = 'EV Vendor' and Name like :queryName ORDER BY Name LIMIT 1000];
	            tooManyResults = true;           
	        }
	        return null;        	
        }
    }  
    
    public PageReference enterVendor() {
        newOrder.Vendor__c = null;
        setshownewVendorForm(true);
        showVendorSearch = false;
        return null;
    }
    public Account getnewVendor() {
        return newVendor;
    }
    
    public void setnewVendor(Account v){
        newVendor = v;
    }
    
    public String getqueryName() {
        return queryName;
    }
    
    public Boolean getshownewVendorForm () {
        return shownewVendorForm;
    }
    
    public void setshownewVendorForm (Boolean b) {
        shownewVendorForm = b;
    }
        
    public List<Account> getfoundVendors () {
        return foundVendors; 
    }
    
    public Boolean geteditMode() {
        return editMode;
    }
    
    public void seteditMode(Boolean b){
        editMode = b;
    }

    public Boolean getshownewClientContactForm () {
        return shownewClientContactForm;
    }
    
    public void setshownewClientContactForm(Boolean b){
        shownewClientContactForm = b;
    }    
    
    public PageReference vendorEdit(){
        seteditMode(true);
        return null;
    }
    
    public PageReference ccEdit(){
        ccEditMode = true;
        return null;
    }
        
    public PageReference enterNewClientContact(){
        setshownewClientContactForm(true);
        newClientContact.AccountId = newOrder.Client__c;
        return null;
    }
              
    public PageReference createClientContactAcct(){       
        try {
            insert newClientContact;
            newOrder.Client_Contact__c = newClientContact.Id;
            setshownewClientContactForm(false);
            clientContact = newClientContact;
            return null;
         } catch (Exception e) {
            ApexPages.addMessages(e);
            return null;
        }   
    }
    
   public PageReference createNewVendor(){       
        try {
            newVendor.Type = 'EV Vendor';
            insert newVendor;
            vendor = newVendor;
            newOrder.Vendor__c = newVendor.Id;
            setshownewVendorForm(false);
            return null;
         } catch (Exception e) {
            ApexPages.addMessages(e);
            return null;
        }   
    }
    
    public void selectVC() {
        String tempId = ApexPages.currentPage().getParameters().get('vcid');
        Contact temp = [ select Id, Name, Phone, Email from Contact where Id = :tempId ];
        newOrder.Vendor_Contact_Name__c = temp.Name;
        newOrder.Vendor_Contact_Phone__c = temp.Phone;
        newOrder.Vendor_Contact_Email__c = temp.Email;
    }

    public PageReference CancelClientCreate() {
        setshownewClientContactForm(false);
        return null;
    }
    
    public PageReference CancelVendorCreate() {
        setshownewVendorForm(false);
        showVendorSearch = true;
        return null;
    }

    public PageReference ClearSelectedVendor() {
        vendor = null;
        newOrder.Vendor__c = null;
        showVendorSearch = true;
        return null;
    }              

    public PageReference saveContactEdit(){
        try {
            UPDATE clientContact;
            ccEditMode = false;
        } catch (Exception e) {
            ApexPages.addMessages(e);
        }
        return null;
    }
    
    public PageReference cancelContactEdit() {
        ccEditMode = false;
        return null;
    }
    
    public PageReference saveEdit(){
        try {
            UPDATE vendor;
            editMode = false;
        } catch (Exception e) {
            ApexPages.addMessages(e);
        }
        return null;
    }
    
    public PageReference cancelEdit() {
        editMode = false;
        return null;
    }
    
    public Account getvendor() {
 
        if(newOrder.Vendor__c != null)
        {
            vendor = [SELECT Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, phone, Fax, (Select Name, Id From Contacts ORDER BY FirstName, LastName) FROM Account where Id = :newOrder.Vendor__c ];
        }
        return vendor;
     
    }
    
    public Contact getclientContact() {
 
        if(newOrder.Client_Contact__c != null)
        {
            clientContact = [Select Id, Name, Phone, Email from Contact where Id = :newOrder.Client_Contact__c ];
        }
        return clientContact;
     
    }
    
    public Contact getvendorContact() {
        return vendorContact;
    }
    
    public void setvendorContact (Contact tc) {
        vendorContact = tc;
    }
    
    public void setnewClientContact(Contact c) {
        newClientContact = c;
    }
    
    public Contact getnewClientContact() {
        return newClientContact;
    }
    
    public PageReference resetClient() {
        newOrder.Client__c = null;
        newOrder.Client_Contact__c = null;
        return null;
    }
        
    public Account getclient() {
        if(newOrder.Client__c != null)
        {
            client = [SELECT Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, phone, Fax, (Select Name, Id From Contacts ORDER BY FirstName, LastName) FROM Account where Id = :newOrder.Client__c ];
        }
        return client;
    }
    
    public void selectV() {
        String tempId = ApexPages.currentPage().getParameters().get('cvid');
        system.debug('selected vendor id  = ' + tempId);
        vendor = [SELECT Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, phone, Fax FROM Account where Id = :tempId ];
        newOrder.Vendor__c = vendor.Id;
        system.debug('newOrder.Vendor__c = ' + newOrder.Vendor__c);
        showVendorSearch = false;
    }
        
                
    public void selectCC() {
        String tempId = ApexPages.currentPage().getParameters().get('ccid');
        newOrder.Client_Contact__c = tempId;
        clientContact = [Select Id, Name, Phone, Email from Contact where Id = :tempId ];
    }
        
    public String getBillable2Client() {
        return newOrder.Billable_to_Client__c; 
    }  
    
    public void setBillable2Client(String b) {
        newOrder.Billable_to_Client__c = b; 
    }  
    
    public PageReference initialize() {
        newOrder.Requesting_Staff_Member__c = UserInfo.getUserId();
        return null;
    }
    
    public PageReference save()
    {
       system.debug('newOrder.Vendor__c = ' +  newOrder.Vendor__c);
       if( newOrder.Vendor__c == null )
       {
           ApexPages.Message myMsg = new  ApexPages.Message(ApexPages.Severity.ERROR,  'Invalid Vendor: please click the magnifying glass icon to search for and select a vendor account');
           ApexPages.addMessage(myMsg);
           return null;
       }
system.debug('line 341');       
        //Logical actions
       database.DMLOptions dmo = new database.DMLOptions();
       dmo.AssignmentRuleHeader.useDefaultRule = true;
       dmo.EmailHeader.triggerUserEmail = true; 
       dmo.EmailHeader.triggerAutoResponseEmail = true;
       newOrder.setOptions(dmo);
       system.debug('attachment = ' +  attachment.Name);      
       Database.SaveResult MySaveResult = Database.Insert(newOrder, false);

       if(attachment.Body != null)
       {
       	   system.debug('MySaveResult.getId() = ' +  MySaveResult.getId());
           attachment.parentid = MySaveResult.getId();
           insert attachment;       
       }
system.debug('line 357');
       PageReference confirmationPage = Page.PurchaseOrderSubmitted;
       confirmationPage.getParameters().put('posubmitted','success');
       confirmationPage.getParameters().put('id',MySaveResult.getId());
       confirmationPage.setRedirect(true);
       return confirmationPage;

       //return new PageReference( '/'+MySaveResult.getId());
    }
}