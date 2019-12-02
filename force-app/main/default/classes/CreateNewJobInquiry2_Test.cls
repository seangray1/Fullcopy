/**
* @Auhtor : Narasimha (Perficient)
* @Created: 09.APR.2015
* @Desc   : Test Class for the CreateNewJobInquiry2 apex class
*/
@isTest
private class CreateNewJobInquiry2_Test {
    
    static testMethod void myUnitTest() {
        
        //create Custom Settings Trigger Status
        TestDataUtil.createCustomSettings_TriggerStatus();
        //create Account 
        list<Account> lstAccounts = TestDataUtil.createAccounts(2, false, new map<String,Object>());
        lstAccounts[0].type ='Property Owner'; 
        insert lstAccounts;
        
        list<contact> lstContact = TestDataUtil.createContacts(2, false, new map<String,Object>(), lstAccounts[0].Id);
        
        insert lstContact;
        
        list<ATI_Job__c> lstOppty = TestDataUtil.createJob(4, false, new map<String,Object>(), lstAccounts[0].Id);
        
        lstOppty[0].contact__c = lstContact[0].id;
        lstOppty[0].Project_Site_Contact_Name__c = lstContact[1].id;
        lstOppty[0].Insurance_Adjuster_Broker__c = lstContact[0].id;
        lstOppty[0].Primary_Account__c = 'Caller Account';
        
        lstOppty[1].contact__c = lstContact[0].id;
        lstOppty[1].Insurance_Adjuster_Broker__c = lstContact[0].id;
        lstOppty[1].Primary_Account__c = 'Insurance';
        
        lstOppty[2].contact__c = lstContact[0].id;
        lstOppty[2].Insurance_Adjuster_Broker__c =null;
        lstOppty[2].Primary_Account__c = 'Insurance';
        
        lstOppty[3].contact__c = lstContact[0].id;
        lstOppty[3].Primary_Account__c = 'Insurance';
        lstOppty[3].Insurance_Adjuster_Broker__c =null;
        lstOppty[3].Job_Name__c ='test';
        
        PageReference pageRef = page.NewJob2;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', lstOppty[0].id);
        
        Test.startTest();
        
        CreateNewJobInquiry2 testObj = new CreateNewJobInquiry2();
        testObj.showNewCaller = true;
        testObj.showNewAccount = true;
        testObj.showNewCustomerPerson = true;
        testObj.showNewCustomerBusiness = true;
        testObj.showNewProjectSiteContact = true;
        testObj.showNewProjectSiteContactAccount = true;
        testObj.showNewInsuranceCompany = true;
        testObj.showNewAdjuster = true;
        testObj.showNewAdjusterAccount = true;
        
        testObj.job = lstOppty[0];
        testObj.Sameascaller = false;
        testObj.save();
        testObj.cancel();
        testObj.assign2ProjectSiteContactInfo();
        testObj.showOrHideNewCaller();
        testObj.showOrHideNewAccount();
        testObj.showOrHideNewProjectSiteContactAccount();
        testObj.showOrHideNewProjectSiteContact();
        testObj.showOrHideNewCustomerPerson();
        testObj.showOrHideNewCustomerBusiness();
        testObj.showOrHideNewAdjuster();
        testObj.showOrHideNewAdjusterAccount();
        testObj.showOrHideNewInsuranceCompany();
         
        ApexPages.currentPage().getParameters().put('id', lstOppty[1].id);
        CreateNewJobInquiry2 testObj2 = new CreateNewJobInquiry2();
        
        testObj2.save();   
        ApexPages.currentPage().getParameters().put('id', lstOppty[2].id);
        CreateNewJobInquiry2 testObj3 = new CreateNewJobInquiry2();
        testObj3.job = lstOppty[1];
        testObj3.Sameascaller = true;
        testObj3.save();
        insert lstOppty[3];
        
        lstOppty[3].Add_Correct_Email__c ='test@test.com';
        lstOppty[3].Contact__c =lstContact[1].Id;
        lstOppty[3].Project_Site_Contact_Account__c =lstAccounts[0].Id;
        lstOppty[3].Account__c =lstAccounts[1].Id;
        
        update lstOppty[3];
        
        Test.stopTest();
    }
    
