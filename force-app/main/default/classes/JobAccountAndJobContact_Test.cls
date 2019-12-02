@isTest
public with sharing class JobAccountAndJobContact_Test {
    static List<ATI_Job__c> lstJob;
    static list<Account> lstAccounts; 
    static list<contact> lstContact;
    
    static testMethod void testNoChanges(){
        
        testDataSetup();
        map<Id,ATI_Job__c> oldMap = new map<Id,ATI_Job__c>();
        for(ATI_Job__c Job : lstJob){
            oldMap.put(Job.id, Job);
        }
        
        JobAccountAndJobContact.UpdateJobAccountandJobContact(OldMap, lstJob);    
    
    }
    
    static testMethod void testChanges(){
        
        testDataSetup();
        
        //add the old Job to a map before change. 
        map<Id,ATI_Job__c> oldMap = new map<Id,ATI_Job__c>();
        for(ATI_Job__c Job : lstJob){
            Job.contact__c = lstContact[0].id;
            Job.Owner__c = lstAccounts[0].id;
            oldMap.put(Job.id, Job);
        }
        
        lstJob[0].contact__c = lstContact[5].id;
        lstJob[0].Account__c = lstAccounts[3].id;
        lstJob[0].Owner__c = lstAccounts[3].id;


        update lstJob;
        
        JobAccountAndJobContact.UpdateJobAccountandJobContact(oldMap, lstJob);    
    
    }
    
    static testMethod void testAllConditions(){
        
        testDataSetup();
        
        //add the old Job to a map before change. 
        map<Id,ATI_Job__c> oldMap = new map<Id,ATI_Job__c>();
        for(ATI_Job__c Job : lstJob){
            oldMap.put(Job.id, Job);
        }

            lstJob[0].contact__c = lstContact[0].id;
            lstJob[0].Project_Site_Contact_Name__c = lstContact[1].id;
            lstJob[0].Owner__c = lstAccounts[0].id;
            lstJob[0].Insurance_Adjuster_Broker__c = lstContact[5].id;
            
            lstJob[1].contact__c = lstContact[0].id;
            lstJob[1].Project_Site_Contact_Account__c = lstAccounts[1].id;
            lstJob[1].Insurance_Adjuster_Broker__c = lstContact[3].id;
            
            lstJob[2].contact__c = lstContact[0].id;
            lstJob[2].Project_Site_Contact_Name__c = lstContact[1].id;
            lstJob[2].Insurance_Adjuster_Broker__c =null;
            
            lstJob[3].Account__c = lstAccounts[6].id;
            lstJob[3].Project_Site_Contact_Account__c = lstAccounts[6].id;
            lstJob[3].Insurance_Adjuster_Broker__c =null;
            lstJob[3].Job_Name__c ='test';
            
            lstJob[4].contact__c = lstContact[0].id;
            lstJob[4].Project_Site_Contact_Name__c = lstContact[1].id;
            lstJob[4].Insurance_Adjuster_Broker__c = lstContact[0].id;
            
            lstJob[5].contact__c = lstContact[0].id;
            lstJob[5].Project_Site_Contact_Name__c = lstContact[0].id;
            lstJob[5].Insurance_Adjuster_Broker__c = lstContact[3].id;
            
            lstJob[6].contact__c = lstContact[0].id;
            lstJob[6].Project_Site_Contact_Name__c = lstContact[1].id;
            lstJob[6].Owner__c = lstAccounts[3].id;
            
            lstJob[7].Account__c = lstAccounts[3].id;
            lstJob[7].Project_Site_Contact_Account__c = lstAccounts[6].id;
            lstJob[7].Owner__c = lstAccounts[3].id;
            
            lstJob[8].contact__c = lstContact[0].id;
            lstJob[8].Project_Site_Contact_Account__c = lstAccounts[3].id;
            lstJob[8].Owner__c = lstAccounts[3].id;


        update lstJob;
        
        JobAccountAndJobContact.UpdateJobAccountandJobContact(oldMap, lstJob);    
        
    
    }

    static void testDataSetup(){
        //create Custom Settings Trigger Status
        //TestDataUtil.createCustomSettings_TriggerStatus();
        
         System.runAs(new User(Id = userinfo.getUserId())){
            TestDataUtil.createCustomSettings_TriggerStatus();
        }
        
        //create Account 
        lstAccounts = TestDataUtil.createAccounts(10, false, new map<String,Object>());
        lstAccounts[0].type ='Property Owner'; 
        insert lstAccounts;
        
        lstContact = TestDataUtil.createContacts(10, false, new map<String,Object>(), lstAccounts[0].Id);
        insert lstContact;
        
        lstJob = TestDataUtil.createJob(10, true, new Map<String, String>{'Account__c' => lstAccounts[0].Id});
                                    
        
        List<RecordType> rtypes = [SELECT Id FROM RecordType WHERE SObjectType ='ATI_Job__c' AND DeveloperName = 'Job_Approved'];

       
            
    }
}