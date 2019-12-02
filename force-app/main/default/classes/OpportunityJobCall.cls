/**
 * HTTP Call to FotoIN 
 *
 */
global class OpportunityJobCall {

    public static String message = 'Successful';

    WebService static String syncFotoIn(String oppId) {
        if(oppId == null || oppId == ''){
            return 'Salesforce Key is empty';
        }
        Map <String, Schema.RecordTypeInfo> jobRecordTypeMap = Schema.SObjectType.Opportunity.RecordTypeInfosByName;
        if(Schema.SObjectType.Opportunity.RecordTypeInfosByName.get('Job (Approved)') == null) {
            return 'Job (Approved) Record Type Not Found.';
        }
        //took out the Project_Site_Address_2__c from the s0ql query. 
        Opportunity oppJob = [Select Id, Name, StageName, Division__c, RecordTypeId, Project_Site_Record_Id__c, Project_Site_Address__c, Project_Site_City__c, Project_Site_State__c, Project_Site_Zipcode__c, County__c From Opportunity where Id=: oppId limit 1];
        if(Schema.SObjectType.Opportunity.RecordTypeInfosByName.get('Job (Approved)').RecordTypeId != oppJob.RecordTypeId){
             return 'Job is not approved Yet.';
        }
        if(oppJob.Division__c == 'Marketing'){
            return 'Job division can not be Marketing';
        }
        Set<Id> oppJobIdSet = new Set<Id>();
        oppJobIdSet.add(oppJob.id);
        if(oppJob.Project_Site_Record_Id__c == null) {
            //call to create
            OpportunityJobUtility.callFotoIn2Create(oppJobIdSet);
        }
        /*else if(oppJob.StageName == 'Lost' || oppJob.StageName == 'Complete'){
            //call to delete
            OpportunityJobUtility.callFotoIn2Delete(oppJobIdSet);
        }*/
        else{
            //call to update
            OpportunityJobUtility.callFotoIn2Update(oppJobIdSet);
        }
        return message;
    }
}