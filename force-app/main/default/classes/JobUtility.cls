/**
 * @File Name          : JobUtility.cls
 * @Description        : 
 * @Author             : sean.gray@atirestoration.com
 * @Group              : 
 * @Last Modified By   : sean.gray@atirestoration.com
 * @Last Modified On   : 11/27/2019, 9:50:01 AM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    7/12/2019, 9:48:26 AM   sean.gray@atirestoration.com     Initial Version
**/
public class JobUtility {

    public static final List<String> JOB_OWNER_ROLE = new List<String>{'Job Owner', 'Project Director'};    
    /*************************************************************************/
    /*Helper Methods **************/  
    public static void offerLetterToPDF(List<ATI_Job__c> job, map<Id, ATI_Job__c> oldjob){
        //date createDate = date.newInstance(2019, 08, 01);
        List<Attachment> attachToInsert = new List<Attachment>();
            for(ATI_Job__c j : job){
                
           If(j.stage__c == 'Won' &&  j.stage__c != oldjob.get(j.id).stage__c){
                //j.createdDate > createDate
           
            string message =  'Project Name: ' + j.job_name__c + '<br>' +  'Project Number: ' + j.job_number__c  + '<br>'+
            'Date: ' + system.today() + '<br>'+ '<br>'+ 'Dear Valued Client: ' + '<br>'+ '<br>'+ '<p>'+'American Technologies, Inc. (ATI) thanks you for the opportunity to serve you. This welcome letter is to inform you of the details of the restoration, remediation, and/or abatement work we are performing on your property to restore it to pre-loss condition. As we undertake this project, please know that we are deeply committed to your complete satisfaction. Our goal is to provide exceptional customer service that exceeds your expectations, and we welcome your feedback to ensure we meet your needs.'+ '</p>' +
            '<br>' + '<p>' + 'Your assigned Project Director responsible for the overall project management and Project Manager overseeing performance of the day-to-day work are:'+ '</p>' +
            '<br>';
            message = message + '<pre>' + 'Project Director: ' + j.Project_Manager_Full_Name__c   + '         Mobile Phone: ' + j.Project_Manager_Phone__c + '</pre>' + '<br>' + 
            '<pre>'+'Project Manager: ' + j.Project_manager_new_full_Name__c + '         Mobile Phone: ' + j.super_ops_phone__c + '</pre>' +
            '<br>' + '<p>' + 'Our team is committed to ATI’s high standard of quality. If at any time you feel that either individual listed above is not providing you exemplary service, please contact our Customer Service Team at (800) 400-9353 or via email at customerservice@ATIrestoration.com. ' + '</p>' +
            '<br>' + '<p>' + 'In order to communicate effectively with you throughout the project, please let your Project Director and Project Manager know how often you wish to receive updates (daily, twice per week, weekly, every other week or monthly) and your preferred primary contact method (email, phone or other).' + '</p>' +
            '<br>' + '<p>' + 'ATI greatly values your feedback and we strive to exceed your expectations. At the conclusion of the project, we will send you an email survey asking if you would recommend ATI to friends and family. This quick survey will only take a minute to complete and will help us measure the quality of our customer service. We thank you in advance for your participation in this valuable process. If you would like to provide any additional comments, please contact us at (800) 400-9353 at any time to speak with a customer service representative.' + '</p>' +
            '<br>' + '<p>' + 'On behalf of the team here at ATI, thank you for choosing ATI and providing the opportunity for us to serve you.' + '</p>' +
            '<br>' + 'Sincerely,' + 
            '<br>' + '<br>' + 'ATI Customer Service Department';
            Attachment attach = new Attachment();
            String name= 'Welcome Letter '+ j.name + '.pdf';
            attach.body = blob.toPdf(message);
            attach.name = name;
            
            id parentId = j.id;
            attach.parentId = parentId;
            attachToInsert.add(attach);
            //insert attach;
                // ContentVersion conVer = new ContentVersion();
                // conVer.PathOnClient = '/' + attach.name; // The files name, extension is very important here which will help the file in preview.
                // conVer.Title = attach.name; // Display name of the files
            
                // conVer.VersionData = attach.body;
                // insert conVer;
                // ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :conVer.Id];
    
                // ContentDocumentLink cDe = new ContentDocumentLink();
                // cDe.ContentDocumentId = testContent.ContentDocumentId;
                // cDe.LinkedEntityId = j.id; // you can use objectId,GroupId etc
                // cDe.ShareType = 'I'; // Inferred permission, checkout description of ContentDocumentLink object for more details
                // cDe.Visibility = 'AllUsers';
                // insert cDe;
                //Delete attach;
           
                }}
                if(!attachToInsert.isEmpty()){
                insert attachToInsert;
                }
    }
    

    

