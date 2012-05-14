// The Name of the class
public class OverrideOppButton{

    //Open up the constructor to get the contact records from the current URL
    public OverrideOppButton(ApexPages.StandardController stdController){

    }


    public PageReference init(){
        //Define the variable first

        Map<String, String> params = ApexPages.currentPage().getParameters();
        string redirectURL = '/006/e?opp9=01/01/1900&nooverride=1';    
        for(String key: params.keySet())
        {
            if( key != 'save_new')
            redirectURL = redirectURL + '&' + key + '=' +  params.get(key);
        }             

        PageReference createnewOpp = new PageReference(redirectURL);
        return createnewOpp;
    }

}