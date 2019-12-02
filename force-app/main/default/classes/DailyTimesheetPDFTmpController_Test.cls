@istest
public with sharing class DailyTimesheetPDFTmpController_Test {
    
     static List<ATI_Job__c> jobs;
    public String Location = 'CA';
    public date StartDate = date.newInstance(2019,03,11);
    public date EndDate = date.newInstance(2019,03,17);
    public string JobName = 'test';
    public string JobNumber = '1234578960';
    public string Shift = 'Day';
    
    public string GetSDate = '0.0';
    public string Date_mon = '0.0';
    public string Date_tue = '0.0';
    public string Date_wed = '0.0';
    public string Date_thu = '0.0';
    public string Date_fri = '0.0';
    public string Date_sat = '0.0';
    public string Date_sun = '0.0';
    public string GetEDate = '0.0';
    
     static testmethod  void DailyTimesheetPDFTmpController_Test()
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
       
        test.startTest();       
        ApexPages.CurrentPage().getparameters().put('id', DailyTimesheetRecord.id); 
        ApexPages.StandardController sc = new ApexPages.StandardController(DailyTimesheetRecord);
        PageReference pageRef = Page.DailyTimesheetPDFpageTemplate;
		pageRef.getParameters().put('id',DailyTimesheetRecord.id );
		Test.setCurrentPage(pageRef);
        blob pdfBody;
		if(Test.isRunningTest()) { 
		  pdfBody = blob.valueOf('Unit.Test');
		} else {
 		 pdfBody = pageRef.getContentAsPDF();
		} 
         
        DailyTimesheetPDFTmpController DailyTimesheetPDFmethod = new DailyTimesheetPDFTmpController();
        DailyTimesheetPDFTmpController.ProjectManagers a= new  DailyTimesheetPDFTmpController.ProjectManagers();
         DailyTimesheetPDFTmpController.JSON2Apex b=new DailyTimesheetPDFTmpController.JSON2Apex();
        DailyTimesheetPDFTmpController.Supervisors c=new DailyTimesheetPDFTmpController.Supervisors();
        DailyTimesheetPDFTmpController.CrewMembers d=new DailyTimesheetPDFTmpController.CrewMembers();
        a.Name  = 'test' ;            
        a.PW = 'test';
        a.LaborCode = 'BCD';      
        a.MondayDBLHours  ='0.0';  
        a.MondayOTHours   ='0.0'; 
        a.MondayRegHours ='0.0'; 
        a.TuesdayDBLHours ='0.0'; 
        a.TuesdayOTHours ='0.0'; 
        a.TuesdayRegHours ='0.0'; 
        a.WednesdayDBLHours ='0.0'; 
        a.WednesdayOTHours ='0.0'; 
        a.WednesdayRegHours ='0.0'; 
        a.ThursdayDBLHours ='0.0'; 
        a.ThursdayOTHours ='0.0'; 
        a.ThursdayRegHours ='0.0'; 
        a.FridayDBLHours ='0.0'; 
        a.FridayOTHours ='0.0'; 
        a.FridayRegHours ='0.0'; 
        a.SaturdayDBLHours ='0.0'; 
        a.SaturdayOTHours ='0.0'; 
        a.SaturdayRegHours ='0.0'; 
        a.SundayDBLHours ='0.0'; 
        a.SundayOTHours  ='0.0'; 
        a.SundayRegHours ='0.0'; 
         b.TotSupPWReg = 0.0; 
        b.TotSupPWOT = 0.0;
        b.TotSupPWDBL = 0.0;
        b.TotSupNPWReg = 0.0;
        b.TotSupNPWOT = 0.0;
        b.TotSupNPWDBL = 0.0;
        b.TotCWPWReg = 0.0;
        b.TotCWPWOT = 0.0;
        b.TotCWPWDBL = 0.0;
        b.TotCWNPWReg = 0.0;
        b.TotCWNPWOT = 0.0;
        b.TotCWNPWDBL = 0.0;
        b.TotSupMon = '0.0';
        b.TotSupTue = '0.0';
        b.TotSupWed = '0.0';
        b.TotSupThu = '0.0';
        b.TotSupFri = '0.0';
        b.TotSupSat = '0.0';
        b.TotSupSun = '0.0';
        b.TotCWMon = '0.0';
        b.TotCWTue = '0.0';
        b.TotCWWed = '0.0';
        b.TotCWThu = '0.0';
        b.TotCWFri = '0.0';
        b.TotCWSat = '0.0';
        b.TotCWSun = '0.0';
        c.Name  = 'test' ;            
        c.PW = 'test';
        c.LaborCode = 'BCD';      
        c.MondayDBLHours  ='0.0';  
        c.MondayOTHours   ='0.0'; 
        c.MondayRegHours ='0.0'; 
        c.TuesdayDBLHours ='0.0'; 
        c.TuesdayOTHours ='0.0'; 
        c.TuesdayRegHours ='0.0'; 
        c.WednesdayDBLHours ='0.0'; 
        c.WednesdayOTHours ='0.0'; 
        c.WednesdayRegHours ='0.0'; 
        c.ThursdayDBLHours ='0.0'; 
        c.ThursdayOTHours ='0.0'; 
        c.ThursdayRegHours ='0.0'; 
        c.FridayDBLHours ='0.0'; 
        c.FridayOTHours ='0.0'; 
        c.FridayRegHours ='0.0'; 
        c.SaturdayDBLHours ='0.0'; 
        c.SaturdayOTHours ='0.0'; 
        c.SaturdayRegHours ='0.0'; 
        c.SundayDBLHours ='0.0'; 
        c.SundayOTHours  ='0.0'; 
        c.SundayRegHours ='0.0'; 
         d.Name  = 'test' ;            
        d.PW = 'test';
        d.LaborCode = 'BCD';      
        d.MondayDBLHours  ='0.0';  
        d.MondayOTHours   ='0.0'; 
        d.MondayRegHours ='0.0'; 
        d.TuesdayDBLHours ='0.0'; 
        d.TuesdayOTHours ='0.0'; 
        d.TuesdayRegHours ='0.0'; 
        d.WednesdayDBLHours ='0.0'; 
        d.WednesdayOTHours ='0.0'; 
        d.WednesdayRegHours ='0.0'; 
        d.ThursdayDBLHours ='0.0'; 
        d.ThursdayOTHours ='0.0'; 
        d.ThursdayRegHours ='0.0'; 
        d.FridayDBLHours ='0.0'; 
        d.FridayOTHours ='0.0'; 
        d.FridayRegHours ='0.0'; 
        d.SaturdayDBLHours ='0.0'; 
        d.SaturdayOTHours ='0.0'; 
        d.SaturdayRegHours ='0.0'; 
        d.SundayDBLHours ='0.0'; 
        d.SundayOTHours  ='0.0'; 
        d.SundayRegHours ='0.0'; 
        DailyTimesheetPDFTmpController.parse(json); 
        test.stopTest();
    }

}