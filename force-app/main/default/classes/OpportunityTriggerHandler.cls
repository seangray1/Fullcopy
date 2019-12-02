/* @Author: Narasimha (Perficient)
* @Created: 17.MAR.2015
* @Desc: Handler class for the Opportunity Trigger
* Edited by Semira Roy on 1/19/2015 added Line 315, 317, 350, 354
Line 42 added By Nanda @ Perficient on 04/04/2017
*
*/

public without sharing class OpportunityTriggerHandler {
    
    public static TriggerStatus__c cfg = TriggerConfig.raw;
    public static String JobOwnerRole ='Job Owner';    
    
    public static void handleBeforeInsertOnly(){
        // PREVENT DUPLICATE JOB NUMBERS ON CLONE
        if (cfg.JobSetJobNumber__c && Trigger.isBefore && Trigger.isInsert) {
            System.debug(Logginglevel.INFO, 'JobTrigger: Running ATIJobControl.preventDuplicateJobNumbers...');
            ATIJobControl.preventDuplicateJobNumbers(Trigger.new);
        }
        JobAEBonusTriggerHandler.populateAEs( null, Trigger.new );  
              

    }
    
    public static void handleAfterInsertOnly(){                        
        //JobAEBonusTriggerHandler.createJobPrimaryContactRoles( null, Trigger.new );        
        JobAEBonusTriggerHandler.updateLastPreviousJobDateOnAccount( Trigger.new );
        //JobAccountAndJobContact.InsertJobAccountandJobContact(Trigger.new);
               
        //synch After Hour Leads with Econz
        Id approvedRecordTypeId = Schema.SObjectType.ATI_Job__c.getRecordTypeInfosByName().get('Job (Approved)').getRecordTypeId();
        map<Id,ATI_Job__c> newJobMap =(map<Id,ATI_Job__c>)Trigger.newMap;
        
        for(ATI_Job__c Job: newJobMap.values()){
        
            if(Job.recordtypeid == approvedRecordTypeId && !SyncEconzLT.isECONZCalloutsProcessed){
                system.debug('====Integration====');
                SyncEconzLT.AfterHourEconzCall(Trigger.new);
                SyncEconzLT.isECONZCalloutsProcessed = true;
                
            }
            system.debug('===final==='+[select ECONZ_Task_Created__c from ATI_Job__c where id =: newJobMap.keyset()][0].ECONZ_Task_Created__c );
            
            //when regular lead entry is taken, office and division is empty until they update the record.
            if(Job.office__c != null && Job.division__c != null){
                JobUtility.createFotoInProject(null, newJobMap.values());
            }
            
        }
        
    }
    
    /* handles after updates only */
    public static void handleAfterUpdatesOnly(){
        map<Id,ATI_Job__c> oldJobMap =(map<Id,ATI_Job__c>)Trigger.oldMap;
        map<Id,ATI_Job__c> newJobMap =(map<Id,ATI_Job__c>)Trigger.newMap;
        JobUtility.removeJobOwnerfromTeam( oldJobMap, Trigger.new );
        //JobAEBonusTriggerHandler.createJobPrimaryContactRoles( oldJobMap, newJobMap.values() );
        
        JobUtility.EmailUpdateOnJob(oldJobMap,Trigger.new);        
        JobAccountAndJobContact.UpdateJobAccountandJobContact(oldJobMap,Trigger.new);
        JobAEBonusTriggerHandler.updateTeamMembersOnAEChange( oldJobMap, newJobMap );        
        JobAEBonusTriggerHandler.populateAEsOnInvoices( oldJobMap, newJobMap );
        JobAEBonusTriggerHandler.populateAEsOnForecasts( oldJobMap, newJobMap );
        JobAEBonusTriggerHandler.calculateCommissions( oldJobMap, newJobMap );   
        JobUtility.createFotoInProject( oldJobMap, newJobMap.values() );
        JobUtility.updateFotoInProject( oldJobMap, newjobMap.values() );
        
        if(!Econz_Integration_Callouts.isECONZCalloutsProcessed){
        system.debug('====Integration====');
            Econz_Integration_Callouts.manageEConzCallouts(oldJobMap, newJobMap.values());
            Econz_Integration_Callouts.isECONZCalloutsProcessed = true;

        }
        system.debug('===final==='+[select ECONZ_Task_Created__c from ATI_Job__c where id =: newJobMap.keyset()][0].ECONZ_Task_Created__c );
    }
    
    public static void handleBeforeUpdatesOnly(){        
        map<Id,ATI_Job__c> oldJobMap =(map<Id,ATI_Job__c>)Trigger.oldMap;
        JobAEBonusTriggerHandler.populateAEOnApprovedJobs( oldJobMap, (map<Id,ATI_Job__c>)Trigger.newMap );
        JobAEBonusTriggerHandler.afterCreditRequestApproved( oldJobMap, (map<Id,ATI_Job__c>)Trigger.newMap );        
        JobAEBonusTriggerHandler.populateAEs( oldJobMap, Trigger.new );
        Econz_Integration_Callouts.updateOldName( oldJobMap, Trigger.new );
        //Athith Comments
        //Prepopulate the Timestamp for Date_Time_Approved__c field if the record type is Job (Approved)
        Id approvedRecordTypeId = Schema.SObjectType.ATI_Job__c.getRecordTypeInfosByName().get('Job (Approved)').getRecordTypeId();
        Id devRecordTypeId = Schema.SObjectType.ATI_Job__c.getRecordTypeInfosByName().get('New Job (Not Approved)').getRecordTypeId();
        map<Id,ATI_Job__c> newJobMap =(map<Id,ATI_Job__c>)Trigger.newMap;
        for(ATI_Job__c Job: newJobMap.values()){
        if( Job.recordtypeid != oldJobMap.get(Job.Id).recordtypeid && Job.recordtypeid == approvedRecordTypeId){
            Job.Date_Time_Approved__c = system.now();
            system.debug('===Date Time Approved==='+Job.Date_Time_Approved__c);
            }
        }
        
    }
    
    /* handles both before insert and updates */
    public static void handleBeforeInsertUpdate(){
        // Update Job Number
        if (cfg.JobSetJobNumber__c && Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
            
            map<Id,ATI_Job__c> oldMap =null;
            if(Trigger.isUpdate){
                oldMap =(map<Id,ATI_Job__c>)Trigger.oldMap;
            }
            ATIJobControl.setJobNumberSequential(Trigger.new, (Trigger.isInsert) ? null : oldMap);
            
            
            System.debug(Logginglevel.INFO, 'JobTrigger: Running ATIJobControl.recalculateJobNumbers...');
            ATIJobControl.recalculateJobNumbers(Trigger.new, (Trigger.isInsert) ? null : oldMap);
            
            System.debug(Logginglevel.INFO, 'Trigger: Running ATIJobControl.setGLAccountPrefix...');
            ATIJobControl.setGLAccountPrefix(Trigger.new);
            
        }
        
        if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
            //logic - copies the Jobs Project Manager into the Owner field
            JobUtility.ManagerToOwnerCopy((map<Id,ATI_Job__c>)Trigger.oldMap, Trigger.new);
        }
    }
    
    /* handles both After insert and updates */
    public static void handleAfterInsertUpdate(){ 
        // moving this to after update as we cannot change the Job owner on insert due to Job splits issue
        JobUtility.removeJobOwnerfromTeam((map<Id,ATI_Job__c>)Trigger.oldMap, Trigger.new);
    }
}