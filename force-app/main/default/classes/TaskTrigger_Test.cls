/**
 * @File Name          : TaskTrigger_Test.cls
 * @Description        : 
 * @Author             : sean.gray@atirestoration.com
 * @Group              : 
 * @Last Modified By   : sean.gray@atirestoration.com
 * @Last Modified On   : 7/3/2019, 1:04:30 PM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    7/3/2019, 1:04:30 PM   sean.gray@atirestoration.com     Initial Version
**/
@isTest
//Versoin 1.0
//Created by - Prabaharan Periasamy
//Date - 07/05/2016
//Tests  task trigger functionality , as upon update of one or bulk jobs objects.
//
private class TaskTrigger_Test {
   
    //tests trigger invoke on insert of single task object
   public static testMethod void testTaskInsert(){
        Account newAcct = TestDataUtil.createAccounts(1, true, 
                                                      new Map<String, Object>{ 'Name' => 'testAcct',
                                                                               'BillingStreet' => 'Street 12',
                                                                               'BillingCity' => 'San Francisco',
                                                                               'BillingCountry' => 'USA',
                                                                               'BillingPostalCode' => '1234',
                                                                               'BillingState' => 'CA' })[0];
        
        Contact newCont = TestDataUtil.createContacts(1, true, 
                                                      new Map<String, String>{ 'Accountid' => newAcct.Id,
                                                                               'LastName' => 'lname',
                                                                               'MailingStreet' => 'line1'})[0]; 
        
        Test.startTest();
        Profile pr = [ SELECT Id FROM Profile WHERE Name =: 'System Administrator' ];
        System.runas(TestDataUtil.createUsers(1, false, new Map<String, String>{ 'profileId' => pr.Id,
                                                                                 'AE_Type__c' => 'Local',
                                                                                 'ManagerId' => Userinfo.getUserId()})[0]){
            Task task = new Task( type = TaskTriggerUtility.TASK_TYPE_LUNCH_AND_LEARN, WhoId = newCont.Id, Subject = 'testing' );
            
            try{
                Database.SaveResult result = Database.insert(task);    
                system.assert(result.isSuccess());
            }catch(Exception e){
                System.debug(LoggingLevel.DEBUG ,'error while inserting task ' + e.getStackTraceString());                                                                         
            }
            
        }
        Test.stopTest();
    }
    
    


   //tests trigger invoke on update of single task object
   public static testMethod void testTaskUpdate(){
   
        Account newAcct = TestDataUtil.createAccounts(1, true, 
                                                      new Map<String, Object>{ 'Name' => 'testAcct',
                                                                               'BillingStreet' => 'Street 12',
                                                                               'BillingCity' => 'San Francisco',
                                                                               'BillingCountry' => 'USA',
                                                                               'BillingPostalCode' => '1234',
                                                                               'BillingState' => 'CA' })[0];
        
        Contact newCont = TestDataUtil.createContacts(1, true, 
                                                      new Map<String, String>{ 'Accountid' => newAcct.Id,
                                                                               'LastName' => 'lname',
                                                                               'MailingStreet' => 'line1'})[0]; 

        
        Profile pr = [ SELECT Id FROM Profile WHERE Name =: 'System Administrator' ];
        System.runas(TestDataUtil.createUsers(1, false, new Map<String, String>{ 'profileId' => pr.Id,
                                                                                 'AE_Type__c' => 'Local',
                                                                                 'ManagerId' => Userinfo.getUserId()})[0]){
            Task task = new Task( type = TaskTriggerUtility.TASK_TYPE_LUNCH_AND_LEARN, WhoId = newCont.Id, Subject = 'testing');
            
            insert task;  
                                                                                    
            try{
                task.Subject = 'subject update';
                Database.SaveResult result = Database.update(task);    
                system.assert(result.isSuccess());
            }catch(Exception e){
                System.debug(LoggingLevel.DEBUG ,'error while inserting task ' + e.getStackTraceString());                                                                         
            }
            
       
                                                                                     
                                                                                     
                                                                                
                                                                                     
                                                                                     
        }
        
    }
    
   
    //tests trigger invoke on insert of single task object
   static testMethod void testTaskInsertJob2(){
       //system.runAs(new User(Id=Userinfo.getUserId())){
       TestDataUtil.createCustomSettings_TriggerStatus();
        
        Map <String, Schema.RecordTypeInfo> jobRecordTypeMap = Schema.SObjectType.ATI_job__c.RecordTypeInfosByName;
            Id notApprovedId = Schema.SObjectType.ATI_job__c.RecordTypeInfosByName.get('New Job (Not Approved)').RecordTypeId;
            Id approvedId = Schema.SObjectType.ATI_job__c.RecordTypeInfosByName.get('Job (Approved)').RecordTypeId;
         list<Account> lstAccounts = TestDataUtil.createAccounts(2, false, new map<String,Object>());
            lstAccounts[0].type ='Property Owner';             
            insert lstAccounts;
            
            lstAccounts[0].Status__c = 'Approved';
            update lstAccounts;
            
            list<contact> lstContact = TestDataUtil.createContacts(2, false, new map<String,Object>(), lstAccounts[0].Id);
            insert lstContact;
      
       Office__c newOff = new Office__c(Name = 'Chicago');
        insert newOff;
        List<Office__c> off = new List<Office__c>([Select Id, Name FROM Office__c WHERE Name =: 'Chicago' Limit 1]);
           ATI_Job__c Jobs = new ATI_Job__c ();
       		
        	Jobs.contact__c = lstContact[0].id;
            Jobs.Project_Site_Contact_Name__c = lstContact[1].id;
            Jobs.Insurance_Adjuster_Broker__c = lstContact[0].id;
            Jobs.Primary_Account__c = 'Caller Account';
            Jobs.Project_Site_Address__c = '7550 st. patrick way';
            Jobs.Project_Site_Address_2__c = '';
            Jobs.Project_Site_City__c = 'Dublin';
            Jobs.Project_Site_State__c = 'CA';
            Jobs.Project_Site_Zipcode__c = '94568';
            Jobs.Project_Site_Contact_Account__c = lstAccounts[0].id;
            Jobs.Project_Site_Record_Id__c = '12345';
            Jobs.RecordTypeId = notApprovedId;
            Jobs.Job_Name__c ='test';
       		Jobs.Office2__c = off[0].Id;
       		Jobs.lead_Source__c = 'Program-Alacrity REO';
       		Jobs.Stage__c = 'Qualification';

       insert jobs;
      // }
        
        Test.startTest();
        Profile pr = [ SELECT Id FROM Profile WHERE Name =: 'System Administrator' ];
        System.runas(TestDataUtil.createUsers(1, false, new Map<String, String>{ 'profileId' => pr.Id,
                                                                                 'AE_Type__c' => 'Local',
                                                                                 'ManagerId' => Userinfo.getUserId()})[0]){
              List<Ati_Job__c> jobss = new List<Ati_Job__c>([Select Id FROM ATI_Job__c]);
            Task task = new Task( type = 'Project Note', WhatId = Jobss[0].Id, Subject = 'testing', description = 'Test' );
            
            try{
                Database.SaveResult result = Database.insert(task);    
                system.assert(result.isSuccess());
            }catch(Exception e){
                System.debug(LoggingLevel.DEBUG ,'error while inserting task ' + e.getStackTraceString());                                                                         
            }
                                                                                 
        }
        Test.stopTest();
    }
    

      
}