trigger OpportunityDatestamping on Opportunity (before insert, before update, before delete) {

    if(trigger.isBefore)
    {
        String currentTime = (System.today()).format(); 
            
        if(Trigger.isInsert) 
        {
            for(Integer i = 0; i < Trigger.new.size(); i++)
            {
                Opportunity nw = Trigger.new[i];
                //start datestamping routine, check if fields are blank or not. if not, add stamp to end of field value
                
                //attendees is required if opp closes
                if(nw.Attendees__c != '' && nw.Attendees__c != null)
                {
                    String tempAttendees = nw.Attendees__c;
                    nw.Attendees__c = tempAttendees + '  *<' + currentTime + ' - ' + UserInfo.getFirstName() + ' ' + UserInfo.getLastName() + '>*\n'  ;
                        
                }
                if(nw.Background__c != '' && nw.Background__c != null) 
                {
                    String tempBackground = nw.Background__c;
                    nw.Background__c = tempBackground + '  *<' + currentTime + ' - ' + UserInfo.getFirstName() + ' ' + UserInfo.getLastName() + '>*\n'  ;
                        
                }
                //Challenges 
                if(nw.Challenges__c != '' && nw.Challenges__c != null)
                {
                    String tempChallenges = nw.Challenges__c;
                    nw.Challenges__c = tempChallenges + '  *<' + currentTime + ' - ' + UserInfo.getFirstName() + ' ' + UserInfo.getLastName() + '>*\n'  ;
                }           
                if(nw.Closing_Criterion_Interest_Objections__c != '' && nw.Closing_Criterion_Interest_Objections__c != null)
                {
                    String tempClosing_Criterion_Interest_Objections = nw.Closing_Criterion_Interest_Objections__c;
                    nw.Closing_Criterion_Interest_Objections__c = tempClosing_Criterion_Interest_Objections + '  *<' + currentTime + ' - ' + UserInfo.getFirstName() + ' ' + UserInfo.getLastName() + '>*\n'  ;
                        
                }
                if(nw.Closing_Criterion_Timeframe__c != '' && nw.Closing_Criterion_Timeframe__c != null)
                {
                    String tempClosing_Criterion_Timeframe = nw.Closing_Criterion_Timeframe__c;
                    nw.Closing_Criterion_Timeframe__c = tempClosing_Criterion_Timeframe + '  *<' + currentTime + ' - ' + UserInfo.getFirstName() + ' ' + UserInfo.getLastName() + '>*\n'  ;
                        
                }
                if(nw.Description != '' && nw.Description != null)
                {
                    String tempDescription = nw.Description;
                    nw.Description = tempDescription + '  *<' + currentTime + ' - ' + UserInfo.getFirstName() + ' ' + UserInfo.getLastName() + '>*\n'  ;
                }
                //Goals
                if(nw.Goals__c != '' && nw.Goals__c != null)
                {
                    String tempGoals = nw.Goals__c;
                    nw.Goals__c = tempGoals + '  *<' + currentTime + ' - ' + UserInfo.getFirstName() + ' ' + UserInfo.getLastName() + '>*\n'  ;
                }
                if(nw.Implementation_Timeline__c != '' && nw.Implementation_Timeline__c != null)
                {
                    String tempImplementation_Timeline = nw.Implementation_Timeline__c;
                    nw.Implementation_Timeline__c = tempImplementation_Timeline + '  *<' + currentTime + ' - ' + UserInfo.getFirstName() + ' ' + UserInfo.getLastName() + '>*\n'  ;
                        
                }
                if(nw.Next_Steps__c != '' && nw.Next_Steps__c != null)
                {
                    String tempNext_Steps = nw.Next_Steps__c;
                    nw.Next_Steps__c = tempNext_Steps + '  *<' + currentTime + ' - ' + UserInfo.getFirstName() + ' ' + UserInfo.getLastName() + '>*\n'  ;                   
                }
                //Peers/Competitors
                if(nw.Peers_Competitors__c != '' && nw.Peers_Competitors__c != null)
                {
                    String tempPeers = nw.Peers_Competitors__c;
                    nw.Peers_Competitors__c = tempPeers + '  *<' + currentTime + ' - ' + UserInfo.getFirstName() + ' ' + UserInfo.getLastName() + '>*\n'  ;
                }   
                if(nw.Purchasing_Process__c != '' && nw.Purchasing_Process__c != null)
                {
                    String tempPurchasing_Process = nw.Purchasing_Process__c;
                    nw.Purchasing_Process__c = tempPurchasing_Process + '  *<' + currentTime + ' - ' + UserInfo.getFirstName() + ' ' + UserInfo.getLastName() + '>*\n'  ;
                        
                }
                if(nw.Qualifying_Criterion_Actionable_Other__c != nw.Qualifying_Criterion_Actionable_Other__c)
                {
                    String tempQualifying_Actionable = nw.Qualifying_Criterion_Actionable_Other__c;
                    nw.Qualifying_Criterion_Actionable_Other__c = tempQualifying_Actionable + '  *<' + currentTime + ' - ' + UserInfo.getFirstName() + ' ' + UserInfo.getLastName() + '>*\n'  ;
                        
                }               
                //Research Needs
                if(nw.Research_Needs__c != '' && nw.Research_Needs__c != null)
                {
                    String tempResearch_Needs = nw.Research_Needs__c;
                    nw.Research_Needs__c = tempResearch_Needs + '  *<' + currentTime + ' - ' + UserInfo.getFirstName() + ' ' + UserInfo.getLastName() + '>*\n'  ;
                }   
                
                if(nw.StageName == 'Closed Won')
                {
                    nw.Close_Date_New__c = System.today();
                }
            }   
        }
        else if(Trigger.isUpdate)
        {
            Set<ID> ids = Trigger.newMap.keySet();
            Map<Id,Opportunity> updatedOppsMap = new Map<Id,Opportunity> ([SELECT Id, 
                     (SELECT Id, Opportunity__c, Opportunity_Price__c, Product_Group__c, Opportunity_Type__c from Quote_Items__r) 
                      FROM Opportunity WHERE Id in :ids]);
         
            for(Integer i = 0; i < Trigger.new.size(); i++)
            {
                Opportunity nw = Trigger.new[i];
                Opportunity old = Trigger.old[i];
            
                if(old.Attendees__c != nw.Attendees__c)
                {
                    String tempAttendees = nw.Attendees__c;
                    nw.Attendees__c = tempAttendees + '  *<' + currentTime + ' - ' + UserInfo.getFirstName() + ' ' + UserInfo.getLastName() + '>*\n'  ;
                        
                }
                if(old.Background__c != nw.Background__c)
                {
                    String tempBackground = nw.Background__c;
                    nw.Background__c = tempBackground + '  *<' + currentTime + ' - ' + UserInfo.getFirstName() + ' ' + UserInfo.getLastName() + '>*\n'  ;
                        
                }
                //Challenges
                if(old.Challenges__c != nw.Challenges__c)
                {
                    String tempChallenges = nw.Challenges__c;
                    nw.Challenges__c = tempChallenges + '  *<' + currentTime + ' - ' + UserInfo.getFirstName() + ' ' + UserInfo.getLastName() + '>*\n'  ;
                }           
                if(old.Closing_Criterion_Interest_Objections__c != nw.Closing_Criterion_Interest_Objections__c)
                {
                    String tempClosing_Criterion_Interest_Objections = nw.Closing_Criterion_Interest_Objections__c;
                    nw.Closing_Criterion_Interest_Objections__c = tempClosing_Criterion_Interest_Objections + '  *<' + currentTime + ' - ' + UserInfo.getFirstName() + ' ' + UserInfo.getLastName() + '>*\n'  ;
                        
                }
                if(old.Closing_Criterion_Timeframe__c != nw.Closing_Criterion_Timeframe__c)
                {
                    String tempClosing_Criterion_Timeframe = nw.Closing_Criterion_Timeframe__c;
                    nw.Closing_Criterion_Timeframe__c = tempClosing_Criterion_Timeframe + '  *<' + currentTime + ' - ' + UserInfo.getFirstName() + ' ' + UserInfo.getLastName() + '>*\n'  ;
                        
                }
                if(old.Description != nw.Description)
                {
                    String tempDescription = nw.Description;
                    nw.Description = tempDescription + '  *<' + currentTime + ' - ' + UserInfo.getFirstName() + ' ' + UserInfo.getLastName() + '>*\n'  ;
                }
                //Goals
                if(old.Goals__c != nw.Goals__c)
                {
                    String tempGoals = nw.Goals__c;
                    nw.Goals__c = tempGoals + '  *<' + currentTime + ' - ' + UserInfo.getFirstName() + ' ' + UserInfo.getLastName() + '>*\n'  ;
                }
                if(old.Implementation_Timeline__c != nw.Implementation_Timeline__c)
                {
                    String tempImplementation_Timeline = nw.Implementation_Timeline__c;
                    nw.Implementation_Timeline__c = tempImplementation_Timeline + '  *<' + currentTime + ' - ' + UserInfo.getFirstName() + ' ' + UserInfo.getLastName() + '>*\n'  ;
                        
                }
                if(old.Next_Steps__c != nw.Next_Steps__c)
                {
                    String tempNext_Steps = nw.Next_Steps__c;
                    nw.Next_Steps__c = tempNext_Steps + '  *<' + currentTime + ' - ' + UserInfo.getFirstName() + ' ' + UserInfo.getLastName() + '>*\n'  ;                   
                }
                //Peers/Competitors
                if(old.Peers_Competitors__c != nw.Peers_Competitors__c)
                {
                    String tempPeers = nw.Peers_Competitors__c;
                    nw.Peers_Competitors__c = tempPeers + '  *<' + currentTime + ' - ' + UserInfo.getFirstName() + ' ' + UserInfo.getLastName() + '>*\n'  ;
                }   
                if(old.Purchasing_Process__c != nw.Purchasing_Process__c)
                {
                    String tempPurchasing_Process = nw.Purchasing_Process__c;
                    nw.Purchasing_Process__c = tempPurchasing_Process + '  *<' + currentTime + ' - ' + UserInfo.getFirstName() + ' ' + UserInfo.getLastName() + '>*\n'  ;
                        
                }
                if(old.Qualifying_Criterion_Actionable_Other__c != nw.Qualifying_Criterion_Actionable_Other__c)
                {
                    String tempQualifying_Actionable = nw.Qualifying_Criterion_Actionable_Other__c;
                    nw.Qualifying_Criterion_Actionable_Other__c = tempQualifying_Actionable + '  *<' + currentTime + ' - ' + UserInfo.getFirstName() + ' ' + UserInfo.getLastName() + '>*\n'  ;
                        
                }               
                //Research Needs
                if(old.Research_Needs__c != nw.Research_Needs__c)
                {
                    String tempResearch_Needs = nw.Research_Needs__c;
                    nw.Research_Needs__c = tempResearch_Needs + '  *<' + currentTime + ' - ' + UserInfo.getFirstName() + ' ' + UserInfo.getLastName() + '>*\n'  ;
                }   
                
                //refresh the opportunity Close Date when the Stage Name is set to "Closed Won". This is so 
                //whomever is inputting the LOA doesn't need to remember to adjust the Close Date 
                if( (old.StageName != nw.StageName) && (nw.StageName == 'Closed Won') )
                {
                    nw.Close_Date_New__c = System.today();
                }
            }  
        }
        if(Trigger.isDelete) 
        {
            List<Quote_Item__c> existingQuoteItems = [ SELECT Id, Opportunity__c FROM Quote_Item__c WHERE Quote_Item__c.LOA_Quote__r.Status__c not in ('Preparing Quote (not submitted)', 'Rejected') and Opportunity__c in :Trigger.oldMap.keyset()]; 
            if(!existingQuoteItems.isEmpty())
            {
                for(Quote_Item__c qi: existingQuoteItems)
                {
                    Trigger.oldMap.get(qi.Opportunity__c).addError('You cannot delete this opportunity because it is included in an existing quote (that has already either been submitted or approved.)');
                }
            }           
        }
    }
    
}