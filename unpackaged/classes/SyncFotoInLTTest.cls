@isTest
public class SyncFotoInLTTest {
    public static TestMethod void testFotoInLT(){
    
        TestDataUtil.createCustomSettings_TriggerStatus();
        
        list<Account> lstAccounts = TestDataUtil.createAccounts(1, false, new map<String,Object>());
        insert lstAccounts;
        
        list<contact> lstContact = TestDataUtil.createContacts(1, false, new map<String,Object>(), lstAccounts[0].Id);
        insert lstContact;
        
        list<ATI_Job__c> lstJob = TestDataUtil.createJob(1, false, new map<String,Object>(), lstAccounts[0].Id);
        lstJob[0].Job_Name__c = 'test';
        insert lstJob;
        
        Test.startTest();
        SyncFotoInLT.executeJob(lstJob[0].Id);
        Test.stopTest();
            
    }

    
}