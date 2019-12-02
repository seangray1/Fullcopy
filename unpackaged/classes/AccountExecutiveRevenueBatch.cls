global class AccountExecutiveRevenueBatch implements Database.Batchable<sObject> {
            
    global Database.QueryLocator start(Database.BatchableContext BC) {
         
        return Database.getQueryLocator('SELECT Account_Executive_1__c,Account_Executive__c,Id FROM ATI_Job__c WHERE CreatedDate >= 2018-01-01T00:00:00Z');

    }
     
    global void execute(Database.BatchableContext BC, List<sobject> scope) {
           

        try {
            
            AccountExecutiveController.UpdateForecastAccountExecutiveRecord(scope);
         
        } catch(Exception e) {
            System.debug(e);
        }
         
    }   
     
    global void finish(Database.BatchableContext BC) {

  }
}