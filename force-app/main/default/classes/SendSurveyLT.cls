public class SendSurveyLT {
    @AuraEnabled
    public static String executeJob(String JobId){
       
        String message = '';
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        ATI_Job__c Job = [select Id from ATI_Job__c where Id =: JobId];
       
        if (profilename == 'System Administrator' || profilename == 'Customer Service Specialist'){
            List<ATI_Job__c> jobList = new list<ATI_Job__c>();
             ATI_Job__c JobValueToUpdate = new ATI_Job__c();
            if(JobValueToUpdate.ManualSurveySend__c != True){
                JobValueToUpdate.id = Job.id;
               JobValueToUpdate.ManualSurveySend__c = true;
                jobList.add(JobValueToUpdate);
            }
            if(!jobList.isEmpty())
            {
            update jobList;
                }
            message = 'Success';
             if(message != null)
                 return message;
            else
                return null;
        } 
        else
            message = 'Not Authorized';
            return message;
            
    }
}