    public static void DeleteNotification(List<ATI_Job__c> jobs){
      for(ATI_Job__c job : jobs){
                if(job.Last_Successful_Timberline_Update__c != null){
              // List<ATI_Job__c> jobati = jobs.get(job);
             system.debug('The job is called');
               Messaging.reserveSingleEmailCapacity(2);
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
					String[] toAddresses = new String[] {};
                    toAddresses.add('charlotte.neuhaus@atirestoration.com');
                   // toAddresses.add('sean.gray@atirestoration.com');
					//String[] ccAddresses = new String[] {'sean.gray@atirestoration.com'};
                    mail.setToAddresses(toAddresses);
                 //	mail.setCcAddresses(ccAddresses);
                   // mail.setReplyTo('sean.gray@atirestoration.com');
                    mail.setSenderDisplayName('Salesforce Support');
                    mail.setSubject('Job Name :'+job.name + ' Deleted' );
                    mail.setBccSender(false);
                    mail.setUseSignature(false);
                    mail.setPlainTextBody('Job Comments: ' );
   	                mail.setHtmlBody('Job Name: ' + job.name + '<p>' + 
                                    'Last Successful Timberline Sync Date: ' + job.Last_Successful_Timberline_Update__c + '<p>' +
                                    'Date/Time Deleted: ' + System.now() + '<p>'+
                                    'User who Deleted Record: ' + UserInfo.getName()  );
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

           }
       }
    }
    
    public static void ManagerToOwnerCopy( Map<Id, ATI_Job__c> oldJobsMap, list<ATI_Job__c> lstNewJobs){
        //logic to copies the Jobs Project Manager into the Owner field     
        if (! TriggerConfig.raw.JobCopyPMToOwner__c) {
            return;
        }        
               
        //loop through all of the jobs
        for (ATI_Job__c j : lstNewJobs){
            //if project manager isn't empty
            if(j.Project_Manager__c != null){
                //copy the manager ID to the owner
                j.OwnerId = j.Project_Manager__c;
            }
        }   
    }
    @AuraEnabled
    public static Date projectNoteDate(String recordId){
         if(recordId != null){
        List<ATI_Job__c> job = [Select Id, Estimated_Completion_Date_Per_PD__c FROM ATI_Job__c WHERE Id =: recordId];
        system.debug('Job info is : '+' Job Info 0 is : ' + job);
       
        return job[0].Estimated_Completion_Date_Per_PD__c;
        }else{
            return null;
        }
    }
     @AuraEnabled
     public static Decimal projectNotePercent(String recordId){
         if(recordId != null){
        List<ATI_Job__c> job = [Select Id, Percent_Complete__c FROM ATI_Job__c WHERE Id =: recordId];

       
        return job[0].Percent_Complete__c;
        }else{
            return null;
        }
    }
    @AuraEnabled
    public static String createTaskProjectNote(Decimal percent, String recordId, String ownerId, String workCompleted, String workStarted, Date completionDate, String insured, String supplement, String repairComments){
        ATI_Job__c job = [Select Id, office2__c, Project_Manager__c, Project_manager_new__c, Name, Percent_Complete__c, Estimated_Completion_Date_Per_PD__c FROM ATI_Job__c WHERE Id =: recordId];
        List<office__c> office = [Select Id, office_manager__c, project_coordinator__c, project_admin_two__c FROM Office__c WHERE id =:job.office2__c];
        system.debug('Working + ' + ownerId);
        string comments = '\n' + 'Project Note: ' + job.name +'\n' + '\n' + '\n' + 'Percent of Job Complete: ' + percent + '%' + '\n' +'\n' + 'Work/Trades started/completed since last week: ' + workCompleted + '\n' +'\n' + 'Work to be started this week: '+ workStarted + '\n' + '\n' +'Estimated completion date Per PM: '+ completionDate + '\n' + '\n' +'Has Insured/Member completed all selections? Y/N:' + insured + '\n' +'\n' + 'Potential Supplement?Y/N: '+ supplement + '\n' +'\n' + 'Repair Update Comments: ' + repairComments;
        Task t = new Task( Type = 'Project Note', ActivityDate = system.today(), Description = comments, OwnerId = ownerId, Priority = 'Low', Status='Completed', Subject = 'Project Note', WhatId = recordId);
        
        insert t;
        system.debug('Task '+ t);
        FeedItem post = new FeedItem();
        post.ParentId = recordId;
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        ConnectApi.MentionSegmentInput mentionSegmentInput1 = new ConnectApi.MentionSegmentInput();
        ConnectApi.MentionSegmentInput mentionSegmentInput2 = new ConnectApi.MentionSegmentInput();
        ConnectApi.MentionSegmentInput mentionSegmentInput3 = new ConnectApi.MentionSegmentInput();
        if(office != null && office[0].project_admin_two__c != null){
        mentionSegmentInput3.id = office[0].project_admin_two__c;
        messageBodyInput.messageSegments.add(mentionSegmentInput3);
        }
        if(job.Project_Manager__c != null){
        mentionSegmentInput.id = job.project_manager__c;
        messageBodyInput.messageSegments.add(mentionSegmentInput);
        }
        if(job.Project_Manager_new__c != null){
            mentionSegmentInput1.id = job.project_manager_new__c;
             messageBodyInput.messageSegments.add(mentionSegmentInput1);
        }
        if(office != null && office[0].project_coordinator__c != null){
             mentionSegmentInput2.id = office[0].project_coordinator__c;
            messageBodyInput.messageSegments.add(mentionSegmentInput2);
        }
       
        
        //messageBodyInput.messageSegments.add(mentionSegmentInput1);
        
        textSegmentInput.text = comments;
        messageBodyInput.messageSegments.add(textSegmentInput);
        feedItemInput.body = messageBodyInput;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        feedItemInput.subjectId = recordId;
        if(Test.isRunningTest()){return 'success';}
        else{
        ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
        UpdateProjectNote(job.id, completionDate, percent);
        // job.Percent_Complete__c = percent;
        // job.Estimated_Completion_Date_Per_PD__c = completionDate;
        // update job;
        return 'Success';
        }
//insert feedElement;

       
    }
    
