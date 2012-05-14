@isTest
private class testLoaQuotes {

    public static testMethod void testLOAQuoteBehaviors() {
                             
        AggregateResult[] theOpps  = [SELECT AccountId, StageName, Type, COUNT(Id) FROM Opportunity 
                                WHERE Stagename in ('Upside','Closeable','Qualified') and AccountId != '0013000000G3Y0S'
                                AND RecordType.DeveloperName in ('MemberPrograms','MemberProgramRenewals')
                                AND Product_Group__c != null
                                GROUP BY AccountId, StageName, Type HAVING COUNT(Id) >= 1 LIMIT 1];
        Account anAccount = [ SELECT Id, Name, Active_Engagements__c, 
                                ( SELECT Id, StageName, Type, Product_Group__c from Opportunities 
                                    WHERE StageName in ('Upside','Closeable','Qualified')
                                    AND RecordType.DeveloperName in ('MemberPrograms','MemberProgramRenewals')
                                	AND Product_Group__c != null
                                     ORDER BY Close_Date_New__c DESC)
                                 FROM Account WHERE Id = :(Id)theOpps[0].get('AccountId')];     
                                                                 
        List<Opportunity> acctOpps = anAccount.Opportunities;                                        
        PageReference pageRefNewQuote = new PageReference('/apex/NewQuote?oppid=' + acctOpps[0].Id);
        Test.setCurrentPage(pageRefNewQuote);          
        EVQuote__c newQuote = new EVQuote__c(); 
        ApexPages.StandardController sc = new ApexPages.standardController(newQuote);
        
        NewQuoteController controllerNQ = new NewQuoteController( sc );
        controllerNQ.init();   

        /*ApexPages.currentPage().getParameters().put('addid', acctOpps[1].Id);
        controllerNQ.selectOpp(); 
        ApexPages.currentPage().getParameters().put('remid', acctOpps[1].Id);
        controllerNQ.removeOpp();*/
        controllerNQ.theQuote.Offer_Expiration_Date__c = System.today() + 7;
        controllerNQ.theQuote.Price__c = controllerNQ.theQuote.Price__c - 1000;
        controllerNQ.theQuote.Status__c = 'Approved';
        controllerNQ.theQuote.Contract_Length__c = 12;
        controllerNQ.save();
        newQuote = controllerNQ.theQuote;

        if(acctOpps[0].Product_Group__c == 'CPE')
        {
            acctOpps[0].Product_Group__c = 'OHE';
        } else 
        {
            acctOpps[0].Product_Group__c = 'CPE';   
        }
        
        if(acctOpps[0].Type == 'New Business')
        {
            acctOpps[0].Type = 'Renewal Business';
        } else 
        {
            acctOpps[0].Type = 'New Business';  
        } 
        /*OpportunityLineItem oli = [SELECT Id, UnitPrice, ListPrice, Quantity, TotalPrice, OpportunityId 
                                        from OpportunityLineItem WHERE OpportunityId = :acctOpps[0].Id];
        oli.UnitPrice = oli.ListPrice - (oli.ListPrice * .25);
        update oli; */
        acctOpps[0].Close_Date_New__c = System.today();            
        update acctOpps[0];
        List<Quote_Item__c> qis = [SELECT Id, Opportunity__c, LOA_Quote__c, CreatedDate, Opportunity_Price__c, Product_Group__c, Opportunity_Type__c 
                                        from Quote_Item__c  WHERE Opportunity__c = :acctOpps[0].Id  AND LOA_Quote__c = :newQuote.Id];
                                        
        System.assert(qis.size() == 1, 'No Matching Quote Item found for Opportunity ' + acctOpps[0].Id);
               
        ApexPages.StandardController esc = new ApexPages.standardController(newQuote);      
        PageReference pageRefEditQuote = new PageReference('/apex/EditQuote');
        Test.setCurrentPage(pageRefEditQuote);                 
        EditQuoteController controllerEQ = new EditQuoteController( esc );
        ApexPages.currentPage().getParameters().put('remid', acctOpps[0].Id);
        controllerEQ.removeOpp();
        ApexPages.currentPage().getParameters().put('addid', acctOpps[0].Id);
        controllerEQ.selectOpp();
        controllerEQ.save();

        ApexPages.StandardController csc = new ApexPages.standardController(controllerEQ.theQuote);             
        PageReference pageRefConvertQuote = new PageReference('/apex/ConvertQuote');
        Test.setCurrentPage(pageRefConvertQuote);          
        ConvertQuoteController controllerCQ = new ConvertQuoteController( csc );
        controllerCQ.next();
        controllerCQ.theQuote.LOA_Start_Date__c = System.today();
        controllerCQ.theQuote.Primary_Contact__c = '0033000000LPQRo';
        controllerCQ.next();
        for(LOA__c l : controllerCQ.loasToCreate)
        {
            l.Amount__c = controllerCQ.theQuote.Price__c / controllerCQ.loasToCreate.size();
        }
        controllerCQ.next();
        controllerCQ.cancel();
        
        ApexPages.StandardController ptqsc = new ApexPages.standardController(controllerCQ.theQuote);       
        PageReference pageRefPDFQuote = new PageReference('/apex/QuoteToPDF');
        Test.setCurrentPage(pageRefPDFQuote);                 
        QuoteToPDF printController = new QuoteToPDF( ptqsc );
        printController.getPBR();
        printController.getTerms();
        
    } 
}