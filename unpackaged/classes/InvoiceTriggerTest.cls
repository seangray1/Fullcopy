//Versoin 1.0
//Created by - Prabaharan Periasamy
//Date - 06/30/2016
//Tests invoice trigger functionality , as upon insert, update delete of one or bulk invoices
//
@isTest
public class InvoiceTriggerTest {

   // oldtestCode 
     private static testmethod void test_mapSFDCJobNumberToInvoice() {
        System.assertEquals('',       InvoiceControl.mapSFDCJobNumberToInvoice(null));
        System.assertEquals('',       InvoiceControl.mapSFDCJobNumberToInvoice(''));
        System.assertEquals('123',    InvoiceControl.mapSFDCJobNumberToInvoice('123'));
        System.assertEquals('12-12',  InvoiceControl.mapSFDCJobNumberToInvoice('12-12'));
        System.assertEquals('12-123', InvoiceControl.mapSFDCJobNumberToInvoice('121-23'));
        System.assertEquals('12-345', InvoiceControl.mapSFDCJobNumberToInvoice('000-00-12345'));
    }
    
    private static testmethod void test_mapSFDCDateToInvoice() {
        System.assertEquals('',         InvoiceControl.mapSFDCDateToInvoice((Date)null, true));
        System.assertEquals('',         InvoiceControl.mapSFDCDateToInvoice((Date)null, false));
        System.assertEquals('10022012', InvoiceControl.mapSFDCDateToInvoice(Date.newInstance(2012,10,2), false));
        System.assertEquals('100212',   InvoiceControl.mapSFDCDateToInvoice(Date.newInstance(2012,10,2), true));
        System.assertEquals('05022012', InvoiceControl.mapSFDCDateToInvoice(Date.newInstance(2012,5,2), false));
        System.assertEquals('050212',   InvoiceControl.mapSFDCDateToInvoice(Date.newInstance(2012,5,2), true));
        System.assertEquals('10022012', InvoiceControl.mapSFDCDateToInvoice(DateTime.newInstance(2012,10,2,5,5,5), false));
        System.assertEquals('100212',   InvoiceControl.mapSFDCDateToInvoice(DateTime.newInstance(2012,10,2,5,5,5), true));
    }
    
    //create simple invoice 
    private static testmethod void test_invoiceTrigger() {
        TestDataUtil.createCustomSettings_TriggerStatus();
        Invoice__c newInvoice = new Invoice__c(); 
        newInvoice.Due_Date__c = Date.Today();
        newInvoice.status__c = 'Ready for Billing';
        insert newInvoice;
    }
    
    //invoice with tax group
    private static testmethod void test_invoiceTrigger3() {
        TestDataUtil.createCustomSettings_TriggerStatus();
        RecordType tBusiness = [SELECT Id 
                                FROM RecordType 
                                WHERE Name = 'Business Account' 
                                    AND SObjectType = 'Account'];     
        Tax_Group__c taxGrp = new Tax_Group__c(   
            Name = 'EXEMPT',
            Tax_Rate__c = 10,
            Timberline_Id__c = 'EXEMPT'   
        );
        insert taxGrp;
        
        Account acct = TestDataUtil.createAccounts(1, true, new Map<String, String>{
                                                                'RecordTypeId' => tBusiness.Id,
                                                                'Status__c' => 'Active',
                                                                'Company_Type__c' => 'Agent/ Brokerage',
                                                                'Industry' => 'Apparel',
                                                                'Tax_group__c' => taxGrp.id
                                                            })[0];
        
        Contact con = TestDataUtil.createContacts(1, true, new Map<String, String>{'AccountId' => acct.Id})[0];
        List<ATI_Job__c> Jobs = TestDataUtil.createJob(10, true, new Map<String, String>{'account__c' => acct.Id} );
        
        Invoice__c inv = new Invoice__c(
            Due_Date__c = Date.Today()+1,
            ATI_Job__c = Jobs[0].Id,
            status__c = 'Ready for Billing'
        );
        insert inv;
        
        Invoice__c inv2 = new Invoice__c(
            Due_Date__c = Date.Today()+2,
            Bill_To__c = acct.Id,
            CC__c = con.Id,
            ATI_Job__c = Jobs[0].Id,
            status__c = 'Ready for Billing'
        );
        insert inv2;

        inv.name = 'test';
        inv.Bill_To__c = acct.id; 
        update inv;

    }
   
}