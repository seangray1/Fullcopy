public class SyncFotoInLT {
    
     @AuraEnabled
    public static String executeJob(String jobId){
        ATI_Job__c job = [select Id, Stage__c from ATI_Job__c where Id =: jobId];
        if (job.Stage__c != 'Work Complete' || job.Stage__c != 'Billing Complete' || job.Stage__c != 'Lost'){
            return JobCall.syncFotoIn(jobId);
        } 
        return null;
    }

}