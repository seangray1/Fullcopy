/*
* Helper class for the Budget Trigger 
*/
public without sharing class BudgetFieldUpdate {

    public static TriggerStatus__c cfg = TriggerConfig.raw;
    /**
    * @param survey A collection of Budget__c records for insert
    */
    public static void AlertPmNewBudget(List<Budget__c> budget){
        Set<Id> ProjectManagerIds = new Set<Id>();
        Map<Id,User> projectmanagers = new Map<Id, User>();
        List<User> PMlistIds = new List<User>();
        Map<Id, Budget__c> ProjectManagersMap = new Map<Id, Budget__c>();
        List<Budget__c> UpdateBudgetList = new List<Budget__c>();
        for(Budget__c b: budget)
        {
            if(!string.isBlank(b.project_manager__c))
            {
                ProjectManagerIds.add(b.project_manager__c);
                ProjectManagersMap.put(b.project_manager__c, b);
                UpdateBudgetList.add(b);
            }
        }
        if(!ProjectManagerIds.isEmpty())
        {
            List<User> userList = [Select Id, email FROM User Where Id=:ProjectManagerIds];
            for (User u : userList) 
            {
                if (!string.isBlank(u.email)) 
                {
                   projectmanagers.put(U.id, u);
                   PMlistIds.add(u);

                }
            }
        }
        if(!PMlistIds.isEmpty())
        {
            for (Budget__c bu : UpdateBudgetList) 
            {
                String PMEmail = projectmanagers.get(bu.project_manager__c).email;
                if (!String.isBlank(PMEmail)) 
                {
                    String fullRecordURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + bu.id;
                    Messaging.reserveSingleEmailCapacity(2);
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
					String[] toAddresses = new String[] {};
                    toAddresses.add(PMEmail);
                    //toAddresses.add('sean.gray@atirestoration.com');
					//String[] ccAddresses = new String[] {'sean.gray@atirestoration.com'};
                    mail.setToAddresses(toAddresses);
                 //	mail.setCcAddresses(ccAddresses);
                   // mail.setReplyTo('sean.gray@atirestoration.com');
                    mail.setSenderDisplayName('Salesforce Support');
                    mail.setSubject('Budget ' + bu.name + ' for Job ' + bu.Job_Name_and_Number__c +' has been Created' );
                    mail.setBccSender(false);
                    mail.setUseSignature(false);
                    mail.setPlainTextBody('Job Comments: ' );
   	                mail.setHtmlBody('The following Budget has been created for Job ' + bu.Job_Name_and_Number__c + '<p>' + '<br>'+
                                    'Job: ' + bu.Job_Name_and_Number__c + '<p>' +
                                    'Budget is pending your review. Please Reject or Submit for Approval once reviewed '+ '<p>'+ '<br>' +
                                    'To view the Budget <a href='+ fullRecordURL +'>Click here.</a>');
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                }
            }
        }
    }
    public static void BudgetFieldUpdate(list<Budget__c> budget){
        
        Set<Id> ATI_JobIds = new Set<Id>(); 
        for(Budget__c b: budget){
            
            if(!String.isBlank(b.ATI_Job__c)){ 
                ATI_JobIds.add(b.ATI_Job__c);
            }
        }
        Map<Id, ATI_Job__c> ATIJobMap = new Map<Id, ATI_Job__c>();
        if(!ATI_JobIds.isEmpty()){
            ATIJobMap = new Map<Id, ATI_Job__c>([SELECT id, Name, Budget__c, Job_Number__c, ownerID, Office2__c, Project_Manager__c, Project_Manager_new__c, Project_Manager__r.ManagerId, 
                                                      Structure_Superintendent__c, Operations_Manager__c, Branch_Manager__c 
                                               FROM ATI_Job__c 
                                               WHERE id IN:ATI_JobIds]);
        }
        
   //Update all the fields from ATI Job to Budget     
   list<ATI_Job__c> jobsToUpdate = new List<ATI_Job__c>(); 
        for(Budget__c b: budget){
            //check to see if the jobIds exists
            ATI_Job__c job = ATIJobMap.get(b.ATI_Job__c);
            if(!String.isEmpty(job.id)){
                b.name = job.Job_Number__c+'-'+b.Budget_Number_Incremental__c;
                b.Project_Director__c = job.Project_Manager__c;
                b.Regional_Manager__c = job.Branch_Manager__c;
                b.Project_Manager__c = job.Project_Manager_new__c;
                job.budget__c = 'Created';
                jobsToUpdate.add(job);
                
                // if(b.budget_status__c == 'Submitted for Approval'){
                //     job.budget__c = 'Submitted for Approval';
                // }
                // if(b.budget_status__c == 'Approved'){
                //     job.budget__c = 'Approved';
                // }
                // if(b.budget_status__c == 'Rejected'){
                //     job.budget__c = 'Rejected';
                // }
            


            
            }
        }//for loop for each customer survey and assign them to customer survey.  
        update jobsToUpdate;
     
    }
    public static void UpdateFinancialGP(List<Budget__c> bud, Map<Id,Budget__c> oldBud)
    {
        Set<Id> jobIds = new Set<Id>();
        Map<Id,String> jobMap = new Map<Id,String>();
        system.debug('Before Budget if statement');
            for(Budget__c b : bud)
            {
            if((!String.isEmpty(b.gp_goal__c)) && b.budget_status__c == 'Approved' && b.budget_status__c != oldBud.get(b.id).budget_status__c && (b.gp_goal__c == '29' || b.gp_goal__c == '28' ||
             b.gp_goal__c == '27' || b.gp_goal__c == '26' || b.gp_goal__c == '25' || b.gp_goal__c == '24' || b.gp_goal__c == '23' ||
              b.gp_goal__c == '22' || b.gp_goal__c == '21' || b.gp_goal__c == '21' || b.gp_goal__c == '20')) 
                {
                jobIds.add(b.ati_job__c);
                jobMap.put(b.ati_job__c, b.gp_goal__c);
                }
            }
        system.debug('Set of Job Ids' + jobIds);
        if(!jobIds.isEmpty())
        {
            futureUpdateFinancialGP(jobIds, jobMap);
        }
    }
    public static void deleteBudgetLineItems(List<Budget__c> bud, Map<Id,Budget__c> oldMap){
        Set<Id> budgetIds = new Set<Id>();
        List<Budget_Line_Item__c> lineItemsToDelete = new List<Budget_Line_Item__c>();
        for(Budget__c b : bud)
        {
            if(b.budget_status__c == 'Approved' && b.budget_status__c != oldMap.get(b.id).budget_status__c)
            {
                budgetIds.add(b.id);
            }
        }
        List<Budget_Line_Item__c> lineItems = [Select Id, revenue__c FROM Budget_Line_Item__c Where Budget__c=:budgetIds];
        for(Budget_Line_Item__c lineItem : lineItems)
        {   
            system.debug('Line Item value : ' + lineItem.revenue__c);
            String rev = String.valueOf(lineItem.revenue__c);
            Boolean q = String.isBlank(rev);
            if(lineItem.revenue__c == 0 || q == true)
            {
                lineItemsToDelete.add(lineItem);
            }
        }
        if (!lineItemsToDelete.isEmpty()) 
        {
            Delete lineItemsToDelete;
        }
    }
    
    
     @future
     public static void futureUpdateFinancialGP(Set<Id> jobIds, Map<Id,String> jobIdGP)
     {
         List<Financial__c> financeList = new List<Financial__c>();
          if(!jobIds.isEmpty())
          { 
            Map<Id,ATI_Job__c> jobs = new Map<Id,ATI_Job__c>([Select Id, project_manager__c, branch_manager__c, name FROM ATI_Job__c Where Id =:jobIds]);
            Map<Id,Financial__c> financialGPToUpdate = new Map<Id,Financial__c>([Select Id, ATI_Job__c, gross_profit__c FROM Financial__c WHERE ATI_Job__c =:jobIds]);
                for(Id finance : financialGPToUpdate.keySet())
                {
                Financial__c gp = financialGPToUpdate.get(finance);
                system.debug('Finance is ' + finance);
                String gpstring = jobIdGP.get(gp.Ati_job__c);
                Decimal gpdecimal = Decimal.valueOf(gpstring);
                system.debug('Gp Decimal is ' + gpdecimal);
            //decimal dec = 23.00;
                gp.gross_profit__c = gpdecimal;
                //update gp;
                financeList.add(gp);
                Financial__c f = [Select Id, gross_profit__c FROM Financial__c Where Id =: gp.id];
                system.debug('Gross profit for 1st financial is ' + f);
                
                ATI_Job__c job = jobs.get(gp.ATI_Job__c);
                FeedItem post = new FeedItem();
                post.ParentId = job.id;
                ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        ConnectApi.MentionSegmentInput mentionSegmentInput1 = new ConnectApi.MentionSegmentInput();
        ConnectApi.MentionSegmentInput mentionSegmentInput2 = new ConnectApi.MentionSegmentInput();
        system.debug(job);
        //mentionSegmentInput1.id = job.project_manager_new__c;
        if(!String.isEmpty(job.project_manager__c)){
             mentionSegmentInput1.id = job.project_manager__c;
            messageBodyInput.messageSegments.add(mentionSegmentInput1);
        }
        if(!String.isEmpty(job.branch_manager__c)){
             mentionSegmentInput2.id = job.branch_manager__c;
            messageBodyInput.messageSegments.add(mentionSegmentInput2);
        }
        system.debug('The MentionSegment contains before text  ' + messageBodyInput.messageSegments);
       system.debug('gp is  '+ gpstring);
        //messageBodyInput.messageSegments.add(mentionSegmentInput);
       // messageBodyInput.messageSegments.add(mentionSegmentInput1);
        String comments = 'Job: '+ job.name + ' is Below 30%. Currently Estimated for '+ gpstring+'%';
        textSegmentInput.text = comments;
        messageBodyInput.messageSegments.add(textSegmentInput);
        system.debug('The MentionSegment contains After text  ' + messageBodyInput.messageSegments);
    
        feedItemInput.body = messageBodyInput;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        feedItemInput.subjectId = job.id;
         if(Test.isRunningTest()){system.debug('test  '+ gpstring);}
        else{
            system.debug('after test  '+ gpstring);
        ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);  
        system.debug('After connectAPI ' + job);
                }
          }
          if(!financeList.isEmpty())
          {
              update financeList;
          } 
          }
     }
     @AuraEnabled
     public static string retrieveBudgetStatus(Id recordId){
         String showRejectOption;
         list<Budget__c> bud1 = [Select Id, Budget_Status__c FROM Budget__c WHERE id =: recordId];
         for(budget__c bud : bud1){
         if(bud.Budget_Status__c == 'Submitted For Approval' || bud.Budget_Status__c == 'Approved' || bud.Budget_Status__c == 'Rejected'){
             showRejectOption = '2';
         }
         else {
             showRejectOption = '1';
         }
         }
         return showRejectOption;
     }


     public static void UpdateSalesTax(List<Budget__c> bud){
        for(Budget__c b : bud){
            if(!String.isBlank(string.valueOf(b.Sales_Tax__c)) && b.Exclude_Tax_From_Total__c == 'No' && b.Overhead_Profit_Sales_Tax__c == true){
                system.debug('hitting this' + b.Sales_Tax__c + '      allocation percentage ' + b.Allocation_percentage__c);
            //Integer salesPercentage = (((b.Sales_Tax__c) - b.Sales_Tax__c / b.Allocations_Percentage__c) * 2) + b.Sales_Tax__c;
            b.sales_tax_percent__c = ((b.Sales_Tax__c - (b.Sales_Tax__c / (b.Allocation_Percentage__c/100))) * 2) + b.Sales_Tax__c;
            //(B.Sales_Tax__c * (b.Allocation_Percentage__c * 2)) + B.Sales_Tax__c;
            system.debug('SalestaxPercent ' + b.sales_tax_percent__c);
          
            }
        }
    }

    /*public static void updateProjectManager(list<budget__c> bud){
        List<ATI_Job__c> job = new List<ATI_Job__c>([Select Id, Project_Manager_new__c FROM ATI_Job__c Where Id =: bud[0].ATI_Job__c limit 1]);
        for(Budget__c b : bud){
            b.Project_Manager__c = job[0].Project_manager_new__c;
          
        }
    }*/
    public static void BudgetFieldUpdate2(list<Budget__c> budget){

        Set<Id> ATI_JobIds = new Set<Id>(); 
        for(Budget__c b: budget){
            
            if(!String.isBlank(b.ATI_Job__c)){ 
                ATI_JobIds.add(b.ATI_Job__c);
            }
        }
        Map<Id, ATI_Job__c> ATIJobMap = new Map<Id, ATI_Job__c>();
        if(!ATI_JobIds.isEmpty()){
            ATIJobMap = new Map<Id, ATI_Job__c>([SELECT id, Name, Job_Number__c, ownerID, Office2__c, Project_Manager__c, Project_Manager_new__c, Project_Manager__r.ManagerId, 
                                                      Structure_Superintendent__c, Operations_Manager__c, Branch_Manager__c, Budget__c 
                                               FROM ATI_Job__c 
                                               WHERE id IN:ATI_JobIds]);
        }
        list<ATI_Job__c> jobsToUpdate = new List<ATI_Job__c>();
   //Update all the fields from ATI Job to Budget        
        for(Budget__c b: budget){
            //check to see if the jobIds exists
            ATI_Job__c job = ATIJobMap.get(b.ATI_Job__c);
            if(!String.isBlank(job.id)){
                //b.name = job.Job_Number__c+'-'+b.Budget_Number_Incremental__c;
                b.Project_Director__c = job.Project_Manager__c;
                b.Regional_Manager__c = job.Branch_Manager__c;
                b.Project_Manager__c = job.Project_Manager_new__c;
                
                
                 if(b.budget_status__c == 'Submitted for Approval'){
                    job.budget__c = 'Submitted for Approval';
                    update job;
                }
                if(b.budget_status__c == 'Approved'){
                    job.budget__c = 'Approved';
                    update job;
                }
                if(b.budget_status__c == 'Rejected'){
                    job.budget__c = 'Rejected';
                    update job;
                    //update job;
                }
                 
                //jobsToUpdate.add(job);
            }
        }
        //update jobsToUpdate;
   /* public static void updateJob (List<Budget__c> budget){
        List<ATI_Job__c> jobs = new List<ATI_Job__c>();
        for(budget__c b : budget){
            system.debug(b.Approved_Budget__c + 'budget approved is idk' );
            if(b.approved_budget__c = true){
                ATI_Job__c job = [Select Id, Budget__c FROM ATI_Job__c Where Id =: b.ati_job__c];
                system.debug('job Id is ' + job + 'and the BudgetRejected is ' + job.budget__c);
                job.Budget__c = 'Approved';
                system.debug(job.budget__c + 'job budget rejected');
            }
        }

       
    }*/
    }
    @AuraEnabled
    public static String rejectBudget(Id budgetId, string comments){
        //User u = [Select Id, Name, Email FROM User WHERE Name = 'Sean Gray'];
        List<Budget__c> budsToUpdate = new List<Budget__c>();
        List<Budget__c> buds = [Select Id, name, total_revenue__c, Rejected_reason__c, reject_budget__c, ATI_Job__c, Job_Name_and_Number__c, Project_Director__c, Project_Manager__c, Regional_Manager__c FROM Budget__c WHERE id =:budgetId];
        for(Budget__c b : buds){
        b.rejected_reason__c = comments;
        b.reject_budget__c= true;
        b.Budget_Status__c = 'Rejected';
        update b;
        //budsToUpdate.add(b);
        
       ATI_Job__c j = [Select Id, budget__c FROM ATI_Job__c WHERE id =: b.ATI_job__c];
       j.budget__c = 'Rejected';
       update j;
       List<User> u = [Select Id, Email FROM User WHERE Id =: b.project_director__c];
       //for(User us : u){
           if(!String.isBlank(u[0].email)){
               String fullRecordURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + b.id;
       Messaging.reserveSingleEmailCapacity(2);
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
					list<String> toAddresses = new List<String> {};
                    toAddresses.add(u[0].email);
                   // toAddresses.add('sean.gray@atirestoration.com');
					//String[] ccAddresses = new String[] {'sean.gray@atirestoration.com'};
                    mail.setToAddresses(toAddresses);
                 //	mail.setCcAddresses(ccAddresses);
                   // mail.setReplyTo('sean.gray@atirestoration.com');
                    mail.setSenderDisplayName('Salesforce Support');
                    mail.setSubject('Budget ' + b.name + ' for Job ' + b.Job_Name_and_Number__c +' has been Rejected' );
                    mail.setBccSender(false);
                    mail.setUseSignature(false);
                    mail.setPlainTextBody('Job Comments: ' );
   	                mail.setHtmlBody('The following Budget has been rejected for Job ' + b.Job_Name_and_Number__c + '<p>' + '<br>'+
                                    'Job: ' + b.Job_Name_and_Number__c + '<p>' +
                                    'Total Revenue: ' + b.Total_Revenue__c + '<p>'+ '<br>' +
                                    'To view the Budget <a href=' + fullRecordURL + '>Click here.</a>');
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

        approval.LockResult lrList = Approval.lock(b, false);
          // }

       }
        }
        //update budsToUpdate;
        //for(budget__c b : budsToUpdate){
      //  approval.LockResult lrList = Approval.lock(b, false);
       // }
        return 'Success';
       
        //   }
     //  }  
    }
    // @AuraEnabled
    // public static void insertLineItem(string lineitemId, string recordId){
    //     system.debug('working'+ lineitemId);
    //     string body = lineItemId;
    //     system.debug(body);
    //     //Ati_job__c j = [Select Id from ati_job__c where id =: lineItemId];
    //     //TokenWrapper token = TokenWrapper.getBody()
    //     TokenWrapper token = (TokenWrapper)JSON.deserialize(lineitemId, TokenWrapper.class);
    //     system.debug('Id of job is ' +token.key1);
    //     system.debug('id '+ token.key1[0]);
        
    //     //Budget_Line_Item__c b = [Select Id, budget__c FROM Budget_Line_Item__c WHERE id=:lineitemId];
    //    // b.budget__c = recordId;
    //    // system.debug('working'+ b);
    //     //insert b;
    // }
     public class TokenWrapper{
        public List<String> key1 {get;set;}
        public String firm {get;set;}
        public String SystemId {get;set;}
    }
    public class RandomTokenWrapperException extends Exception{
    }
    }