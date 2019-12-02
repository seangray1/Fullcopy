trigger JobAccountTrigger on Job_Account__c (after insert,after update,after delete) {
    
    if(trigger.isafter &&(trigger.isinsert || trigger.isupdate))
    {
        JobAccountTriggerHandler.JobAccountNameUpdate(trigger.new);
    }
    if(trigger.isafter && trigger.isdelete)
    {
        JobAccountTriggerHandler.JobAccountNameUpdate(trigger.old);
    }

}