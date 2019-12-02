@istest
public class BatchToSendYearlyQuotaEmail_Test {
    public static testmethod void batchSendEmail(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Executive Management']; 
        User u = new User(Alias = 'standt', Email='demaduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, Default_Gross_Profit__c = 5,
                          TimeZoneSidKey='America/Los_Angeles', UserName='demanduser@testorg.com');
        
        System.runAs(u) {
            Test.startTest();
            BatchToSendYearlyQuotaEmailReminders obj = new BatchToSendYearlyQuotaEmailReminders();
            DataBase.executeBatch(obj); 
            Test.stopTest();
        }
    }
}