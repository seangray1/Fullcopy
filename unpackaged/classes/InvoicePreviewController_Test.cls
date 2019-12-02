@isTest
public class InvoicePreviewController_Test {
    
    private static testmethod void test_cancelPDF() {   
        RecordType tBusiness = [Select Id from RecordType Where Name = 'Business Account' and SObjectType = 'Account'];        
        TriggerStatus__c tStat = new TriggerStatus__c(
            AccountGenerateCustomerNumber__c = true,
            AccountSyncToTimberline__c = true,
            Forecast_Sync_to_Timberline__c = true,
            InvoiceAutomaticInvoiceNumber__c = true,
            InvoiceSyncToTimberline__c= true,
            InvoiceLineItemAutoCreation__c= true,
            InvoiceLineItemAutomaticNaming__c= true,
            InvoiceLineItemAutomaticOrder__c= true,
            InvoiceTaxGroupSetUp__c= true,
            JobCopyPMToOwner__c= true,
            JobOpportunitySync__c= true,
            JobSetJobNumber__c= true,
            JobSyncToTimberline__c= true,
            LeadPMLeadSync__c= true,
            OpportunityJobSync__c= true,
            PMLeadCalculateJobNumber__c= true,
            PMLeadConversion__c= true,
            PMLeadLeadSync__c= true,
            TaskTaskSync__c= true,
            TaxGroupRefreshFromTimberline__c= true,
            TaxGroupSetName__c= true
        );
        insert tStat; 
         
        
        Account acct = new Account(
            Name = 'TestAccount',
            RecordTypeId = tBusiness.Id,
            type = 'Insurance Company',
            Status__c = 'Active',
            BillingCity = 'test',
            BillingCountry = 'US',
            BillingState = 'st',
            BillingStreet = 'TestBStreet',
            BillingPostalCode = '23232',
            ShippingCity = 'TestSCity',
            ShippingCountry = 'TestSCountry',
            ShippingState = 'TestSState',
            ShippingStreet = 'TestSStreet',
            Company_Type__c = 'Agent/ Brokerage',
            Industry = 'Apparel'
        );
        insert acct;
        List<ATI_Job__c> jobs = TestDataUtil.createJob(10, true, new Map<String, String>{'Account__c' => acct.Id} );
     
        List<RecordType> rtypes = [SELECT Id FROM RecordType WHERE SObjectType ='ATI_Job__c' AND DeveloperName = 'Job_Approved'];
        for( Integer i=0; i< 10; i++ ){
            ATI_Job__c job = jobs[i];
            job.RecordTypeId = rtypes[0].Id;

        }
        update jobs;
   
        
        Contact con = new Contact(
            FirstName = 'TestFN',
            LastName = 'TestLN',
            Account = acct,
            Phone = '1234'
        );    
        //insert con;
        
        Invoice__c inv = new Invoice__c(
            Due_Date__c = Date.Today(),
            Bill_To__c = acct.Id,
            ATI_Job__c = jobs[0].id
            //CC__c = con.Id 
        );
        insert inv;
        
        String fields = ADCUtil_Base.strJoin(',', InvoicePDFController.ADDL_FIELDS, 'Id');
        Invoice__c r = (Invoice__c) Database.query('SELECT '+fields+' FROM Invoice__c ORDER BY LastModifiedDate DESC LIMIT 1');
        
        PageReference ref = Page.InvoicePreview;
        Test.setCurrentPage(ref);
        Apexpages.StandardController std = new Apexpages.StandardController(r);
        
        Test.startTest();
        InvoicePreviewController controller = new InvoicePreviewController(std);
        controller.formGeneratePDF.cancelPDF();            
        Test.stopTest();        
    }
    
