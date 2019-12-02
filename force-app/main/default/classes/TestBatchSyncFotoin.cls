@isTest
public class TestBatchSyncFotoin {

    static TestMethod void SynchFotoIn_Test(){
        
        List<ATI_Job__c> jobs = getJob();
        test.startTest();
       // if (!System.isFuture() && !System.isBatch())
       // {
            BatchSyncFotoIn fotoin = new BatchSyncFotoIn(jobs);
        	Database.executeBatch(fotoin);
            ID batchprocessid = Database.executeBatch(fotoin);
       // }        
        test.stopTest();
        
    }
    
    public static List<ATI_Job__c> GetJob()
    {
        List<ATI_Job__c> jobs;
        System.runAs(new User(Id = userinfo.getUserId())){
            TestDataUtil.createCustomSettings_TriggerStatus();
        }
        List<Account> accounts = TestDataUtil.createAccounts(1, true, new Map<String, Object>{ 'Name' => 'testAcct',
                                               'BillingStreet' => 'Street 12',
                                                                       'BillingCity' => 'San Francisco',
                                                                       'BillingCountry' => 'USA',
                                                                       'BillingPostalCode' => '1234',
                                                                       'BillingState' => 'CA' } );
        List<Contact> con = TestDataUtil.createContacts(1, true, new Map<String, String>{'accountId' => accounts[0].Id});   
     
        jobs = TestDataUtil.createJob(10, true, new Map<String, String>{'account__c' => accounts[0].Id} );
        
        List<RecordType> rtypes = [SELECT Id FROM RecordType WHERE SObjectType ='ATI_Job__c' AND DeveloperName = 'Job_Approved'];
        
        for( Integer i=0; i< 10; i++ ){
            ATI_Job__c job = jobs[i];
            job.RecordTypeId = rtypes[0].Id;
            job.Project_Site_Contact_Name__c = con[0].id;
            job.Project_Site_Contact_Account__c = accounts[0].Id;
            job.division__c = 'Asbestos';

        }
        update jobs; 
        
        return jobs;
    }
}