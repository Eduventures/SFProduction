@isTest
private class testRenewalTracker { 
 
    public static testMethod void testRenewalTrackerv2 () {
 
       RenewalTrackerControllerv2 controllerRTv2 = new RenewalTrackerControllerv2();         
       PageReference pageRefRT2 = new PageReference('/apex/RenewalTrackerv2?selected='+controllerRTv2.currentPrograms[2]);
       Test.setCurrentPage(pageRefRT2);                
    try 
    {    
        controllerRTv2.updateLOA();
        controllerRTv2.wrapLOAs();         
    }
    catch (System.DmlException e) 
      {
        System.debug('Failed to run testProjectsDashboardController method testRenewalTrackerv2: '+ e.getMessage());
      }    
    } 
}