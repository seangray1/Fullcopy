/*
* Generic trigger for Budget__c 
*/
trigger BudgetTrigger on Budget__c ( before insert, before update,after insert,after update,before delete) 
{
        
    //  custom start
    // Defining the operation here.
    // We need to identify which Opportunities we want to make change/trigger.  work with all insert and/Or all update and/or all delete etc

    if (Trigger.isBefore && Trigger.IsInsert)
    {
        system.debug('Before Insert gets called');
            BudgetFieldUpdate.BudgetFieldUpdate( trigger.new );
            BudgetNameFormat.setBudgetNumbers(trigger.new);
    }
    if (Trigger.isafter && Trigger.IsInsert)
    {
        BudgetPreviousVersion.VersionUpdatE(trigger.new);
        BudgetFieldUpdate.AlertPmNewBudget(trigger.new);
        system.debug('after insert is called');
    }
   if (Trigger.isBefore && (Trigger.isUpdate || Trigger.isInsert))
    {
         BudgetFieldUpdate.UpdateSalesTax(trigger.new);
    }
     if (Trigger.isBefore && Trigger.isUpdate){
         BudgetFieldUpdate.BudgetFieldUpdate2(Trigger.new);
        
     }
     if (Trigger.isAfter && Trigger.isUpdate){
         BudgetFieldUpdate.UpdateFinancialGP(Trigger.new, Trigger.oldMap);
         BudgetFieldUpdate.deleteBudgetLineItems(Trigger.new, Trigger.oldMap);
     }
}