@isTest
Public class BudgetPreviewController_Test{
 private static testmethod void test_cancelPDF() {   
    
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

        Budget__c budget = new Budget__c();
        budget.ATI_Job__c = jobs[0].Id;
        budget.Allocations__c = '2';
        
        insert budget; 
        
         List<Budget_Line_Item__c> lineitem = TestDataUtil.createLineItem(10, true, new Map<String, String>{'budget__c' => budget.Id} );
        for( Integer i=0; i< 10; i++ ){
            Budget_Line_Item__c item = lineitem[i];

        }
        update lineitem;
        
        
        String fields = ADCUtil_Base.strJoin(',', BudgetPreviewController.ADDL_FIELDS, 'budget.Id');
        //Budget__c r = (Budget__c) Database.query('SELECT '+fields+' FROM Budget__c ORDER BY CreatedDate DESC LIMIT 1');
        
       // String fields = ADCUtil_Base.strJoin(',', ATI_Job_BudgetPreviewController.ADDL_FIELDS, 'budgetId');
        List<Budget__c> recs = (List<Budget__c>)(Database.query('SELECT '+fields+' FROM Budget__c ORDER BY CreatedDate DESC LIMIT 1'));
        Budget__c r = recs.size() > 0 ? recs[0] : budget;
        
        
        PageReference ref = Page.expensePreview;
        Test.setCurrentPage(ref);
        Apexpages.StandardController std = new Apexpages.StandardController(r);
        
        Test.startTest();
        BudgetPreviewController controller = new BudgetPreviewController(std);
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

        Budget__c budget = new Budget__c();
        budget.ATI_Job__c = jobs[0].Id;
        budget.Allocations__c = '2';
        
        insert budget; 
        
         List<Budget_Line_Item__c> lineitem = TestDataUtil.createLineItem(10, true, new Map<String, String>{'budget__c' => budget.Id} );
        for( Integer i=0; i< 10; i++ ){
            Budget_Line_Item__c item = lineitem[i];

        }
        update lineitem;
        
        
        String fields = ADCUtil_Base.strJoin(',', BudgetPreviewController.ADDL_FIELDS, 'budget.Id');
        //Budget__c r = (Budget__c) Database.query('SELECT '+fields+' FROM Budget__c ORDER BY CreatedDate DESC LIMIT 1');
        
       // String fields = ADCUtil_Base.strJoin(',', ATI_Job_BudgetPreviewController.ADDL_FIELDS, 'budgetId');
        List<Budget__c> recs = (List<Budget__c>)(Database.query('SELECT '+fields+' FROM Budget__c ORDER BY CreatedDate DESC LIMIT 1'));
        Budget__c r = recs.size() > 0 ? recs[0] : budget;
        
        PageReference ref = Page.expensePreview;
        Test.setCurrentPage(ref);
        Apexpages.StandardController std = new Apexpages.StandardController(r);
        
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Test.startTest();
        BudgetPreviewController controller = new BudgetPreviewController(std);
        controller.formGeneratePDF.savePDF();  
        Test.stopTest();        
    }   


}