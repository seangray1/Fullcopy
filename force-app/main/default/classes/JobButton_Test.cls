/**
 * @File Name          : JobButton_Test.cls
 * @Description        : 
 * @Author             : Sean Gray
 * @Group              : 
 * @Last Modified By   : Sean Gray
 * @Last Modified On   : 11/25/2019, 12:21:22 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    10/5/2019   Sean Gray     Initial Version
**/
@isTest(SeeAllData=true)
private class JobButton_Test {
    static testmethod void JobButton_Test() {
        Id u2 = UserInfo.getUserId();
        Budget__c bud1 = [Select Id, Budget_status__c, ati_job__c FROM Budget__c Where Id = 'a3u70000001C2wnAAC'];
        //Budget__c b = new budget__c(name='Test', ati_job__c = bud1.ATI_Job__c, gp_goal__c = '22');
       // insert b;
        //b.Budget_Status__c = 'Approved';
        //update b;
        //BudgetFieldUpdate.rejectBudget(b.id, 'test');
        //BudgetFieldUpdate.retrieveBudgetStatus(b.id);
        //budList.add(bud1);
        //Budget__c bud1 = [Select Id, Budget_status__c FROM Budget__c Where Id = 'a3u70000001C0wvAAC'];
        bud1.Budget_status__c = 'Approved';
        update bud1;
        ATI_Job__c jobs = [Select Id, amount__c,stage__c,total_billing_forecast_amount__c, Insurance_Adjuster_Broker__c, contact__c,office2__c, Project_Manager__c, Project_manager_new__c, Name, Percent_Complete__c, Estimated_Completion_Date__c, completion_date__c FROM ATI_Job__c WHERE name = '000-00-00002 | Test Job 1'];
        List<office__c> office = [Select Id, office_manager__c, project_coordinator__c, regional_manager__c FROM Office__c WHERE name = 'HQ'];
        Contact cont = [Select Name FROM Contact Where Id =: jobs.contact__c];
        Contact con1 = [Select Name, Id FROM Contact Where Name = 'Test Tester1234' Limit 1];
        List<task> tasks = [Select Id, Type, whoId, OwnerId FROM Task Where whoId =: con1.id AND Type = 'Lunch and Learn' LIMIT 1];
        List<Budget__c> bud = [Select Name, Total_Allocations__c, Total_Program_Fees_New__c, Total_Budget_Goal__c, ATI_Job__c FROM Budget__c Where ATI_Job__c =:jobs.id Order By createdDate DESC Limit 1];
        // Id approvedRecordTypeId = Schema.SObjectType.ATI_Job__c.getRecordTypeInfosByName().get('Contact Center Case').getRecordTypeId();
         Case c = [Select Id FROM CASE Where ATI_Job__c =: jobs.id LIMIT 1];
        // Case ca = new Case(recordTypeId = approvedRecordTypeId, Priority = '1-Accident/Injury', OwnerId = UserInfo.getUserId(), Next_Action_Date_Time__c = System.Now() + 1, Subject = 'Call', Description = 'Test', ATI_Job__c = jobs.id, ContactId = cont.Id );
        // insert ca;
        //jobutility.offerLetterToPDF(jobs, jobs);
            jobutility.createTaskProjectNote(.1, jobs.id, U2, '1', '2', system.today(), 'Yes', 'No', 'Test');
            jobutility.PMAssignmentChatter(system.today(), jobs.id, U2, 'test', system.today(), 'test', 'test', U2);
            jobutility.projectNoteDate(jobs.id);
            jobutility.projectNotePercent(jobs.id);
            JobUtility.PMAssignmentQuery(jobs.id);
            JobUtility.CaseChatterTaskCreation(jobs.id, 'Test', 'Test');
            JobUtility.JobCaseInfo(jobs.id);
            TaskTriggerUtility.LogACall(c.id, '{"ContactString":["' + cont.Id +'"]}', 'Call', 'Normal', system.today(), 'Coffee', 'Payments', 'Paid', 'Log A Call', 'Test', true);
            TaskTriggerUtility.LogACall(c.id, '{"ContactString":"' + cont.Id +'"}', 'Call', 'Normal', system.today(), 'Coffee', 'Payments', 'Paid', 'Log A Call', 'Test', false);
            TaskTriggerUtility.getContacts(c.id);
            TaskTriggerUtility.updateTaskOwnerEmailOnContact(tasks);
        system.debug('oldjob + ' + jobs.Stage__c);
        system.debug('newjob + ' + jobs.Stage__c);
        // jobs.Stage__c='Won';
        // update jobs;
        system.debug('newjob + ' + jobs.Stage__c);
        
    }
    
}