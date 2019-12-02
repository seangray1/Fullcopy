global class BatchSyncFotoIn implements Database.Batchable<Sobject>{
    
    //get the list of Jobs where id is not null and Call Result Message is not null 
    global final List<ATI_Job__c> job;
    
    global BatchSyncFotoIn(List<ATI_Job__c> Jobs){
        job = jobs;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        // String query = [Select ID from ATI_Job__c where id in : job]; 
        return Database.getQueryLocator([Select ID from ATI_Job__c where id in : job]);
    }
    
    global void execute(Database.BatchableContext bc, List<ATI_Job__c> scope){
        
        set<id> jobId = new set<id>();
        for (Integer i=0;i<job.size();i++)
        {
            jobID.add(job[i].id);
        }
        if(!JobId.isEmpty() && System.isFuture())
        {
            JobUtility.callFotoIn2Create(JobId);
        }
    }
    
    global void finish(Database.BatchableContext bc){
        
    }
}