Public class BudgetNameFormat{

      public static void setBudgetNumbers(List<Budget__c> Budget) {
    
        // Validate preconditions
        if (Budget == null || Budget.isEmpty()) {
            System.debug(Logginglevel.INFO, 'BudgetNameFormat.setBudgetNumbers: Argument contains no Budget to process');
            return;
        }
        
        // Ignore all Budget that don't have jobs and sort Budget by job
        // number
        Map<Id, List<Budget__c>> BudgetJobBuckets = new Map<Id, List<Budget__c>>();
        for (Budget__c i : Budget) {
            if (i.ATI_Job__c!= null) {
                if (! budgetJobBuckets.containsKey(i.ATI_Job__c)) {
                    budgetJobBuckets.put(i.ATI_Job__c, new List<Budget__c>{i});
                } else {
                    budgetJobBuckets.get(i.ATI_Job__c).add(i);
                }
            }
        }
        
        // No buckets = no Budget = no work
        if (budgetJobBuckets.isEmpty()) {
            System.debug(Logginglevel.INFO, 'BudgetNameFormat.setbudgetNumbers: No valid Budget to process');
            return;
        }
        
        // Define a mapping between Job ID and job number
        Map<Id, String> jobNumbers = new Map<Id, String>();
        
        // Determine the current incremental value for each job
        AggregateResult[] maxResults = [SELECT ATI_Job__c,  ATI_Job__r.Job_Number__c jn, 
                                               MAX(Budget_Number_Incremental__c)m
                                        FROM Budget__c
                                        WHERE ATI_Job__c IN :budgetJobBuckets.keySet()
                                        GROUP BY ATI_Job__c,  ATI_Job__r.Job_Number__c];
        
        // Generate a mapping from job ID to nexts incremental
        Map<Id, Integer> budgetIncrementals = new Map<Id, Integer>();
        for (AggregateResult ar : maxResults) {
            
            // Retrieve the current incremental value
            Decimal incRaw = (Decimal) ar.get('m');
            Integer inc = (Integer) ((incRaw == null) ? 0 : incRaw.round());
            
            // Get the job information
            Id jobId = (Id) ar.get('ATI_Job__c');
            budgetIncrementals.put(jobId, inc);
            
            String jobNumber = (String) ar.get('jn');
            jobNumbers.put(jobId, jobNumber);
            
        }
        
        // Go through each of the Budget that may not have numbers yet
        Set<Id> jobIdsForFirstBudget = new Set<Id>();
        for (Id jobId : budgetJobBuckets.keySet()) {
            if (! jobNumbers.keySet().contains(jobId)) {
                jobIdsForFirstBudget.add(jobId);
            }
        }
        
        // Get information for the first Budget per job
        if (! jobIdsForFirstBudget.isEmpty()) {
            
            // Get job numbers for all of the first Budget per job
            List<ATI_Job__c> jobs = [SELECT Id, Job_Number__c FROM ATI_Job__c WHERE Id IN :jobIdsForFirstBudget];
            
            // Retain the information for the first budget per job
            for (ATI_Job__c j : jobs) {
                budgetIncrementals.put(j.Id, 0);
                jobNumbers.put(j.Id, j.Job_Number__c);
            }
            
        }
        
        // Go through each of the input jobs
        for (Id jobId : budgetJobBuckets.keySet()) {
            
            // Normalize job data from the aggregate result
            Integer bud = budgetIncrementals.get(jobId);
            String jobNumber = jobNumbers.get(jobId);
            
            System.debug('BudgetNameFormat.setbudgetNumbers: Handling Job '+jobNumber+' ['+jobId+']. Current incremental: '+bud);
            
            // Go through each of the Budget related to this job
            for (Budget__c i : budgetJobBuckets.get(jobId)) {
                
                // Check if the budget needs an incremental value
                if (i.Budget_Number_Incremental__c == null) {
                    bud += 1;
                    i.Budget_Number_Incremental__c = bud;
                }
                
                // Get the integer value of the budget incremental (while this
                // may sometimes be redundant, it is safer to do it every time)
                Integer budInc = (Integer) i.Budget_Number_Incremental__c.round();
                
                System.debug('BudgetNameFormat.setbudgetNumbers: Handling budget ['+i.Id+'] for job ['+jobId+']. Current incremental: '+budInc);
                
                // If a job number was not available, add an error
                if (jobNumber == null) {
                    i.addError('Both "Job Number" fields must be populated on the associated Job before this record can be saved.'+
                               '  Please fix the Job then re-save this budget.');
                }
                
                // Set the budget name based on the job number (no hyphens)
                // and the budget incremental
                String budgetNumber = jobNumber.replace('-','');
                budgetNumber = 'BUD-' + budgetNumber + '-' + ADCUtil_Base.forceStringLength((''+budInc), 2, '0', false);
                
                System.debug('BudgetNameFormat.setbudgetNumbers: budget number for budget ['+i.Id+'] calculated: '+budgetNumber);
                
                // Set the budget name to the new budget number
                i.Name = budgetNumber;
                
            }
        
        }
      
    }

}