    static testMethod void myUnitTest2() {
        
        //create Custom Settings Trigger Status
        TestDataUtil.createCustomSettings_TriggerStatus();
        //create Account 
        list<Account> lstAccounts = TestDataUtil.createAccounts(2, false, new map<String,Object>());
        lstAccounts[0].type ='Property Owner'; 
        insert lstAccounts;
        
        list<contact> lstContact = TestDataUtil.createContacts(2, false, new map<String,Object>(), lstAccounts[0].Id);
        lstContact[1].contact_type__c = 'property owner';
        insert lstContact;
        
        list<ATI_Job__c> lstOppty = TestDataUtil.createJob(4, false, new map<String,Object>(), lstAccounts[0].Id);
        
        lstOppty[0].contact__c = lstContact[0].id;
        lstOppty[0].Project_Site_Contact_Name__c = lstContact[1].id;
        lstOppty[0].Insurance_Adjuster_Broker__c = lstContact[0].id;
        lstOppty[0].Primary_Account__c = 'Caller Account';
        
        lstOppty[1].contact__c = lstContact[0].id;
        lstOppty[1].Insurance_Adjuster_Broker__c = lstContact[0].id;
        lstOppty[1].Primary_Account__c = 'Insurance';
        
        lstOppty[2].contact__c = lstContact[0].id;
        lstOppty[2].Insurance_Adjuster_Broker__c =null;
        lstOppty[2].Primary_Account__c = 'Insurance';
        
        lstOppty[3].contact__c = lstContact[0].id;
        lstOppty[3].Primary_Account__c = 'Insurance';
        lstOppty[3].Insurance_Adjuster_Broker__c =null;
        lstOppty[3].Job_Name__c ='test';
        
        PageReference pageRef = page.NewJob2;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', lstOppty[0].id);
        
        Test.startTest();
        
        CreateNewJobInquiry2 testObj = new CreateNewJobInquiry2();
        testObj.showNewCaller = false;
        testObj.showNewAccount = false;
        testObj.showNewCustomerPerson = false;
        testObj.showNewCustomerBusiness = false;
        testObj.showNewProjectSiteContact = false;
        testObj.showNewProjectSiteContactAccount = false;
        testObj.showNewInsuranceCompany = false;
        testObj.showNewAdjuster = false;
        testObj.showNewAdjusterAccount = false;
        
        testObj.job = lstOppty[0];
        testObj.newProjectSiteContact = lstContact[1];
        
        testObj.Sameascaller = false;
        testObj.save(); 
        testObj.assign2ProjectSiteContactInfo();
        testObj.showOrHideNewCaller();
        testObj.showOrHideNewAccount();
        testObj.showOrHideNewProjectSiteContactAccount();
        testObj.showOrHideNewProjectSiteContact();
        testObj.showOrHideNewCustomerPerson();
        testObj.showOrHideNewCustomerBusiness();
        testObj.showOrHideNewAdjuster();
        testObj.showOrHideNewAdjusterAccount();
        testObj.showOrHideNewInsuranceCompany();
        testObj.associateBillingAddress(lstAccounts[0].id);
        
        ApexPages.currentPage().getParameters().put('id', lstOppty[1].id);
        CreateNewJobInquiry2 testObj2 = new CreateNewJobInquiry2();
        testObj2.save();       
       
        ApexPages.currentPage().getParameters().put('id', lstOppty[2].id);
        CreateNewJobInquiry2 testObj3 = new CreateNewJobInquiry2();
        testObj3.job = lstOppty[1];
        testObj3.Sameascaller = true;
        testObj3.save();      
        insert lstOppty[3];
        
        lstOppty[3].Add_Correct_Email__c ='test@test.com';
        lstOppty[3].Contact__c =lstContact[1].Id;
        lstOppty[3].Project_Site_Contact_Account__c =lstAccounts[0].Id;
        lstOppty[3].Account__c =lstAccounts[1].Id;
        
        update lstOppty[3];
        
        Test.stopTest();
    }
    
    static testMethod void myUnitTest3() {
        
        //create Custom Settings Trigger Status
        TestDataUtil.createCustomSettings_TriggerStatus();
        //create Account 
        list<Account> lstAccounts = TestDataUtil.createAccounts(2, false, new map<String,Object>());
        lstAccounts[0].type ='Property Owner'; 
        insert lstAccounts;
        
        list<contact> lstContact = TestDataUtil.createContacts(2, false, new map<String,Object>(), lstAccounts[0].Id);
        lstContact[0].contact_type__c = 'property owner';
        insert lstContact;
        
        list<ATI_Job__c> lstOppty = TestDataUtil.createJob(4, false, new map<String,Object>(), lstAccounts[0].Id);
        
        lstOppty[0].contact__c = lstContact[0].id;
        lstOppty[0].Project_Site_Contact_Name__c = lstContact[1].id;
        lstOppty[0].Insurance_Adjuster_Broker__c = lstContact[0].id;
        lstOppty[0].Primary_Account__c = 'Caller Account';
        
        lstOppty[1].contact__c = lstContact[0].id;
        lstOppty[1].Insurance_Adjuster_Broker__c = lstContact[0].id;
        lstOppty[1].Primary_Account__c = 'Insurance';
        
        lstOppty[2].contact__c = lstContact[0].id;
        lstOppty[2].Insurance_Adjuster_Broker__c =null;
        lstOppty[2].Primary_Account__c = 'Insurance';
        
        lstOppty[3].contact__c = lstContact[0].id;
        lstOppty[3].Primary_Account__c = 'Insurance';
        lstOppty[3].Insurance_Adjuster_Broker__c =null;
        lstOppty[3].Job_Name__c ='test';
        
        PageReference pageRef = page.NewJob2;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', lstOppty[0].id);
        
        Test.startTest();
        
        CreateNewJobInquiry2 testObj = new CreateNewJobInquiry2();
        testObj.showNewCaller = false;
        testObj.showNewAccount = false;
        testObj.showNewCustomerPerson = false;
        testObj.showNewCustomerBusiness = false;
        testObj.showNewProjectSiteContact = false;
        testObj.showNewProjectSiteContactAccount = false;
        testObj.showNewInsuranceCompany = false;
        testObj.showNewAdjuster = false;
        testObj.showNewAdjusterAccount = false;
        
        testObj.job = lstOppty[0];
        testObj.newCaller = lstContact[0];
        
        testObj.Sameascaller = false;
        testObj.save(); 
        testObj.assign2ProjectSiteContactInfo();
        testObj.showOrHideNewCaller();
        testObj.showOrHideNewAccount();
        testObj.showOrHideNewProjectSiteContactAccount();
        testObj.showOrHideNewProjectSiteContact();
        testObj.showOrHideNewCustomerPerson();
        testObj.showOrHideNewCustomerBusiness();
        testObj.showOrHideNewAdjuster();
        testObj.showOrHideNewAdjusterAccount();
        testObj.showOrHideNewInsuranceCompany();
        testObj.associateBillingAddress(lstAccounts[0].id);
        
        ApexPages.currentPage().getParameters().put('id', lstOppty[1].id);
        CreateNewJobInquiry2 testObj2 = new CreateNewJobInquiry2();
        testObj2.save();       
       
        ApexPages.currentPage().getParameters().put('id', lstOppty[2].id);
        CreateNewJobInquiry2 testObj3 = new CreateNewJobInquiry2();
        testObj3.job = lstOppty[1];
        testObj3.Sameascaller = true;
        testObj3.save();      
        insert lstOppty[3];
        
        lstOppty[3].Add_Correct_Email__c ='test@test.com';
        lstOppty[3].Contact__c =lstContact[1].Id;
        lstOppty[3].Project_Site_Contact_Account__c =lstAccounts[0].Id;
        lstOppty[3].Account__c =lstAccounts[1].Id;
        
        update lstOppty[3];
        
        Test.stopTest();
    }
    
