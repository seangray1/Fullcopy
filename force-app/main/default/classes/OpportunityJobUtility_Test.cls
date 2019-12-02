@isTest
public with sharing class OpportunityJobUtility_Test {
   
   static testMethod void ManagerToOwnerCopy(){
        list<ATI_job__c> Jobs;
        Id approvedId;
        
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
            
           
        User u2 = new User(
            LastName='LastName_', 
            Alias='Users_', 
            Email='test12_'+ '@gmail.com', 
            UserName='testcaseuser12_' + '@gmail.com',  
            ProfileId = p.Id,
            CommunityNickname='NickNames_',
            Department = 'Some Department',
            EmailEncodingKey = 'ISO-8859-1',
            TimeZoneSidKey = 'America/Los_Angeles', 
            LocaleSidKey = 'en_US', 
            LanguageLocaleKey = 'en_US',
            collector__c = u.Id,
            IsActive = true);
        insert U2; 
        
        system.runAs(u2){
            
            Map <String, Schema.RecordTypeInfo> jobRecordTypeMap = Schema.SObjectType.ATI_job__c.RecordTypeInfosByName;
            Id notApprovedId = Schema.SObjectType.ATI_job__c.RecordTypeInfosByName.get('New Job (Not Approved)').RecordTypeId;
            approvedId = Schema.SObjectType.ATI_job__c.RecordTypeInfosByName.get('Job (Approved)').RecordTypeId;
    
            TestDataUtil.createCustomSettings_TriggerStatus();
            
            Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Accounting' LIMIT 1];

            //create a new User for PM. 
           // list<User> lstUsers = TestDataUtil.createUsers(2, true, new Map<String, String>{'email' => 'abcde123@gmail.com', 
                                                                            //'ProfileId' => profileId.id, 'Collector__c' => Userinfo.getUserId()});

            
            //create Account 
            list<Account> lstAccounts = TestDataUtil.createAccounts(2, false, new map<String,Object>());
            lstAccounts[0].type ='Property Owner';             
            insert lstAccounts;
            
            lstAccounts[0].Status__c = 'Approved';
            update lstAccounts;
            
            list<contact> lstContact = TestDataUtil.createContacts(2, false, new map<String,Object>(), lstAccounts[0].Id);
            insert lstContact;
            
            Jobs = TestDataUtil.createJob(3, true, new Map<String, String>{'Account__c' => lstAccounts[0].Id, 'Add_Correct_Email__c' => ''});
           
            map<id, ATI_job__c> oldmap = new map<id, ATI_job__c>();
            oldmap.put(Jobs[0].id, Jobs[0]);
            
            update Jobs; 
            
            Test.startTest();
            JobUtility.ManagerToOwnerCopy(oldmap, Jobs);
            JobUtility.removeJobOwnerfromTeam(oldmap, Jobs);
            Test.stopTest();
            
        }
    }

    static testMethod void EmailUpdateOnJob(){
        list<ATI_job__c> Jobs;
        Id approvedId;
        
        system.runAs(new User(Id=Userinfo.getUserId())){
            
            Map <String, Schema.RecordTypeInfo> jobRecordTypeMap = Schema.SObjectType.ATI_job__c.RecordTypeInfosByName;
            Id notApprovedId = Schema.SObjectType.ATI_job__c.RecordTypeInfosByName.get('New Job (Not Approved)').RecordTypeId;
            approvedId = Schema.SObjectType.ATI_job__c.RecordTypeInfosByName.get('Job (Approved)').RecordTypeId;
    
            TestDataUtil.createCustomSettings_TriggerStatus();
            //create Account 
            list<Account> lstAccounts = TestDataUtil.createAccounts(2, false, new map<String,Object>());
            lstAccounts[0].type ='Property Owner';             
            insert lstAccounts;
            
            lstAccounts[0].Status__c = 'Approved';
            update lstAccounts;
            
            list<contact> lstContact = TestDataUtil.createContacts(2, false, new map<String,Object>(), lstAccounts[0].Id);
            insert lstContact;
            
            Jobs = TestDataUtil.createJob(3, true, new Map<String, String>{'Account__c' => lstAccounts[0].Id, 'Add_Correct_Email__c' => 'test@demand.com', 'Project_site_contact_name__c' => lstContact[0].id});
            
            map<id, ATI_job__c> oldmap = new map<id, ATI_job__c>();
            oldmap.put(Jobs[0].id, Jobs[0]);
            Jobs[0].Add_Correct_Email__c = 'abc@gmail.com';
            
            update Jobs; 
            
            Test.startTest();
            JobUtility.EmailUpdateOnJob(oldmap, Jobs);
            Test.stopTest();
            
        }
    }
  
    static testMethod void callFotoInProject() {
        //create Custom Settings Trigger Status
        list<ATI_job__c> Jobs;
        Id approvedId;
        
        system.runAs(new User(Id=Userinfo.getUserId())){
            
            Map <String, Schema.RecordTypeInfo> jobRecordTypeMap = Schema.SObjectType.ATI_job__c.RecordTypeInfosByName;
            Id notApprovedId = Schema.SObjectType.ATI_job__c.RecordTypeInfosByName.get('New Job (Not Approved)').RecordTypeId;
            approvedId = Schema.SObjectType.ATI_job__c.RecordTypeInfosByName.get('Job (Approved)').RecordTypeId;
    
            TestDataUtil.createCustomSettings_TriggerStatus();
            //create Account 
            list<Account> lstAccounts = TestDataUtil.createAccounts(2, false, new map<String,Object>());
            lstAccounts[0].type ='Property Owner';             
            insert lstAccounts;
            
            lstAccounts[0].Status__c = 'Approved';
            update lstAccounts;
            
            list<contact> lstContact = TestDataUtil.createContacts(2, false, new map<String,Object>(), lstAccounts[0].Id);
            insert lstContact;
            
            Jobs = TestDataUtil.createJob(3, false, new map<String,Object>(), lstAccounts[0].Id);
    
            Jobs[0].contact__c = lstContact[0].id;
            Jobs[0].Project_Site_Contact_Name__c = lstContact[1].id;
            Jobs[0].Insurance_Adjuster_Broker__c = lstContact[0].id;
            Jobs[0].Primary_Account__c = 'Caller Account';
            Jobs[0].Project_Site_Address__c = '7550 st. patrick way';
            Jobs[0].Project_Site_Address_2__c = '';
            Jobs[0].Project_Site_City__c = 'Dublin';
            Jobs[0].Project_Site_State__c = 'CA';
            Jobs[0].Project_Site_Zipcode__c = '94568';
            Jobs[0].Project_Site_Contact_Account__c = lstAccounts[0].id;
            Jobs[0].Project_Site_Record_Id__c = '12345';
            Jobs[0].RecordTypeId = notApprovedId;
            Jobs[0].Job_Name__c ='test';
    
            
            Jobs[1].contact__c = lstContact[0].id;
            Jobs[1].Project_Site_Contact_Name__c = lstContact[1].id;
            Jobs[1].Insurance_Adjuster_Broker__c = lstContact[0].id;
            Jobs[1].Primary_Account__c = 'Insurance';
            Jobs[1].Project_Site_Address__c = '39802 cedar blve';
            Jobs[1].Project_Site_Address_2__c = '';
            Jobs[1].Project_Site_City__c = 'Newark';
            Jobs[1].Project_Site_State__c = 'CA';
            Jobs[1].Project_Site_Zipcode__c = '94560';
            Jobs[1].Project_Site_Contact_Account__c = lstAccounts[0].id;
            Jobs[1].RecordTypeId = approvedId;
            Jobs[1].Job_Name__c ='test1';
            
            Jobs[2].contact__c = lstContact[0].id;
            Jobs[2].Project_Site_Contact_Name__c = lstContact[1].id;
            Jobs[2].Insurance_Adjuster_Broker__c =null;
            Jobs[2].Primary_Account__c = 'Insurance';
            Jobs[2].Project_Site_Address__c = '';
            Jobs[2].Project_Site_Address_2__c = '';
            Jobs[2].Project_Site_City__c = '';
            Jobs[2].Project_Site_State__c = '';
            Jobs[2].Project_Site_Zipcode__c = '';
            Jobs[2].Project_Site_Contact_Account__c = lstAccounts[0].id;
            Jobs[2].Job_Name__c ='test2';
            
            insert Jobs;                
        }
        
        System.runAs( new User(Id = userInfo.getUserId())){
            for(ATI_job__c Job : Jobs){
                Job.Project_Site_City__c = 'Fremont';
            }
            Jobs[0].RecordTypeId = approvedId;
            update Jobs;            
        }

        Test.startTest();
            String outPutJson = '{"location": { "lat": 37.09024, "lng": -95.712891}}';
            Test.setMock(HttpCalloutMock.class, new MockHttpFotoIn(200, 'success', outPutJson, null));
            JobCall.syncFotoIn(Jobs[0].id);
            JobCall.syncFotoIn(Jobs[1].id);
        Test.stopTest();    
    }
    
    static testMethod void callFotoInUpdateProject() {
                //create Custom Settings Trigger Status
        list<ATI_job__c> Jobs;
        Id approvedId;
        
        system.runAs(new User(Id=Userinfo.getUserId())){
            
            Map <String, Schema.RecordTypeInfo> jobRecordTypeMap = Schema.SObjectType.ATI_job__c.RecordTypeInfosByName;
            Id notApprovedId = Schema.SObjectType.ATI_job__c.RecordTypeInfosByName.get('New Job (Not Approved)').RecordTypeId;
            approvedId = Schema.SObjectType.ATI_job__c.RecordTypeInfosByName.get('Job (Approved)').RecordTypeId;
    
            TestDataUtil.createCustomSettings_TriggerStatus();
            //create Account 
            list<Account> lstAccounts = TestDataUtil.createAccounts(2, false, new map<String,Object>());
            lstAccounts[0].type ='Property Owner';             
            insert lstAccounts;
            
            lstAccounts[0].Status__c = 'Approved';
            update lstAccounts;
            
            list<contact> lstContact = TestDataUtil.createContacts(2, false, new map<String,Object>(), lstAccounts[0].Id);
            insert lstContact;
            
            Jobs = TestDataUtil.createJob(3, false, new map<String,Object>(), lstAccounts[0].Id);
    
            Jobs[0].contact__c = lstContact[0].id;
            Jobs[0].Project_Site_Contact_Name__c = lstContact[1].id;
            Jobs[0].Insurance_Adjuster_Broker__c = lstContact[0].id;
            Jobs[0].Primary_Account__c = 'Caller Account';
            Jobs[0].Project_Site_Address__c = '7550 st. patrick way';
            Jobs[0].Project_Site_Address_2__c = '';
            Jobs[0].Project_Site_City__c = 'Dublin';
            Jobs[0].Project_Site_State__c = 'CA';
            Jobs[0].Project_Site_Zipcode__c = '94568';
            Jobs[0].Project_Site_Contact_Account__c = lstAccounts[0].id;
            Jobs[0].Project_Site_Record_Id__c = '12345';
            Jobs[0].RecordTypeId = notApprovedId;
            Jobs[0].Job_Name__c ='test';
    
            
            Jobs[1].contact__c = lstContact[0].id;
            Jobs[1].Project_Site_Contact_Name__c = lstContact[1].id;
            Jobs[1].Insurance_Adjuster_Broker__c = lstContact[0].id;
            Jobs[1].Primary_Account__c = 'Insurance';
            Jobs[1].Project_Site_Address__c = '39802 cedar blve';
            Jobs[1].Project_Site_Address_2__c = '';
            Jobs[1].Project_Site_City__c = 'Newark';
            Jobs[1].Project_Site_State__c = 'CA';
            Jobs[1].Project_Site_Zipcode__c = '94560';
            Jobs[1].Project_Site_Contact_Account__c = lstAccounts[0].id;
            Jobs[1].RecordTypeId = approvedId;
            Jobs[1].Job_Name__c ='test1';
            
            Jobs[2].contact__c = lstContact[0].id;
            Jobs[2].Project_Site_Contact_Name__c = lstContact[1].id;
            Jobs[2].Insurance_Adjuster_Broker__c =null;
            Jobs[2].Primary_Account__c = 'Insurance';
            Jobs[2].Project_Site_Address__c = ''; 
            Jobs[2].Project_Site_Address_2__c = '';
            Jobs[2].Project_Site_City__c = '';
            Jobs[2].Project_Site_State__c = '';
            Jobs[2].Project_Site_Zipcode__c = '';
            Jobs[2].Project_Site_Contact_Account__c = lstAccounts[0].id;
            Jobs[2].Job_Name__c ='test2';
            
            insert Jobs;                
        }
        
        System.runAs( new User(Id = userInfo.getUserId())){
            for(ATI_job__c Job : Jobs){
                Job.Project_Site_City__c = 'Fremont';
            }
            Jobs[0].RecordTypeId = approvedId;
            update Jobs;

        }

        Test.startTest();
            String outPutJson = '{"location": { "lat": 37.09024, "lng": -95.712891}}';
            Test.setMock(HttpCalloutMock.class, new MockHttpFotoIn(200, 'success', outPutJson, null));
            JobCall.syncFotoIn(Jobs[0].id);
        Test.stopTest();    
    }
    
}