    @future
    public static void UpdateProjectNote(Id JobID, Date estimatedCompletionDate, Decimal percent){
        ATI_Job__c job = new ATI_Job__c(ID = JobID, Estimated_completion_date_per_PD__c = estimatedCompletionDate, percent_complete__c = percent);
        update job;
    }

    @AuraEnabled
    public static string PMAssignmentQuery(String recordId){
        
        ATI_Job__c job = [Select Id, amount__c,total_billing_forecast_amount__c, Insurance_Adjuster_Broker__c, contact__c,office2__c, Project_Manager__c, Project_manager_new__c, Name, Percent_Complete__c, Estimated_Completion_Date__c, completion_date__c FROM ATI_Job__c WHERE Id =: recordId];
        List<office__c> office = [Select Id, office_manager__c, project_coordinator__c, regional_manager__c FROM Office__c WHERE id =:job.office2__c];
        //List<Contact> cont = [Select Name FROM Contact Where Id =: job.contact__c];
        Contact ins = new Contact();
        if(job.Insurance_Adjuster_Broker__c != null){
        ins = [Select Name FROM Contact Where Id =: job.Insurance_Adjuster_Broker__c Limit 1];
        }
        List<Budget__c> bud = new List<Budget__c>();
        bud = [Select Name, Total_Allocations__c, Total_Program_Fees_New__c, Total_Budget_Goal__c, ATI_Job__c FROM Budget__c Where ATI_Job__c =:job.id Order By createdDate DESC Limit 1];
        Budget__c bu = new Budget__c();
        for(budget__c b : bud){
            bu = b;
        }
        String PMAssignmentResults;
        // if(!ins.isEmpty()){
        PMAssignmentResults = '{"Insurance":"'+ ins.name +'", "Fees":"'+bu.Total_Program_Fees_New__c+'","Allocation":"'+ bu.Total_Allocations__c +'", "Price":"'+ job.amount__c +'", "Budget":"'+ bu.Total_Budget_Goal__c +'", "Forecast":"'+ job.total_billing_forecast_Amount__c +'"}';  
        // }else{
        // PMAssignmentResults = '{"Insurance":"'+ 'Null' +'", "Fees":"'+bud[0].Total_Program_Fees_New__c+'","Allocation":"'+ bud[0].Total_Allocations__c +'", "Price":"'+ job.amount__c +'", "Budget":"'+ bud[0].Total_Budget_Goal__c +'", "Forecast":"'+ job.total_billing_forecast_Amount__c +'"}';
        // }
            system.debug('JSON set up : ' + PMAssignmentResults);
            return PMAssignmentResults;
    }


