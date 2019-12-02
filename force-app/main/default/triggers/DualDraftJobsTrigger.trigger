trigger DualDraftJobsTrigger on Dual_Draft_Job__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
    
     if(Trigger.isAfter && Trigger.isInsert){
         DualDraftJobs.DualDraftNotes(Trigger.New);
    }

}