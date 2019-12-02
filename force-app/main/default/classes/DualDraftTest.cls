@isTest

Public Class DualDraftTest{

    Public static TestMethod void TestLineItem()
    {
        List<ATI_Job__c> jobs = getJob();
        
        Dual_Draft__c draft = new Dual_Draft__c();
        draft.Check_Number__c = 'Test';
        draft.Check_Amount__c = 399;
        draft.Check_Date__c = date.today();
        draft.Sent_Date__c = date.today();
        draft.Return_Date__c = date.today();
        draft.Description__c = 'Test';
        
        insert draft; 
        
        Dual_Draft_Job__c draftjobs = new Dual_Draft_Job__c ();
        draftjobs.Dual_Draft__c = draft.id;
        draftjobs.ATI_Job__c = jobs[0].id;
               
        insert draftjobs;
        
        draft.Description__c = 'Test123';
        update draft;

    }  
    
    //Create ATI_Job__c
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

        }
        update jobs; 
        
        return jobs;
    }

}