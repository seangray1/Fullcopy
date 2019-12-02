trigger ContractTrigger on Contract ( after insert, after update ) {
    
    if( trigger.isInsert && trigger.isAfter ){
        ContractTriggerUtility.afterContractInsert( trigger.new );
    }
    
    if( trigger.isUpdate && trigger.isAfter ){
        ContractTriggerUtility.afterContractUpdate( trigger.oldMap, trigger.new );
    }
}