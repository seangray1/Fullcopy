global class BatchToUpdateAEBonusOnForecasts implements Database.batchable<SObject>{

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, AE1_Bonus__c, AE2_Bonus__c, Invoice_Date__c, ATI_Job__c, Revenue_Amount__c FROM Forecast__c '+
            		   ' WHERE Invoice_Date__c = THIS_YEAR OR Invoice_Date__c = NEXT_YEAR';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Forecast__c> scope) {
        if( !scope.isEmpty() ){
            BillingForecastTriggerUtility.populateAEsOnForecasts(scope);
            update scope;
        }
    }   

    global void finish(Database.BatchableContext BC) {
    }
}