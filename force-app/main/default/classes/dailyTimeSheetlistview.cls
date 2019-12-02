public without sharing class dailyTimeSheetlistview {
    @AuraEnabled(cacheable=true)
    public static List<ATI_Job__c> relatedJobNAme (String jobId){
        
        List<ATI_Job__c> relatedJobNAmeList = [SELECT Id,Name FROM ATI_Job__c WHERE ID=:jobId];
        system.debug('@@@JobName'+relatedJobNAmeList);
        return relatedJobNAmeList;
    }
    @AuraEnabled(cacheable=true)
    public static List<Daily_Timesheet__c> relatedTimesheetsforJobRecord (String jobId){
        
        List<Daily_Timesheet__c> relatedTimeSheetsList = [SELECT Id,Name,Job__c,StartDate__c,EndDate__c,Final__c FROM Daily_Timesheet__c WHERE Job__c=:jobId ORDER BY CreatedDate DESC];
        system.debug('@@@RelatedTimeSheets'+relatedTimeSheetsList);
        return relatedTimeSheetsList;
    }
}