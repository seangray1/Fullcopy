public class DualDraftJobs{

    public Map<Id, Dual_Draft_Job__c> dualdraftJob;
    
    public static void DualDraftNotes(List<Dual_Draft_Job__c > dualdraft){
        
        List<Task> Addtask = new List<Task>(); 

        for(Dual_Draft_Job__c draft: [select id, Dual_Draft__c, Dual_Draft__r.Description__c, Dual_Draft_Job__c.ATI_Job__c from Dual_Draft_Job__c where id in: dualdraft]){
            
            system.debug('This is the note:' + draft.Dual_Draft__r.Description__c);
            if(draft.Dual_Draft__r.Description__c != null){  
                
                String userId = UserInfo.getUserId(); 
                Task task = new Task();
                task.OwnerId = userid;
                task.WhatId = draft.ATI_Job__c;
                task.type = 'Accounting Note';
                task.subject = 'Dual Draft Notes';
                task.ActivityDate = date.today();
                task.Description = draft.Dual_Draft__r.Description__c;
                task.Status = 'Completed';
                Addtask.add(task);
               
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