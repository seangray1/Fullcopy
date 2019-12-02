@isTest
private class MRPcaseTriggerTest {
 static testMethod void testTaskInsert(){
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
     system.runAs(u){
         TestDataUtil.createCustomSettings_TriggerStatus();
         list<ati_job__c> job;
        list<Account> newAcct = TestDataUtil.createAccounts(2, false, new map<String,Object>());
            newAcct[0].type ='Property Owner';             
            insert newAcct;
        	newAcct[0].Status__c = 'Approved';
            update newAcct;
        list<contact> newCont = TestDataUtil.createContacts(2, false, new map<String,Object>(), newAcct[0].Id);
            insert newCont;
        Office__c off = new Office__c(Name = 'Anaheim');
         insert off;
     Id notApprovedId = Schema.SObjectType.ATI_job__c.RecordTypeInfosByName.get('New Job (Not Approved)').RecordTypeId;
    	Job = TestDataUtil.createJob(1, false, new map<String,Object>(), newAcct[0].Id);
    	Job[0].contact__c = newCont[0].id;
            Job[0].Project_Site_Contact_Name__c = newCont[0].id;
            Job[0].Insurance_Adjuster_Broker__c = newCont[0].id;
            Job[0].Primary_Account__c = 'Caller Account';
            Job[0].Project_Site_Address__c = '7550 st. patrick way';
            Job[0].Project_Site_Address_2__c = '';
            Job[0].Project_Site_City__c = 'Dublin';
            Job[0].Project_Site_State__c = 'CA';
            Job[0].Project_Site_Zipcode__c = '94568';
            Job[0].Project_Site_Contact_Account__c = newAcct[0].id;
            Job[0].Project_Site_Record_Id__c = '12345';
            Job[0].RecordTypeId = notApprovedId;
            Job[0].Job_Name__c ='test';
         	
         job[0].office2__c = off.Id;
         insert job;
         MRP_Case__c mrp = new MRP_Case__c();
        Id approvedId = Schema.SObjectType.MRP_Case__c.RecordTypeInfosByName.get('Job Issue').RecordTypeId;
        mrp.recordTypeId = approvedId;
    	mrp.Name = 'a';
    	mrp.Activity__c = 'Job Issue';
    	mrp.Job__c = job[0].id;
     insert mrp;
    	//Test.startTest();
            //MRPcaseUtility.updateNames(mrp);
        //Test.stopTest();
     }      
}
}