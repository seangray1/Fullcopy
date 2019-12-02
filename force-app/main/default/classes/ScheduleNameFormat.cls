Public class ScheduleNameFormat{

    public static void setScheduleNumbers(List<Schedule__c> Schedule) {
    
        // Validate preconditions
        if (Schedule == null || Schedule.isEmpty()) {
            System.debug(Logginglevel.INFO, 'ScheduleNameFormat.setScheduleNumbers: Argument contains no Schedule to process');
            return;
        }
        
        // Ignore all Schedule that don't have jobs and sort Schedule by job
        // number
        Map<Id, List<Schedule__c>> ScheduleJobBuckets = new Map<Id, List<Schedule__c>>();
        for (Schedule__c i : Schedule) {
            if (i.ATI_Job__c != null) {
                if (! ScheduleJobBuckets.containsKey(i.ATI_Job__c)) {
                    ScheduleJobBuckets.put(i.ATI_Job__c, new List<Schedule__c>{i});
                } else {
                    ScheduleJobBuckets.get(i.ATI_Job__c).add(i);
                }
            }
        }
        
        // No buckets = no Schedule = no work
        if (ScheduleJobBuckets.isEmpty()) {
            System.debug(Logginglevel.INFO, 'ScheduleNameFormat.setScheduleNumbers: No valid Schedule to process');
            return;
        }
        
        // Define a mapping between Job ID and job number
        Map<Id, String> jobNumbers = new Map<Id, String>();
        
        // Determine the current incremental value for each job
        AggregateResult[] maxResults = [SELECT ATI_Job__c,  ATI_Job__r.Job_Number__c jn, 
                                               MAX(Schedule_Number_Incremental__c)m
                                        FROM Schedule__c
                                        WHERE ATI_Job__c IN :ScheduleJobBuckets.keySet()
                                        GROUP BY ATI_Job__c, ATI_Job__r.Job_Number__c];
        
        // Generate a mapping from job ID to nexts incremental
        Map<Id, Integer> ScheduleIncrementals = new Map<Id, Integer>();
        for (AggregateResult ar : maxResults) {
            
            // Retrieve the current incremental value
            Decimal incRaw = (Decimal) ar.get('m');
            Integer inc = (Integer) ((incRaw == null) ? 0 : incRaw.round());
            
            // Get the job information
            Id jobId = (Id) ar.get('ATI_Job__c');
            ScheduleIncrementals.put(jobId, inc);
            
            String jobNumber = (String) ar.get('jn');
            jobNumbers.put(jobId, jobNumber);
            
        }
        
        // Go through each of the Schedule that may not have numbers yet
        Set<Id> jobIdsForFirstSchedule = new Set<Id>();
        for (Id jobId : ScheduleJobBuckets.keySet()) {
            if (! jobNumbers.keySet().contains(jobId)) {
                jobIdsForFirstSchedule.add(jobId);
            }
        }
        
        // Get information for the first Schedule per job
        if (! jobIdsForFirstSchedule.isEmpty()) {
            
            // Get job numbers for all of the first Schedule per job
            List<ATI_Job__c> jobs = [SELECT Id, Job_Number__c FROM ATI_Job__c WHERE Id IN :jobIdsForFirstSchedule];
            
            // Retain the information for the first Schedule per job
            for (ATI_Job__c j : jobs) {
                ScheduleIncrementals.put(j.Id, 0);
                jobNumbers.put(j.Id, j.Job_Number__c);
            }
            
        }
        
        // Go through each of the input jobs
        for (Id jobId : ScheduleJobBuckets.keySet()) {
            
            // Normalize job data from the aggregate result
            Integer count = ScheduleIncrementals.get(jobId);
            String jobNumber = jobNumbers.get(jobId);
            
            System.debug('ScheduleNameFormat.setScheduleNumbers: Handling Job '+jobNumber+' ['+jobId+']. Current incremental: '+count);
            
            // Go through each of the Schedule related to this job
            for (Schedule__c i : ScheduleJobBuckets.get(jobId)) {
                
                // Check if the Schedule needs an incremental value
                if (i.Schedule_Number_Incremental__c == null) {
                    count += 1;
                    i.Schedule_Number_Incremental__c = count;
                }
                
                // Get the integer value of the Schedule incremental (while this
                // may sometimes be redundant, it is safer to do it every time)
                Integer countInc = (Integer) i.Schedule_Number_Incremental__c.round();
                
                System.debug('ScheduleNameFormat.setScheduleNumbers: Handling Schedule ['+i.Id+'] for job ['+jobId+']. Current incremental: '+countInc);
                
                // If a job number was not available, add an error
                if (jobNumber == null) {
                    i.addError('Both "Job Number" fields must be populated on the associated Job before this record can be saved.'+
                               '  Please fix the Job then re-save this Schedule.');
                }
                
                // Set the Schedule name based on the job number (no hyphens)
                // and the Schedule incremental
                String ScheduleNumber = jobNumber.replace('-','');
                ScheduleNumber = 'SCH-' + ScheduleNumber + '-' + ADCUtil_Base.forceStringLength((''+countInc), 2, '0', false);
                
                System.debug('ScheduleNameFormat.setScheduleNumbers: Schedule number for Schedule ['+i.Id+'] calculated: '+ScheduleNumber);
                
                // Set the Schedule name to the new Schedule number
                i.Name = ScheduleNumber;
                
            }
        
        }
      
    }

}