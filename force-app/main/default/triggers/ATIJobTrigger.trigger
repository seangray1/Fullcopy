trigger ATIJobTrigger on ATI_Job__c (before insert, before update,
                                     after insert,after update,
                                     before delete) {
                                         List<Profile> profileName = [SELECT Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
                                         if(profileName[0].Name != 'Restricted Process Execution')
                                         {
                                             if(TriggerFlagController.flag == true) {
                                             if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
                                                 JobTriggerHandler.handleBeforeInsertUpdate();
                                                 system.debug('The before Update Insert is called');
                                             }}
                                             if(TriggerFlagController.flag == true) {
                                             if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
                                                 JobTriggerHandler.handleAfterInsertUpdate();
                                                 system.debug('The after Update Insert is called');
                                             }}
                                             if(TriggerFlagController.flag == true) {
                                             if(Trigger.isBefore && Trigger.isInsert){
                                                 JobTriggerHandler.handleBeforeInsertOnly();
                                                 system.debug('The before Insert is called');
                                             }}
                                             if(TriggerFlagController.flag == true) {
                                             if(Trigger.isBefore && Trigger.isUpdate){
                                                 JobTriggerHandler.handleBeforeUpdatesOnly();
                                                system.debug('The before Update is called');
                                             }}
                                             if(TriggerFlagController.flag == true) {
                                             if(Trigger.isAfter && Trigger.isInsert){
                                                 JobTriggerHandler.handleAfterInsertOnly();
                                                 //TriggerFlagController.flag = false;
                                                 system.debug('The after Insert is called');
                                             }}
                                             if(TriggerFlagController.flag == true) {
                                             if(Trigger.isAfter && Trigger.isUpdate ){
                                                 TriggerFlagController.flag = false;
                                                 JobTriggerHandler.handleAfterUpdatesOnly();
                                                 system.debug('The after Update is called');
                                             } }   
                                              
                                             if(Trigger.isBefore && (Trigger.isDelete)){
                                                 JobTriggerHandler.handleBeforeDelete();
                                                 system.debug('The delete is called');
                                             }          
                                     }
                                    }