public class ProjectPMViewController {
    public Projects__c proj {get;set;}
    public String assignedTo {get;set;}
    public List<User> staffList {get;set;}
    public String selected {get;set;}
    public String editingId {get;set;}
    public String linkingId {get;set;}
    public Date preceedingMaxDate {get;set;}        
    public Boolean editMode {get;set;}
    public Boolean linkMode {get;set;}    
    public List<milestoneWrapper> milestones {get;set;}
    public Map<Id,Id> editMilestoneMap {get;set;}
    public Map<Id, Project_Milestone__c> tempmilestones {get;set;}    
    public Project_Milestone__c newMilestone {get;set;}
    public String messageDisplay {get;set;}
    public Integer occuranceCount;
    
    public ProjectPMViewController (ApexPages.StandardController stdController) {
        
        try {
            String projId = Apexpages.currentPage().getParameters().get('id');
            proj = [ SELECT name, Account__c, Stage__c, Complete_by_hours__c, Estimated_End_Date__c, End_Date__c,
            Estimated_Hours__c, Milestone_Hours__c, Total_Hours_Calc__c, Total_Hours_New__c, Billable_Hours__c, Variance__c
             from Projects__c where Id = :projId];
            init();
        } catch (Exception e)  {
            proj = new Projects__c();
        }
        
    }

    public class milestoneWrapper{
        public Project_Milestone__c pm {get;set;}
        public Boolean editing {get;set;}
        
        public milestoneWrapper(Project_Milestone__c m){
            pm = m;
            editing = false;
        }                   
    }
    
    public Integer getoccuranceCount() {
    	return occuranceCount;	
    }  
    
    public void setoccuranceCount(Integer stringNumber){
    	try {
    		occuranceCount = Integer.valueOf(stringNumber);
    	} catch (Exception e)
    	{
    		ApexPages.Message occurance = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter a valid number for Occurrance Count');
            ApexPages.addMessage(occurance);
    	}		
    }
    
    public void init(){
    	occuranceCount = 1;
        editMode = false;
        linkMode = false;
        staffList = [Select u.ProfileId, u.Name, u.IsActive, u.Billing_Rate__c, u.Work_Week_Hours__c
                        From User u where u.ProfileId = '00e30000000nDXP' ORDER BY u.Name];
        Schema.DescribeFieldResult FR = Project_Milestone__c.Status__c.getDescribe();
        newMilestone = new Project_Milestone__c(Project__c = proj.Id, Status__c = FR.getDefaultValueFormula());
        milestones = new List<milestoneWrapper>();
        editMilestoneMap = new Map<Id,Id> ();
        tempmilestones =  new Map<Id, Project_Milestone__c>();  
        buildMilestoneList();
        if(Apexpages.currentPage().getParameters().containsKey('selected'))
        {
           selected = Apexpages.currentPage().getParameters().get('selected');
        }else
        {
            selected = '';
        }   
    }

    public List<SelectOption> getStaff() {
        List<SelectOption> staffOptions = new List<SelectOption>();
        //staffOptions.add(new SelectOption('','--select--'));
        for(User u : staffList)
        {
            staffOptions.add(new SelectOption(u.Id,u.Name));
        }
        return staffOptions;
    }

    public PageReference editPreceeding() {
        editingId = Apexpages.currentPage().getParameters().get('editPreceedingId');
        linkMode = true;
        for(milestoneWrapper mw: milestones)
        {
            if(mw.pm.Id == editingId)
            {
                preceedingMaxDate = mw.pm.Start__c;
                break;
            }
        }
        return null;       
    }
    
    
    public PageReference linkPreceeding() {
        linkingId = Apexpages.currentPage().getParameters().get('preceedingId');
        messageDisplay = '';
        for(milestoneWrapper mw: milestones)
        {
            if(mw.pm.Id == editingId)
            {
                mw.pm.Preceeding_Milestone__c = linkingId;
                try {
                       update mw.pm;
                       break;         
                } catch (DmlException e) {
                    System.debug(e.getDmlMessage(0));
                    messageDisplay = 'There was an error saving, please contact the <a href="mailto:adellicicchi@eduventures.com?subject=Error - ProjectMilestoneView: Error Saving new milestone">system administrator</a> for help.';
                    return null; 
                }
            }
 
        }
        messageDisplay = 'Edits saved.';
        linkMode = false;
        buildMilestoneList(); 
        return null;      
    }
        
    private void buildMilestoneList(){
        milestones.clear();
        Projects__c temp = [select Id, (Select Name, Project__c, Project__r.name, Assigned_To__c, 
                Estimated_Hours__c, Status__c, Start__c, End__c, Booked_Hours__c,
                Preceeding_Milestone__c, Preceeding_Milestone__r.Name, Work_Days__c, Average_Daily_Hours__c 
                From Project_Milestones__r ORDER BY Start__c, End__c) from Projects__c where Id = :proj.Id];

        for(Project_Milestone__c milestone: temp.Project_Milestones__r)
        {
            milestones.add( new milestoneWrapper(milestone));
        }
    }
    
