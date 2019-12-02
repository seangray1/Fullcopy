@istest
Private Class LeadEntry_Test{

    static testMethod void UnitTest(){
        
        try{
        Office__c office = new Office__c(name='orange');
        insert office; 
        
        TestDataUtil.createCustomSettings_TriggerStatus();
        System.runAs(new User(Id = userinfo.getUserId())){
 
        }
        List<Account> accounts = TestDataUtil.createAccounts(1, true, new Map<String, Object>{ 'Name' => 'leadentry',
                                               'BillingStreet' => 'Street 12',
                                                                       'BillingCity' => 'test',
                                                                       'BillingCountry' => 'USA',
                                                                       'BillingPostalCode' => '1234',
                                                                       'BillingState' => 'CA' } );
        System.assert(accounts.size()>0);

        List<ATI_Job__c> jobs = TestDataUtil.createJob(1, false, new Map<String, String>{'account__c' => accounts[0].Id} );
        
        ApexPages.StandardController controller = new ApexPages.standardController(jobs[0]);
        LeadEntry lead = new LeadEntry(controller);
        
        PageReference pageRef = page.LeadEntry;
        Test.setCurrentPage(pageRef);
        if(jobs.size()>0){
        ApexPages.currentPage().getParameters().put('id', jobs[0].id);
        }
        Test.startTest();
            lead.job = jobs[0];
            lead.save(); 

        //no account
        LeadEntry lead2 = new LeadEntry(controller);
        ApexPages.currentPage().getParameters().put('id', jobs[0].id);
        
        jobs[0].account__c = null;
            lead2.job = jobs[0];
            lead2.save(); 
        
        EconzIntegration__c Prodcredentials_Customsetting = new EconzIntegration__c();
        Prodcredentials_Customsetting.Name = 'Prod';
        Prodcredentials_Customsetting.EndPointURL__c = 'http://timecardweb.econz.com/axis/services/timecard1Soap';
        Prodcredentials_Customsetting.Password__c = 'pe45';
        Prodcredentials_Customsetting.UserID__c = 'perficient@atirestoration.com';
        insert Prodcredentials_Customsetting;
        
        EconzIntegration__c Testcredentials_Customsetting = new EconzIntegration__c();
        Testcredentials_Customsetting.Name = 'Test';
        Testcredentials_Customsetting.EndPointURL__c = 'http://timecardweb.econz.com/axis/services/timecard1Soap';
        Testcredentials_Customsetting.Password__c = 'pe45';
        Testcredentials_Customsetting.UserID__c = 'perficient@atirestoration.com';
        insert Testcredentials_Customsetting;
        
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource('http://timecardweb.econz.com/axis/services/timecard1Soap', 'Econz_Response');
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, multimock); 

        Test.stopTest();
        }
        Catch(Exception e){
            
            
        }
    }
}