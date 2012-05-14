public class QuoteToPDF {
    public String todaysDate {get;set;}
    public EVQuote__c theQuote {get;set;}
    public Opportunity theOpp {get;set;}
    public List<Id> oppIds {get;set;} 
    public Map<Id,Opportunity> oppMap {get;set;}
    public Account theAccount {get;set;}
    public LOA__c theLastLOA {get;set;}
    public Contact thePrimaryContact {get;set;}
    public map <String, String> membershipValues;
    public map <String, String> membershipAbbr;
    public String lcNames {get;set;}
    public String rlNames {get;set;}
    public Boolean isRenewal {get;set;}
    public Boolean okToPrint {get;set;}
    public List<Quote_Item__c> quoteItems {get;set;}
    public Boolean includesSEM {get;set;}
    public String listOfErrors {get;set;}   
    
    public QuoteToPDF (ApexPages.StandardController stdController){
        theQuote = (EVQuote__c)stdController.getRecord();      
        init();
    }
    
    public class myException extends Exception {}
    
    public void init() {
    	listOfErrors = '';
        if(theQuote.Status__c != 'Approved')
        {
                okToPrint = false;
                listOfErrors = listOfErrors + '<font style="color:red;">This quote has NOT been approved by finance, please submit it.</font><br />';            
        } 
        if(theQuote.Payment_Terms__c == null)
        {
                okToPrint = false;
                listOfErrors = listOfErrors + '<font style="color:red;">This quote is missing Payment Terms. Please edit the Quote and provide them.</font><br />';            
        } 
        if(theQuote.Offer_Expiration_Date__c == null && Math.round(theQuote.Calculated_List_Price__c) > theQuote.Price__c)
        {
                okToPrint = false;
                listOfErrors = listOfErrors + '<font style="color:red;">This quote is discounted but missing an offer expiration date. Please edit the quote and provide one.<br />';               
        }     
        lcNames = '';
        rlNames =  '';
        thePrimaryContact = new Contact();
        theAccount = new Account();
        oppIds = new List<Id>();
        todaysDate = System.today().format();
        includesSEM = false;
        membershipValues = new map <String, String>();
        membershipValues.put('ACL','Academic Leadership Learning Collaborative' );
        membershipValues.put('AIE','Assessment and Institutional Effectiveness Learning Collaborative' );  
        membershipValues.put('CPE', 'Continuing and Professional Education Learning Collaborative');
        membershipValues.put('DEV', 'Development Learning Collaborative');
        membershipValues.put('ENM', 'Enrollment Management Learning Collaborative');
        membershipValues.put('OHE', 'Online Higher Education Learning Collaborative');
        membershipValues.put('SOE', 'Schools of Education Learning Collaborative');
        membershipValues.put('ACL-RL','Academic Leadership Learning Collaborative' );
        membershipValues.put('AIE-RL','Assessment and Institutional Effectiveness Learning Collaborative' );  
        membershipValues.put('CPE-RL', 'Continuing and Professional Education Learning Collaborative');
        membershipValues.put('DEV-RL', 'Development Learning Collaborative');
        membershipValues.put('ENM-RL', 'Enrollment Management Learning Collaborative');
        membershipValues.put('OHE-RL', 'Online Higher Education Learning Collaborative');
        membershipValues.put('SOE-RL', 'Schools of Education Learning Collaborative');
        membershipAbbr = new map <String, String>();
        membershipAbbr.put('ACL','(AL-LC)' );
        membershipAbbr.put('AIE','(AIE-LC)' );  
        membershipAbbr.put('CPE', '(CPE-LC)');
        membershipAbbr.put('DEV', '(DEV-LC)');
        membershipAbbr.put('ENM', '(EM-LC)');
        membershipAbbr.put('OHE', '(OHE-LC)');
        membershipAbbr.put('SOE', '(SOE-LC)');
        membershipAbbr.put('ACL-RL','(AL-LC)' );
        membershipAbbr.put('AIE-RL','(AIE-LC)' );  
        membershipAbbr.put('CPE-RL', '(CPE-LC)');
        membershipAbbr.put('DEV-RL', '(DEV-LC)');
        membershipAbbr.put('ENM-RL', '(EM-LC)');
        membershipAbbr.put('OHE-RL', '(OHE-LC)');
        membershipAbbr.put('SOE-RL', '(SOE-LC)');
        isRenewal = false;
        
        theAccount = [Select Id, Name from Account where Id = :theQuote.Account__c];            
        quoteItems = [SELECT Id, LOA_Quote__c, Opportunity__c, Opportunity_Price__c, Product_Group__c, Opportunity_Type__c 
        				 FROM Quote_item__c WHERE LOA_Quote__c = :theQuote.Id ORDER BY Opportunity_Type__c ];

        for(integer i=0; i<quoteItems.size(); i++)
        {
            if(quoteItems[i].Opportunity_Type__c.contains('Renewal'))
            {
                isRenewal = true;
            }                                       
            if(quoteItems[i].Product_Group__c.contains('-RL'))
            {
                if(rlnames == '')
                {
                        rlnames =  membershipValues.get(quoteItems[i].Product_Group__c);
                } else 
                {
                        rlnames = rlnames + ' & ' + membershipValues.get(quoteItems[i].Product_Group__c);
                    }
            } else  if (quoteItems[i].Product_Group__c == 'SEM')
            {
            	includesSEM = true;
            	
            } else 
            {
                if(lcNames == '')
                {
                        lcNames =  membershipValues.get(quoteItems[i].Product_Group__c);
                } else 
                {
                        lcNames = lcNames + ' & ' + membershipValues.get(quoteItems[i].Product_Group__c);
                }
            }
        }
        if(theQuote.Primary_Contact__c != null)
        {
            thePrimaryContact = [ select Id, Name, Title, Account.Name, Phone, Fax, email,
                                    MailingStreet, MailingCountry, MailingState, MailingCity, MailingPostalCode 
                                    from Contact
                                    where Id = :theQuote.Primary_Contact__c ];  
        } else 
        {
            thePrimaryContact = new Contact();
        }
        if(isRenewal && theQuote.LOA_Start_Date__c == null)
        {
                okToPrint = false;
                listOfErrors = listOfErrors + '<font style="color:red;">This quote is for renewal business but is missing a LOA Start Date. Please edit the Quote and provide one (the Anniversary Date).</font><br />';              
        }
        if(listOfErrors != '')
        {
        	myException theErrors = new myException();
        	theErrors.setMessage(listOfErrors);
        	ApexPages.addMessages(theErrors);
        }    
    }
        
    //Proposed Business Relationship   
    public String getPBR() {
        String pbrHTML = 'Eduventures proposes that ' + theAccount.Name + '("Member")';
        String opType = '';
        Boolean RLfirstPass = true;
        Boolean LCfirstPass = true;             
        for(Quote_item__c qi :  quoteItems)
        {
        	if(qi.Product_Group__c != 'SEM')
        	{

                if(qi.Opportunity_Type__c == 'New Business')
                {
                        opType = qi.Opportunity_Type__c;
                        if(qi.Product_Group__c.contains('-RL'))
                        {
                                if(RLfirstPass)
                                {
                                        if(LCfirstPass == false)
                                        {
                                                pbrHTML = pbrHTML + ' and';
                                        }
                                        pbrHTML = pbrHTML + ' have access to the Eduventures ' + membershipValues.get(qi.Product_Group__c) + ' Research Library ' + membershipAbbr.get(qi.Product_Group__c) ;
                                        RLfirstPass = false;
                                } else
                                {
                                        pbrHTML = pbrHTML + ' and the ' + membershipValues.get(qi.Product_Group__c) + ' Research Library ' + membershipAbbr.get(qi.Product_Group__c) ;
                                }
                        } else 
                        {
                                if(LCfirstPass)
                                {
                                        if(RLfirstPass  == false)
                                        {
                                                pbrHTML = pbrHTML + ' and';
                                        }                                       
                                        pbrHTML = pbrHTML + ' join the Eduventures ' + membershipValues.get(qi.Product_Group__c) + ' ' + membershipAbbr.get(qi.Product_Group__c) ;
                                        LCfirstPass = false;
                                } else
                                {
                                        pbrHTML = pbrHTML + ' and the ' + membershipValues.get(qi.Product_Group__c) + ' ' + membershipAbbr.get(qi.Product_Group__c) ;
                                }
                        }
                } else 
                {
                        if(opType == 'New Business')
                        {
                                pbrHTML = pbrHTML + ' and';
                                opType = qi.Opportunity_Type__c;
                                RLfirstPass = true;
                                        LCfirstPass = true;     
                        }
                        if(qi.Product_Group__c.contains('-RL'))
                        {
                                if(RLfirstPass)
                                {
                                        if(LCfirstPass == false)
                                        {
                                                pbrHTML = pbrHTML + ' and';
                                        }
                                        pbrHTML = pbrHTML + ' renew access to the Eduventures ' + membershipValues.get(qi.Product_Group__c) + ' Research Library ' + membershipAbbr.get(qi.Product_Group__c) ;
                                        RLfirstPass = false;
                                } else
                                {
                                        pbrHTML = pbrHTML + ' and the ' + membershipValues.get(qi.Product_Group__c) + ' Research Library ' + membershipAbbr.get(qi.Product_Group__c) ;
                                }
                        } else 
                        {
                                if(LCfirstPass)
                                {
                                        if(RLfirstPass  == false)
                                        {
                                                pbrHTML = pbrHTML + ' and';
                                        }
                                        pbrHTML = pbrHTML + ' renew membership in the Eduventures ' + membershipValues.get(qi.Product_Group__c) + ' ' + membershipAbbr.get(qi.Product_Group__c) ;
                                        LCfirstPass = false;
                                } else
                                {
                                        pbrHTML = pbrHTML + ' and the ' + membershipValues.get(qi.Product_Group__c) + ' ' + membershipAbbr.get(qi.Product_Group__c) ;
                                }
                        }
                }
        	}
        }                       
                pbrHTML = pbrHTML + ', on the following terms:';
        return pbrHTML;
    }
        
    //Term 
    public String getTerms() {
        String termsHTML = 'The "Term" of this membership agreement is ' + theQuote.Contract_Length__c + ' months, and shall begin upon Member’s ';
        if(theQuote.LOA_Start_Date__c == null)
        {
                        termsHTML = termsHTML + 'signature of this agreement.';
        } else 
        {
                termsHTML = termsHTML + 'anniversary date, ' + theQuote.LOA_Start_Date__c.format() + '.';
        }               
        termsHTML = termsHTML + '<br />';

        return termsHTML;   
    }

}