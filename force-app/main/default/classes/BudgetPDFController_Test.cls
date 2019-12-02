@isTest()
public class BudgetPDFController_Test{

    private static testmethod void test_init() {
        
        System.runAs(new User(Id = userinfo.getUserId())){
            TestDataUtil.createCustomSettings_TriggerStatus();
        }
        List<Account> accounts = TestDataUtil.createAccounts(1, true, new Map<String, Object>{ 'Name' => 'testAcct',
                                               'BillingStreet' => 'Street 12',
                                                                       'BillingCity' => 'San Francisco',
                                                                       'BillingCountry' => 'USA',
                                                                       'BillingPostalCode' => '1234',
                                                                       'BillingState' => 'CA' } );
        List<ATI_Job__c> jobs = TestDataUtil.createJob(10, true, new Map<String, String>{'account__c' => accounts[0].Id} );
     
        List<RecordType> rtypes = [SELECT Id FROM RecordType WHERE SObjectType ='ATI_Job__c' AND DeveloperName = 'Job_Approved'];
        for( Integer i=0; i< 10; i++ ){
            ATI_Job__c job = jobs[i];
            job.RecordTypeId = rtypes[0].Id;

        }
        update jobs;
        
        
        Budget__c budget = new Budget__c();
        budget.ATI_Job__c = jobs[0].Id;
        budget.Allocations__c = '2';
        insert budget;
        
              
         List<Budget_Line_Item__c> lineitem = TestDataUtil.createLineItem(10, true, new Map<String, String>{'budget__c' => budget.Id} );
        for( Integer i=0; i< 10; i++ ){
            Budget_Line_Item__c item = lineitem[i];

        }
        update lineitem;
          
        String fields = ADCUtil_Base.strJoin(',', BudgetPDFController.ADDL_FIELDS, 'budgetId');
        List<Budget__c> recs = (List<Budget__c>)(Database.query('SELECT '+fields+' FROM Budget__c ORDER BY CreatedDate DESC LIMIT 1'));
        Budget__c r = recs.size() > 0 ? recs[0] : budget;
        
        PageReference ref = Page.ExpensePDF;
        Test.setCurrentPage(ref);
        Apexpages.StandardController std = new Apexpages.StandardController(r);
        
        Test.startTest();
        BudgetPDFController controller = new BudgetPDFController(std);
        
        
        Test.stopTest();
        
    } 
    
}