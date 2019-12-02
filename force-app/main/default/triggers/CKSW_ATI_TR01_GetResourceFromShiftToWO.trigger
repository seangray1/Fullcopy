/*
* Trigger for CKSW_BASE__Shift__c - s.jeyarammoorthy - 6/28/2016 
*/
trigger CKSW_ATI_TR01_GetResourceFromShiftToWO on CKSW_BASE__Shift__c (after insert, after update, before insert) {
    
    if(Trigger.isInsert && Trigger.isBefore){
        CKSW_ATI_TR01_GetResFromShiftToWOUtil.CKSWInsert(Trigger.new, Trigger.oldMap);
    }
    else if(Trigger.isUpdate && Trigger.isAfter){
        CKSW_ATI_TR01_GetResFromShiftToWOUtil.CKSWUpdate(Trigger.new, Trigger.oldMap);
    }
  }