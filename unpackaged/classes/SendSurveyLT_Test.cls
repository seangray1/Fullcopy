@isTest
public class SendSurveyLT_Test {
    
    Public static TestMethod void testStandardUser(){
        
        List<ATI_Job__c> jobs = GetJob();
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(
            LastName='LastName_', 
            Alias='User_', 
            Email='test_'+ '@gmail.com', 
            UserName='testcaseuser_' + '@gmail.com',  
            ProfileId = p.Id,
            CommunityNickname='NickName_',
            Department = 'Some Department',
            EmailEncodingKey = 'ISO-8859-1',
            TimeZoneSidKey = 'America/Los_Angeles', 
            LocaleSidKey = 'en_US', 
            LanguageLocaleKey = 'en_US',
            IsActive = true);
        insert U; 
        
        System.runas(u){
            Test.startTest();
            SendSurveyLT.executeJob(jobs[0].Id);
            Test.stopTest();
        }
    }
    
    Public static TestMethod void testCurrentUser(){
        
        List<ATI_Job__c> jobs = GetJob();
        
        Test.startTest();
        SendSurveyLT.executeJob(jobs[0].Id);
        Test.stopTest();
    }
        
    public static List<ATI_Job__c> GetJob(){
        
        TestDataUtil.createCustomSettings_TriggerStatus();
        
        list<Account> lstAccounts = TestDataUtil.createAccounts(1, false, new map<String,Object>());
        insert lstAccounts;
        
        list<contact> lstContact = TestDataUtil.createContacts(1, false, new map<String,Object>(), lstAccounts[0].Id);
        insert lstContact;
        
        list<ATI_Job__c> lstJob = TestDataUtil.createJob(1, false, new map<String,Object>(), lstAccounts[0].Id);
        lstJob[0].Job_Name__c = 'test';
        insert lstJob;
        
        return lstJob;
 
    }
}