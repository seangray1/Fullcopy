@isTest
public class ScheduleController_Test {
    //static List<ATI_Job__c> Jobs;
    //static list<Schedule_Line_Item__c> lineItems;
    
    public static TestMethod void TestScheduleController()
    {
        List<ATI_Job__c> Jobs = getJob();
        Schedule__c schedule = new Schedule__c();
        schedule.ATI_Job__c = Jobs[0].id;
        schedule.Final_Completion_date__c = date.today();
        
        insert schedule; 
        
        list<Schedule_Line_Item__c> lineItems = new list<Schedule_Line_Item__c>();
        
        for(Integer i=0; i<10; i++ ){
            Schedule_Line_Item__c item = new Schedule_Line_Item__c();
            item.schedule__c = schedule.Id;
            item.start_date__c = date.today();
            item.Completion_Date__c = date.today();
            item.Products__c = 'Appliances';
            
            system.debug('this is the lineitem:' + lineItems);
            lineItems.add(item);
        }
        if(lineItems != null)
   			upsert lineItems;

        
        ApexPages.StandardController controller = new ApexPages.StandardController(schedule);
        ScheduleController testSchedule = new ScheduleController(controller);
        PageReference pg = Page.Schedule;
        
        test.setCurrentPage(pg);
        pg.getParameters().put('id', schedule.id);
        ApexPages.CurrentPage().getParameters().put('id', schedule.Id);
        
        System.assertEquals(true, Schedule.id != null);
        testSchedule.SaveLineItem(schedule.id);
        testSchedule.saveSchedule();
        testSchedule.quickSaveSchedule();
        testSchedule.addrow();
        testSchedule.CreateLineItem();
        testSchedule.DeleteLineItem();   
        
    }
    
    //test data
 public static List<ATI_Job__c> GetJob()
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
        Jobs = TestDataUtil.createJob(10, true, new Map<String, String>{'account__c' => accounts[0].Id} );
     
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