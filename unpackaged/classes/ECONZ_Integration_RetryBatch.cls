//ECONZ_Integration_RetryBatch

global class ECONZ_Integration_RetryBatch implements Database.Batchable<SObject>,Database.AllowsCallouts{
    global string strQuery;
    
    global ECONZ_Integration_RetryBatch(string condition){
        strQuery = 'SELECT Id FROM ATI_Job__c WHERE (ECONZ_Integration_Error__c = true AND Job_Start_Date__c != NULL) OR (Job_Start_Date__c != NULL AND ECONZ_Task_Created__c = false AND Stage__c = \'Won\')';
                        system.debug('----Query---'+strQuery);

        if(!string.isEmpty(condition))
            strQuery = strQuery +  ' AND ' + condition;
    }
    
    global database.Querylocator start(Database.batchableContext bc){   
                system.debug('----Query---'+strQuery);

        return Database.getQueryLocator(strQuery);
    }
            
    global void execute(Database.BatchableContext BC, list<ATI_JOb__c> sobjlist){ 
        for(ATI_Job__c obj : sobjlist){
            //ATI_Job__c Job = (ATI_Job__c) obj;
            if(!Test.isRunningTest())
                Econz_Integration_Callouts.invokeIntegration(obj.Id);
        }
    }
                
    global void finish(Database.BatchableContext BC){ 
                        
    }

}