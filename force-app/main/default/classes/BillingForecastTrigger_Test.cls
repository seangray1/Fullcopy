@istest
public with sharing class BillingForecastTrigger_Test {
     static List<ATI_Job__c> jobs;
    
    public static testmethod void BillingForecastTrigger_Test(){
    TestDataUtil.createCustomSettings_TriggerStatus();
    Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
    User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');
    
    System.runAs(new User(Id = userinfo.getUserId())){
        
            
     List<Account> accounts = TestDataUtil.createAccounts(1, true, new Map<String, Object>{ 'Name' => 'testAcct',
                                               'BillingStreet' => 'Street 12',
                                                                       'BillingCity' => 'San Francisco',
                                                                       'BillingCountry' => 'USA',
                                                                       'BillingPostalCode' => '1234',
                                                                       'BillingState' => 'CA' } );
        jobs = TestDataUtil.createJob(10, true, new Map<String, String>{'Account__c' => accounts[0].Id} );
     
        List<RecordType> rtypes = [SELECT Id FROM RecordType WHERE SObjectType ='ATI_Job__c' AND DeveloperName = 'Job_Approved'];
        for( Integer i=0; i< 10; i++ ){
            ATI_Job__c job = jobs[i];
            job.RecordTypeId = rtypes[0].Id;
            job.Account_Executive_1__c = u.id;
            job.Account_Executive_2__c = u.id;

        }
    //    update jobs;
        
        
        List<Forecast__c> forecast = new  List<Forecast__c>();
        Forecast__c  BillingForecastObj =  new Forecast__c();
        BillingForecastObj.ATI_Job__c = jobs[0].id;
        BillingForecastObj.Invoice_Date__c = Date.today();
        BillingForecastObj.Revenue_Amount__c = 4500;
        insert BillingForecastObj; 
        test.startTest();
        delete BillingForecastObj;
        test.stopTest();
        
         }
    
     }
}