    @AuraEnabled
    public static string PMAssignmentChatter(Date startDate, String recordId, String ownerId, String contactInfo, Date completionDate, String briefScope, String notes, String projectManager){
        ATI_Job__c job = [Select Id, amount__c,total_billing_forecast_amount__c, Insurance_Adjuster_Broker__c, contact__c,office2__c, Project_Manager__c, Project_manager_new__c, Name, Percent_Complete__c, Estimated_Completion_Date_Per_PD__c, completion_date__c FROM ATI_Job__c WHERE Id =: recordId];
        List<office__c> office = [Select Id, office_manager__c, project_coordinator__c, branch_manager__c FROM Office__c WHERE id =:job.office2__c];
         Contact ins = new Contact();
         if(job.Insurance_Adjuster_Broker__c != null){
        ins = [Select Name FROM Contact Where Id =: job.Insurance_Adjuster_Broker__c];
         }
        List<Budget__c> bud = [Select Name, Total_Allocations__c, Total_Program_Fees_New__c, Total_Budget_Goal__c, ATI_Job__c FROM Budget__c Where ATI_Job__c =:job.id Order By createdDate DESC Limit 1];
        system.debug('Working + ' + ownerId);
        Budget__c bu = new Budget__c();
        for(budget__c b : bud){
            bu = b;
        }
        //if(!bud.isempty()){
            
        string comments = '\n' + 'PM Assignment: ' + job.name +'\n' + '\n' + '\n' + 'Insurance Carrier/TPA: ' + ins.name +'\n' + 'Fees: ' + bu.Total_Program_Fees_New__c + '\n' + 'Allocation: '+ bu.Total_Allocations__c + '\n'  +'Price: '+ job.amount__c + '\n'  +'Budget: ' + bu.Total_Budget_Goal__c + '\n' + 'Contract Start Date: '+ startDate + '\n' + 'Contract Completion Date: ' + completionDate + '\n' + 'Forecast: '+ job.total_billing_forecast_Amount__c +'\n' + 'Brief Scope: '+briefScope+'\n' + 'Notes: '+notes +'\n' + 'ContactInfo: '+contactInfo+'\n' + 'Suggested PM: ' + projectManager;
        //Task t = new Task( Type = 'Project Note', ActivityDate = system.today(), Description = comments, OwnerId = ownerId, Priority = 'Low', Status='Completed', Subject = 'Project Note', WhatId = recordId);
        //insert t;
        //system.debug('Task '+ t);
        //FeedItem post = new FeedItem();
        //post.ParentId = recordId;
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        ConnectApi.MentionSegmentInput mentionSegmentInput1 = new ConnectApi.MentionSegmentInput();
        ConnectApi.MentionSegmentInput mentionSegmentInput2 = new ConnectApi.MentionSegmentInput();
        mentionSegmentInput.id = job.project_manager__c;
        //mentionSegmentInput1.id = job.project_manager_new__c;
        if(office != null && office[0].office_manager__c != null){
             mentionSegmentInput1.id = office[0].office_manager__c;
            messageBodyInput.messageSegments.add(mentionSegmentInput1);
        }
        if(office != null && office[0].branch_manager__c != null){
             mentionSegmentInput2.id = office[0].branch_manager__c;
            messageBodyInput.messageSegments.add(mentionSegmentInput2);
        }
       
        //messageBodyInput.messageSegments.add(mentionSegmentInput);
       // messageBodyInput.messageSegments.add(mentionSegmentInput1);
        
        textSegmentInput.text = comments;
        messageBodyInput.messageSegments.add(textSegmentInput);
        feedItemInput.body = messageBodyInput;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        feedItemInput.subjectId = recordId;
        ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
        //job.estimated_completion_date_per_PD__c = completionDate;
        UpdateCompletionDatePerPM(job.id, completionDate);
       //update job;
//insert feedElement;
        return 'Success';
    }
    @future
    public static void UpdateCompletionDatePerPM(Id JobID, Date completionDatePerPD){
        ATI_Job__c job = new ATI_Job__c(ID = JobID, Estimated_Completion_Date__c = completionDatePerPD);
        update job;
    }


