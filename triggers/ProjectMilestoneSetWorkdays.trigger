trigger ProjectMilestoneSetWorkdays on Project_Milestone__c (before insert, before update) {
	if(Trigger.isInsert)
	{		
		for(Project_Milestone__c pm: trigger.new)
		{
	        //calculate the 'work days' for this milestone
	        Date startD = pm.Start__c;
	        Date endD = pm.End__c;
	        Integer daysLoop = startD.daysBetween(endD);
	        Integer numWorkDays = 0;
	        Date tempD = startD;
	        System.debug('daysLoop = ' + daysLoop );
	        Date aSaturday = Date.newInstance(2010,5,1);
	        for(integer i=0; i <= daysLoop; i++ )
	        {
	            Integer x = aSaturday.daysBetween(tempD);
	            System.debug('x = ' + x);
	            System.debug('Math.mod(x,7) = ' + Math.mod(x,7));
	            if(Math.mod(x,7) > 1)
	            {
	                numWorkDays++; 
	            }
	            tempD = tempD + 1;
	        }
	        pm.Work_Days__c = numWorkDays;
	    }
	}
	
	if(Trigger.isUpdate)
	{		
		for(Integer n = 0; n < Trigger.new.size(); n++)  
		{	 			
			Project_Milestone__c pmOld = Trigger.old[n];
			Project_Milestone__c pmNew = Trigger.new[n];	    	
	    	if( (pmOld.Start__c != pmNew.Start__c) || (pmOld.End__c != pmNew.End__c) )
	    	{
		        //recalculate the 'work days' for this milestone
		        Date startD = pmNew.Start__c;
		        Date endD = pmNew.End__c;
		        Integer daysLoop = startD.daysBetween(endD);
		        Integer numWorkDays = 0;
		        Date tempD = startD;
		        System.debug('daysLoop = ' + daysLoop );
		        Date aSaturday = Date.newInstance(2010,5,1);
		        for(integer i=0; i <= daysLoop; i++ )
		        {
		            Integer x = aSaturday.daysBetween(tempD);
		            System.debug('x = ' + x);
		            System.debug('Math.mod(x,7) = ' + Math.mod(x,7));
		            if(Math.mod(x,7) > 1)
		            {
		                numWorkDays++; 
		            }
		            tempD = tempD + 1;
		        }
		        pmNew.Work_Days__c = numWorkDays;
	    	}
	    }
	}
	    
}