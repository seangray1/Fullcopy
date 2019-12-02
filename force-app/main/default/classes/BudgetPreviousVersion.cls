public without sharing class BudgetPreviousVersion {
    public static TriggerStatus__c cfg = TriggerConfig.raw;

    public static void VersionUpdate(list<Budget__c> budget){
        
        Set<Id> jobIds = new Set<Id>(); 
        List<Id> budgetId = new List<Id>();

        for(Budget__c b: budget){
            
            budgetId.add(b.Id);
            
            if(b.ATI_Job__c != null){ 
                jobIds.add(b.ATI_Job__c);
                
            }
        }
        
        
       List<ATI_Job__c> JobList = new List<ATI_Job__c>([select id, (Select id, previous_version__c, CreatedDate From Budgets__r where previous_version__c = false order by createddate DESC) from ATI_Job__c where id in:jobIds]);
        
       List<budget__c> listb = new list<budget__c>();
       integer count = 0;
        For(ATI_Job__c job : JobList){
        
            Boolean FoundRecent = false;
            for(Budget__c bud: job.Budgets__r){
            
                if(FoundRecent == false){
                    FoundRecent = true;
                    system.debug('This is the first false: '+foundRecent);
                }
                else{
                    bud.previous_version__c = true; 
                    system.debug('This is the previous: '+bud.previous_version__c);
                }
                
                listb.add(bud);
                count++;
                system.debug('This is the count: '+count);
            }
            update listb;
        }  


    } 
}