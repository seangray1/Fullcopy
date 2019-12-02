global class BatchToUpdateJobAccountNames implements Database.Batchable<sObject> {
            
    global Database.QueryLocator start(Database.BatchableContext BC) {
         
        return Database.getQueryLocator('SELECT ATI_Job__c,Id,Name,Account__r.name FROM Job_Account__c WHERE CreatedDate >= 2018-01-01T00:00:00Z');

    }
     
    global void execute(Database.BatchableContext BC, List<sobject> scope) {
           

        try {
            
            JobAccountTriggerHandler.JobAccountNameUpdate(scope);
         
        } catch(Exception e) {
            System.debug(e);
        }
         
    }   
     
    global void finish(Database.BatchableContext BC) {

  }
}