// invoice trigger 
trigger InvoiceTrigger on Invoice__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
       
    TriggerStatus__c cfg = TriggerConfig.raw;
    system.debug(cfg);    
    //////////////////////////////////////////////////////
    // INVOICE NUMBER GENERATION
    if (cfg.InvoiceAutomaticInvoiceNumber__c && Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate))
    {
        System.debug(Logginglevel.WARN, 'InvoiceTrigger: Running automatic invoice number generation');
        InvoiceControl.setInvoiceNumbers(Trigger.new);
    }
    else if (! cfg.InvoiceAutomaticInvoiceNumber__c)
    {
        System.debug(Logginglevel.WARN, 'InvoiceTrigger: Skipped because InvoiceAutomaticInvoiceNumber__c is false');
    }
    
    //////////////////////////////////////////////////////
    // INVOICE TAX Group creatios
    if (cfg.InvoiceTaxGroupSetUp__c && Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate))
    {
        System.debug(Logginglevel.WARN, 'InvoiceTrigger: Running automatic tax group set up');
        InvoiceControl.setTaxGroup(Trigger.new, Trigger.oldMap);
    }
    
    //////////////////////////////////////////////////////
    // SYNC TO TIMBERLINE
    if (cfg.InvoiceSyncToTimberline__c && Trigger.isBefore && Trigger.isUpdate) 
    {
        System.debug(Logginglevel.WARN, 'InvoiceTrigger: Running sync to Timberline');
        InvoiceControl.SyncToTimberline(Trigger.newMap, Trigger.oldMap);
    }
    else if (! cfg.InvoiceSyncToTimberline__c)
    {
        System.debug(Logginglevel.WARN, 'InvoiceTrigger: Skipped because InvoiceSyncToTimberline__c is false');
    }     
}