public class DualDraft{

    public Map<Id, Dual_Draft_Job__c> dualdraftJob;
    
    public static void DualDraftNotes(Map<id, Dual_Draft__c> olddraftMap, List<Dual_Draft__c> dualdraft){
        
        set<ID> DualDraftID = new set<ID>();
        for(dual_Draft__c draft: dualdraft){
            Dual_Draft__c OldDraft = oldDraftMap.get(draft.id);
            if(Olddraft.Description__c != draft.Description__c )
                DualDraftID.add(draft.id);
        }
        
       // List<Dual_Draft_Job__c> DraftJobs = new List<Dual_Draft_Job__c>();
        set<ID> JobId = new set<ID>();
        
        if(!DualDraftID.isEmpty())
        {
            //Map<id, Dual_Draft_Job__c > DraftJobMap = new Map<id, Dual_Draft_Job__c >(]);
            
            for(Dual_Draft_Job__c DraftJobs: [select  ATI_Job__c from Dual_Draft_Job__c where Dual_Draft__c In: DualDraftID]){
                
                JobId.add(draftJobs.ATI_Job__c);                
            }
        }
        
        List<Task> Addtask = new List<Task>();
        
        for(Dual_Draft__c DDraft: dualdraft){
        
            if(DDraft.Description__c != null){
                if(!jobID.isEmpty()){  
                    for(Id i: JobId){   
                        String userId = UserInfo.getUserId(); 
                        Task task = new Task();
                        task.OwnerId = userid;
                        task.WhatId = i;
                        task.type = 'Accounting Note';
                        task.subject = 'Dual Draft Notes';
                        task.ActivityDate = date.today();
                        task.Description = DDraft.Description__c;
                        task.Status = 'Completed';
                        Addtask.add(task);
                     }
                }    
            
            }
        
        }
        
        insert Addtask;
        
        
        //pass the suvery through the method.
        //check if statement to see list is empty. 
        //run soql to fetch the job id in a set (no duplicate)
        
        //run a loop through the dualdraft
        //add a list of task with job ID
        //insert the list. 
    }


}