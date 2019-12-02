@istest
public class BatchToUpdateLastYrsRvnOnContacts_Test {
    static testMethod void testMethod1() 
    {
        System.runAs(new User(Id = userinfo.getUserId())){
            
            TriggerStatus__c trigStatus = new TriggerStatus__c();
            trigStatus.SetupOwnerId = UserInfo.getUserId();
            trigStatus.Name = 'Test Setting';
            trigStatus.JobSetJobNumber__c = true;
            insert trigStatus;
            
            List<Account> accounts = TestDataUtil.createAccounts(1, true, new Map<String, Object>{ 'Name' => 'testAcct',
                'BillingStreet' => 'Street 12',
                'BillingCity' => 'San Francisco',
                'BillingCountry' => 'USA',
                'BillingPostalCode' => '1234',
                'BillingState' => 'CA' } );
            
            List<ATI_Job__c> jobs = TestDataUtil.createJob(10, true, new Map<String, String>{'account__c' => accounts[0].Id} );
           	Test.setCreatedDate(jobs[0].id, DateTime.newInstance(2017,09,17));
            Test.startTest();
            BatchToUpdateLastYrsRevenueOnContacts obj = new BatchToUpdateLastYrsRevenueOnContacts();
            DataBase.executeBatch(obj); 
            BatchToUpdateLastYrsRevenueOnAcc obj2 = new BatchToUpdateLastYrsRevenueOnAcc();
            DataBase.executeBatch(obj2); 
            Test.stopTest();
        }
    }
}