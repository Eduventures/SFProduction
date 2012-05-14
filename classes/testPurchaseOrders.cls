@isTest
private class testPurchaseOrders { 
    public static testMethod void testPurchaseOrderCreation() {
        Account textVendor = [ SELECT Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, phone, Fax, Type from Account where Type ='EV Vendor' limit 1];
        User testUser = [ SELECT Id, Name from User where Alias = 'Adell'];  
        Purchase_Order__c dummypo = new Purchase_Order__c();
         
        PageReference pageRefPO = new PageReference('/apex/New_Purchase_Order');
        Test.setCurrentPage(pageRefPO);          
        
        System.runAs(testUser) {
            PurchaseOrderControllerExtension controllerPO = new PurchaseOrderControllerExtension( dummypo );
            
            controllerPO.init();   

            try
            {
                controllerPO.initialize();
                controllerPO.isTestingMethod = true;
                ApexPages.currentPage().getParameters().put('sterm','A');
                controllerPO.validateSearch();
                controllerPO.gettooManyResults();
                controllerPO.getshowVendorSearch();
                controllerPO.getsearchTerm();
                controllerPO.setsearchTerm('A');
                controllerPO.getqueryName();
                controllerPO.getfoundVendors();
                controllerPO.geteditMode();
                ApexPages.currentPage().getParameters().put('cvid','0013000000K2fUX');
                controllerPO.selectV();
                controllerPO.vendorEdit();
                controllerPO.saveEdit();
                controllerPO.vendorEdit();
                controllerPO.cancelEdit();
                controllerPO.ClearSelectedVendor();              
                controllerPO.enterVendor();
                controllerPO.getshownewClientContactForm();
                controllerPO.getnewVendor();
                controllerPO.CancelVendorCreate();
                controllerPO.enterVendor();
                Account temp = new Account( 
                    Name = 'TEST',
                    Phone = '617-532-6026',
                    BillingStreet = '',
                    BillingCity = '',
                    BillingState = 'MA',
                    BillingPostalCode = '02110');
                controllerPO.setnewVendor(temp);    
                controllerPO.createNewVendor(); 
                controllerPO.getshownewVendorForm();
                controllerPO.getvendor();
                ApexPages.currentPage().getParameters().put('vcid','0033000000LPQRo');
                controllerPO.selectVC();
                Contact tempC = [ Select Id, Name, Phone, Email from Contact where Id = '0033000000LPQRo'];
                controllerPO.setvendorContact(tempC); 
                controllerPO.getvendorContact();
                controllerPO.setBillable2Client('No');
                controllerPO.setBillable2Client('Yes');
                controllerPO.getBillable2Client();
                controllerPO.newOrder.Client__c = '0013000000K2fUX';
                controllerPO.resetClient();
                controllerPO.newOrder.Client__c = '0013000000K2fUX';
                controllerPO.getclient();
                controllerPO.enterNewClientContact();
                controllerPO.CancelClientCreate();
                
                ApexPages.currentPage().getParameters().put('ccid','0033000000LPQRo');
                controllerPO.selectCC();
                controllerPO.ccEdit();
                controllerPO.saveContactEdit();
                controllerPO.ccEdit();
                controllerPO.cancelContactEdit();
                controllerPO.getclientContact();
               
                controllerPO.newOrder.Payment_Terms__c = 'TEST';
                controllerPO.newOrder.PO_Account__c = 'ACL: 5616: Travel';
                controllerPO.newOrder.Number_of_Invoices__c = 1;
                controllerPO.newOrder.Estimated_Total_Cost__c = 10.00;
                controllerPO.newOrder.Description__c = 'TEST DESC';
                controllerPO.newOrder.Class__c = 'ACL';
                controllerPO.save();
                Purchase_Order__c temppo = controllerPO.newOrder;
                insert temppo;
                
                /*
                createClientContactAcct()
                setnewClientContact(Contact c) 
                getnewClientContact()                             
                */
            }
            catch (System.DmlException e) 
              {
                System.debug('Failed to run Purchase Order creation: ' + e);
              }

                //System.assertEquals('/cases/casesavedjump.jsp', nextPage.getUrl());
        }
    } 
}