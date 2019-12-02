@istest
public class AccountExecutiveRevenueBatchTest {
    
        static List<ATI_Job__c> jobs;
    public testmethod static void AccountExecutiveRevenueBatchTest(){    
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
        update jobs;
        
        AccountExecutiveRevenueBatch c = new AccountExecutiveRevenueBatch();
        Database.executeBatch(c);
    }
    }
}