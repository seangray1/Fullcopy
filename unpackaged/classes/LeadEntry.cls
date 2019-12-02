public class LeadEntry {

public ATI_Job__c job {get; set;}
ApexPages.StandardController controller;

    public LeadEntry(ApexPages.StandardController controller) {
        
        job = new ATI_Job__c(); 
        
    }
    
    Public PageReference Save(){
        
        try{
        
            Id RT = Schema.SObjectType.ATI_Job__c.getRecordTypeInfosByName().get('Job (Approved)').getRecordTypeId();
            List<Account> account = [select id, PersonContactId, name from account where LastName =: 'ES Job Account'];
            
            //system.debug('this is the job name==============' + account.name);
            
            
            Job.RecordTypeID = RT;
            job.Stage__c='Qualification';
            job.date_time_approved__c = datetime.now();
            job.Taken_by__c = UserInfo.getUserId();
            job.CloseDate__c=date.today().adddays(5);
            job.name = job.Job_Name__c; 
            Job.Job_Number_Sequence__c=null;
            job.Job_Number__c='';
            job.Date_Time_Taken__c= datetime.now();
           
            if(!account.isempty()){
                job.Account__c = account[0].id;
                job.Project_site_Contact_Name__c = account[0].PersonContactId;
                job.Project_site_Contact_Account__c = account[0].id;
            } 
            else
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Account not found. Please contact your administrator.'));
            
            if(job.name!=null){
                system.debug('this is the job name==============' + job.name);
                insert job;
            } 
                
            PageReference returnPage = new PageReference('/'+job.id);
            returnPage.setRedirect(true);
            return returnPage;
            
        }catch(Exception e){
            system.debug(e);
            ApexPages.addMessages(e);
            return null;
        }
    }

}