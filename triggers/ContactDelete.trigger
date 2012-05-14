trigger ContactDelete on Contact (before delete) {

    if(Trigger.isDelete) 
    {
        for (Contact d : Trigger.old)  //change Object Name 
        {
            if(d.Website_username__c != null)
            {
                  // Note! - You should comment out the following line if you need to merge contacts, otherwise you'll get an error
                  //d.addError('You can not delete a former seat holder or Liaison!'); 
            }
        } 
    }
}