    public PageReference editMilestone(){
        
        Map <Id, Integer> milestoneMap = new Map <Id, Integer>();
        String milestoneid = Apexpages.currentPage().getParameters().get('mid');
        messageDisplay = 'Now editing milestone....   <b>Note: all dependent milestones are also made editable.</b>';
        selected = milestoneid;
        editMode = true;
        
        for(integer i = 0; i <milestones.size(); i++)
        {
            milestoneMap.put(milestones[i].pm.Id, i);
        }
        
        Integer editIndex = milestoneMap.get(milestoneid);
        
        for(integer i=editIndex; i >= 0; i--)
        {
            if(i == editIndex)
            {
                milestones[i].editing = true;
                editMilestoneMap.put(milestones[i].pm.Id,milestones[i].pm.Id);
                tempmilestones.put(milestones[i].pm.Id,milestones[i].pm.clone(true,true));
                if(milestones[i].pm.Preceeding_Milestone__c != null)
                {
                    editMilestoneMap.put(milestones[i].pm.Preceeding_Milestone__c,milestones[i].pm.Preceeding_Milestone__c);
                }
                else
                {
                    break;
                }                
            } else if (editMilestoneMap.containsKey(milestones[i].pm.Id))
            {
            	tempmilestones.put(milestones[i].pm.Id,milestones[i].pm.clone(true,true));
                milestones[i].editing = true;
                if(milestones[i].pm.Preceeding_Milestone__c != null)
                {
                    editMilestoneMap.put(milestones[i].pm.Preceeding_Milestone__c,milestones[i].pm.Preceeding_Milestone__c);
                }
            } 
        }
        
        for(integer j = editIndex+1; j <milestones.size(); j++)
        {
            if(milestones[j].pm.Preceeding_Milestone__c != null)
            {
                if (editMilestoneMap.containsKey(milestones[j].pm.Preceeding_Milestone__c))
                {
                     milestones[j].editing = true;
                     tempmilestones.put(milestones[j].pm.Id,milestones[j].pm.clone(true,true));
                     editMilestoneMap.put(milestones[j].pm.Id,milestones[j].pm.Id);
                }
            }
        }
        return null;

    }

    public pageReference editAll(){
        messageDisplay = '';
        selected = '';
        editMode = true;
        for(milestoneWrapper mw: milestones)
        {
        	tempmilestones.put(mw.pm.Id,mw.pm.clone(true,true));
        	editMilestoneMap.put(mw.pm.Id,mw.pm.Id);
            mw.editing = true;
        }
        return null;
    }
    
    public PageReference saveEdits(){
        messageDisplay = '';
        for(milestoneWrapper mw: milestones)
        {
            //try-catch update;
            try {
                   update mw.pm;          
            } catch (DmlException e) {
                System.debug(e.getDmlMessage(0));
                messageDisplay = 'There was an error saving, please contact the <a href="mailto:adellicicchi@eduventures.com?subject=Error - ProjectMilestoneView: Error Saving new milestone">system administrator</a> for help.';
                return null; 
            } 
            mw.editing = false;
        }
        messageDisplay = 'Edits saved.';
        editMode = false;
        buildMilestoneList(); 
        return null;
    }
    
    private Boolean insertMilestone(Project_Milestone__c newPm){
        //try-catch insert;
       try {
           Project_Milestone__c temp = new Project_Milestone__c(   Project__c = proj.Id,
                                                                    Status__c = newPm.Status__c, 
                                                                    Start__c = newPm.Start__c, 
                                                                    Name = newPm.Name ,
                                                                    Estimated_Hours__c = newPm.Estimated_Hours__c,
                                                                    End__c = newPm.End__c,
                                                                    Assigned_To__c = newPm.Assigned_To__c );
           Database.SaveResult MySaveResult = Database.Insert(temp, false);
           for(integer i=1; i<occuranceCount;i++)
           {
           		Project_Milestone__c recurtemp = temp.clone(false,true);
           		recurtemp.Name = temp.Name + '(' + (i+1) + ')';
           		recurtemp.Start__c = temp.Start__c + (7*i);
           		recurtemp.End__c = temp.End__c + (7*i); 
           		insert recurtemp;
           }
           system.debug('new milestone inserted ' + MySaveResult.getId());
           selected = MySaveResult.getId();
           buildMilestoneList(); 
           occuranceCount = 1;         
      } catch (DmlException e) {
          System.debug('insert failed');
          System.debug(e.getDmlMessage(0));
          return false; 
      }
      return true; 
    }
    
    public PageReference saveNew(){
        messageDisplay = '';
        system.debug('begin saving new milestone');
        /*if(assignedTo == '--select--')
        {
            ApexPages.Message selectUserMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please Select a Staff member for this milestone');
            ApexPages.addMessage(selectUserMsg);
            return null;
        } else {
            newMilestone.Assigned_To__c = assignedTo;
        }*/
        
        if(insertMilestone(newMilestone))
        {                       
            messageDisplay = '<p>Success! New Record Added.</p>';
            Schema.DescribeFieldResult FR = Project_Milestone__c.Status__c.getDescribe();
            newMilestone = new Project_Milestone__c(Project__c = proj.Id,Status__c = FR.getDefaultValueFormula());
        } else {
            messageDisplay = '<p>There was an error, please try again.</p>';
        }
        return null;
    }   
        
    public PageReference cancelEdits(){
    	
        messageDisplay = '<p>Edit action has been cancelled.</p>';
        editMode = false;
        linkMode = false;
        editingId = '';
        linkingId = '';
        for(milestoneWrapper mw: milestones)
        {
            if(editMilestoneMap.containsKey(mw.pm.Id))
            {
            	mw.editing = false;
            	mw.pm = tempmilestones.get(mw.pm.Id);            
            }	
        }
        tempmilestones.clear();
        editMilestoneMap.clear();
        return null;
    }       
}