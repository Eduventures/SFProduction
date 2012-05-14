public with sharing class clientsController {

    public Map<String, List<Account>> accountsMap { get; set; }
    public List<Id> acctIds { get; set; }
    public List<String> alpha { get; set; }
    public Integer clientCount { get; set; }
    public Integer numOfColumns { get; set; }
    public Integer split { get; set; }
    public String breaks { get; set; }
    public String myJSONObject { get; set; }

    public clientsController () {
        init();
    }
    

    public void init() {
        accountsMap = new  Map<String, List<Account>>();
        acctIds = new List<String>();
        breaks = '';
        alpha = new List<String> { 'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z'};      
        clientCount = 0;    
        numOfColumns = 3;
        /*for(Integer k=1;k<numOfColumns ;k++)
        {
            breaks.add('');
        }*/
        
        for(AggregateResult ar: [SELECT Account__c acctId From LOA__c where Status__c in ( 'Active', 'Extended') and Do_Not_Publish__c = false
            and RecordTypeId = '01230000000DMbx' and Program__c != 'RPT' GROUP BY Account__c ])
        {
            acctIds.add((String)ar.get('acctId'));
            clientCount = clientCount + 1;
        }
        
        split = Integer.valueOf(clientCount/numOfColumns );
        Integer loopCount = 0;
        Boolean breakNext = false; 
        String currentLetter = 'A';    
        List<Account> accountsList = [SELECT Id, Name, website from Account where Id in :acctIds order by Name ];
        
        for(integer m=0; m<accountsList.size();m++)
        {
            Account tempAcct = accountsList[m];
            String firstLetter = tempAcct.Name.substring(0,1).toLowerCase();
            if(breakNext && firstLetter != currentLetter )
            {
                breaks = breaks + firstLetter;
                breakNext = false;
            }
            
            if(accountsMap.containsKey(firstLetter))
            {
                accountsMap.get(firstLetter).add(tempAcct);
            } else 
            {
                List<Account> temp =  new List<Account>();
                temp.add(tempAcct);
                accountsMap.put(firstLetter,temp);
            }
            loopCount = loopCount + 1;
            
            if(loopCount > split)
            {
                breakNext = true;
                loopCount = 0;
            }
            currentLetter = firstLetter;
        } 
         
        myJSONObject = '{ "breaks": "' + breaks + '", "clients":[ ';
        String tempLetter = '';
        for(integer i=0; i<alpha.size(); i++)
        {
            String letter = alpha.get(i);
            tempLetter = '{"letter": "'+ letter +'", "accounts": [ ';
            String tempAccts = '';
            if(accountsMap.containsKey(letter))
            {
                for(Account a: accountsMap.get(letter))
                {
                    tempAccts = tempAccts + ' "'+a.name+'",';
                }
                tempAccts = tempAccts.substring(0,tempAccts.length()-1);  
            }
            tempLetter = tempLetter + tempAccts + ']},';
            myJSONObject = myJSONObject  + tempLetter;                        
        }
        myJSONObject = myJSONObject.substring(0,myJSONObject.length()-1)  + ']}';  
        String jsoncb = ApexPages.currentPage().getParameters().get('jsoncallback');
        myJSONObject = jsoncb + '(' + myJSONObject + ');'; 
        /*
        {
            "clients" : [ 
                            { "letter": "A", 
                              "accounts": [ 
                                      "Name",
                                      "Name",
                                      "Name"
                                  ]
                            },
                            { "letter": "B", 
                              "accounts": [ 
                                      "Name",
                                      "Name",
                                      "Name"
                                  ]
                            }
                        ],
            "breaks" : "JT",            
            "count" : 300
        }
        */     
    }

    public static testMethod void testClientList() {
    	PageReference clientsRef = new PageReference('/apex/clients');
        Test.setCurrentPage(clientsRef);          
		clientsController proto = new clientsController();
    	
    }
}