    static testMethod void myUnitTest4() {
        
        //create Custom Settings Trigger Status
        TestDataUtil.createCustomSettings_TriggerStatus();
        //create Account 
        list<Account> lstAccounts = TestDataUtil.createAccounts(2, false, new map<String,Object>());
        lstAccounts[0].type ='Property Owner'; 
        insert lstAccounts;
        
        list<contact> lstContact = TestDataUtil.createContacts(2, false, new map<String,Object>(), lstAccounts[0].Id);
        lstContact[0].contact_type__c = 'property owner';
        insert lstContact;
        
        list<ATI_Job__c> lstOppty = TestDataUtil.createJob(4, false, new map<String,Object>(), lstAccounts[0].Id);
        
        lstOppty[0].contact__c = lstContact[0].id;
        lstOppty[0].Project_Site_Contact_Name__c = lstContact[1].id;
        lstOppty[0].Insurance_Adjuster_Broker__c = lstContact[0].id;
        lstOppty[0].Primary_Account__c = 'Caller Account';
        
        lstOppty[1].contact__c = lstContact[0].id;
        lstOppty[1].Insurance_Adjuster_Broker__c = lstContact[0].id;
        lstOppty[1].Primary_Account__c = 'Insurance';
        
        lstOppty[2].contact__c = lstContact[0].id;
        lstOppty[2].Insurance_Adjuster_Broker__c =null;
        lstOppty[2].Primary_Account__c = 'Insurance';
        
        lstOppty[3].contact__c = lstContact[0].id;
        lstOppty[3].Primary_Account__c = 'Insurance';
        lstOppty[3].Insurance_Adjuster_Broker__c =null;
        lstOppty[3].Job_Name__c ='test';
        
        PageReference pageRef = page.NewJob2;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', lstOppty[0].id);
        
        Test.startTest();
        
        CreateNewJobInquiry2 testObj = new CreateNewJobInquiry2();
        testObj.showNewCaller = false;
        testObj.showNewAccount = false;
        testObj.showNewCustomerPerson = false;
        testObj.showNewCustomerBusiness = false;
        testObj.showNewProjectSiteContact = false;
        testObj.showNewProjectSiteContactAccount = false;
        testObj.showNewInsuranceCompany = false;
        testObj.showNewAdjuster = false;
        testObj.showNewAdjusterAccount = false;
        
        testObj.job = lstOppty[0];
        testObj.newCustomerPerson = lstContact[0];
        
        testObj.Sameascaller = false;
        testObj.save(); 
        testObj.assign2ProjectSiteContactInfo();
        testObj.showOrHideNewCaller();
        testObj.showOrHideNewAccount();
        testObj.showOrHideNewProjectSiteContactAccount();
        testObj.showOrHideNewProjectSiteContact();
        testObj.showOrHideNewCustomerPerson();
        testObj.showOrHideNewCustomerBusiness();
        testObj.showOrHideNewAdjuster();
        testObj.showOrHideNewAdjusterAccount();
        testObj.showOrHideNewInsuranceCompany();
        testObj.associateBillingAddress(lstAccounts[0].id);
        
        ApexPages.currentPage().getParameters().put('id', lstOppty[1].id);
        CreateNewJobInquiry2 testObj2 = new CreateNewJobInquiry2();
        testObj2.save();       
       
        ApexPages.currentPage().getParameters().put('id', lstOppty[2].id);
        CreateNewJobInquiry2 testObj3 = new CreateNewJobInquiry2();
        testObj3.job = lstOppty[1];
        testObj3.Sameascaller = true;
        testObj3.save();      
        insert lstOppty[3];
        
        lstOppty[3].Add_Correct_Email__c ='test@test.com';
        lstOppty[3].Contact__c =lstContact[1].Id;
        lstOppty[3].Project_Site_Contact_Account__c =lstAccounts[0].Id;
        lstOppty[3].Account__c =lstAccounts[1].Id;
        
        update lstOppty[3];
        Test.stopTest();
    }
    
