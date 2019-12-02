//Versoin 1.0
//Created by - Prabaharan Periasamy
//Date - 07/11/2016
//trigger for invoice line item object gets invoked on delete, insert and update actions.
//
trigger InvoiceLineItemTrigger on Invoice_Line_Item__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) 
{
    TriggerStatus__c cfg = TriggerConfig.raw;
    
    /////////////////////////////////////////////////////
    // Order change
    // This only runs when one item is changed.
    if(cfg.InvoiceLineItemAutomaticOrder__c && Trigger.isBefore && Trigger.isUpdate && !InvoiceLineItemControl.IsRunning)
    {
        System.debug(Logginglevel.WARN, 'InvoiceLineItemTrigger: Running automatic Order');
        
        InvoiceLineItemControl.setOrder(trigger.oldMap, Trigger.new); 
    }
    
    //////////////////////////////////////////////////////
    // Name Convination
    if (cfg.InvoiceLineItemAutomaticNaming__c && Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate))
    {
        System.debug(Logginglevel.WARN, 'InvoiceLineItemTrigger: Running automatic Name generation');
        
        InvoiceLineItemControl.setInvoiceName(Trigger.new);
    }
}