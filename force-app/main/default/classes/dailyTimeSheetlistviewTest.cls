@istest
public class dailyTimeSheetlistviewTest {
    
    static List<ATI_Job__c> jobs;
     static testmethod  void dailyTimeSheetlistviewTest()
    {
        
        System.runAs(new User(Id = userinfo.getUserId())){
            TestDataUtil.createCustomSettings_TriggerStatus();
        }
        List<Account> accounts = TestDataUtil.createAccounts(1, true, new Map<String, Object>{ 'Name' => 'testAcct',
                                               'BillingStreet' => 'Street 12',
                                                                       'BillingCity' => 'San Francisco',
                                                                       'BillingCountry' => 'USA',
                                                                       'BillingPostalCode' => '1234',
                                                                       'BillingState' => 'CA' } );
        jobs = TestDataUtil.createJob(10, true, new Map<String, String>{'Account__c' => accounts[0].Id} );
     
        List<RecordType> rtypes = [SELECT Id FROM RecordType WHERE SObjectType ='ATI_Job__c' AND DeveloperName = 'Job_Approved'];
        for( Integer i=0; i< 10; i++ ){
            ATI_Job__c job = jobs[i];
            job.RecordTypeId = rtypes[0].Id;

        }
        update jobs;
         
        string json = '{"ProjectManagers":[],"Supervisors":[],"CrewMembers":[],"TotSupMon":0,"TotSupTue":0,"TotSupWed":0,"TotSupThu":0,"TotSupFri":0,"TotSupSat":0,"TotSupSun":0,"TotCwMon":0,"TotCwTue":0,"TotCWwed":0,"TotCwThu":0,"TotCwFri":0,"TotCwSat":0,"TotCwSun":0,"TotSupPWReg":0,"TotSupPWOT":0,"TotSupPWDBL":0,"TotSupNPWReg":0,"TotSupNPWOT":0,"TotSupNPWDBL":0,"TotCWPWReg":0,"TotCWPWOT":0,"TotCWPWDBL":0,"TotCWNPWReg":0,"TotCWNPWOT":0,"TotCWNPWDBL":0}';
        Daily_Timesheet__c DailyTimesheetRecord = new Daily_Timesheet__c();
        DailyTimesheetRecord.Job__c=jobs[0].id;
        DailyTimesheetRecord.StartDate__c=date.newinstance(2019, 3, 11);
        DailyTimesheetRecord.EndDate__c=date.newinstance(2019, 3, 17);  
        DailyTimesheetRecord.Name=jobs[0].job_number__c +'-'+ date.newinstance(2019, 3, 11) +'-'+date.newinstance(2019, 3, 17);
        DailyTimesheetRecord.DailyTimsheetRecord__c=json;
        DailyTimesheetRecord.Shift__c= 'Day';
        DailyTimesheetRecord.Location__c='US';
        DailyTimesheetRecord.Final__c=false;
        DailyTimesheetRecord.comments__c = 'Test';
        insert DailyTimesheetRecord;       
       
        String timesheetID = DailyTimesheetRecord.id;
        String dailyTimesheetJson =  DailyTimesheetRecord.DailyTimsheetRecord__c;
        ID JobID = jobs[0].id;
        String StartDate = '2019-03-11';
        String EndDate =  '2019-03-17';
        Boolean finalcheckbox = DailyTimesheetRecord.Final__c;
        string location = DailyTimesheetRecord.Location__c;
        string shift =  DailyTimesheetRecord.Shift__c;
        string JobNumber = DailyTimesheetRecord.Job_Number__c;
        string comments =  DailyTimesheetRecord.comments__c;     
        test.startTest();
        dailyTimeSheetlistview.relatedJobNAme(JobID);
        dailyTimeSheetlistview.relatedTimesheetsforJobRecord(JobID);
        test.stoptest();
    }

}