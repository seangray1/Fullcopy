/* This trigger is for inserting all the related ATI jobs on the current ATI job to cloned related ATI job */
trigger CloneRelatedATIJob on ATI_Job__c (after insert) {
    set<Id> parentJob = new set<Id>(); 
    List<Related_ATI_Job__c> insertRelatedJobs = new List<Related_ATI_Job__c>();
    /* This trigger will fire only when we insert ATI Job record */
    
    
    for(ATI_Job__c Job : Trigger.New){
        /* This trigger will fire only when the ATI Job record is cloned ATI Job */
        if(Job.IsCloned__c == true && String.isNotBlank(job.Parent_Job__c)){
            parentJob.add(Job.Parent_Job__c);
        }
    }
    system.debug('parentJob---'+parentJob);
    
    Map<Id,List<Related_ATI_Job__c>> rltdJobMap = new Map<Id,List<Related_ATI_Job__c>>();
    if(!parentJob.isEmpty() && parentJob!=null){
    for(Related_ATI_Job__c rltdJob : [select Cloned_ATI_Job__c, ATI_ParentJob__c from Related_ATI_Job__c where ATI_ParentJob__c =: parentJob]){
        if( rltdJobMap.containsKey( rltdJob.ATI_ParentJob__c) ){
            rltdJobMap.get( rltdJob.ATI_ParentJob__c).add( rltdJob );
        }
        else{
            rltdJobMap.put(rltdJob.ATI_ParentJob__c, new List<Related_ATI_Job__c>{rltdJob} );
        }
    }
    
    system.debug('rltdJobMap--'+rltdJobMap.values());
    
    for(ATI_Job__c Job : Trigger.New){
        if(Job.IsCloned__c == true){
            /* Insert the current ATI Job to cloned related ATI Job */
            Related_ATI_Job__c relatedParentJob = new Related_ATI_Job__c();
            relatedParentJob.ATI_ParentJob__c = Job.Id;
            relatedParentJob.Cloned_ATI_Job__c = Job.Parent_Job__c;
            insertRelatedJobs.add(relatedParentJob);  
            /* Inserting all the related ATI Jobs on the current ATI Job to cloned ATI Job*/  
            system.debug('size'+rltdJobMap.get(job.Parent_Job__c));
            if(rltdJobMap.containskey(job.Parent_Job__c)){
            for(Related_ATI_Job__c rltedJob : rltdJobMap.get(job.Parent_Job__c)){
                Related_ATI_Job__c newrelatedJob = new Related_ATI_Job__c();
                newrelatedJob.ATI_ParentJob__c = Job.Id;
                newrelatedJob.Cloned_ATI_Job__c = rltedJob.Cloned_ATI_Job__c;
                insertRelatedJobs.add(newrelatedJob);
            }
        }
    }
    }
    }

    system.debug('insertRelatedJobs---'+insertRelatedJobs.size());
    if(!insertRelatedJobs.isEmpty() && insertRelatedJobs!=null)
    insert insertRelatedJobs;  
}