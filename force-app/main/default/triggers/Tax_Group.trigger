//Version 1.0
//create by - Prabaharan Periasamy
//trigger called when there are updates, deletes, inserts on tax group custom object.
trigger Tax_Group on Tax_Group__c (before insert, before update) 
{    
    TriggerStatus__c cfg = TriggerConfig.raw;   

    // Including the Name for Taxgroup with Timberline Id before Insert Or Update 
    if (null != cfg && cfg.TaxGroupSetName__c && 
        trigger.isBefore && (trigger.isInsert || trigger.isUpdate)) 
    {
        for (Tax_Group__c t : Trigger.new) 
        {
            t.Name = t.Timberline_Id__c;
        }
    }

    if (null != cfg && cfg.TaxGroupRefreshFromTimberline__c && 
        trigger.isBefore && (trigger.isInsert || trigger.isUpdate)) 
    {
        TaxGroupControl.taxGroupRefreshTrigger(Trigger.new);
    }
}