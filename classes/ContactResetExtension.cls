public class ContactResetExtension {
    private Contact currentContact;
    public Boolean resetSuccess {get;set;}   
//    public Boolean getresetSuccess() { return resetSuccess;}   
//    private void setresetSuccess(Boolean rs) { resetSuccess = rs;}
    
    public ContactResetExtension(ApexPages.StandardController controller) {
        this.currentContact = (Contact)controller.getRecord();
        init();
    }
    
    public ContactResetExtension (Contact c)
    {
        currentContact = c;
        init();
    }

    private void init() {
        
        resetSuccess = false;
    }
    
    public PageReference submitReset(){
        String result = ContactReset.reset(currentContact.Id);
        //setresetSuccess(true);
        if(result.startsWith('Contact '))
        {
            resetSuccess = true;
        }            
        return null;
    }
    
}