    // Fail case
    private static testmethod void test_savePDF_withoutMockCallout() {   
        RecordType tBusiness = [Select Id from RecordType Where Name = 'Business Account' and SObjectType = 'Account'];        
        TriggerStatus__c tStat = new TriggerStatus__c(
            AccountGenerateCustomerNumber__c = true,
            AccountSyncToTimberline__c = true,
            Forecast_Sync_to_Timberline__c = true,
            InvoiceAutomaticInvoiceNumber__c = true,
            InvoiceSyncToTimberline__c= true,
            InvoiceLineItemAutoCreation__c= true,
            InvoiceLineItemAutomaticNaming__c= true,
            InvoiceLineItemAutomaticOrder__c= true,
            InvoiceTaxGroupSetUp__c= true,
            JobCopyPMToOwner__c= true,
            JobOpportunitySync__c= true,
            JobSetJobNumber__c= true,
            JobSyncToTimberline__c= true,
            LeadPMLeadSync__c= true,
            OpportunityJobSync__c= true,
            PMLeadCalculateJobNumber__c= true,
            PMLeadConversion__c= true,
            PMLeadLeadSync__c= true,
            TaskTaskSync__c= true,
            TaxGroupRefreshFromTimberline__c= true,
            TaxGroupSetName__c= true
        );
        insert tStat; 
   
        Account acct = new Account(
            Name = 'TestAccount',
            RecordTypeId = tBusiness.Id,
            type = 'Insurance Company',
            Status__c = 'Active',
            BillingCity = 'test',
            BillingCountry = 'US',
            BillingState = 'st',
            BillingStreet = 'TestBStreet',
            BillingPostalCode = '87765',
            ShippingCity = 'TestSCity',
            ShippingCountry = 'TestSCountry',
            ShippingState = 'TestSState',
            ShippingStreet = 'TestSStreet',
            Company_Type__c = 'Agent/ Brokerage',
            Industry = 'Apparel'
        );
        insert acct;
        List<ATI_Job__c> jobs = TestDataUtil.createJob(10, true, new Map<String, String>{'Account__c' => acct.Id} );
        Contact con = new Contact(
            FirstName = 'TestFN',
            LastName = 'TestLN',
            Account = acct,
            Phone = '1234'
        );    
        //insert con;
        
        Invoice__c inv = new Invoice__c(
            Due_Date__c = Date.Today(),
            Bill_To__c = acct.id,
            ATI_Job__c = jobs[0].id
            //CC__c = con.Id 
        );
        insert inv;
        
        String fields = ADCUtil_Base.strJoin(',', InvoicePDFController.ADDL_FIELDS, 'Id');
        Invoice__c r = (Invoice__c) Database.query('SELECT '+fields+' FROM Invoice__c ORDER BY LastModifiedDate DESC LIMIT 1');
        
        PageReference ref = Page.InvoicePreview;
        Test.setCurrentPage(ref);
        Apexpages.StandardController std = new Apexpages.StandardController(r);
        
        Test.startTest();
        InvoicePreviewController controller = new InvoicePreviewController(std);
        controller.formGeneratePDF.savePDF();  
        Test.stopTest();        
    }
    
    // Success case
    private static testmethod void test_savePDF_withMockCallout() {   
        RecordType tBusiness = [Select Id from RecordType Where Name = 'Business Account' and SObjectType = 'Account'];        
        TriggerStatus__c tStat = new TriggerStatus__c(
            AccountGenerateCustomerNumber__c = true,
            AccountSyncToTimberline__c = true,
            Forecast_Sync_to_Timberline__c = true,
            InvoiceAutomaticInvoiceNumber__c = true,
            InvoiceSyncToTimberline__c= true,
            InvoiceLineItemAutoCreation__c= true,
            InvoiceLineItemAutomaticNaming__c= true,
            InvoiceLineItemAutomaticOrder__c= true,
            InvoiceTaxGroupSetUp__c= true,
            JobCopyPMToOwner__c= true,
            JobOpportunitySync__c= true,
            JobSetJobNumber__c= true,
            JobSyncToTimberline__c= true,
            LeadPMLeadSync__c= true,
            OpportunityJobSync__c= true,
            PMLeadCalculateJobNumber__c= true,
            PMLeadConversion__c= true,
            PMLeadLeadSync__c= true,
            TaskTaskSync__c= true,
            TaxGroupRefreshFromTimberline__c= true,
            TaxGroupSetName__c= true
        );
        insert tStat; 
   
        Account acct = new Account(
            Name = 'TestAccount',
            RecordTypeId = tBusiness.Id,
            type = 'Insurance Company',
            Status__c = 'Active',
            BillingCity = 'test',
            BillingCountry = 'US',
            BillingState = 'Ts',
            BillingStreet = 'TestBStreet',
            BillingPostalCode = '00073',
            ShippingCity = 'TestSCity',
            ShippingCountry = 'TestSCountry',
            ShippingState = 'TestSState',
            ShippingStreet = 'TestSStreet',
            Company_Type__c = 'Agent/ Brokerage',
            Industry = 'Apparel'
        );
        insert acct;
         List<ATI_Job__c> jobs = TestDataUtil.createJob(10, true, new Map<String, String>{'Account__c' => acct.Id} );
        Contact con = new Contact(
            FirstName = 'TestFN',
            LastName = 'TestLN',
            Account = acct,
            Phone = '1234'
        );    
        //insert con;
        
        Invoice__c inv = new Invoice__c(
            Due_Date__c = Date.Today(),
            Bill_To__c = acct.Id,
            ATI_Job__c = jobs[0].id
           // CC__c = con.Id 
        );
        insert inv;
        
        String fields = ADCUtil_Base.strJoin(',', InvoicePDFController.ADDL_FIELDS, 'Id');
        Invoice__c r = (Invoice__c) Database.query('SELECT '+fields+' FROM Invoice__c ORDER BY LastModifiedDate DESC LIMIT 1');
        
        PageReference ref = Page.InvoicePreview;
        Test.setCurrentPage(ref);
        Apexpages.StandardController std = new Apexpages.StandardController(r);
        
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Test.startTest();
        InvoicePreviewController controller = new InvoicePreviewController(std);
        controller.formGeneratePDF.savePDF();  
        Test.stopTest();        
    }

}