trigger MRPcaseTrigger on MRP_Case__c (before insert) {
                                         
                                             
        MRPcaseTriggerHandler.MRPcaseTriggerHandler();
        system.debug('The before Update Insert is called');
                                             

}