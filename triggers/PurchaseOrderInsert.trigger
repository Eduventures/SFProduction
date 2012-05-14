trigger PurchaseOrderInsert on Purchase_Order__c (after insert) {
    Id currentUserId = UserInfo.getUserId();
     
    for (Purchase_Order__c po : Trigger.new) 
    {           
        Approval.ProcessSubmitRequest tempSubmitRequest = new Approval.ProcessSubmitRequest();
        tempSubmitRequest.setComments('Submitting request for approval.');
        tempSubmitRequest.setObjectId(po.id);// Submit the approval request for the account     
        Approval.process(tempSubmitRequest);            
    }    
}