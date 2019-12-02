trigger BillingForecastTrigger on Forecast__c ( after insert, after update,before delete) {

   
    if(trigger.isBefore && trigger.isDelete)
    {
        AccountExecutiveController.AccountExecutiveRevenueRecordDeletion(trigger.old);
        
    }
    
    if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate))
    {
        AccountExecutiveController.AccountExecutiveBillingForecastInsertHandler(trigger.new);
        
    }
    
    
    
}