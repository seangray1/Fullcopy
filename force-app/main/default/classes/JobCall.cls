/**
 * HTTP Call to FotoIN 
 *
 */
global class JobCall {

    public static String message = 'Successful';
    
    WebService static String syncFotoIn(String jobId) {
        if(jobId == null || jobId == ''){
            return 'Salesforce Key is empty';
        }
        Map <String, Schema.RecordTypeInfo> jobRecordTypeMap = Schema.SObjectType.ATI_Job__c.RecordTypeInfosByName;
        if(Schema.SObjectType.ATI_Job__c.RecordTypeInfosByName.get('Job (Approved)') == null) {
            return 'Job (Approved) Record Type Not Found.';
        }
        //took out the Project_Site_Address_2__c from the s0ql query. 
        ATI_Job__c aJob = [Select Id, Name, Stage__c, Division__c, RecordTypeId, Project_Site_Record_Id__c, Project_Site_Address__c, Project_Site_City__c, Project_Site_State__c, Project_Site_Zipcode__c, County__c From ATI_Job__c where Id=: jobId limit 1];
        if(Schema.SObjectType.ATI_Job__c.RecordTypeInfosByName.get('Job (Approved)').RecordTypeId != aJob.RecordTypeId){
            return 'Job is not approved Yet.';
        }
        if(aJob.Division__c == 'Marketing'){
            return 'Job division can not be Marketing';
        }
        Set<Id> aJobIdSet = new Set<Id>();
        aJobIdSet.add(aJob.id);
        if(aJob.Project_Site_Record_Id__c == null) {
            //call to create
            JobUtility.callFotoIn2Create(aJobIdSet);
        }
        /*else if(oppJob.StageName == 'Lost' || oppJob.StageName == 'Complete'){
//call to delete
ATI_Job_Utility.callFotoIn2Delete(oppJobIdSet);
}*/
        else{
            //call to update
            JobUtility.callFotoIn2Update(aJobIdSet);
        }
        return message;
    }
}