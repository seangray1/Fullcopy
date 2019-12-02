/**
AUTHOR:    LENNARD SANTOS
COMPANY:    CLOUDSHERPAS
DATE CREATED:  MARCH 19,2013
DESCRIPTION: TEST CLASS FOR ATIInvoiceController apex class
HISTORY: 03-19-2013  Created.
**/
@isTest
private class TestATIInvoiceController{
    
    static testMethod void TestInvController(){    
        TestDataUtil.createCustomSettings_TriggerStatus();
        RecordType tBusiness = [Select Id from RecordType Where Name = 'Business Account' and SObjectType = 'Account'];
        RecordType tPersons = [Select Id from RecordType Where Name = 'Person Accounts' and SObjectType = 'Account'];    
        //Create Test Record for Custom Setting
        
        Tax_Group__c taxGrp = new Tax_Group__c(
            
            Name = 'TestTaxGroup',
            Tax_Rate__c = 25,
            Timberline_Id__c = 'TestTaxGroup'   
        );
        insert taxGrp;
        Account personacc = New Account(
            firstName = 'testAcct',
            lastname = 'test',
            BillingStreet = 'Street \\\\ 12',
            BillingCity = 'test',
            BillingState = 'CA',
            BillingCountry = 'US',
            BillingPostalCode = '00002', 
            RecordTypeID = tpersons.id
            );
                                                                               
        Account acc = TestDataUtil.createAccounts(1, true, 
                                                      new Map<String, Object>{ 'Name' => 'testAcct',
                                                                               'BillingStreet' => 'Street \\\\ 12',
                                                                               'BillingCity' => 'San Francisco',
                                                                               'BillingCountry' => 'USA',
                                                                               'BillingPostalCode' => '1234',
                                                                               'BillingState' => 'CA',
                                                                               'Billing_Notes__c' => 'Test',
                                                                               'RecordTypeId' => tBusiness.Id,
                                                                               'Status__c' => 'Active',                        
                                                                               'Tax_Group__c' => taxGrp.Id,
                                                                               'ShippingCity' => 'SFO',
                                                                               'ShippingCountry' => 'USA',
                                                                               'ShippingState' => 'CA',
                                                                               'ShippingStreet' => 'TestSStreet',
                                                                               'Company_Type__c' => 'Agent/ Brokerage',
                                                                               'Industry' => 'Apparel'})[0];       
        
        
        Contact con = new Contact(
            FirstName = 'TestFN',
            LastName = 'TestLN',
            AccountId = acc.Id,
            Phone = '1234'
        );    
        
        insert con;   
        
        Billing_Address__c Address = new Billing_Address__c(
            Billing_Street__c = 'test',
            Billing_City__c = 'test',
            Billing_State__c = 'LA',
            Billing_Zipcode__c = '90003',
            Account__c = personacc.id
         );
         
        Invoice__c inv = new Invoice__c(
            //Name = 'TestInvoice',
            Due_Date__c = Date.Today(),
            Bill_To__c = acc.Id,
            CC__c = con.Id, 
            CC_Account__c = acc.Id,
            Care_Of__c = acc.id,
            Bill_to_Tax_Group__c = taxGrp.id,
            status__c = 'Ready for Billing'
            
        );
        insert inv;
        Invoice_Line_Item__c invLineItem1 = new Invoice_Line_Item__c(
            Invoice__c = inv.Id,
            PickListName__c = 'Value4',
            Description__c = 'Value4',
            Amount__c = 25,
            Order__c = 1,
            IsCredit__c = true,
            Taxable__c = true
        );
        insert invLineItem1;
        Invoice_Line_Item__c invLineItem2 = new Invoice_Line_Item__c(
            Invoice__c = inv.Id,
            PickListName__c = 'Value4',
            Description__c = 'Value4',
            Amount__c = 0,
            Order__c = 1
        );    
        insert invLineItem2;
        Invoice_Line_Item__c invLineItem3 = new Invoice_Line_Item__c(
            Invoice__c = inv.Id,
            PickListName__c = 'Value4',
            Description__c = 'Value4',
            Note__c = true,
            Order__c = 1
        );       
        insert invLineItem3;
        Invoice_Line_Item__c invLineItemWC = new Invoice_Line_Item__c(
            PickListName__c = 'Value4',
            Description__c = 'Value4',
            Note__c = true,
            Order__c = 1
        );
        
        ApexPages.StandardController controller = new ApexPages.StandardController(inv);
        ApexPages.currentPage().getParameters().put('id', inv.id);
        ATIInvoiceController ATIcon = new ATIInvoiceController(controller);
        ATIcon.invoiceRecord.Bill_To__c = acc.Id;
        ATIcon.invoiceRecord.CC__c = con.Id;
        //ATICon.contextBusinessAddressType = 'BillToAddress';
        //ATIcon.contextBusinessAddressId = Address.id;
        //Insert new record in wrapper list
        ATIcon.WrapInvoice.add(new ATIInvoiceController.WrapperClass(1,invLineItemWC));
        System.Assert(ATIcon.WrapInvoice.isEmpty()!=true);
        integer wrapListSize = ATIcon.WrapInvoice.size();
        //Run instance of add line items to mimic Add Line Item button on VF page
        ATIcon.AddLineItem();
        System.AssertEquals(ATIcon.WrapInvoice.size(),wrapListSize + 1);
        ATIcon.updateBillingTo();
        ATIcon.PrePopData();
        ATIcon.PrePopCC();
        ATIcon.quickSaveInvoice();
        ATIcon.saveInvoice();
        System.assertEquals(ApexPages.currentPage().getParameters().get('id'),inv.Id);
        //Check if value of Controller Variable sBillingStreet is equal to inserted Account BillingStreet
        system.debug('****************************************************************'+aticon.sbillingstreet);
        //System.assertEquals(ATIcon.sBillingStreet,acc.BillingStreet);         
        //Check if value of Controller Variable sMailingStr is equal to inserted Contact Mailing Street
        //System.assertEquals(ATIcon.sMailStr,con.MailingStreet);
     
        
    }
    
