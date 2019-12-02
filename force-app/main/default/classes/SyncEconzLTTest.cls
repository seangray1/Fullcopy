@isTest
public class SyncEconzLTTest {
     public static TestMethod void testFotoInLT(){
    
        TestDataUtil.createCustomSettings_TriggerStatus();
        
        list<Account> lstAccounts = TestDataUtil.createAccounts(1, false, new map<String,Object>());
        insert lstAccounts;
        
        list<contact> lstContact = TestDataUtil.createContacts(1, false, new map<String,Object>(), lstAccounts[0].Id);
        insert lstContact;
        
        list<ATI_Job__c> lstjob = TestDataUtil.createJob(1, false, new map<String,Object>(), lstAccounts[0].Id);
        lstjob[0].Job_Name__c = 'test';
        insert lstjob;
        
        Test.startTest();
        SyncEconzLT.executeJob(lstjob[0].Id);
        SyncEconzLT.AfterHourEconzCall(lstjob);
        Test.stopTest();

    }
    
     public static TestMethod void testFotoInLT2(){
    
        TestDataUtil.createCustomSettings_TriggerStatus();
        
        list<Account> lstAccounts = TestDataUtil.createAccounts(1, false, new map<String,Object>());
        insert lstAccounts;
        
        list<contact> lstContact = TestDataUtil.createContacts(1, false, new map<String,Object>(), lstAccounts[0].Id);
        insert lstContact;
        
         list<ATI_Job__c> lstjob = TestDataUtil.createJob(1, false, new map<String,Object>(), lstAccounts[0].Id);
        lstjob[0].Job_Name__c = 'test';
         //lstjob[0].Parent_Job__c = 'test';
         lstjob[0].IsCloned__c = true;
        insert lstjob;
        
        list<ATI_Job__c> lstjob1 = TestDataUtil.createJob(1, false, new map<String,Object>(), lstAccounts[0].Id);
        lstjob1[0].Job_Name__c = 'test';
         lstjob1[0].Parent_Job__c = lstjob[0].Id;
         lstjob1[0].IsCloned__c = true;
        insert lstjob1;
        
        Test.startTest();
        SyncEconzLT.executeJob(lstjob[0].Id);
        SyncEconzLT.AfterHourEconzCall(lstjob);
        Test.stopTest();

    }
    
     public static TestMethod void testFotoInLT3(){
    
        TestDataUtil.createCustomSettings_TriggerStatus();
        
        list<Account> lstAccounts = TestDataUtil.createAccounts(1, false, new map<String,Object>());
        insert lstAccounts;
        
        list<contact> lstContact = TestDataUtil.createContacts(1, false, new map<String,Object>(), lstAccounts[0].Id);
        insert lstContact;
        
         list<ATI_Job__c> lstjob = TestDataUtil.createJob(1, false, new map<String,Object>(), lstAccounts[0].Id);
        lstjob[0].Job_Name__c = 'test';
         //lstjob[0].Parent_Job__c = 'test';
         lstjob[0].IsCloned__c = true;
        insert lstjob;
        
        list<ATI_Job__c> lstjob1 = TestDataUtil.createJob(1, false, new map<String,Object>(), lstAccounts[0].Id);
        lstjob1[0].Job_Name__c = 'test';
         lstjob1[0].Parent_Job__c = lstjob[0].Id;
         lstjob1[0].IsCloned__c = true;
        insert lstjob1;
        
         Related_ATI_Job__c relatedJob = new Related_ATI_Job__c();
        relatedJob.ATI_ParentJob__c = lstjob[0].Id;
        relatedJob.Cloned_ATI_Job__c = lstjob1[0].Id;
         insert relatedJob;
         
        list<ATI_Job__c> lstjob2 = TestDataUtil.createJob(1, false, new map<String,Object>(), lstAccounts[0].Id);
        lstjob2[0].Job_Name__c = 'test';
         lstjob2[0].Parent_Job__c = lstjob[0].Id;
         lstjob2[0].IsCloned__c = true;
        insert lstjob2;
        
     
       
        
        Test.startTest();
        SyncEconzLT.executeJob(lstjob[0].Id);
        SyncEconzLT.AfterHourEconzCall(lstjob);
        Test.stopTest();

    }
}