    static testMethod void myUnitTest5() {
        
        //create Custom Settings Trigger Status
        TestDataUtil.createCustomSettings_TriggerStatus();
        //create Account 
        list<Account> lstAccounts = TestDataUtil.createAccounts(2, false, new map<String,Object>());
        lstAccounts[0].type ='Property Owner'; 
        insert lstAccounts;
        
        list<contact> lstContact = TestDataUtil.createContacts(2, false, new map<String,Object>(), lstAccounts[0].Id);
       
        insert lstContact;
        
        list<ATI_Job__c> lstOppty = TestDataUtil.createJob(4, false, new map<String,Object>(), lstAccounts[0].Id);
        
        lstOppty[0].contact__c = lstContact[0].id;
        lstOppty[0].Project_Site_Contact_Name__c = lstContact[1].id;
        lstOppty[0].Insurance_Adjuster_Broker__c = lstContact[0].id;
        lstOppty[0].Primary_Account__c = 'Project Site Contact';
        
        lstOppty[1].contact__c = lstContact[0].id;
        lstOppty[1].Insurance_Adjuster_Broker__c = lstContact[0].id;
        lstOppty[1].Primary_Account__c = 'Insurance';
        
        lstOppty[2].contact__c = lstContact[0].id;
        lstOppty[2].Insurance_Adjuster_Broker__c =null;
        lstOppty[2].Primary_Account__c = 'Insurance';
        
        lstOppty[3].contact__c = lstContact[0].id;
        lstOppty[3].Primary_Account__c = 'Insurance';
        lstOppty[3].Insurance_Adjuster_Broker__c =null;
        lstOppty[3].Job_Name__c ='test';
        
        PageReference pageRef = page.NewJob2;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', lstOppty[0].id);
        
        Test.startTest();
        
        CreateNewJobInquiry2 testObj = new CreateNewJobInquiry2();
        testObj.showNewCaller = false;
        testObj.showNewAccount = false;
        testObj.showNewCustomerPerson = false;
        testObj.showNewCustomerBusiness = false;
        testObj.showNewProjectSiteContact = true;
        testObj.showNewProjectSiteContactAccount = false;
        testObj.showNewInsuranceCompany = false;
        testObj.showNewAdjuster = false;
        testObj.showNewAdjusterAccount = false;
        
        testObj.job = lstOppty[0];
        testObj.newCaller = lstContact[1];
        
        testObj.Sameascaller = false;
        testObj.save(); 
        testObj.assign2ProjectSiteContactInfo();
        testObj.showOrHideNewCaller();
        testObj.showOrHideNewAccount();
        testObj.showOrHideNewProjectSiteContactAccount();
        testObj.showOrHideNewProjectSiteContact();
        testObj.showOrHideNewCustomerPerson();
        testObj.showOrHideNewCustomerBusiness();
        testObj.showOrHideNewAdjuster();
        testObj.showOrHideNewAdjusterAccount();
        testObj.showOrHideNewInsuranceCompany();
        testObj.associateBillingAddress(lstAccounts[0].id);
        
        ApexPages.currentPage().getParameters().put('id', lstOppty[1].id);
        CreateNewJobInquiry2 testObj2 = new CreateNewJobInquiry2();
        testObj2.save();       
       
        ApexPages.currentPage().getParameters().put('id', lstOppty[2].id);
        CreateNewJobInquiry2 testObj3 = new CreateNewJobInquiry2();
        testObj3.job = lstOppty[1];
        testObj3.Sameascaller = true;
        testObj3.save();      
        insert lstOppty[3];
        
        lstOppty[3].Add_Correct_Email__c ='test@test.com';
        lstOppty[3].Contact__c =lstContact[1].Id;
        lstOppty[3].Project_Site_Contact_Account__c =lstAccounts[0].Id;
        lstOppty[3].Account__c =lstAccounts[1].Id;
        
        update lstOppty[3];
        Test.stopTest();
    }
    
