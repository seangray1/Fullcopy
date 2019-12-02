@istest
public class InvoiceExport_Test {
    public static testmethod void method1(){
                RecordType tBusiness = [Select Id from RecordType Where Name = 'Business Account' and SObjectType = 'Account'];        
        TestDataUtil.createCustomSettings_TriggerStatus();
        Tax_Group__c taxGrp = new Tax_Group__c(           
            Name = 'TestTaxGroup',
            Tax_Rate__c = 25,
            Timberline_Id__c = 'TestTaxGroup',
                        Tax1Name__c = 'TestTax',
            Tax1Rate__c = 1,
            Tax2Name__c = 'TestTax2',
            Tax2Rate__c = 2,
            Tax3Name__c = 'TestTax3',
            Tax3Rate__c = 3,
            Tax4Name__c ='Tax4',
            Tax4Rate__c = 4,
            Tax5Name__c = 'tax5',
            Tax5Rate__c = 5,
            Tax6Name__c = 'tax6',
            Tax6Rate__c = 6,
            Tax7Name__c = 'tax6',
            Tax7Rate__c = 7,
            Tax8Name__c = 'tax6',
            Tax8Rate__c = 8,
            Tax9Name__c = 'tax6',
            Tax9Rate__c = 9
        );
        insert taxGrp;
   
        Account acct = TestDataUtil.createAccounts(1, true, 
                                                      new Map<String, Object>{ 'Name' => 'testAcct',
                                               'BillingStreet' => 'Street \\\\ 12',
                                                                       'BillingCity' => 'San Francisco',
                                                                       'BillingCountry' => 'USA',
                                                                       'BillingPostalCode' => '1234',
                                                                       'BillingState' => 'CA',
                                                                       'RecordTypeId' => tBusiness.Id,
                                                                               'Status__c' => 'Active',                        
                                                                               'ShippingCity' => 'SFO',
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
        
        Invoice__c inv = new Invoice__c(
            Due_Date__c = Date.Today(),
            Bill_To__c = acct.Id,
            CC__c = con.Id,
            Retainage_Held_percent__c=1,
            Bill_to_Tax_Group__c = taxGrp.id
            
        );
        insert inv;

        Invoice_Line_Item__c invLineItem1 = new Invoice_Line_Item__c(
            Invoice__c = inv.Id,
            PickListName__c = 'Value4',
            Description__c = 'Value4',
            Amount__c = 25,
            Order__c = 1,
            IsCredit__c = False,
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
        
        Test.StartTest();
        List<InvoiceExport.Invoice> invoices = InvoiceExport.getInvoice(new List<Id>{inv.id});
        Test.StopTest();
        
      //  System.AssertEquals(1, invoices.size());
     //   System.AssertEquals(1, invoices[0].InvoiceLines.size());
      //  System.AssertEquals(0, invoices[0].TaxLines.size());
        
    }

    }