    @AuraEnabled
    public static string JobCaseInfo(Id recordId){
    ATI_Job__c job = [Select Id, project_site_contact_name__c FROM ATI_Job__c Where Id =: recordId];
    if(job.project_Site_contact_name__c != null){
    return job.project_site_contact_Name__c;
    }else{
        return null;
    }
    }
    @AuraEnabled
    public static string ContactAccount(Id recordId){
    ATI_Job__c job = [Select Id, project_site_contact_name__c FROM ATI_Job__c Where Id =: recordId];
    
    if(job.project_Site_contact_name__c != null){
        system.debug('Job project site contact ' + job.Project_Site_Contact_Name__c);
        Contact c = [Select id, AccountId FROM Contact where id =: job.Project_Site_Contact_Name__c];
        system.debug('contact is ' + c);
    Account a = [Select Id FROM Account Where Id =: c.AccountId];
    system.debug('Account ' + a);
    return a.id;
    }else{
        return null;
    }
    }
    @AuraEnabled
    public static Case ChatterJobId(Id recordId) {
        Case cs = [Select Id, ATI_Job__c FROM Case Where Id =: recordId];
        system.debug('Cs is ' + cs);
        return cs;
    }
    @AuraEnabled
    public static String CaseChatterTaskCreation(Id recordId, String subject, String description){
        
            
       
        Id caseOwner = UserInfo.getUserId();
        List<case> cases = [Select Id FROM CASE WHERE ATI_Job__c =: recordId ORDER BY createdDate DESC LIMIT 1];
        system.debug('Cases ' + cases);
        String fullRecordURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + cases[0].id;
        String fullRecordURLJOB = URL.getSalesforceBaseUrl().toExternalForm() + '/' + recordId;
        
        string descriptionPlus = 'A new case has been opened for the Job: ' + fullRecordURLJOB+  '\n' +'Case Link: '+ fullRecordURL + '\n' + '\n' +description;

        Task t = new Task( Type = 'Log a Call', ActivityDate = system.today(), Description = descriptionPlus, OwnerId = caseOwner, Priority = 'Low', Status='Completed', Subject = subject, WhatId = recordId);
        insert t;
        ATI_Job__c job = [Select Id, Project_Manager__c, Project_manager_new__c, Name FROM ATI_Job__c WHERE Id =: recordId];
        
        FeedItem post = new FeedItem();
        post.ParentId = recordId;
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        ConnectApi.MentionSegmentInput mentionSegmentInput1 = new ConnectApi.MentionSegmentInput();
        ConnectApi.MentionSegmentInput mentionSegmentInput2 = new ConnectApi.MentionSegmentInput();
        if(job.Project_Manager_new__c != null){
            mentionSegmentInput.id = job.project_manager_new__c;
            messageBodyInput.messageSegments.add(mentionSegmentInput);
        }
        if(job.Project_Manager__c != null){
            mentionSegmentInput1.id = job.project_manager__c;
            messageBodyInput.messageSegments.add(mentionSegmentInput1);
        }
        
        
        String comments = '\n' + 'Case Link: ' + fullRecordURL +  '\n' + '\n' +description;
        // messageBodyInput.messageSegments.add(mentionSegmentInput);
        // messageBodyInput.messageSegments.add(mentionSegmentInput1);
        
        textSegmentInput.text = descriptionPlus;
        messageBodyInput.messageSegments.add(textSegmentInput);
        feedItemInput.body = messageBodyInput;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        feedItemInput.subjectId = recordId;
        if(Test.isRunningTest()){}
        else{
        ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
        }
        system.debug('Cases Id before return is ' + cases[0].id);
        return cases[0].id;
        

    }
    
    public static void EmailUpdateOnJob(map<Id,ATI_Job__c> mapOldJob, list<ATI_Job__c> mapNewJob){                
        //Limit the size of list by using Sets which do not contain duplicate elements
        set<Id> ContactIds = new set<Id>();
        List<ATI_Job__c> UpdateJob = new List<ATI_Job__c>();
        
        String Email = '';
        ID jobId = null;        
        
        //When adding new Jobss or updating existing Jobs
        for(ATI_Job__c p : mapNewJob){
            if(p.Add_Correct_Email__c != null && p.Project_site_contact_name__c != null){
                email = p.Add_Correct_Email__c;
                jobId = p.id;
                ContactIds.add(p.Project_site_contact_name__c);
            }  

            List<Contact> contactNeedActions = new list<contact>();
            
            if(!contactIds.isEmpty() ){                
                for( Contact a : [Select Id, email from Contact where Id IN :ContactIds]){                    
                    System.debug('Email is::::::::::::::::::::::::::::::::::::::' + a.email);
                    System.debug('Contact Id is::::::::::::::::::::::::::::::::::::::' + a.Id);                    
                    a.email = email;                    
                    contactNeedActions.add(a);                    
                }
                
                if(!contactNeedActions.isEmpty() ){
                    update contactNeedActions;
                }
            }  
        }

    }
    
    
    /*
* @Method: removeJobOwnerfromTeam
* @ Functionality: remove Job owner from the ATI_Job__c team if the owner exists in the team as "ATI_Job__c Owner" 
    and ATI_Job__c Project Manager is not blank 
*/
    
