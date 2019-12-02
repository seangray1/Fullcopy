/*
*   Trigger on Expense_Line_Item__c - s.jeyarammoorthy - 6/28/2016 
*/
trigger UpdateAmountOnLineItem on Expense_Line_Item__c (after update, before delete, after delete) {
    
    if(trigger.Isupdate && trigger.IsAfter){
        UpdateAmountOnLineItemUtil.UpdateOperations(Trigger.oldMap, Trigger.newMap);
    }
    if(trigger.isDelete ){
        UpdateAmountOnLineItemUtil.deleteOperations(Trigger.old);
    }
    
}