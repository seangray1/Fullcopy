@isTest
public class SchedulePDFController_Test {

    private static testmethod void test_init() {
        
        List<ATI_Job__c> jobs = getOpportunity();
        Schedule__c schedule = new Schedule__c();
        schedule.ATI_Job__c = jobs[0].id;
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

          
        String fields = ADCUtil_Base.strJoin(',', SchedulePDFController.ADDL_FIELDS, 'scheduleId');
        List<schedule__c> recs = (List<schedule__c>)(Database.query('SELECT '+fields+' FROM schedule__c ORDER BY CreatedDate DESC LIMIT 1'));
        schedule__c r = recs.size() > 0 ? recs[0] : schedule;
        
        PageReference ref = Page.SchedulePDF;
        Test.setCurrentPage(ref);
        Apexpages.StandardController std = new Apexpages.StandardController(r);
        
        Test.startTest();
        SchedulePDFController controller = new SchedulePDFController(std);
        
        
        Test.stopTest(); 
        
    } 
     public static List<ATI_Job__c> GetOpportunity()
    {
        List<ATI_Job__c> jobs;
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
            job.Division__c = 'Asbestos';

        }
        update jobs; 
        
        return jobs;
    }

}