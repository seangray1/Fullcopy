/*
Version : 1.0
Company : CloudSherpas
Date : 19 AUG 2013
Author : Ma. Katrina B. Atanacio 
Description : Generic trigger for Job_Contact__c object
History : 1.0 - 19 AUG 2013 - MKBA - Created.
*/

trigger JobContactTrigger on Job_Contact__c (before insert, before update) {
    if(trigger.isBefore) { 
        if(trigger.isInsert || trigger.isUpdate) {
            //Invoke Handler class to auto-populate Account lookup  
            JobContactHandler.populateJobAccount(trigger.new); 
        }
    }
}