    static testMethod void TestErrorMsg(){
        Test.setCurrentPage(Page.ATIInvoicePage);
        ApexPages.StandardController controller = new ApexPages.StandardController(new Invoice__c());
        ATIInvoiceController ATIcon = new ATIInvoiceController(controller); 
        ATIcon.saveInvoice();   
        List<ApexPages.Message> msgList = ApexPages.getMessages();
         for(ApexPages.Message msg :  ApexPages.getMessages()) {
             System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity()); 
         }   
    }
    
    static testMethod void TestErrorMsg2(){
        Test.setCurrentPage(Page.ATIInvoicePage);
        ApexPages.StandardController controller = new ApexPages.StandardController(new Invoice__c());
        ATIInvoiceController ATIcon = new ATIInvoiceController(controller); 
        ATIcon.quickSaveInvoice();  
        List<ApexPages.Message> msgList = ApexPages.getMessages();
                for(ApexPages.Message msg :  ApexPages.getMessages()) {
                System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity()); 
                }
   
    }
    
    static testMethod void TestInvWithNull(){
        Test.setCurrentPage(Page.ATIInvoicePage);
        ApexPages.StandardController controller = new ApexPages.StandardController(new Invoice__c());
        ATIInvoiceController ATIcon = new ATIInvoiceController(controller); 
        ATIcon.invoiceRecord.Bill_To__c = null;
   
    }
    
   
   static testMethod void TestDeleteLineItem(){
        RecordType tBusiness = [Select Id from RecordType Where Name = 'Business Account' and SObjectType = 'Account'];
        RecordType tPersons = [Select Id from RecordType Where Name = 'Person Accounts' and SObjectType = 'Account'];
        TestDataUtil.createCustomSettings_TriggerStatus();
        Account acc = TestDataUtil.createAccounts(1, true, 
                                                      new Map<String, Object>{ 'Name' => 'testAcct',
                                                                               'BillingStreet' => 'Street \\\\ 12',
                                                                               'BillingCity' => 'San Francisco',
                                                                               'BillingCountry' => 'USA',
                                                                               'BillingPostalCode' => '1234',
                                                                               'BillingState' => 'CA',
                                                                               'RecordTypeId' => tBusiness.Id,
                                                                               'Status__c' => 'Active', 
                                                                               'Billing_Notes__c' => 'Test',                       
                                                                               'ShippingCity' => 'SFO',
                                                                               'ShippingCountry' => 'USA',
                                                                               'ShippingState' => 'CA',
                                                                               'ShippingStreet' => 'TestSStreet',
                                                                               'Company_Type__c' => 'Agent/ Brokerage',
                                                                               'Industry' => 'Apparel'})[0];
                         
        Contact con = new Contact(
            FirstName = 'TestFN',
            LastName = 'TestLN',
            AccountId = acc.Id,
            Phone = '1234'
        );        
         
        insert con;        
        Invoice__c inv = new Invoice__c(
            //Name = 'TestInvoice',
            Due_Date__c = Date.Today(),
            status__c = 'Ready for Billing'
        );     
        insert inv;
        Invoice_Line_Item__c invLineItemWC = new Invoice_Line_Item__c(
            Invoice__c = inv.id,
            PickListName__c = 'Value4',
            Description__c = 'Value4',
            Taxable__c = true,
            Order__c = 1
        );
        insert invLineItemWC;
        ApexPages.StandardController controller = new ApexPages.StandardController(inv);
        ATIInvoiceController ATIcon = new ATIInvoiceController(controller);
        ATIcon.invoiceRecord.Bill_To__c = acc.Id;
        ATIcon.invoiceRecord.CC__c = con.Id;
        ATIcon.count = 1;
        ATIcon.deleteLineItem();
        System.debug('****WRAP INVOICE TEST***' + ATIcon.WrapInvoice);
        ATIcon.saveInvoice();
        System.debug('****WRAP INVOICE AFTER TEST***' + ATIcon.WrapInvoice);
        //Check wrapper list size if wrapper has 2 records...wrapper list always starts with 3 empty records
        //upon running the controller instance
        System.Assert(ATIcon.WrapInvoice.size()==2);       
    }
}