    static testMethod void myUnitTest6() {
        
        //create Custom Settings Trigger Status
        TestDataUtil.createCustomSettings_TriggerStatus();
        //create Account 
        list<Account> lstAccounts = TestDataUtil.createAccounts(2, false, new map<String,Object>());
        lstAccounts[0].type ='Property Owner'; 
        insert lstAccounts;
        
        list<contact> lstContact = TestDataUtil.createContacts(2, false, new map<String,Object>(), lstAccounts[0].Id);
       
        insert lstContact;
        
        list<ATI_Job__c> lstOppty = TestDataUtil.createJob(4, false, new map<String,Object>(), lstAccounts[0].Id);
        
        lstOppty[0].contact__c = lstContact[0].id;
        lstOppty[0].Project_Site_Contact_Name__c = lstContact[1].id;
        lstOppty[0].Insurance_Adjuster_Broker__c = null;
        lstOppty[0].Primary_Account__c = 'Customer';
        lstOppty[0].Owner__c = lstAccounts[0].id;
        
        lstOppty[1].contact__c = lstContact[0].id;
        lstOppty[1].Insurance_Adjuster_Broker__c = lstContact[0].id;
        lstOppty[1].Primary_Account__c = 'Insurance';
        
        lstOppty[2].contact__c = lstContact[0].id;
        lstOppty[2].Insurance_Adjuster_Broker__c =null;
        lstOppty[2].Primary_Account__c = 'Insurance';
        
        lstOppty[3].contact__c = lstContact[0].id;
        lstOppty[3].Primary_Account__c = 'Insurance';
        lstOppty[3].Insurance_Adjuster_Broker__c =null;
        lstOppty[3].Job_Name__c ='test';
        
        PageReference pageRef = page.NewJob2;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', lstOppty[0].id);
        
        Test.startTest();
        
        CreateNewJobInquiry2 testObj = new CreateNewJobInquiry2();
        testObj.showNewCaller = false;
        testObj.showNewAccount = false;
        testObj.showNewCustomerPerson = false;
        testObj.showNewCustomerBusiness = false;
        testObj.showNewProjectSiteContact = true;
        testObj.showNewProjectSiteContactAccount = false;
        testObj.showNewInsuranceCompany = false;
        testObj.showNewAdjuster = false;
        testObj.showNewAdjusterAccount = false;
        
        testObj.job = lstOppty[0];
        testObj.newCaller = lstContact[1];
        
        testObj.Sameascaller = false;
        testObj.save(); 
        testObj.assign2ProjectSiteContactInfo();
        testObj.showOrHideNewCaller();
        testObj.showOrHideNewAccount();
        testObj.showOrHideNewProjectSiteContactAccount();
        testObj.showOrHideNewProjectSiteContact();
        testObj.showOrHideNewCustomerPerson();
        testObj.showOrHideNewCustomerBusiness();
        testObj.showOrHideNewAdjuster();
        testObj.showOrHideNewAdjusterAccount();
        testObj.showOrHideNewInsuranceCompany();
        testObj.associateBillingAddress(lstAccounts[0].id);
        
        ApexPages.currentPage().getParameters().put('id', lstOppty[1].id);
        CreateNewJobInquiry2 testObj2 = new CreateNewJobInquiry2();
        testObj2.save();       
       
        ApexPages.currentPage().getParameters().put('id', lstOppty[2].id);
        CreateNewJobInquiry2 testObj3 = new CreateNewJobInquiry2();
        testObj3.job = lstOppty[1];
        testObj3.Sameascaller = false;
        testObj3.save();      
        insert lstOppty[3];
        
        lstOppty[3].Add_Correct_Email__c ='test@test.com';
        lstOppty[3].Contact__c =lstContact[1].Id;
        lstOppty[3].Project_Site_Contact_Account__c =lstAccounts[0].Id;
        lstOppty[3].Account__c =lstAccounts[1].Id;
        
        update lstOppty[3];
        Test.stopTest();
    }
    
        static testMethod void myUnitTest7() {
        
        //create Custom Settings Trigger Status
        TestDataUtil.createCustomSettings_TriggerStatus();
        //create Account 
        list<Account> lstAccounts = TestDataUtil.createAccounts(2, false, new map<String,Object>());
        lstAccounts[0].type ='Property Owner'; 
        insert lstAccounts;
        
        list<contact> lstContact = TestDataUtil.createContacts(2, false, new map<String,Object>(), lstAccounts[0].Id);
        lstContact[0].Contact_Type__c = 'property owner';
        insert lstContact;
        
        list<ATI_Job__c> lstOppty = TestDataUtil.createJob(4, false, new map<String,Object>(), lstAccounts[0].Id);
        
        lstOppty[0].contact__c = lstContact[0].id;
        lstOppty[0].Project_Site_Contact_Name__c = lstContact[1].id;
        lstOppty[0].Insurance_Adjuster_Broker__c = null;
        lstOppty[0].Primary_Account__c = 'Insurance';
        lstOppty[0].Owner__c = lstAccounts[0].id;
        
        lstOppty[1].contact__c = lstContact[0].id;
        lstOppty[1].Insurance_Adjuster_Broker__c = lstContact[0].id;
        lstOppty[1].Primary_Account__c = 'Insurance';
        
        lstOppty[2].contact__c = lstContact[0].id;
        lstOppty[2].Insurance_Adjuster_Broker__c =null;
        lstOppty[2].Primary_Account__c = 'Insurance';
        
        lstOppty[3].contact__c = lstContact[0].id;
        lstOppty[3].Primary_Account__c = 'Insurance';
        lstOppty[3].Insurance_Adjuster_Broker__c =null;
        lstOppty[3].Job_Name__c ='test';
        
        PageReference pageRef = page.NewJob2;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', lstOppty[0].id);
        
        Test.startTest();
        
        CreateNewJobInquiry2 testObj = new CreateNewJobInquiry2();
        testObj.showNewCaller = false;
        testObj.showNewAccount = false;
        testObj.showNewCustomerPerson = false;
        testObj.showNewCustomerBusiness = false;
        testObj.showNewProjectSiteContact = true;
        testObj.showNewProjectSiteContactAccount = false;
        testObj.showNewInsuranceCompany = false;
        testObj.showNewAdjuster = false;
        testObj.showNewAdjusterAccount = false;
        
        testObj.job = lstOppty[0];
        testObj.newCaller = lstContact[1];
        
        testObj.Sameascaller = false;
        testObj.save(); 
        testObj.assign2ProjectSiteContactInfo();
        testObj.showOrHideNewCaller();
        testObj.showOrHideNewAccount();
        testObj.showOrHideNewProjectSiteContactAccount();
        testObj.showOrHideNewProjectSiteContact();
        testObj.showOrHideNewCustomerPerson();
        testObj.showOrHideNewCustomerBusiness();
        testObj.showOrHideNewAdjuster();
        testObj.showOrHideNewAdjusterAccount();
        testObj.showOrHideNewInsuranceCompany();
        testObj.associateBillingAddress(lstAccounts[0].id);
        
        ApexPages.currentPage().getParameters().put('id', lstOppty[1].id);
        CreateNewJobInquiry2 testObj2 = new CreateNewJobInquiry2();
        testObj2.save();       
       
        ApexPages.currentPage().getParameters().put('id', lstOppty[2].id);
        CreateNewJobInquiry2 testObj3 = new CreateNewJobInquiry2();
        testObj3.job = lstOppty[1];
        testObj3.Sameascaller = false;
        testObj3.save();      
        insert lstOppty[3];
        
        lstOppty[3].Add_Correct_Email__c ='test@test.com';
        lstOppty[3].Contact__c =lstContact[1].Id;
        lstOppty[3].Project_Site_Contact_Account__c =lstAccounts[0].Id;
        lstOppty[3].Account__c =lstAccounts[1].Id;
        
        update lstOppty[3];
        Test.stopTest();
    }
    