    public static void removeJobOwnerfromTeam(Map<Id, ATI_Job__c> oldJobMap, list<ATI_Job__c> lstNewJob){
        
        set<Id> JobIds = new set<Id>();
        map<Id,ATI_Job__c> mapJob = new map<Id,ATI_Job__c>();
        list<ATI_Job_Team__c> lstDeleteJobTeam = new list<ATI_Job_Team__c>();
        for(ATI_Job__c Job:lstNewJob){
            ATI_Job__c oldJob = oldJobMap != null ? oldJobMap.get( Job.Id ) : null ;
            if( oldJob == null || oldJob.OwnerId != Job.OwnerId ){
                JobIds.add( Job.Id);
                mapJob.put(Job.Id, Job);
            }
        }
        
        //Adding the split
        if( oldJobMap != null && !JobIds.isEmpty() ){
            List<ATI_Job_Split__c> JobSplitsToDelete = new List<ATI_Job_Split__c>();
            
            for( ATI_Job_Split__c os : [ SELECT Id, Team_Member__c, ATI_Job__c,
                                        ATI_Job__r.OwnerId 
                                         FROM ATI_Job_Split__c 
                                         WHERE ATI_Job__c IN : JobIds ] ){  
               
                ATI_Job__c owner = oldJobMap.get( os.ATI_Job__c );
                            
                if(owner != null && os.Team_Member__c == owner.ownerID){
                    JobSplitsToDelete.add( os );
                }  
            }
            
            if( !JobSplitsToDelete.isEmpty() ){
             //   delete JobSplitsToDelete;
            }
        }
        if( !JobIds.isEmpty() ){
            //Query for Owner
            list<ATI_Job_Team__c> lstJobTeam = [SELECT User__c, Team_Member_Role__c, ATI_Job__c, Id from  ATI_Job_Team__c 
                                                        WHERE ATI_Job__c IN :JobIds 
                                                        AND  Team_Member_Role__c = :JOB_OWNER_ROLE];
            system.debug('lstJobTeam===>'+lstJobTeam);
            for(ATI_Job_Team__c JobMem :lstJobTeam ){
                system.debug('lstJobTeam For===>'+lstJobTeam);
                ATI_Job__c Job = mapJob.get(JobMem.ATI_Job__c);
                if(Job !=null && (Job.OwnerId != JobMem.User__c )){
                    //do not delete the current Owner
                    lstDeleteJobTeam.add(JobMem);
                }
            }
            
            if( !lstDeleteJobTeam.isEmpty() ){
                try{
                    system.debug('lstDeleteJobTeam===>'+lstDeleteJobTeam);
                  //  delete lstDeleteJobTeam;
                }catch(DmlException dmlex){
                    for(Integer iFailedRow=0; iFailedRow<dmlex.getNumDml();iFailedRow++){
                        Integer Orginalindex = dmlex.getDmlIndex(iFailedRow);
                        ATI_Job_Team__c JobTeamMem = lstDeleteJobTeam[Orginalindex];
                            ATI_Job__c Job = mapJob.get(JobTeamMem.ATI_Job__c);
                        Job.addError('Failed to remove the Job Owner from team -'+ dmlex.getDmlMessage(iFailedRow) +
                                       ' - Stacktrace::'+dmlex.getStackTraceString());
                    }
                }
            }
        }
    }
    

    /**
* Call google map api first to get lat, lng
* Call FotoIn api to create project
* @param job [description]
*/
    public static void createFotoInProject( Map<Id, ATI_Job__c> oldJobMap, List<ATI_Job__c> jobs ){
        
        Map <String, Schema.RecordTypeInfo> jobRecordTypeMap = Schema.SObjectType.ATI_Job__c.RecordTypeInfosByName;
        Map<Id, ATI_Job__c> JobMap = new Map<Id, ATI_Job__c>();
        for(ATI_Job__c job : jobs){
            //job record type changed, only approved job will be considered to call FotoIn
            if(Schema.SObjectType.ATI_Job__c.RecordTypeInfosByName.get('Job (Approved)') == null || 
               Schema.SObjectType.ATI_Job__c.RecordTypeInfosByName.get('Job (Approved)').RecordTypeId != job.RecordTypeId || 
               (oldJobMap != null && job.RecordTypeId == oldJobMap.get(job.id).RecordTypeId)){
                continue;
            }
            // job division is Marketing will be ignored
            if(job.Division__c == 'Marketing'){
                continue;
            }
            /*if(job.Job_Number__c.contains('#')){
                continue;
            }*/
            if(job.Project_Site_Address__c == null 
               || job.Project_Site_Address__c == null //&& job.Project_Site_Address_2__c == null) 
               || job.Project_Site_City__c == null 
               || job.Project_Site_State__c == null 
               || job.Project_Site_Zipcode__c == null){
                   continue;
               }else{
                   JobMap.put(job.id, job);
               }
        }
        if( !JobMap.isEmpty() && !System.isBatch() && !System.isScheduled() ){
            callFotoIn2Create(JobMap.keySet());
        }
        
    }
    
