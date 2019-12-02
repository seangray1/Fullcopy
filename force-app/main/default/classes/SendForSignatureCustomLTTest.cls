@isTest
public class SendForSignatureCustomLTTest {
    
     public static TestMethod void testSendForSignatureCustomLT(){
    
        TestDataUtil.createCustomSettings_TriggerStatus();
        
        list<Account> lstAccounts = TestDataUtil.createAccounts(1, false, new map<String,Object>());
        insert lstAccounts;
        
        list<contact> lstContact = TestDataUtil.createContacts(1, false, new map<String,Object>(), lstAccounts[0].Id);
        insert lstContact;
        
        list<ATI_Job__c> lstJob = TestDataUtil.createJob(1, false, new map<String,Object>(), lstAccounts[0].Id);
        lstJob[0].Job_Name__c = 'test';
        lstJob[0].Project_Site_State__c = 'CA';
        insert lstJob;
        
        Test.startTest();
        SendForSignatureCustomLT.getEchoSignAgreements(lstJob[0].Id);
        Test.stopTest();
            
    }

}