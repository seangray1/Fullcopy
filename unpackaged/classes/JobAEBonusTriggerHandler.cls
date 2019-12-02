public without sharing class JobAEBonusTriggerHandler {

    public static final string Job_CREDIT_REQ_STATUS = 'Approved';
    public static final string PROFILE_MARKETING_REP = 'Marketing Representative';
    public static final string Job_TEAM_ROLE_ACC_EXEC1 = 'Account Executive 1';
    public static final string Job_TEAM_ROLE_ACC_EXEC2 = 'Account Executive 2';
    public static final string TASK_TYPE_LUNCH_LEARN = 'Lunch and Learn';
    public static final string Job_RTYPE_JOB_APPROVED_DEV_NAME = 'Job_Approved';
    
   @testvisible private static string getCurrentQuarter(){
        Date todaysDate = Date.today();
        return getCurrentQuarter( todaysDate );
    }
    
    public static string getCurrentQuarter( Date currentDate ){
        if( currentDate.month() <= 3 ){
            return 'Q1';
        }
        else if( currentDate.month() > 3 && currentDate.month() <= 6 ){
            return 'Q2';
        }
        else if( currentDate.month() > 6 && currentDate.month() <= 9 ){
            return 'Q3';
        }
        else {
            return 'Q4';
        }
    }
    
   @testvisible private static Map<Id, List<Invoice__c>> getRelatedInvoices( Set<Id> jobIds ){
        Map<Id, List<Invoice__c>> invoicesMap = new Map<Id, List<Invoice__c>>();
        for( Invoice__c inv : [ SELECT Id, ATI_Job__c FROM Invoice__c WHERE ATI_Job__c IN: jobIds ] ){
            if( invoicesMap.containsKey( inv.ATI_Job__c) ){
                invoicesMap.get( inv.ATI_Job__c).add( inv );
            }else{
                invoicesMap.put( inv.ATI_Job__c, new List<Invoice__c>{ inv } );
            }
        }
        return invoicesMap;
    }
    
   @testvisible private static Map<Id, List<Forecast__c>> getRelatedForecasts( Set<Id> jobIds ){
        Map<Id, List<Forecast__c>> forecastsMap = new Map<Id, List<Forecast__c>>();
        for( Forecast__c f : [ SELECT Id, ATI_Job__c FROM Forecast__c WHERE ATI_Job__c IN: jobIds ] ){
            if( forecastsMap.containsKey( f.ATI_Job__c) ){
                forecastsMap.get( f.ATI_Job__c).add( f );
            }else{
                forecastsMap.put( f.ATI_Job__c, new List<Forecast__c>{ f } );
            }
        }
        return forecastsMap;
    }
    
    public static void afterCreditRequestApproved( Map<Id, ATI_Job__c> oldJobsMap, Map<Id, ATI_Job__c> newJobsMap ){
        Set<String> creditReqEmails = new Set<String>();
        try{            
            for( ATI_Job__c job : newJobsMap.values() ){
                ATI_Job__c oldJob = oldJobsMap.get( job.Id );
                if( job.Credit_Request_Status__c != oldJob.Credit_Request_Status__c && 
                   job.Credit_Request_Status__c == Job_CREDIT_REQ_STATUS ){
                       if( job.Credit_Request_Submitter_Email__c != null ){
                           creditReqEmails.add( job.Credit_Request_Submitter_Email__c );        
                       }
                   }
            }
            if( !creditReqEmails.isEmpty() ){
                Map<String, Id> userEmailToId = new Map<String, Id>();
                for( User u : [ SELECT Id, Email FROM User WHERE Email IN : creditReqEmails] ){
                    userEmailToId.put( u.email, u.id );
                }
                for( ATI_Job__c job : newJobsMap.values() ){
                    ATI_Job__c oldJob = oldJobsMap.get( job.Id );
                    if( job.Credit_Request_Status__c != oldJob.Credit_Request_Status__c && 
                       job.Credit_Request_Status__c == Job_CREDIT_REQ_STATUS && job.Credit_Request_Submitter_Email__c != null ){
                           Id currentUserId = userEmailToId.get( job.Credit_Request_Submitter_Email__c );    
                           //If there is already an AE 1 associated with that job that the requester is requesting credit for, 
                           //instead of wiping all AE's out we would add the requester as AE 2 and set both AE 1 and AE 2 to a 50% split. 
                           if( job.Account_Executive_1__c != null && job.Account_Executive_2__c == null && 
                              job.Account_Executive_1__c != currentUserId ){
                                  job.Account_Executive_2__c = currentUserId; 
                              }else if( job.Account_Executive_2__c != null && job.Account_Executive_1__c == null && 
                                       job.Account_Executive_2__c != currentUserId ){
                                           job.Account_Executive_1__c = currentUserId; 
                                       }else if( job.Account_Executive_1__c == null && job.Account_Executive_2__c == null ){
                                           //If there is not an AE 1, then the Requester is added as the AE 1 with a 100% split (as is happening now)
                                           job.Account_Executive_1__c = currentUserId;
                                       }else if( job.Account_Executive_1__c != null && job.Account_Executive_2__c != null &&
                                                job.Account_Executive_1__c != currentUserId ){
                                                    //If there is already an AE 1 and an AE 2 on a job and someone requests credit, 
                                                    //then it gives them an error(already an AE1 And AE 2 assigned, please contact the Marketing Manager etc.)
                                                    job.addError( 'You may not request credit for a job with 2 AE\'s assigned. Please contact Marketing Manager'+
                                                                 ' for assistance' );
                                                }
                       }
                }            
            }
        }catch( DmlException ex ){
            system.debug( ex.getMessage() );            
        }
    }
    
    
    /*
* • When a Job is created, the associated Contact’s owner should be added into the 
* ‘Account Executive 1’ lookup field, IF that user’s profile is Marketing Representative
o   That same user populated into ‘Account Executive 1’ lookup field, 
should then be created as Job Team (ATI_Job__c Team) Member with the role of ‘Account Executive 1’
o   This user should then be created as an ATI_Job__c Split Member with a Split Type of ‘Revenue.’  If there is no Account Executive 2 (explained below), then the Split should be set to 100%.  If there is an Account Executive 2, then the Split should be set to 50%.
o   A user should have the option to manually change the Account Executive 1 lookup field, which will then delete the associated ATI_Job__c Team and ATI_Job__c Split Member and add the updated person as the ATI_Job__c Team and ATI_Job__c Split Member.
o   A user should also have the option to manually edit/delete the ATI_Job__c Percentages
*/
   @testvisible private static Map<Id, Contact> getJobContacts( List<ATI_Job__c> jobs ){
        Set<Id> contactIds = new Set<Id>();
        Map<Id, Contact> contactsMap;
        for( ATI_Job__c job : jobs ){
            if( job.Contact__c != null ){
                contactIds.add( job.Contact__c );
            }
        }
        if( !contactIds.isEmpty() ){
            contactsMap = new Map<Id, Contact>(
                [ SELECT Id, OwnerId 
                 FROM Contact
                 WHERE Id IN : contactIds AND Owner.Profile.Name =: PROFILE_MARKETING_REP ]);            
        }
        return contactsMap;
    }
    
   @testVisible private static Map<Id, Account> getJobAccounts( List<ATI_Job__c> jobs ){
        Set<Id> accountIds = new Set<Id>();
        Map<Id, Account> accountsMap;
        for( ATI_Job__c job : jobs ){
            if( job.Account__c != null ){
                accountIds.add( job.Account__c );
            }
        }
        if( !accountIds.isEmpty() ){
            accountsMap = new Map<Id, Account>([ SELECT Id, OwnerId
                                                FROM Account 
                                                WHERE Id IN :accountIds AND Owner.Profile.Name =: PROFILE_MARKETING_REP ]);
        }
        return accountsMap;
    }
    
    public static void populateAEOnApprovedJobs( Map<Id, ATI_Job__c> oldJobsMap, Map<Id, ATI_Job__c> newJobsMap ){
        List<ATI_Job__c> jobs = new List<ATI_Job__c>();
        List<RecordType> rtypes = [ SELECT Id FROM RecordType 
                                   WHERE DeveloperName =: 'Job_Approved' 
                                   AND SobjectType = 'ATI_Job__c' ];
        system.debug('1234'+rtypes);
        if( !rtypes.isEmpty() ){            
            for( ATI_Job__c job : newJobsMap.values() ){
                ATI_Job__c oldjob = oldJobsMap.get( job.Id );
                system.debug('1234'+oldjob.RecordTypeId);
                system.debug('1234'+job.RecordTypeId);
                system.debug('1234'+rtypes[0].Id);
                if( oldjob.RecordTypeId != job.RecordTypeId && job.RecordTypeId == rtypes[0].Id ){
                    jobs.add( job );
                }
            }
        }
        if( !jobs.isEmpty() ){
            Map<Id, Contact> contactsMap = getJobContacts( jobs );
            Map<Id, Account> accountsMap = getJobAccounts( jobs );            
            
            if( contactsMap != null || accountsMap != null ){
                for( ATI_Job__c o : jobs ){
                    ATI_Job__c job = newJobsMap.get( o.Id );
                    if( job.Contact__c != null && contactsMap != null && contactsMap.containsKey(job.Contact__c)){
                        job.Account_Executive_1__c = contactsMap.get( job.Contact__c).OwnerId;
                    }
                    if( job.Account__c != null && accountsMap != null && accountsMap.containsKey(job.Account__c) ){
                        job.Account_Executive_2__c = accountsMap.get( job.Account__c ).OwnerId;
                    }
                    if( job.Account_Executive_1__c == job.Account_Executive_2__c ){
                        job.Account_Executive_2__c = null;
                    }
                    if( job.Account_Executive_1__c == null && job.Account_Executive_2__c != null ){
                        job.Account_Executive_1__c = job.Account_Executive_2__c;
                        job.Account_Executive_2__c = null;
                    }
                }
            }
        }
    }
    
    public static void addTeamMembersJobSplitsOnInsert( List<ATI_Job__c> newJobs ){
        updateTeamMembersAndAESplits( newJobs );
    }
    
    public static void updateTeamMembersOnAEChange(  Map<Id, ATI_Job__c> oldJobsMap, Map<Id, ATI_Job__c> newJobsMap ){
        List<ATI_Job__c> updatedJobs = new List<ATI_Job__c>();
        
        for(ATI_Job__c job : newJobsMap.values()) {
            ATI_Job__c oldJob = oldJobsMap.get(job.id);
            if (job.Account_Executive_1__c != oldJob.Account_Executive_1__c ||
                job.Account_Executive_2__c != oldJob.Account_Executive_2__c) {
                    updatedJobs.add(job);        
                }
        }
        if(!updatedJobs.isEmpty())
        updateTeamMembersAndAESplits( updatedJobs );
    }
    
   @testvisible private static void updateTeamMembersAndAESplits( List<ATI_Job__c> jobs ){
        List<ATI_Job_Team__c> otmToInsert = new List<ATI_Job_Team__c>();
        List<ATI_Job_Split__c> jobSplitsToUpsert = new List<ATI_Job_Split__c>();
        List<ATI_Job_Team__c> otmToDelete = new List<ATI_Job_Team__c>();
        List<ATI_Job_Split__c> jobSplitsDelete = new List<ATI_Job_Split__c>();
        
        if (!jobs.isEmpty()) {
            // Get existing Job splits
            Map<Id, List<ATI_Job_Split__c>> existingJobSplitsMap = new Map<Id, List<ATI_Job_Split__c>>();
            
            for (ATI_Job_Split__c os : [SELECT Id, ATI_Job__c, Percentage__c, Team_Member__c 
                                        FROM ATI_Job_Split__c 
                                        WHERE ATI_Job__c IN:jobs]) {
                                            if (!existingJobSplitsMap.containsKey(os.ATI_Job__c)) {
                                                existingJobSplitsMap.put(os.ATI_Job__c, new List<ATI_Job_Split__c> {os});
                                            } else {
                                                existingJobSplitsMap.get(os.ATI_Job__c).add(os);
                                            }
                                        }
            Set<Id> jobIds = (new Map<Id, ATI_Job__c>(jobs)).keySet();
            Map<Id, List<ATI_Job_Team__c>> existingOTMMap = new Map<Id, List<ATI_Job_Team__c>>();
            for (ATI_Job_Team__c otm : [SELECT Id, ATI_Job__c, User__c, Team_Member_Role__c  
                                              FROM ATI_Job_Team__c
                                              WHERE ATI_Job__c IN :jobIds]) {
                                                  System.debug('OTMId: ' + otm.Team_Member_Role__c);
                                                  if (!existingOTMMap.containsKey(otm.ATI_Job__c)) {
                                                      existingOTMMap.put(otm.ATI_Job__c, new List<ATI_Job_Team__c> {otm});
                                                  } else {
                                                      existingOTMMap.get(otm.ATI_Job__c).add(otm);
                                                  }
                                              }            
            
            for (ATI_Job__c job : jobs) {
                // Construct list of job team members to be inserted
                if( job.Account_Executive_1__c != null && job.OwnerId != job.Account_Executive_1__c ){
                    otmToInsert.add(new ATI_Job_Team__c(User__c=job.Account_Executive_1__c, 
                                                              ATI_Job__c = job.Id, 
                                                              Team_Member_Role__c='Account Executive 1'));
                }
                
                if( job.Account_Executive_2__c != null && 
                   job.OwnerId != job.Account_Executive_2__c && 
                   job.Account_Executive_1__c != job.Account_Executive_2__c){
                       otmToInsert.add(new ATI_Job_Team__c(User__c=job.Account_Executive_2__c, 
                                                                 ATI_Job__c = job.Id, 
                                                                 Team_Member_Role__c='Account Executive 2'));  
                   }
                if( !existingOTMMap.isEmpty() ){
                    System.debug( existingOTMMap );                   
                    system.debug( job );
                    if( existingOTMMap.containsKey(job.Id)){
                        for( ATI_Job_Team__c otm : existingOTMMap.get(job.Id) ){
                            system.debug( otm );                            
                            if( otm != null && otm.User__c != job.OwnerId ){                        
                                if( otm.Team_Member_Role__c == 'Account Executive 2' || otm.Team_Member_Role__c == 'Account Executive 1'){
                                    otmToDelete.add( otm ); 
                                }
                            }
                        }                               
                    }
                }
            }
            
            // Insert Job splits for new members    
            for( ATI_Job__c job : jobs ){
                Decimal splitPercent = 0;
                IF((job.Account_Executive_1__c != null && job.Account_Executive_2__c != null) || 
                   (job.Account_Executive_1__c == null && job.Account_Executive_2__c != null))
                {
                       splitPercent = 50;
                   }else{
                       IF(Job.Account_Executive_1__c != null && Job.Account_Executive_2__c == null){
                           splitPercent = 100;
                       }
                   }
                system.debug('RK ---- ae1' +  job.Account_Executive_1__c );
                system.debug('RK ---- ae2' +  job.Account_Executive_2__c );
                system.debug('RK ---- ownerid' +  job.OwnerId );
                if( job.Account_Executive_1__c != null && job.OwnerId != job.Account_Executive_1__c ){
                    system.debug('ae1');
                    ATI_Job_Split__c os = new ATI_Job_Split__c( ATI_Job__c = job.Id, 
                                                               Team_Member__c = job.Account_Executive_1__c, 
                                                               Percentage__c = splitPercent );
                    jobSplitsToUpsert.add( os );                
                }
                
                if( job.Account_Executive_2__c != null && job.OwnerId != job.Account_Executive_2__c && 
                   job.Account_Executive_1__c != job.Account_Executive_2__c){
                       system.debug('ae2');
                       ATI_Job_Split__c os = new ATI_Job_Split__c( ATI_Job__c = job.Id, Team_Member__c = job.Account_Executive_2__c, Percentage__c = splitPercent );
                       jobSplitsToUpsert.add( os );                
                   }
                if(existingJobSplitsMap.containskey(job.Id))
                for( ATI_Job_Split__c os1 : existingJobSplitsMap.get(job.Id) ){
                    system.debug('existingJobsplitsmap');
                    if( os1.Team_Member__c == job.OwnerId ){
                        system.debug('matched ownerid');
                        splitPercent = 0;
                        if (job.Account_Executive_1__c == null && job.Account_Executive_2__c == null) {
                            // only owner no AEs split percent = 100
                            splitPercent = 100;
                            system.debug('Split Percent1' + splitPercent);
                        } else if (job.Account_Executive_1__c == job.OwnerId && job.Account_Executive_2__c == null ) {
                            // AE1 is owner no AE2 split percent = 100
                            splitPercent = 100;
                            system.debug('Split Percent2' + splitPercent);
                        } else if (job.Account_Executive_2__c == job.OwnerId && job.Account_Executive_1__c == null) {
                            // AE2 is owner no AE1 split percent = 100
                                           
                            splitPercent = 100;
                            system.debug('Split Percent3' + splitPercent);
                        } else if (job.Account_Executive_1__c == job.OwnerId && job.Account_Executive_1__c == job.Account_Executive_2__c) {
                            // AE1 and AE2 both are owner - split percent = 100
                            splitPercent = 100;
                            system.debug('Split Percent4' + splitPercent);
                        } else if (job.Account_Executive_1__c == job.OwnerId && job.Account_Executive_2__c != job.OwnerId) {
                            // AE 1 exists and ae1 is owner and AE2 exists but not owner - split percent = 50
                            splitPercent = 50;
                            system.debug('Split Percent5' + splitPercent);
                        } else if (job.Account_Executive_1__c != job.OwnerId && job.Account_Executive_2__c == job.OwnerId) {
                            // AE1 exists but no owner and AE2 exists and is owner - split percent = 50
                            splitPercent = 50;
                            system.debug('Split Percent6' + splitPercent);
                        } else {
                            // AE1 and AE2 both are not owners but both exist - split percent = 0
                            splitPercent = 0;
                            system.debug('Split Percent' + splitPercent);
                        }
                        os1.Percentage__c = splitPercent;
                        jobSplitsToUpsert.add( os1 );
                    }else{
                        jobSplitsDelete.add( os1 );
                    }
                }
                
            }           
            // Delete the old splits 
            if( !jobSplitsDelete.isEmpty() ){                
                system.debug(jobSplitsDelete);
                delete jobSplitsDelete;
            }
            
            // Delete the old team member
            if( !otmToDelete.isEmpty() ){
                system.debug(otmToDelete);
                delete otmToDelete;
            }
            system.debug( [SELECT Id, ATI_Job__c, Percentage__c, Team_Member__c 
                           FROM ATI_Job_Split__c 
                           WHERE ATI_Job__c IN:jobs] );
            // Insert Job team member
            if( !otmToInsert.isEmpty() ){
                system.debug(otmToInsert);
                insert otmToInsert;
            }
            system.debug( [SELECT Id, ATI_Job__c, Percentage__c, Team_Member__c 
                           FROM ATI_Job_Split__c 
                           WHERE ATI_Job__c IN:jobs] );
            if( !jobSplitsToUpsert.isEmpty() ){                
                system.debug(jobSplitsToUpsert);
                Database.upsert( jobSplitsToUpsert );
            }
        }
    }
   /* public static void createJobPrimaryContactRoles( Map<Id, ATI_Job__c> oldJobsMap, List<ATI_Job__c> newJobs ){
        List<OpportunityContactRole> ocrsToInsert = new List<OpportunityContactRole>();
        for( ATI_Job__c job : newJobs ){
            ATI_Job__c oldJob = oldJobsMap == null ? null : oldJobsMap.get( job.Id );
            if( ( oldJob == null || oldJob.Contact__c != job.Contact__c ) && job.Contact__c != null ){
                //OpportunityContactRole ocr = new OpportunityContactRole( opportunityId = job.Id, contactId = job.Contact__c, IsPrimary = true);
                //ocrsToInsert.add( ocr );
            }
        }
        if( !ocrsToInsert.isEmpty() ){
            //insert ocrsToInsert;
        }
    }    */
    
    public static void updateLastPreviousJobDateOnAccount( List<ATI_Job__c> newJobs ){
        Set<Id> accountIds = new Set<Id>();
        List<Account> accountsToUpdate = new List<Account>();
        for( ATI_Job__c job : newJobs ){
            accountIds.add( job.Account__c );
        }
        if( !accountIds.isEmpty() ){
            for( Account acc : [ SELECT Id, Last_Job_Date__c, Previous_Job_Date__c, 
                                ( SELECT Id, CreatedDate FROM ATI_Jobs__r ORDER BY CreatedDate DESC Limit 2) 
                                FROM Account 
                                WHERE Id IN : accountIds ] ){
                                    if( acc.ATI_Jobs__r != null && !acc.ATI_Jobs__r.isEmpty() ){
                                        Boolean hasAccountChanged = false;
                                        if( acc.Last_Job_Date__c != acc.ATI_Jobs__r[0].createdDate ){
                                            DateTime dT = acc.ATI_Jobs__r[0].createdDate;
                                            acc.Last_Job_Date__c = date.newinstance(dT.year(), dT.month(), dT.day());
                                            hasAccountChanged = true;
                                        }
                                        if( acc.ATI_Jobs__r.size() > 1 && acc.ATI_Jobs__r[1].createdDate != acc.Previous_Job_Date__c ){
                                            DateTime dT = acc.ATI_Jobs__r[1].createdDate;
                                            acc.Previous_Job_Date__c = date.newinstance(dT.year(), dT.month(), dT.day());
                                            hasAccountChanged = true;
                                        }
                                        if( hasAccountChanged ){
                                            accountsToUpdate.add( acc );
                                        }
                                    }                                     
                                }            
            if( !accountsToUpdate.isEmpty() ){
                update accountsToUpdate;
            }
        }
    }

}