    /**
* Call google map api first to get lat, lng
* Call FotoIn api to update project or delete project
* @param job [description]
*/
    public static void updateFotoInProject( Map<Id, ATI_Job__c> oldJobMap, List<ATI_Job__c> jobs ){
        
        Map <String, Schema.RecordTypeInfo> jobRecordTypeMap = Schema.SObjectType.ATI_Job__c.RecordTypeInfosByName;
        Map<Id, ATI_Job__c> JobMap = new Map<Id, ATI_Job__c>();
        for(ATI_Job__c job : jobs){
            // only when the job record Type is Job approved
            if(Schema.SObjectType.ATI_Job__c.RecordTypeInfosByName.get('Job (Approved)') == null || 
               Schema.SObjectType.ATI_Job__c.RecordTypeInfosByName.get('Job (Approved)').RecordTypeId != job.RecordTypeId){
                continue;
            }
            // job division is Marketing will be ignored
            if(job.Division__c == 'Marketing'){
                continue;
            }
            if(job.Project_Site_Record_Id__c == null){
                continue;
            }
            if(job.Job_Number__c.contains('#')){
                continue;
            }
            if((oldJobMap.get(job.id).Project_Site_Name_Fotoin__c != job.Project_Site_Name_Fotoin__c) 
               ||(oldJobMap.get(job.id).Project_Site_Address__c != job.Project_Site_Address__c) 
               //|| (oldJobMap.get(job.id).Project_Site_Address_2__c != job.Project_Site_Address_2__c) 
               || (oldJobMap.get(job.id).Project_Site_City__c != job.Project_Site_City__c)
               || (oldJobMap.get(job.id).Project_Site_State__c != job.Project_Site_State__c)
               || (oldJobMap.get(job.id).Project_Site_Zipcode__c != job.Project_Site_Zipcode__c) 
              ){
                  JobMap.put(job.id, job);
              }
        }
        if( !JobMap.isEmpty() && !System.isBatch() && !System.isScheduled()){
            callFotoIn2Update(JobMap.keySet());
            
        }
        
    }

