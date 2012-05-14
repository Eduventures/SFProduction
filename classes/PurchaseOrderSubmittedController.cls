public class PurchaseOrderSubmittedController {

    String redirectUrl;
    public PurchaseOrderSubmittedController () {
        redirectUrl = '/'+ApexPages.currentPage().getParameters().get('id');
    }

    public String getredirectUrl(){
        return redirectUrl;
    }

    public void displayMessages() {
  
        ApexPages.Message myMsg = new  ApexPages.Message(ApexPages.Severity.CONFIRM,  '<br /><b>Your PO has been submitted for approval.</b><br /><br /> Approval History information is reflected on the bottom of the Purchase Order Page (you will be redirected there shortly)');
        ApexPages.addMessage(myMsg);
    }
}