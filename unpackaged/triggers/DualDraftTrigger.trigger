trigger DualDraftTrigger on Dual_Draft__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {

    if(Trigger.isAfter && Trigger.isUpdate){
        DualDraft.DualDraftNotes(Trigger.OldMap, Trigger.New);
    }


}