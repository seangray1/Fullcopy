/*
Versoin 1.0
Created by - Prabha Kalaivani Kannan
Date - 07/04/2016
Handler class for ManagerToOwnerCopy trigger on Job__c object
*/
trigger UpdateApprovedBy on Expense__c (before update) 
{
    if(Trigger.isBefore && Trigger.isUpdate)
    {
        ExpenseReportHandler.UpdateApprovedBy(trigger.new);
    }        
}