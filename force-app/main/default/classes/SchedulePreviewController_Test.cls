@isTest
public class SchedulePreviewController_Test {

 private static testmethod void test_cancelPDF() {   

        List<ATI_Job__c> Jobs = getOpportunity();
        Schedule__c schedule = new Schedule__c();
        schedule.ATI_Job__c = Jobs[0].id;
        schedule.Final_Completion_date__c = date.today();
        
        insert schedule; 
        
      list<Schedule_Line_Item__c> lineitem = new list<Schedule_Line_Item__c>();
        for(Integer i=0; i<10; i++ ){
            Schedule_Line_Item__c item = new Schedule_Line_Item__c();
            item.schedule__c = schedule.Id;
            item.start_date__c = date.today();
            item.Completion_Date__c = date.today();
            item.Products__c = 'Appliances';
            
            system.debug('this is the lineitem:' + lineitem);
            lineitem.add(item);
        }
        if(lineitem != null)
            upsert lineitem;
        
        
        String fields = ADCUtil_Base.strJoin(',', SchedulePDFController.ADDL_FIELDS, 'Schedule.Id');
        //Schedule__c r = (Schedule__c) Database.query('SELECT '+fields+' FROM Schedule__c ORDER BY CreatedDate DESC LIMIT 1');
        
       // String fields = ADCUtil_Base.strJoin(',', SchedulePDFController.ADDL_FIELDS, 'ScheduleId');
        List<Schedule__c> recs = (List<Schedule__c>)(Database.query('SELECT '+fields+' FROM Schedule__c ORDER BY CreatedDate DESC LIMIT 1'));
        Schedule__c r = recs.size() > 0 ? recs[0] : Schedule;
        
        
        PageReference ref = Page.expensePreview;
        Test.setCurrentPage(ref);
        Apexpages.StandardController std = new Apexpages.StandardController(r);
        
        Test.startTest();
        SchedulePreviewController controller = new SchedulePreviewController(std);
        controller.formGeneratePDF.cancelPDF();            
        Test.stopTest();        
    }
    
    // Success case
    private static testmethod void test_savePDF_withMockCallout() {
        System.runAs(new User(Id = userinfo.getUserId())){
            TestDataUtil.createCustomSettings_TriggerStatus();
        }
        List<Account> accounts = TestDataUtil.createAccounts(1, true, new Map<String, Object>{ 'Name' => 'testAcct',
                                               'BillingStreet' => 'Street 12',
                                                                       'BillingCity' => 'San Francisco',
                                                                       'BillingCountry' => 'USA',
                                                                       'BillingPostalCode' => '1234',
                                                                       'BillingState' => 'CA' } );
        List<ATI_Job__c> jobs = TestDataUtil.createJob(10, true, new Map<String, String>{'Account__c' => accounts[0].Id} );
     
        List<RecordType> rtypes = [SELECT Id FROM RecordType WHERE SObjectType ='ATI_Job__c' AND DeveloperName = 'Job_Approved'];
        for( Integer i=0; i< 10; i++ ){
            ATI_Job__c job = jobs[i];
            job.RecordTypeId = rtypes[0].Id;
        }
        update jobs;

        //List<ATI_Job__c> Jobs = getOpportunity();
        Schedule__c schedule = new Schedule__c();
        schedule.ATI_Job__c = Jobs[0].id;
        schedule.Final_Completion_date__c = date.today();
       
        insert schedule; 
        
      list<Schedule_Line_Item__c> lineitem = new list<Schedule_Line_Item__c>();
        for(Integer i=0; i<10; i++ ){
            Schedule_Line_Item__c item = new Schedule_Line_Item__c();
            item.schedule__c = schedule.Id;
            item.start_date__c = date.today();
            item.Completion_Date__c = date.today();
            item.Products__c = 'Appliances';
            
            system.debug('this is the lineitem:' + lineitem);
            lineitem.add(item);
        }
       
            upsert lineitem;
        
        
        String fields = ADCUtil_Base.strJoin(',', SchedulePDFController.ADDL_FIELDS, 'Schedule.Id');
        //Schedule__c r = (Schedule__c) Database.query('SELECT '+fields+' FROM Schedule__c ORDER BY CreatedDate DESC LIMIT 1');
        
       // String fields = ADCUtil_Base.strJoin(',', SchedulePDFController.ADDL_FIELDS, 'ScheduleId');
        List<Schedule__c> recs = (List<Schedule__c>)(Database.query('SELECT '+fields+' FROM Schedule__c ORDER BY CreatedDate DESC LIMIT 1'));
        Schedule__c r = recs.size() > 0 ? recs[0] : Schedule;
        
        PageReference ref = Page.expensePreview;
        Test.setCurrentPage(ref);
        Apexpages.StandardController std = new Apexpages.StandardController(r);
        
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Test.startTest();
        SchedulePreviewController controller = new SchedulePreviewController(std);
        controller.formGeneratePDF.savePDF();  
        Test.stopTest();     
    }   
    
    public static List<ATI_Job__c> GetOpportunity()
    {
        List<ATI_Job__c> Jobs;
        System.runAs(new User(Id = userinfo.getUserId())){
            TestDataUtil.createCustomSettings_TriggerStatus();
        }
        List<Account> accounts = TestDataUtil.createAccounts(1, true, new Map<String, Object>{ 'Name' => 'testAcct',
                                               'BillingStreet' => 'Street 12',
                                                                       'BillingCity' => 'San Francisco',
                                                                       'BillingCountry' => 'USA',
                                                                       'BillingPostalCode' => '1234',
                                                                       'BillingState' => 'CA' } );
        Jobs = TestDataUtil.createJob(10, true, new Map<String, String>{'Account__c' => accounts[0].Id} );
     
        List<RecordType> rtypes = [SELECT Id FROM RecordType WHERE SObjectType ='ATI_Job__c' AND DeveloperName = 'Job_Approved'];
        for( Integer i=0; i< 10; i++ ){
            ATI_Job__c Job = Jobs[i];
            Job.RecordTypeId = rtypes[0].Id;
            Job.Division__c = 'Asbestos';

        }
        update Jobs; 
        
        return Jobs;
    }

}