@isTest()
public class CustomerSurveyTrigger_Test {
    
    static List<ATI_Job__c> jobs;
    
    public static TestMethod void UnitTest(){
        System.runAs(new User(Id = userinfo.getUserId())){
            TestDataUtil.createCustomSettings_TriggerStatus();
        }
        List<Account> accounts = TestDataUtil.createAccounts(1, true, new Map<String, Object>{ 'Name' => 'testAcct',
                                               'BillingStreet' => 'Street 12',
                                                                       'BillingCity' => 'San Francisco',
                                                                       'BillingCountry' => 'USA',
                                                                       'BillingPostalCode' => '1234',
                                                                       'BillingState' => 'CA' } );
        jobs = TestDataUtil.createJob(10, true, new Map<String, String>{'account__c' => accounts[0].Id} );
     
        List<RecordType> rtypes = [SELECT Id FROM RecordType WHERE SObjectType ='ATI_Job__c' AND DeveloperName = 'Job_Approved'];
        for( Integer i=0; i< 10; i++ ){
            ATI_Job__c job = jobs[i];
            job.id = jobs[i].id;
            job.RecordTypeId = rtypes[0].Id;

        }
        update jobs;
        Customer_Survey__c survey = new Customer_Survey__c();
        survey.name = 'test';
        survey.ATI_Job__c = jobs[0].Id;
        survey.Project_Manager__c = userinfo.getUserId();
        survey.Project_Manager_New__c = userinfo.getUserId();
        survey.Regional_Manager__c = userinfo.getUserId();
        survey.Office_Manager__c = userinfo.getUserId();
        survey.EVP_1__c = userinfo.getUserId();
        survey.EVP_2__c = userinfo.getUserId();
        survey.Construction_Office_Manager__c = userinfo.getUserId();
        survey.Survey_Recipient__c = userinfo.getUserId();
        survey.Customer_Service__c = userinfo.getUserId();
        
        upsert survey;      

        
    }
    
}