    public static JobWrap callGoogleMapAPI(ATI_Job__c Job){
        String address = '';
        String JobId = Job.Id;
        if (Job.Project_Site_Address__c != null){
            address += Job.Project_Site_Address__c;
            
            address += ', ';
        }
        if (Job.Project_Site_City__c != null){
            address += Job.Project_Site_City__c +', ';
        }
        if (Job.Project_Site_State__c != null){
            address += Job.Project_Site_State__c +' ';
        }
        if (Job.Project_Site_Zipcode__c != null){
            address += Job.Project_Site_Zipcode__c +', ';
        }
        //address += 'USA';
        //address = EncodingUtil.urlEncode(address, 'UTF-8');
        system.debug('@@@ ADDRESS ===' +address);
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://maps.googleapis.com/maps/api/geocode/json?key=AIzaSyBuE7iBv1fugjx2Az7h-bCwJCoWOadglz8&address='+
                         EncodingUtil.urlEncode(address, 'UTF-8')+'&sensor=false');
        req.setMethod('GET');
        req.setTimeout(60000);
        JobWrap JobWrap = new JobWrap();
        // callout
        HttpResponse res = h.send(req);
        if(res.getStatusCode() == 200 || res.getStatusCode() == 201 ){
            // parse coordinates from response
            System.debug('Google response body ...' + res.getBody());
            JSONParser parser = JSON.createParser(res.getBody());
            double lat = null;
            double lon = null;
            while (parser.nextToken() != null) {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getText() == 'location'){
                    parser.nextToken(); // object start
                    while (parser.nextToken() != JSONToken.END_OBJECT){
                        String txt = parser.getText();
                        parser.nextToken();
                        if (txt == 'lat'){
                            lat = parser.getDoubleValue();
                        }
                        else if (txt == 'lng'){
                            lon = parser.getDoubleValue();
                        } 
                    }
                    System.debug('@@@ LAT ====' +lat);
                }
            }
            // update coordinates if we get back
            JobWrap.locations = new List<JobWrap.Location>();
            JobWrap.Location location = new JobWrap.Location();
            if (lat != null){
                location.latitude = lat;
            }
            if(lon != null){
                location.longitude = lon;
            }
            location.radius = Long.valueOf(Label.FotoIn_Project_Site_Radius);
            JobWrap.locations.add(location);
            JobWrap.archived = false;
            JobWrap.address = address;
            JobWrap.projectName = Job.Project_Site_Name_Fotoin__c;
            JobWrap.projectKey = Job.year__c;
        }
        else{
            throw new CallFotoInException(res.getBody());
        }
        return JobWrap ;
    }
    
    public static HTTPResponse getHttpResponse(String method, String endPoint, String jsonInput, ATI_Job__c updateJob) {
        HttpRequest req = new HttpRequest();
        Blob headerValue = Blob.valueOf(Label.FotoIn_User_Name + ':' + Label.FotoIn_User_Password);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
        req.setMethod(method);
        req.setEndpoint(endPoint);
        req.setHeader('Content-Type','application/json');
        req.setBody(jsonInput);
        req.setTimeout(120000);
        Http http = new Http();
        HTTPResponse res = new HTTPResponse();
        Map<String, Object> responseMap = new Map<String, Object>();
        res = http.send(req);
        System.debug('This is the status code' + res.getStatuscode());
        if(res.getStatusCode() == 200 || res.getStatusCode() == 201){
            //todo need to save the project Id in the salesforce
            System.debug('Input: ... ' + jsonInput);
            System.debug('OutPut: ... ' + res.getBody());
            JSONParser parser = JSON.createParser(res.getBody());
            Long projectRecordId = 0;
            while (parser.nextToken() != null) {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getText() == 'data'){
                    parser.nextToken(); // object start
                    while (parser.nextToken() != JSONToken.END_OBJECT){
                        String txt = parser.getText();
                        parser.nextToken();
                        if (txt == 'id'){
                            projectRecordId = parser.getLongValue();
                        }
                    }
                    System.debug('@@@ projectRecordId ====' +projectRecordId);
                }
            }
            updateJob.Project_Site_Record_Id__c = String.valueOf(projectRecordId);
            updateJob.Last_Successful_FotoIn_Update__c = Datetime.now();
            updateJob.Last_FotoIn_Update__c = Datetime.now();
            updateJob.Project_Site_Call_Result_Message__c = '';
            update updateJob;
        }else{
            throw new CallFotoInException(res.getBody());
        }
        return res;
    }
    
    /**
* credential to cal FotoIn 
* Custom label: 
* @param  jobWrap [description]
* @return         [description]
*/
    @future (callout=true)
    public static void callFotoIn2Create(Set<Id> jobIdSet){
    
        //took out Project_Site_Address_2__c from the soql query. 
        for(ATI_Job__c Job : [SELECT Id, Name, Project_Site_Record_Id__c, Project_Site_Call_Result_Message__c, 
                                         Last_Successful_FotoIn_Update__c, Last_FotoIn_Update__c, Project_Site_Name__c, 
                                         Project_Site_Name_Fotoin__c, Project_Site_Address__c,year__c ,
                                         Project_Site_City__c, Project_Site_State__c, Project_Site_Zipcode__c 
                                  FROM ATI_Job__c 
                                  WHERE Id IN: jobIdSet LIMIT 49999 ]){
            try{
                String jsonInput = JSON.serializePretty(callGoogleMapAPI(Job));
                getHttpResponse('POST', Label.FotoIn_Stage_Project_End_Point_URL, jsonInput, Job);
            }
            catch(Exception e){
                System.debug('Http call error ...' + e.getMessage());
                Job.Last_FotoIn_Update__c = Datetime.now();
                Job.Project_Site_Call_Result_Message__c = e.getMessage().left(2047);
                update Job;
            }
        }
    }
    @future (callout=true) 
    public static void callFotoIn2Update(Set<Id> jobIdSet) {
        
        //took out Project_Site_Address_2__c from the soql query. 
        for(ATI_Job__c Job : [SELECT Id, Name, Project_Site_Name_Fotoin__c, Project_Site_Name__c, 
                                         Project_Site_Record_Id__c, Last_Successful_FotoIn_Update__c, 
                                         Last_FotoIn_Update__c,year__c, Project_Site_Address__c, Project_Site_City__c, Project_Site_State__c, Project_Site_Zipcode__c
                                  FROM ATI_Job__c WHERE Id IN: jobIdSet LIMIT 49999 FOR UPDATE ]){
            try{
                JobWrap updateJobWrap = callGoogleMapAPI(Job);
                updateJobWrap.id = Job.Project_Site_Record_Id__c;
                String jsonInput = JSON.serializePretty(updateJobWrap);
                system.debug('Before PUT');
                getHttpResponse('PUT', Label.FotoIn_Stage_Project_End_Point_URL, jsonInput, Job);
                system.debug('After PUT');
                Job.Last_FotoIn_Update__c = Datetime.now();
                job.Last_Successful_FotoIn_Update__c = Datetime.now();
                Job.Project_Site_Call_Result_Message__c = 'Successfull';
                system.debug('End of PUT');
            }
            catch(Exception e){
                System.debug('Http call error ...' + e.getMessage());
                Job.Last_FotoIn_Update__c = Datetime.now();
                Job.Project_Site_Call_Result_Message__c = e.getMessage().left(2047);
                update Job;
            }
        }
    }

}