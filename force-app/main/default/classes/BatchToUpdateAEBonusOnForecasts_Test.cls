@istest
public class BatchToUpdateAEBonusOnForecasts_Test {
    static List<AE_Bonus__c> bonuses;
    static testMethod void testMethod1() 
    {
        TestDataUtil.createCustomSettings_TriggerStatus();
        System.runAs(new User(Id = userinfo.getUserId())){
            bonuses = new List<AE_Bonus__c>();
            List<Account> accounts = TestDataUtil.createAccounts(1, true, new Map<String, Object>{ 'Name' => 'testAcct',
                'BillingStreet' => 'Street 12',
                'BillingCity' => 'San Francisco',
                'BillingCountry' => 'USA',
                'BillingPostalCode' => '1234',
                'BillingState' => 'CA' } );
            system.debug('Acc---'+accounts[0].id);
            Profile p= [Select id from Profile where Name =: JobAEBonusTriggerHandler.PROFILE_MARKETING_REP LIMIT 1];
            List<User> users = TestDataUtil.createUsers(10, true, new Map<String, Object>{ 'profileId' => p.Id,
                                                                            'AE_Type__c' => 'Local',
                                                                            'ManagerId' => Userinfo.getUserId()});
            List<ATI_Job__c> jobs = TestDataUtil.createJob(10, false, new Map<String, String>{'account__c' => accounts[0].Id} );
           	insert jobs;
            system.debug('jobs---'+jobs[0].id);
            for( User u : users ){ 
            bonuses.add( new AE_Bonus__c( AE_Name__c = u.Id, Quarter_Billed__c = 'Q1', 
                                              Year_Billed__c = '2018', Annual_Quota__c = 100000) );     
            }
            insert bonuses;
            Forecast__c fCast = new Forecast__c();
            fCast.AE1_Bonus__c = bonuses[0].Id;
            fCast.AE2_Bonus__c = bonuses[0].Id;
            fCast.Invoice_Date__c = Date.Today().addDays(-270);
            fCast.ATI_Job__c = jobs[0].id;
            system.debug('fCast.ATI_Job__c--'+fCast.ATI_Job__c);
            fCast.Revenue_Amount__c = 1000;
            insert fCast;
            Test.startTest();
            BatchToUpdateAEBonusOnForecasts obj = new BatchToUpdateAEBonusOnForecasts();
            DataBase.executeBatch(obj); 
            Test.stopTest();
        }
    }
}