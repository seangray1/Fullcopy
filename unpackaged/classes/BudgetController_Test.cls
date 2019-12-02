@istest
public class BudgetController_Test {
    
    static List<ATI_Job__c> jobs;
    static List<Budget_Line_Item__c> lineitem;
    public static TestMEthod Void TestBudgetController()
    {
        testDataSetup();
        Budget__c budget = new Budget__c();
        //budget.name = 'test';
        budget.ATI_Job__c = jobs[0].Id;
        budget.Allocations__c = '2';
        budget.X3_Program_Fees__c = '3';
        insert budget;
        
              
        lineitem = TestDataUtil.createLineItem(10, true, new Map<String, String>{'budget__c' => budget.Id} );
        for( Integer i=0; i< 10; i++ ){
            Budget_Line_Item__c item = lineitem[i];

        }
        update lineitem;
        
        ApexPages.StandardController controller = new ApexPages.standardController(budget);
        BudgetController UnitTest = new BudgetController(controller);
        PageReference pr = Page.BudgetSheet;
        
        test.setCurrentPage(pr);
        pr.getParameters().put('id', budget.id);
        ApexPages.currentPage().getParameters().put('Id', budget.id);
        
        UnitTest.saveLineItem(budget.id);
        UnitTest.saveBudget();
        UnitTest.quickSaveBudget();
        UnitTest.addLineItem();
        UnitTest.createLineItem();
        UnitTest.deleteLineItem();
        
    }
    
     static void testDataSetup(){
        System.runAs(new User(Id = userinfo.getUserId())){
            TestDataUtil.createCustomSettings_TriggerStatus();
        }
        List<Account> accounts = TestDataUtil.createAccounts(1, true, new Map<String, Object>{ 'Name' => 'testAcct',
                                               'BillingStreet' => 'Street 12',
                                                                       'BillingCity' => 'San Francisco',
                                                                       'BillingCountry' => 'USA',
                                                                       'BillingPostalCode' => '1234',
                                                                       'BillingState' => 'CA' } );
        jobs = TestDataUtil.createJob(10, true, new Map<String, String>{'account__c' => accounts[0].Id} );
     
        List<RecordType> rtypes = [SELECT Id FROM RecordType WHERE SObjectType ='ATI_Job__c' AND DeveloperName = 'Job_Approved'];
        for( Integer i=0; i< 10; i++ ){
            ATI_Job__c job = jobs[i];
            job.id = jobs[i].id;
            job.RecordTypeId = rtypes[0].Id;

        }
        update jobs;
 
    }

}