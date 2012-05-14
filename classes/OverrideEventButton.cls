// The Name of the class
public class OverrideEventButton{
    Opportunity o; 
    
    public OverrideEventButton(ApexPages.StandardController stdController){
        //evt1={!Opportunity.OwnerFullName}&evt1_lkid={!Opportunity.OwnerId}&what_id={!Opportunity.Id}&evt5={!Opportunity.Name}"

        // Create a variable to return the current Contact URL;
        string ret;
        ret = ApexPages.currentPage().getParameters().get('RetURL');
        System.debug('Return URL = ' + ret);
		if(ret != null)
		{
        	if(ret.startswith('/006') && ret.length() >= 16) {
        		ret = ret.substring(1,16);
        		System.debug('parsed ret = ' + ret);
        	    o = [Select OwnerId, Owner.Name, Id, Name from Opportunity where Id = :ret];
        	}
		}
    }

    public OverrideEventButton(){
        string ret;
        ret = ApexPages.currentPage().getParameters().get('RetURL');
        ret = ret.substring(1,ret.length());

        if(ret.startswith('006')) {
            o = [Select OwnerId, Owner.Name, Id, Name from Opportunity where Id =: ret];
         }
    }
    
    public PageReference init(){
        //Define the variable first
        string redirectURL  = '';
        Map<String, String> params = ApexPages.currentPage().getParameters();
        if(o != null)
        {
            redirectURL = '/00U/e?nooverride=1&evt1='+ o.Owner.Name + '&evt1_lkid=' + String.valueOf(o.OwnerId).substring(0,15) + '&what_id=' + o.Id + '&evt5=' + o.Name;    
        }
        else
        {
            redirectURL = '/00U/e?nooverride=1';
        }
        for(String key: params.keySet())
        {
            if( key != 'save_new')
            redirectURL = redirectURL + '&' + key + '=' +  params.get(key);
        }             

        PageReference createnewEvent = new PageReference(redirectURL);
        return createnewEvent;
    }
    
    public static testmethod void testOverrideEventButton() {
		PageReference pageRef = new PageReference('/apex/NewEvent?retURL=/home/home.jsp');
        Test.setCurrentPage(pageRef);          
        OverrideEventButton exampleNoURL = new OverrideEventButton ();
        exampleNoURL.init();

		PageReference pageRefNotOpp = new PageReference('/apex/NewEvent?retURL=/0013000000K2fUX');
        Test.setCurrentPage(pageRefNotOpp);          
        OverrideEventButton exampleNotOpp = new OverrideEventButton ();
        exampleNotOpp.init();
        
        PageReference pageRefOpp = new PageReference('/apex/NewEvent?retURL=/0068000000Nx2sX');
        Test.setCurrentPage(pageRefOpp);          
        OverrideEventButton exampleOpp = new OverrideEventButton ();
        exampleOpp.init();
	}

}