public class resourceController {

    public String message { get; set; }
    public String dropped { get; set; }
    public String dragged { get; set; }
    public String resultString {get; set;}

    public Equipment__c equipToUpdate {get; set;}

    //public Case reservationCases;

    public String assignEquipment(){
    	equipToUpdate =  new Equipment__c();
        dragged = Apexpages.currentPage().getParameters().get('equipId');
        dropped = Apexpages.currentPage().getParameters().get('destinationId');
        resultString =  dragged + ' Assigned to ' + dropped;
        Integer equipmentCount = [SELECT count() FROM Equipment__c WHERE Name = :dragged];
        if(equipmentCount == 1)
        {
        	equipToUpdate = [SELECT Id, Name, Status__c, Case__c FROM Equipment__c WHERE Name = :dragged];
	        if(dropped == 'returnMe'){
	           Equipment__c equipToUpdate = [SELECT Id, Name, Status__c, Case__c FROM Equipment__c WHERE Name = :dragged];
	           equipToUpdate.status__c = 'Inventory';
	           equipToUpdate.Case__c = null;
	           try {
	            System.debug('trying to return ' + equipToUpdate.Name);
	            update equipToUpdate;
	           }
	           catch(Exception e){
	            ApexPages.Message saveFail = new ApexPages.Message(ApexPages.Severity.ERROR, 'There was a problem updating this equipment.');
	            Apexpages.addMessage(saveFail);
	            message = 'An Error Occurred! Save not committed.' + e.getMessage();
	           }
	        }
	        else{
	           equipToUpdate.status__c = 'Assigned';
	           equipToUpdate.Case__c = dropped;
	           try {
	            System.debug('trying to assign' + equipToUpdate.Name + ' to case ' + dropped);
	            update equipToUpdate;
	
	           }
	           catch(Exception e){
	            ApexPages.Message saveFail = new ApexPages.Message(ApexPages.Severity.ERROR, 'There was a problem updating the equipment.');
	            Apexpages.addMessage(saveFail);
	            message = 'An Error Occurred! Save not committed.' + e.getMessage();
	           }
	        }        
        } else 
        {
        	String errMsg = '';
        	if(equipmentCount == 0)
        	{
        		errMsg = 'no matching piece of Equipment found with that name!';
        	} else 
        	{
        		errMsg = 'more than one matching piece of Equipment found with that name!';
        	}
        	ApexPages.Message findEuipmentFail = new ApexPages.Message(ApexPages.Severity.ERROR, errMsg);
            Apexpages.addMessage(findEuipmentFail);
        }
        return null;
        
    }
    
    public List<Case> getreservationCases(){
        return [select Id, Contact.Name, CaseNumber, Status, Problem_Detail__c, Type,
        			 (Select Id, Name From Assigned_Equipment__r)
        		 from Case WHERE Status NOT IN ('Closed') AND Type In ('Equipment Reservation')];
    }
    
    public List<Equipment__c> getEquipment(){
        return [select Name, Status__c, Type__c, Case__c from Equipment__c WHERE Status__C  IN ('Inventory')];
    }
    
    public static testMethod void testResourcePage() {
        Equipment__c testEquipmentAssigned =  new Equipment__c( Type__c = 'Projector', 
        													Status__c = 'Assigned', 
        													OwnerId = '00530000000vyOv', 
        													Name = 'testmethod projector');
        insert testEquipmentAssigned;
        Case testCaseWithEquip = new Case( RecordTypeId = '01230000000DMGk', 
        							Subject = 'my existing test case for the Resources Page',
        							ContactId = '0033000000LPQRo',
        							Status = 'Open',
        							Problem_Detail__c = 'Projector', 
        	 						Type = 'Equipment Reservation'); 
        insert testCaseWithEquip;
        testEquipmentAssigned.Case__c =  testCaseWithEquip.Id;
        update testEquipmentAssigned;
        
        Equipment__c testEquipmentInventory =  new Equipment__c( Type__c = 'Floater Battery', 
        													Status__c = 'Inventory', 
        													OwnerId = '00530000000vyOv', 
        													Name = 'testmethod Extended Life - 002');
        insert testEquipmentInventory;
        Case testCaseWithoutEquip = new Case( RecordTypeId = '01230000000DMGk', 
        							Subject = 'my new test case for the Resources Page',
        							ContactId = '0033000000LPQRo',
        							Status = 'New', 
        							Problem_Detail__c = 'Battery', 
        							Type = 'Equipment Reservation');       							                           
        insert testCaseWithoutEquip;
        PageReference resourcesRef = new PageReference('/apex/resources');
        Test.setCurrentPage(resourcesRef);          
		resourceController Rcontroller = new resourceController();
		Rcontroller.getreservationCases(); 
		Rcontroller.getEquipment(); 
        ApexPages.currentPage().getParameters().put('equipId', testEquipmentInventory.Name);
        ApexPages.currentPage().getParameters().put('destinationId', testCaseWithoutEquip.Id);
        Rcontroller.assignEquipment();
        ApexPages.currentPage().getParameters().put('equipId', testEquipmentInventory.Name);
        ApexPages.currentPage().getParameters().put('destinationId', 'returnMe');
        Rcontroller.assignEquipment(); 
        ApexPages.currentPage().getParameters().put('equipId', testEquipmentInventory.Name);
        ApexPages.currentPage().getParameters().put('destinationId', testCaseWithEquip.Id);
        Rcontroller.assignEquipment();
    } 
}