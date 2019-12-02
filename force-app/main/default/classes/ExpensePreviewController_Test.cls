@isTest
Public class ExpensePreviewController_Test{

 private static testmethod void test_cancelPDF() {   
        RecordType tBusiness = [Select Id from RecordType Where Name = 'Business Account' and SObjectType = 'Account'];  
        User user = [Select id from User where name=:'SF Test'];                
     	Account acct = TestDataUtil.createAccounts(1, true, 
                                                      new Map<String, Object>{ 'Name' => 'testAcct',
            																   'BillingStreet' => 'Street 12',
                                                          					   'RecordTypeId' => tBusiness.Id,
            																    'Status__c' => 'Active',
                                                          					   'BillingCity' => 'San Francisco',
                                                          					   'BillingCountry' => 'USA',
                                                          					   'BillingPostalCode' => '1234',
                                                          					   'BillingState' => 'CA',
                                                          					   'ShippingCity' => 'TestSCity',
                                                                               'ShippingCountry' => 'USA',
                                                                               'ShippingState' => 'CA',
                                                                               'ShippingStreet' => 'TestSStreet',
                                                                               'Company_Type__c' => 'Agent/ Brokerage',
                                                                               'Industry' => 'Apparel'})[0];
                
        Contact con = new Contact(
            FirstName = 'TestFN',
            LastName = 'TestLN',
            AccountId = acct.Id,
            Phone = '1234'
        );    
        insert con;
        
       
        Expense__c inv = new Expense__c(
            Date__c = system.Today(),
            Name = 'Test',
            CreatedBy = [Select id from User where name=:'SF Test']
            
        );
        insert inv;  
        
        String fields = ADCUtil_Base.strJoin(',', ExpensePDFController.ADDL_FIELDS, 'inv.Id');
        Expense__c r = (Expense__c) Database.query('SELECT '+fields+' FROM Expense__c ORDER BY LastModifiedDate DESC LIMIT 1');
        
        PageReference ref = Page.expensePreview;
        Test.setCurrentPage(ref);
        Apexpages.StandardController std = new Apexpages.StandardController(r);
        
        Test.startTest();
        ExpensePreviewController controller = new ExpensePreviewController(std);
        controller.formGeneratePDF.cancelPDF();            
        Test.stopTest();        
    }
    
    /***
    // Fail case 
    private static testmethod void test_savePDF_withoutMockCallout() {   
        RecordType tBusiness = [Select Id from RecordType Where Name = 'Business Account' and SObjectType = 'Account'];        
       
        Account acct = new Account(
            Name = 'TestAccount',
            RecordTypeId = tBusiness.Id,
            Status__c = 'Active',
            BillingCity = 'TestBCity',
            BillingCountry = 'TestBCountry',
            BillingState = 'TestBState',
            BillingStreet = 'TestBStreet',
            ShippingCity = 'TestSCity',
            ShippingCountry = 'TestSCountry',
            ShippingState = 'TestSState',
            ShippingStreet = 'TestSStreet',
            Company_Type__c = 'Agent/ Brokerage',
            Industry = 'Apparel'
        );
        insert acct;
        
        Contact con = new Contact(
            FirstName = 'TestFN',
            LastName = 'TestLN',
            Account = acct,
            Phone = '1234'
        );    
        insert con;
        
        Expense__c inv = new Expense__c(
            Date__c = system.Today(),
            name = 'Test123' 
        );
        insert inv;
        
        String fields = ADCUtil_Base.strJoin(',', ExpensePDFController.ADDL_FIELDS, 'Id');
        Expense__c r = (Expense__c) Database.query('SELECT '+fields+' FROM Expense__c ORDER BY LastModifiedDate DESC LIMIT 1');
        
        PageReference ref = Page.expensePreview;
        Test.setCurrentPage(ref);
        Apexpages.StandardController std = new Apexpages.StandardController(r);
        
        Test.startTest();
        ExpensePreviewController controller = new ExpensePreviewController(std);
        controller.formGeneratePDF.savePDF();  
        Test.stopTest();        
    }***/
    
    // Success case
    private static testmethod void test_savePDF_withMockCallout() {   
        RecordType tBusiness = [Select Id from RecordType Where Name = 'Business Account' and SObjectType = 'Account'];        
       
        Account acct = TestDataUtil.createAccounts(1, true, 
                                                      new Map<String, Object>{ 'Name' => 'testAcct',
            																   'BillingStreet' => 'Street 12',
                                                          					   'RecordTypeId' => tBusiness.Id,
            																    'Status__c' => 'Active',
                                                          					   'BillingCity' => 'San Francisco',
                                                          					   'BillingCountry' => 'USA',
                                                          					   'BillingPostalCode' => '1234',
                                                          					   'BillingState' => 'CA',
                                                          					   'ShippingCity' => 'TestSCity',
                                                                               'ShippingCountry' => 'USA',
                                                                               'ShippingState' => 'CA',
                                                                               'ShippingStreet' => 'TestSStreet',
                                                                               'Company_Type__c' => 'Agent/ Brokerage',
                                                                               'Industry' => 'Apparel'})[0];
        
        Contact con = new Contact(
            FirstName = 'TestFN',
            LastName = 'TestLN',
            AccountId = acct.id,
            Phone = '1234'
        );    
        insert con;
        
        Expense__c inv = new Expense__c(
            Date__c = system.Today(),
            name = 'Test345',
            CreatedBy = [Select id from User where name=:'SF Test']
        );
        insert inv;
        
        String fields = ADCUtil_Base.strJoin(',', ExpensePDFController.ADDL_FIELDS, 'inv.Id');
        Expense__c r = (Expense__c) Database.query('SELECT '+fields+' FROM Expense__c ORDER BY LastModifiedDate DESC LIMIT 1');
        
        PageReference ref = Page.expensePreview;
        Test.setCurrentPage(ref);
        Apexpages.StandardController std = new Apexpages.StandardController(r);
        
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Test.startTest();
        ExpensePreviewController controller = new ExpensePreviewController(std);
        controller.formGeneratePDF.savePDF();  
        Test.stopTest();        
    }   
     


}