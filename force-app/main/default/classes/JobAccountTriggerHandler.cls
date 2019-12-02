public with sharing class JobAccountTriggerHandler {
    
    public static void JobAccountNameUpdate(List<Job_Account__c> JobAccs)
    {
    
        List<ATI_Job__c> jobs = new List<ATI_Job__c>();
        List<ATI_Job__c> jobAccountNamesUpdate =new  list<ATI_Job__c>();
        Map<Id,List<String>> jobIdjobNamesMap = new Map<id,List<String>>();
        Set<Id> jobIds = new Set<id>();
        for(Job_Account__c jobAcc : JobAccs)
        {
            if(jobAcc.ATI_Job__c!= null)
            {
                jobIds.add(jobAcc.ATI_Job__c);
            }
       
        }

        List<Job_Account__c> jobAccounts = [select id,name,Account__r.Name,ATI_Job__c from Job_Account__c where ATI_Job__c in: jobIds]; 
        jobs = [Select id,name,Job_Account_Names__c from ATI_Job__c where id in:jobIds];

              for(Job_Account__c jobAccount:jobAccounts)
              {
              
               if(jobIdjobNamesMap.containsKey(jobAccount.ATI_Job__c)) {
                  List<String> jobAccountNames = jobIdjobNamesMap.get(jobAccount.ATI_Job__c);
                  jobAccountNames.add(jobAccount.Account__r.name);
                  jobIdjobNamesMap.put(jobAccount.ATI_Job__c,jobAccountNames);
               } 
               
              else{
              
                  jobIdjobNamesMap.put(jobAccount.ATI_Job__c, new List<String>{jobAccount.Account__r.name});
              }
                  
                  
             }
        system.debug('Map values'+jobIdjobNamesMap);
             
             for(ATI_Job__c job:jobs){
             
                 if(jobIdjobNamesMap.get(job.Id)!=null){
                 
                 job.Job_Account_Names__c = string.join(jobIdjobNamesMap.get(job.Id),';'); 
                 
                 }
                 
                 else{
                 
                 job.Job_Account_Names__c = '';
                 
                 }
                 
                  
                 jobAccountNamesUpdate.add(job);
             
             }

            if(jobAccountNamesUpdate.size()>0){
                
                system.debug('@@@@'+jobAccountNamesUpdate);
            
               update jobAccountNamesUpdate;
            
            }
           
        
    }
   
}