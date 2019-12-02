@istest
public class BudgetCloneController_Test {
    
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
        
        
        Budget__c newBudget = new Budget__c();
        newBudget.ATI_Job__c = jobs[0].Id;
        newBudget.Allocations__c = '2';
        newBudget.X3_Program_Fees__c = '3';
        insert newBudget;
              
        lineitem = TestDataUtil.createLineItem(10, true, new Map<String, String>{'budget__c' => budget.Id} );
        for( Integer i=0; i< 10; i++ ){
            Budget_Line_Item__c item = lineitem[i];

        }
        update lineitem;
        
        ApexPages.StandardController controller = new ApexPages.standardController(budget);
        BudgetCloneController UnitTest = new BudgetCloneController(controller);
        PageReference pr = Page.BudgetSheet;
        
        test.setCurrentPage(pr);
        pr.getParameters().put('id', budget.id);
        ApexPages.currentPage().getParameters().put('Id', budget.id);
    
        
        UnitTest.saveBudget();
        UnitTest.cloneLineItem(newBudget.id, budget.id);
        
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