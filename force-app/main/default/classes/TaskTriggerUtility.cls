/**
 * @File Name          : TaskTriggerUtility.cls
 * @Description        : 
 * @Author             : sean.gray@atirestoration.com
 * @Group              : 
 * @Last Modified By   : Sean Gray
 * @Last Modified On   : 11/25/2019, 12:11:56 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    11/14/2019   sean.gray@atirestoration.com     Initial Version
**/
public without sharing class TaskTriggerUtility {

    public final static string TASK_TYPE_LUNCH_AND_LEARN = 'Lunch and Learn';
    private final static string CONTACT_PREFIX = '003';
    

    
    // helper method called after insert of tasks
    public static void afterTaskInsert( List<Task> tasks, Map<Id,Task> taskMap ){
        if(!tasks.isEmpty())
        {
            updateTaskOwnerEmailOnContact( tasks );
            contactAssignmentForAEs( tasks );
            //notifyProjectDirectorChatter( tasks );
           // AccountRollupFields(tasks, taskMap );
            system.debug(tasks);
        }
    }
    // private static void AccountRollupFields(List<Task> tasks, Map<Id, Task> taskMap){
    //     for(task task : tasks){
    //         system.debug('Task ' + task);
    //         if(!String.isBlank(task.AccountId)){
    //             system.debug('Task ' + task);
    //         }
    //     }


    // }
    // private static void notifyProjectDirectorChatter(List<Task> tasks){
    //     Set<Id> ownerIds = new Set<Id>();
    //     List<Ati_job__c> jobs = new List<Ati_job__c>();
    //     for( Task t : tasks ){
    //         system.debug(t);
    //         if(t.description != null && t.type != null){
    //         if(t.Type == 'Project Note' && String.valueOf(t.WhatId).startsWith('a77') && (!t.description.contains('Project Note')) ){
    //             list<ati_job__c> jb = new List<Ati_Job__c>([Select id, project_manager__c, project_manager_new__c, name, lead_source__c, office__c FROM Ati_Job__c WHERE Id =: t.WhatId]);
    //             system.debug(jb);
    //            // office__c off = [Select Name, Id FROM Office__c Where Name Like 'Chicago'];
    //            if(jb[0].lead_source__c != null && jb[0].office__c != null){
    //             if(String.valueOf(jb[0].lead_source__c).startsWith('Program') == True && jb[0].Office__c == 'Chicago'){
    //                 Messaging.reserveSingleEmailCapacity(2);
    //                 Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	// 				String[] toAddresses = new String[] {};
    //                 toAddresses.add('CHI-Admin@atirestoration.com');
    //                 //toAddresses.add('sean.gray@atirestoration.com');
	// 				//String[] ccAddresses = new String[] {'sean.gray@atirestoration.com'};
    //                 mail.setToAddresses(toAddresses);
    //              //	mail.setCcAddresses(ccAddresses);
    //                 mail.setReplyTo('sean.gray@atirestoration.com');
    //                 mail.setSenderDisplayName('Salesforce Support');
    //                 mail.setSubject('Job Name : ' + jb[0].name);
    //                 mail.setBccSender(false);
    //                 mail.setUseSignature(false);
    //                 mail.setPlainTextBody('Job Comments: ' + jb[0].name + t.description);
   	//                 mail.setHtmlBody('Job Comments for:<b> ' + jb[0].name +' </b>' + t.Description + ' <p>'+
    //                                  'To view the job <a href=https://na64.salesforce.com/'+jb[0].Id+'>click here.</a>');
    //                 Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });




    //               system.debug(jb);  
    //             }
    //            }
               
    //         }    
    // }
    //     }
    // }
    
    //Task with Lunch and Learn Type—populate Task Owner email onto Contact record—‘Lunch and Learn Submitter Email’ field
    public static void updateTaskOwnerEmailOnContact( List<Task> tasks ){
        Set<Id> ownerIds = new Set<Id>();
        List<Contact> contactsToUpdate = new List<Contact>();
        system.debug('Line 90');
        for( Task t : tasks ){
            if( t.Type == TASK_TYPE_LUNCH_AND_LEARN && t.WhoId != null &&  String.valueOf(t.WhoId).startsWith('003') == true ){
                ownerIds.add( t.OwnerId );
                
            }
           
        }
         if( !ownerIds.isEmpty() ){
            Map<Id, User> usersMap = new Map<Id, User>( [ SELECT Id, Email FROM USER WHERE Id IN : ownerIds ] );
            for(task t: tasks){
                if( t.Type == TASK_TYPE_LUNCH_AND_LEARN && t.WhoId != null &&  String.valueOf(t.WhoId).startsWith('003') == true ){
                contactsToUpdate.add( new Contact( Id = t.whoId, Lunch_and_Learn_Submitter_Email__c = usersMap.get( t.OwnerId ).Email, 
                                                      Lunch_and_Learn_Status__c = 'Unapproved' ));    
                }  
            }      
            }
        if( !contactsToUpdate.isEmpty() ){
            update contactsToUpdate;
             for(Contact c : contactsToUpdate){
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setComments('Submitted for approval. Please Approve. ');
        req.setObjectId(c.id);
        req.setProcessDefinitionNameOrId('Lunch_and_Learn_Approval_Process');
        Approval.ProcessResult result = Approval.process(req);
    }
        }
    }
    
    
    //
    
    private static void contactAssignmentForAEs( List<Task> tasks ){
        Set<Id> ownerIds = new Set<Id>();
        for( Task tsk : tasks ){
            
            if( tsk.WhoId != null && tsk.WhoId != null &&  String.valueOf(tsk.WhoId).startsWith('003') == true ){
                ownerIds.add( tsk.OwnerId );
            }
            
        }
        if( !ownerIds.isEmpty() ){
            Set<Id> contactIds = new Set<Id>();
            Map<Id, Set<Id>> contactIdToTaskOwnersMap = new Map<Id, Set<Id>>();
            Map<Id, User> ownersMap = new Map<Id, User>([ SELECT Id 
                                                          FROM User 
                                                          WHERE Id IN : ownerIds 
                                                            AND Profile.Name =: JobAEBonusTriggerHandler.PROFILE_MARKETING_REP ]);
            for( Task tsk : tasks ){
                if( String.valueOf(tsk.WhoId).startsWith('003') == true ){
                    if( ownersMap.containsKey( tsk.OwnerId ) ){
                        if( !contactIdToTaskOwnersMap.containsKey( tsk.WhoId ) ){
                            contactIdToTaskOwnersMap.put( tsk.whoId, new Set<Id>{tsk.OwnerId});
                        }else{
                            contactIdToTaskOwnersMap.get( tsk.WhoId ).add( tsk.OwnerId );
                        }
                    } 
                }
            }
            List<Task> contactAssignmentTasks =new List<Task>();
            if( !contactIdToTaskOwnersMap.isEmpty() ){
                List<Contact> contacts = [ SELECT Id, Name, OwnerId, (SELECT Id, OwnerId FROM Tasks) 
                                           FROM Contact 
                                           WHERE Id IN: contactIdToTaskOwnersMap.keySet() ];
                for( Contact con : contacts ){
                    Integer taskCount = 0;
                    for( Task tsk : con.tasks ){
                        Set<Id> contacOwnerIds = contactIdToTaskOwnersMap.get( con.Id );
                        if( contacOwnerIds.contains( tsk.OwnerId ) ){
                            taskCount = taskCount + 1;
                            if( taskCount >= 5 ){
                                break;
                            }
                        }
                    }
                    if( taskCount >= 5 ){
                        Task t = new Task( type ='Accounting Note', Subject = 'Request Contact Ownership For Contact - ' + con.Name );
                        contactAssignmentTasks.add( t );
                    }
                }
            }
            if( !contactAssignmentTasks.isEmpty() ){
                insert contactAssignmentTasks;
            }
        }                
    }
@AuraEnabled
public static string LogACall(Id recordId, String ContactJSON, String Type1, String Priority1, Date DueDate1, String MarketingType1, String ServiceClass1, String PaymentCallType1, String Subject1, String Comments1, Boolean ContactChange){
    system.debug('RecordId' + recordId + '    Contact JSON is : ' + ContactJSON + Priority1);
    JSONWrapper ContactID;
    JSONWrapper1 ContactID1;
    Id conId;
    system.debug('ContactChange = ' + ContactChange);
    if(ContactChange){
    ContactID = (JSONWrapper)JSON.deserialize(ContactJSON, JSONWrapper.class);
    }else{
    ContactID1 = (JSONWrapper1)JSON.deserialize(ContactJSON, JSONWrapper1.class);
    }
    system.debug('Contact Id : ' + ContactID);
    if(ContactChange){
    for(Id ca : ContactID.ContactString){
        conId = ca;
    }
    }else{
        conId = ContactID1.ContactString;
    }
    system.debug('Con Id' + conId);
    //if(!String.isEmpty(conId)){
         system.debug('Con Id' + conId);
    Case c = [Select Id, ATI_Job__c FROM CASE WHERE Id =: recordId];
    Task t = new Task(whatId = c.ATI_Job__c, tasksubtype='Call', status = 'Completed', whoId=conId, type = Type1, ownerId = UserInfo.getUserId(), Priority = Priority1, ActivityDate = DueDate1, Marketing_Type__c = MarketingType1, Service_Class__c=ServiceClass1, Payment_Call_Type__c = PaymentCallType1, Subject=Subject1, Description=Comments1 );
    insert t;
    system.debug('Task' + t);
    // FeedItem ft = new FeedItem(parentId = t.id, type='CallLogPost', body = 'test' );
    // insert ft;
   // ConnectApi.ChatterFeeds.postFeedItem(null, ConnectApi.FeedType.Record, t.id, ConnectApi.FeedItemInput);
    
    
    // else{
    // Case c = [Select Id, ATI_Job__c FROM CASE WHERE Id =: recordId];
    // Task t = new Task(whatId = c.ATI_Job__c, tasksubtype='Call', status = 'Completed', type = Type1, ownerId = UserInfo.getUserId(), Priority = Priority1, ActivityDate = DueDate1, Marketing_Type__c = MarketingType1, Service_Class__c=ServiceClass1, Payment_Call_Type__c = PaymentCallType1, Subject=Subject1, Description=Comments1 );
    // insert t;
    // system.debug('Task' + t);
    // //ConnectApi.ChatterFeeds.postFeedItem(null, ConnectApi.FeedType.Record, t.id, ConnectApi.FeedItemInput);
    // // FeedItem ft = new FeedItem(parentId = t.id, type='CallLogPost', body = 'test' );
    // // insert ft;
   
    // }
    
    

  return 'Success';
}
public class JSONWrapper{
        public List<Id> ContactString {get;set;}
    }
public class JSONWrapper1{
        public Id ContactString {get;set;}
    }      
@AuraEnabled
public static string getContacts(String recordId){
    Case cont = [Select Id, contactid FROM Case Where id =: recordId limit 1];
    String jsonResponse = '{"ContactId":"'+cont.ContactId+'"}';
    return jsonResponse;
}
}