    static testMethod void myUnitTest8() {
        
        //create Custom Settings Trigger Status
        TestDataUtil.createCustomSettings_TriggerStatus();
        //create Account 
        list<Account> lstAccounts = TestDataUtil.createAccounts(2, false, new map<String,Object>());
        lstAccounts[0].type ='Property Owner'; 
        insert lstAccounts;
        
        list<contact> lstContact = TestDataUtil.createContacts(2, false, new map<String,Object>(), null);
        lstContact[0].Contact_Type__c = 'property owner';
        try{
            insert lstContact;}catch(Exception ex){}
        
        list<ATI_Job__c> lstOppty = TestDataUtil.createJob(4, false, new map<String,Object>(), lstAccounts[0].Id);
        
        lstOppty[0].contact__c = lstContact[0].id;
        lstOppty[0].Project_Site_Contact_Name__c = lstContact[1].id;
        lstOppty[0].Insurance_Adjuster_Broker__c = null;
        lstOppty[0].Primary_Account__c = 'Insurance';
        lstOppty[0].Owner__c = lstAccounts[0].id;
        
        lstOppty[1].contact__c = lstContact[0].id;
        lstOppty[1].Insurance_Adjuster_Broker__c = lstContact[0].id;
        lstOppty[1].Primary_Account__c = 'Insurance';
        
        lstOppty[2].contact__c = lstContact[0].id;
        lstOppty[2].Insurance_Adjuster_Broker__c =null;
        lstOppty[2].Primary_Account__c = 'Insurance';
        
        lstOppty[3].contact__c = lstContact[0].id;
        lstOppty[3].Primary_Account__c = 'Insurance';
        lstOppty[3].Insurance_Adjuster_Broker__c =null;
        lstOppty[3].Job_Name__c ='test';
        
        PageReference pageRef = page.NewJob2;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', lstOppty[0].id);
        
        Test.startTest();
        
        CreateNewJobInquiry2 testObj = new CreateNewJobInquiry2(new ApexPages.StandardController(lstOppty[0]));
        
        testObj.showNewCaller = false;
        testObj.showNewAccount = false;
        testObj.showNewCustomerPerson = false;
        testObj.showNewCustomerBusiness = false;
        testObj.showNewProjectSiteContact = true;
        testObj.showNewProjectSiteContactAccount = false;
        testObj.showNewInsuranceCompany = false;
        testObj.showNewAdjuster = false;
        testObj.showNewAdjusterAccount = false;
        
        testObj.job = lstOppty[0];
        testObj.newCaller = lstContact[1];
        
        testObj.Sameascaller = false;
        testObj.save(); 
        testObj.assign2ProjectSiteContactInfo();
        testObj.showOrHideNewCaller();
        testObj.showOrHideNewAccount();
        testObj.showOrHideNewProjectSiteContactAccount();
        testObj.showOrHideNewProjectSiteContact();
        testObj.showOrHideNewCustomerPerson();
        testObj.showOrHideNewCustomerBusiness();
        testObj.showOrHideNewAdjuster();
        testObj.showOrHideNewAdjusterAccount();
        testObj.showOrHideNewInsuranceCompany();
        testObj.associateBillingAddress(lstAccounts[0].id);
        
        ApexPages.currentPage().getParameters().put('id', lstOppty[1].id);
        CreateNewJobInquiry2 testObj2 = new CreateNewJobInquiry2();
        testObj2.save();       
       
        ApexPages.currentPage().getParameters().put('id', lstOppty[2].id);
        CreateNewJobInquiry2 testObj3 = new CreateNewJobInquiry2();
        testObj3.job = lstOppty[1];
        testObj3.Sameascaller = false;
        testObj3.save();      
        insert lstOppty[3];
        
        lstOppty[3].Add_Correct_Email__c ='test@test.com';
        lstOppty[3].Contact__c =lstContact[1].Id;
        lstOppty[3].Project_Site_Contact_Account__c =lstAccounts[0].Id;
        lstOppty[3].Account__c =lstAccounts[1].Id;
        
        update lstOppty[3];
        Test.stopTest();
    }
    
    
    static testMethod void callFotoInProject() {
        //create Custom Settings Trigger Status
        list<ATI_Job__c> lstOppty;
        Id approvedId;
        system.runAs(new User(Id=Userinfo.getUserId())){
            Map <String, Schema.RecordTypeInfo> jobRecordTypeMap = Schema.SObjectType.ATI_Job__c.RecordTypeInfosByName;
            Id notApprovedId = Schema.SObjectType.ATI_Job__c.RecordTypeInfosByName.get('New Job (Not Approved)').RecordTypeId;
            approvedId = Schema.SObjectType.ATI_Job__c.RecordTypeInfosByName.get('Job (Approved)').RecordTypeId;
            
            TestDataUtil.createCustomSettings_TriggerStatus();
            //create Account 
            list<Account> lstAccounts = TestDataUtil.createAccounts(2, false, new map<String,Object>());
            lstAccounts[0].type ='Property Owner';             
            insert lstAccounts;
            
            lstAccounts[0].Status__c = 'Approved';
            update lstAccounts;
            
            list<contact> lstContact = TestDataUtil.createContacts(2, false, new map<String,Object>(), lstAccounts[0].Id);
            lstContact[0].contact_type__c = 'property owner';
            insert lstContact;
            
            lstOppty = TestDataUtil.createJob(3, false, new map<String,Object>(), lstAccounts[0].Id);
            
            lstOppty[0].contact__c = lstContact[0].id;
            lstOppty[0].Project_Site_Contact_Name__c = lstContact[1].id;
          //  lstOppty[0].Insurance_Adjuster_Broker__c = lstContact[0].id;
            lstOppty[0].Primary_Account__c = 'Caller Account';
            lstOppty[0].Project_Site_Address__c = '7550 st. patrick way';
            lstOppty[0].Project_Site_Address_2__c = '';
            lstOppty[0].Project_Site_City__c = 'Dublin';
            lstOppty[0].Project_Site_State__c = 'CA';
            lstOppty[0].Project_Site_Zipcode__c = '94568';
            lstOppty[0].Project_Site_Contact_Account__c = lstAccounts[0].id;
            lstOppty[0].Project_Site_Record_Id__c = '12345';
            lstOppty[0].RecordTypeId = notApprovedId;
            lstOppty[0].Job_Name__c ='test';
            
            
            lstOppty[1].contact__c = lstContact[0].id;
            lstOppty[1].Project_Site_Contact_Name__c = lstContact[1].id;
            lstOppty[1].Insurance_Adjuster_Broker__c = lstContact[0].id;
            lstOppty[1].Primary_Account__c = 'Insurance';
            lstOppty[1].Project_Site_Address__c = '39802 cedar blve';
            lstOppty[1].Project_Site_Address_2__c = '';
            lstOppty[1].Project_Site_City__c = 'Newark';
            lstOppty[1].Project_Site_State__c = 'CA';
            lstOppty[1].Project_Site_Zipcode__c = '94560';
            lstOppty[1].Project_Site_Contact_Account__c = lstAccounts[0].id;
            lstOppty[1].RecordTypeId = approvedId;
            lstOppty[1].Job_Name__c ='test1';
            
           
            lstOppty[2].contact__c = lstContact[0].id;
            lstOppty[2].Project_Site_Contact_Name__c = lstContact[1].id;
            lstOppty[2].Insurance_Adjuster_Broker__c =null;
            lstOppty[2].Primary_Account__c = 'Insurance';
            
            lstOppty[2].Project_Site_Address_2__c = '';
            lstOppty[2].Project_Site_City__c = 'Livermore';
            lstOppty[2].Project_Site_State__c = 'CA';
            lstOppty[2].Project_Site_Zipcode__c = '94551';
            lstOppty[2].Project_Site_Contact_Account__c = lstAccounts[0].id;
            lstOppty[2].Job_Name__c ='test2';
            
            insert lstOppty;                
        }
        
        System.runAs( new User(Id = userInfo.getUserId())){
            for(ATI_Job__c opp : lstOppty){
                opp.Project_Site_City__c = 'Fremont';
            }
            lstOppty[0].RecordTypeId = approvedId;
            update lstOppty;            
        }
        
        Test.startTest();
        String outPutJson = '{"location": { "lat": 37.09024, "lng": -95.712891}}';
        Test.setMock(HttpCalloutMock.class, new MockHttpFotoIn(200, 'success', outPutJson, null));
        JobCall.syncFotoIn(lstOppty[0].id);
        JobCall.syncFotoIn(lstOppty[1].id);
        Test.stopTest();    
    }
    
