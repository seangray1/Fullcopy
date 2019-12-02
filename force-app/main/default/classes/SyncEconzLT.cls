public class SyncEconzLT {
    
    public static boolean isECONZCalloutsProcessed = false;
    public static dateTime startdate = null;
    @AuraEnabled
    public static String executeJob(String jobId){
        system.debug('jobId--'+jobId);
        ATI_Job__c job = [select Id, Stage__c from ATI_Job__c where Id =: jobId];
            return Econz_Integration_Callouts.invokeIntegration(jobId);
    }
    
    public static void AfterHourEconzCall(list<ATI_Job__c> newValues){
        Id devRecordTypeId = Schema.SObjectType.ATI_Job__c.getRecordTypeInfosByName().get('Job (Approved)').getRecordTypeId();
        
        for(ATI_Job__c job : newValues){
            startdate = job.date_time_approved__c;
            if(job.RecordTypeID == devRecordTypeId && job.ECONZ_Task_Created__c == false)
                Econz_Integration_Callouts.ECONZ_Future_Call(job.Id,'addTask',null,startdate);    
        }      
        
    }
}