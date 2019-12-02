/**
 * @File Name          : ProjectNameFormat.cls
 * @Description        : 
 * @Author             : sean.gray@atirestoration.com
 * @Group              : 
 * @Last Modified By   : Sean Gray
 * @Last Modified On   : 10/6/2019, 1:18:35 PM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    8/23/2019, 1:16:17 PM   sean.gray@atirestoration.com     Initial Version
**/
public class ProjectNameFormat {

    public static void setProjectNumbers(List<Project__c> Project) {
    
        // Validate preconditions
        // if (Project == null || Project.isEmpty()) {
        //     System.debug(Logginglevel.INFO, 'ScheduleNameFormat.setScheduleNumbers: Argument contains no Schedule to process');
        //     return;
        // }
        
        // // Ignore all Schedule that don't have jobs and sort Schedule by job
        // // number
        // Map<Id, List<inspire1__Project__c>> ProjectJobBuckets = new Map<Id, List<inspire1__Project__c>>();
        // for (inspire1__Project__c i : Project) {
        //     if (i.ATI_Job__c != null) {
        //         if (! ProjectJobBuckets.containsKey(i.ATI_Job__c)) {
        //             ProjectJobBuckets.put(i.ATI_Job__c, new List<inspire1__Project__c>{i});
        //         } else {
        //             ProjectJobBuckets.get(i.ATI_Job__c).add(i);
        //         }
        //     }
        // }
        
        // // No buckets = no Schedule = no work
        // if (ProjectJobBuckets.isEmpty()) {
        //     System.debug(Logginglevel.INFO, 'ScheduleNameFormat.setScheduleNumbers: No valid Schedule to process');
        //     return;
        // }
        
        // // Define a mapping between Job ID and job number
        // Map<Id, String> jobNumbers = new Map<Id, String>();
        
        // // Determine the current incremental value for each job
        // AggregateResult[] maxResults = [SELECT ATI_Job__c,  ATI_Job__r.Job_Number__c jn, 
        //                                        MAX(Project_Number_Incremental__c)m
        //                                 FROM inspire1__Project__c
        //                                 WHERE ATI_Job__c IN :ProjectJobBuckets.keySet()
        //                                 GROUP BY ATI_Job__c, ATI_Job__r.Job_Number__c];
        
        // // Generate a mapping from job ID to nexts incremental
        // Map<Id, Integer> ProjectIncrementals = new Map<Id, Integer>();
        // for (AggregateResult ar : maxResults) {
            
        //     // Retrieve the current incremental value
        //     Decimal incRaw = (Decimal) ar.get('m');
        //     Integer inc = (Integer) ((incRaw == null) ? 0 : incRaw.round());
            
        //     // Get the job information
        //     Id jobId = (Id) ar.get('ATI_Job__c');
        //     ProjectIncrementals.put(jobId, inc);
            
        //     String jobNumber = (String) ar.get('jn');
        //     jobNumbers.put(jobId, jobNumber);
            
        // }
        
        // // Go through each of the Schedule that may not have numbers yet
        // Set<Id> jobIdsForFirstProject = new Set<Id>();
        // for (Id jobId : ProjectJobBuckets.keySet()) {
        //     if (! jobNumbers.keySet().contains(jobId)) {
        //         jobIdsForFirstProject.add(jobId);
        //     }
        // }
        
        // // Get information for the first Schedule per job
        // if (! jobIdsForFirstProject.isEmpty()) {
            
        //     // Get job numbers for all of the first Schedule per job
        //     List<ATI_Job__c> jobs = [SELECT Id, Job_Number__c FROM ATI_Job__c WHERE Id IN :jobIdsForFirstProject];
            
        //     // Retain the information for the first Schedule per job
        //     for (ATI_Job__c j : jobs) {
        //         ProjectIncrementals.put(j.Id, 0);
        //         jobNumbers.put(j.Id, j.Job_Number__c);
        //     }
            
        // }
        
        // // Go through each of the input jobs
        // for (Id jobId : ProjectJobBuckets.keySet()) {
            
        //     // Normalize job data from the aggregate result
        //     Integer count = ProjectIncrementals.get(jobId);
        //     String jobNumber = jobNumbers.get(jobId);
            
        //     System.debug('ScheduleNameFormat.setScheduleNumbers: Handling Job '+jobNumber+' ['+jobId+']. Current incremental: '+count);
            
        //     // Go through each of the Schedule related to this job
        //     for (inspire1__Project__c i : ProjectJobBuckets.get(jobId)) {
                
        //         // Check if the Schedule needs an incremental value
        //         if (i.Project_Number_Incremental__c == null) {
        //             count += 1;
        //             i.Project_Number_Incremental__c = count;
        //         }
                
        //         // Get the integer value of the Schedule incremental (while this
        //         // may sometimes be redundant, it is safer to do it every time)
        //         Integer countInc = (Integer) i.Project_Number_Incremental__c.round();
                
        //         System.debug('ScheduleNameFormat.setScheduleNumbers: Handling Schedule ['+i.Id+'] for job ['+jobId+']. Current incremental: '+countInc);
                
        //         // If a job number was not available, add an error
        //         if (jobNumber == null) {
        //             i.addError('Both "Job Number" fields must be populated on the associated Job before this record can be saved.'+
        //                        '  Please fix the Job then re-save this Schedule.');
        //         }
                
        //         // Set the Schedule name based on the job number (no hyphens)
        //         // and the Schedule incremental
        //         String ProjectNumber = jobNumber.replace('-','');
        //         ProjectNumber = 'PRO-' + ProjectNumber + '-' + ADCUtil_Base.forceStringLength((''+countInc), 2, '0', false);
                
        //         System.debug('ScheduleNameFormat.setScheduleNumbers: Schedule number for Schedule ['+i.Id+'] calculated: '+ProjectNumber);
                
        //         // Set the Schedule name to the new Schedule number
        //         i.Name = ProjectNumber;
                
        //     }
        
        // }
      
    }


}