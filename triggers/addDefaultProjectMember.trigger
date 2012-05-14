trigger addDefaultProjectMember on Projects__C (after insert) {

        List <ProjectMember__c> defaultMembersToInsert = new List <ProjectMember__c> ();

        id curUserProfileId = userinfo.getProfileId();
        id curId = UserInfo.getUserId();
        id sysAdminProfileId = [select id from profile where name='System Administrator'].id; 

        if( curUserProfileId != sysAdminProfileId )     
        {   
            User curUser = [ SELECT Id, Name, Email, Phone from User WHERE Id = :curId] ;
            
            for (Projects__c p : Trigger.new)
            {
                if(p.RecordTypeId != '00h30000000zU5w')
                {
                    ProjectMember__c projMem = new ProjectMember__c();
                    projMem.UserId__c = curUser.Id;
                    projMem.Name = curUser.Name;
                    projMem.ProjectId__c = p.Id;
                    //Database.SaveResult lsr2 = Database.insert(projMem, false);
                    defaultMembersToInsert.add(projMem);
                }
            }
        
            if ( defaultMembersToInsert != null)
            {
                insert defaultMembersToInsert;
            }
        }
}