/*
Version : 2.0
Company : CloudSherpas
Date : 19 AUG 2013
Author : Ma. Katrina B. Atanacio 
Description : Test class for JobContactHandler class
History : 1.0 - 19 AUG 2013 - MKBA - Created.
          2.0 - 1 JULY 2016 - s.jeyarammoorthy modified
*/

@isTest
private class JobContactHandler_Test {
    static testMethod void testPopulateJobAccount(){
        //create custom setting TriggerStatus__c;
        
        TriggerStatus__c newTriggerStatus = new TriggerStatus__c ();
        newTriggerStatus.JobSetJobNumber__c = true;
        insert newTriggerStatus;
        
        //Create test Account 
        List<Account> lstAccount = TestDataUtil.createAccounts(1, true, new Map<String, String>());
        
        
        //Create test Contact 
        //Following TestDataUtil method doesnt return any contacts
        //List<Contact> lstContact = TestDataUtil.createContacts(1, true, new Map<String, String>(), lstAccount[0].id);
        Contact testContactObj = new Contact(); 
        testContactObj.AccountId =  lstAccount[0].id; 
        testContactObj.LastName = 'Test'; 
        insert testContactObj; 
         
        //Create test Job
        List<ATI_Job__c> testJobObj= TestDataUtil.createJob(3, false, new map<String,Object>(), lstAccount[0].Id);
       
        
        //Create test Job Contact 
        Test.StartTest();
            try{
                List<Job_Contact__c> lstJobContactObj = new List<Job_Contact__c>();
                for(Integer i=0; i<50;i++){
                    Job_Contact__c testJobContactObj = new Job_Contact__c(); 
                    testJobContactObj.Contact__c = testContactObj.Id; 
                    lstJobContactObj.add(testJobContactObj);
                }
                List<Database.SaveResult> results = Database.insert(lstJobContactObj, false);
                for(Database.SaveResult result : results){
                   system.assert(result.isSuccess()); 
                }
            }catch (Exception e){
                system.debug(LoggingLevel.DEBUG, 'error while inserting trigger status'+ e.getStackTraceString());
            }
            Test.StopTest();
    }
}