    static testMethod void callFotoInUpdateProject() {
        //create Custom Settings Trigger Status
        list<ATI_Job__c> lstOppty;
        Id approvedId;
        system.runAs(new User(Id=Userinfo.getUserId())){
            Map <String, Schema.RecordTypeInfo> jobRecordTypeMap = Schema.SObjectType.ATI_Job__c.RecordTypeInfosByName;
            Id notApprovedId = Schema.SObjectType.ATI_Job__c.RecordTypeInfosByName.get('New Job (Not Approved)').RecordTypeId;
            approvedId = Schema.SObjectType.ATI_Job__c.RecordTypeInfosByName.get('Job (Approved)').RecordTypeId;
            
            TestDataUtil.createCustomSettings_TriggerStatus();
            //create Account 
            list<Account> lstAccounts = TestDataUtil.createAccounts(2, false, new map<String,Object>());
            lstAccounts[0].type ='Property Owner';             
            insert lstAccounts;
            
            lstAccounts[0].Status__c = 'Approved';
            update lstAccounts;
            
            list<contact> lstContact = TestDataUtil.createContacts(2, false, new map<String,Object>(), lstAccounts[0].Id);
            insert lstContact;
            
            lstOppty = TestDataUtil.createJob(3, false, new map<String,Object>(), lstAccounts[0].Id);
            
            lstOppty[0].contact__c = lstContact[0].id;
            lstOppty[0].Project_Site_Contact_Name__c = lstContact[1].id;
            lstOppty[0].Insurance_Adjuster_Broker__c = lstContact[0].id;
            lstOppty[0].Primary_Account__c = 'Caller Account';
            lstOppty[0].Project_Site_Address__c = '7550 st. patrick way';
            lstOppty[0].Project_Site_Address_2__c = '';
            lstOppty[0].Project_Site_City__c = 'Dublin';
            lstOppty[0].Project_Site_State__c = 'CA';
            lstOppty[0].Project_Site_Zipcode__c = '94568';
            lstOppty[0].Project_Site_Contact_Account__c = lstAccounts[0].id;
            lstOppty[0].Project_Site_Record_Id__c = '12345';
            lstOppty[0].RecordTypeId = notApprovedId;
            lstOppty[0].Job_Name__c ='test';
            
            
            lstOppty[1].contact__c = lstContact[0].id;
            lstOppty[1].Project_Site_Contact_Name__c = lstContact[1].id;
            lstOppty[1].Insurance_Adjuster_Broker__c = lstContact[0].id;
            lstOppty[1].Primary_Account__c = 'Insurance';
            lstOppty[1].Project_Site_Address__c = '39802 cedar blve';
            lstOppty[1].Project_Site_Address_2__c = '';
            lstOppty[1].Project_Site_City__c = 'Newark';
            lstOppty[1].Project_Site_State__c = 'CA';
            lstOppty[1].Project_Site_Zipcode__c = '94560';
            lstOppty[1].Project_Site_Contact_Account__c = lstAccounts[0].id;
            lstOppty[1].RecordTypeId = approvedId;
            lstOppty[1].Job_Name__c ='test1';
            
            lstOppty[2].contact__c = lstContact[0].id;
            lstOppty[2].Project_Site_Contact_Name__c = lstContact[1].id;
            lstOppty[2].Insurance_Adjuster_Broker__c =null;
            lstOppty[2].Primary_Account__c = 'Insurance';
            lstOppty[2].Project_Site_Address__c = '559 heligan ln'; 
            lstOppty[2].Project_Site_Address_2__c = '';
            lstOppty[2].Project_Site_City__c = 'Livermore';
            lstOppty[2].Project_Site_State__c = 'CA';
            lstOppty[2].Project_Site_Zipcode__c = '94551';
            lstOppty[2].Project_Site_Contact_Account__c = lstAccounts[0].id;
            lstOppty[2].Job_Name__c ='test2';
            
            insert lstOppty;                
        }
        
        System.runAs( new User(Id = userInfo.getUserId())){
            for(ATI_Job__c opp : lstOppty){
                opp.Project_Site_City__c = 'Fremont';
            }
            lstOppty[0].RecordTypeId = approvedId;
            update lstOppty;
            /*for(ATI_Job__c opp : lstOppty){
opp.StageName = 'Complete';
opp.Project_Manager__c = UserInfo.getUserId();
opp.Operations_Manager__c = UserInfo.getUserId();   
}
update lstOppty;*/
            
            //JobCall.syncFotoIn(lstOppty[0].id);
            //JobCall.syncFotoIn(lstOppty[1].id);
        }
        
        Test.startTest();
        String outPutJson = '{"location": { "lat": 37.09024, "lng": -95.712891}}';
        Test.setMock(HttpCalloutMock.class, new MockHttpFotoIn(200, 'success', outPutJson, null));
        JobCall.syncFotoIn(lstOppty[0].id);
        //JobCall.syncFotoIn(lstOppty[1].id);
        //JobUtility.callGoogleMapAPI(lstOppty[0]);
        Test.stopTest();    
    }
    
}