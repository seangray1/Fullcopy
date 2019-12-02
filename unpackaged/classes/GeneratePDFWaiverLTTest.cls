@isTest
public class GeneratePDFWaiverLTTest {
    public static TestMethod void testGeneratePDFWaiverLT(){
    
        TestDataUtil.createCustomSettings_TriggerStatus();
        
        list<Account> lstAccounts = TestDataUtil.createAccounts(1, false, new map<String,Object>());
        insert lstAccounts;
        
        list<contact> lstContact = TestDataUtil.createContacts(1, false, new map<String,Object>(), lstAccounts[0].Id);
        insert lstContact;
        
        list<ATI_Job__c> lstJobs = TestDataUtil.createJob(1, false, new map<String,Object>(), lstAccounts[0].Id);
        lstJobs[0].Job_Name__c = 'test';
        insert lstJobs;
        
        Waiver__c w = new Waiver__c();
        w.ATI_Job__c = lstJobs[0].Id;
        insert w;
        
        Test.startTest();
        GeneratePDFWaiverLT.getWaiver(w.Id);
        Test.stopTest();
            
    }

}