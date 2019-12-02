trigger FinancialTrigger on Financial__c (before delete) {
    
    for(financial__c finan:trigger.old)
    {
        if(string.isnotblank(finan.ATI_Job__c))
        {
           finan.addError('Financial record cannot be deleted while parent is available'); 
        }
        
    }

}