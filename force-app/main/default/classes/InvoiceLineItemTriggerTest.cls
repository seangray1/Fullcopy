@istest
//Versoin 1.0
//Created by - Prabaharan Periasamy
//Date - 07/11/2016
//Tests invoice line item trigger group functionality , as upon update of one or bulk invoice line item objects.
//
private class InvoiceLineItemTriggerTest{
    
    static Account acc;
    static User u;
    static Contact con;        
    //SETUP METHOD
    private static void setup(){ 
        TestDataUtil.createCustomSettings_TriggerStatus();
        u = new User( Id = Userinfo.getUserId() );        
        acc = TestDataUtil.createAccounts(1, true, 
                                          new Map<String, Object>{ 'Name' => 'testAcct',
                                              'BillingStreet' => 'Street 12566',
                                              'Status__c' => 'Active',
                                              'BillingCity' => 'San Francisco',
                                              'BillingCountry' => 'USA',
                                              'BillingPostalCode' => '1234',
                                              'BillingState' => 'CA',
                                              'Type' => 'Consultant' })[0];
        con = TestDataUtil.createContacts(1, true, new Map<String, String>{
            'accountid' => acc.id,
                'contact_type__c' => 'Consultant', 
                'lastname' => 'Contact123',
                'firstname' => 'testing'
                })[0];
    }
    
    public static TestMethod void testInvoiceLineItem(){
            setup();    
            //Create a job to associate with Invoice record
            List<Contact> cons = TestDataUtil.createContacts(1, true, new Map<String, String>{
            'accountid' => acc.id,
                'contact_type__c' => 'Consultant', 
                'lastname' => 'Contact',
                'firstname' => 'test'
                });
             List<ATI_Job__c> testJobObj= TestDataUtil.createJob(3, false, new map<String,Object>(), acc.Id);
             
            
            //Create an invoice record to assiciate with invoice line item
            Invoice__c invoice = new Invoice__c();
            invoice.Name = 'Invoice 001';
            invoice.ATI_Job__c = testJobObj[0].id ;
            invoice.Due_Date__c = System.now().date();
            invoice.status__c = 'Ready for Billing';
            insert invoice;
                    
            // Create invoice line item
            Invoice_Line_Item__c invoiceLineItem = new Invoice_Line_Item__c();
            invoiceLineItem.PickListName__c = 'Lead Abatement';
            invoiceLineItem.Description__c = 'Testing Class';
            invoiceLineItem.Amount__c = 100;
            invoiceLineItem.Invoice__c = invoice.id;
            invoiceLineItem.Order__c = 1;
            System.runas(u){
            Test.StartTest();
                try{
                    Database.SaveResult result = Database.insert(invoiceLineItem);
                    system.assert(result.isSuccess());
                }catch (Exception exp){
                    system.debug(LoggingLevel.DEBUG, 'error while insert invoice line item ' + exp.getStackTraceString());
                }
            Test.StopTest();
        }
    }
    
    
    
        public static TestMethod void testInvoiceLineItemAutomaticOrderSetTrue(){
            setup();    
            //Create a job to associate with Invoice record
            List<Contact> cons = TestDataUtil.createContacts(1, true, new Map<String, String>{
            'accountid' => acc.id,
                'contact_type__c' => 'Consultant', 
                'lastname' => 'Contact',
                'firstname' => 'test'
                });
            List<ATI_Job__c> testJobObj= TestDataUtil.createJob(3, false, new map<String,Object>(), acc.Id);
             
             
            
            //Create an invoice record to assiciate with invoice line item
            Invoice__c invoice = new Invoice__c();
            invoice.Name = 'Invoice 001';
            invoice.ATI_Job__c = testJobObj[0].id ;
            invoice.Due_Date__c = System.now().date();
            invoice.status__c = 'Ready for Billing';
            insert invoice;
                    
            // Create invoice line item
            Invoice_Line_Item__c invoiceLineItem = new Invoice_Line_Item__c();
            invoiceLineItem.PickListName__c = 'Lead Abatement';
            invoiceLineItem.Description__c = 'Testing Class';
            invoiceLineItem.Amount__c = 100;
            invoiceLineItem.Invoice__c = invoice.id;
            invoiceLineItem.Order__c = 1;
            insert invoiceLineItem;
            System.runas(u){
            Test.StartTest();
                TriggerStatus__c trgStatus = TriggerStatus__c.getInstance( UserInfo.getUserId());
                trgStatus.InvoiceLineItemAutomaticOrder__c = true;
                InvoiceLineItemControl.IsRunning = false;
                insert trgStatus;
                //updating invoice line item
                invoiceLineItem.Description__c = 'updating invoice line item';
                invoiceLineItem.Order__c = 2;
                try{
                    Database.SaveResult result = Database.update(invoiceLineItem);
                    system.assert(result.isSuccess());
                }catch (Exception exp){
                    system.debug(LoggingLevel.DEBUG, 'error while insert invoice line item ' + exp.getStackTraceString());
                }
            Test.StopTest();
        }
    }
    
    public static TestMethod void testBulkInvoiceLineItem(){
            setup();    
            //Create a job to associate with Invoice record
            List<ATI_Job__c> testJobObj= TestDataUtil.createJob(3, false, new map<String,Object>(), acc.Id);
             
            
            //Create an invoice record to assiciate with invoice line item
            List<Invoice__c> invoiceLst = new List<Invoice__c>();
            for(ATI_Job__c job : testJobObj){
                Invoice__c invoice = new Invoice__c();
                invoice.Name = 'Invoice 001';
                invoice.ATI_Job__c = job.id ;
                invoice.Due_Date__c = System.now().date();
                invoice.status__c = 'Ready for Billing';
                invoiceLst.add(invoice);
            }
            insert invoiceLst;
                    
            // Create invoice line item
            List<Invoice_Line_Item__c> invoiceLineItemLst = new List<Invoice_Line_Item__c>();
            for(Invoice__c invoice : invoiceLst){
                Invoice_Line_Item__c invoiceLineItem = new Invoice_Line_Item__c();
                invoiceLineItem.PickListName__c = 'Lead Abatement';
                invoiceLineItem.Description__c = 'Testing Class';
                invoiceLineItem.Amount__c = 100;
                invoiceLineItem.Invoice__c = invoice.id;
                invoiceLineItem.Order__c = 1;      
                invoiceLineItemLst.add(invoiceLineItem);
            }
            System.runas(u){
            Test.StartTest();
                try{
                    List<Database.SaveResult> results = Database.insert(invoiceLineItemLst, false);
                    for(Database.SaveResult result : results){
                        system.assert(result.isSuccess());
                    }
                }catch (Exception exp){
                    system.debug(LoggingLevel.DEBUG, 'error while insert invoice line item ' + exp.getStackTraceString());
                }
            Test.StopTest();
        }
    }
    
    
   public static TestMethod void testBulkInvoiceLineItemUpdate(){
            setup();    
            //Create a job to associate with Invoice record
            List<ATI_Job__c> testJobObj= TestDataUtil.createJob(3, false, new map<String,Object>(), acc.Id);
             
             
            
            //Create an invoice record to assiciate with invoice line item
            List<Invoice__c> invoiceLst = new List<Invoice__c>();
            for(ATI_Job__c job : testJobObj){
                Invoice__c invoice = new Invoice__c();
                invoice.Name = 'Invoice 001';
                invoice.ATI_Job__c = job.id ;
                invoice.Due_Date__c = System.now().date();
                invoice.status__c = 'Ready for Billing';
                invoiceLst.add(invoice);
            }
            insert invoiceLst;
                    
            // Create invoice line item
            List<Invoice_Line_Item__c> invoiceLineItemLst = new List<Invoice_Line_Item__c>();
            for(Invoice__c invoice : invoiceLst){
                Invoice_Line_Item__c invoiceLineItem = new Invoice_Line_Item__c();
                invoiceLineItem.PickListName__c = 'Lead Abatement';
                invoiceLineItem.Description__c = 'Testing Class';
                invoiceLineItem.Amount__c = 100;
                invoiceLineItem.Invoice__c = invoice.id;
                invoiceLineItem.Order__c = 1;      
                invoiceLineItemLst.add(invoiceLineItem);
            }
            insert invoiceLineItemLst;
            //updating invoice line item description
            for(Invoice_Line_Item__c invoiceLineItem : invoiceLineItemLst){
               invoiceLineItem.Description__c = 'Updating invoice line item';
            }
            System.runas(u){
            Test.StartTest();
                try{
                    List<Database.SaveResult> results = Database.update(invoiceLineItemLst, false);
                    for(Database.SaveResult result : results){
                        system.assert(result.isSuccess());
                    }
                }catch (Exception exp){
                    system.debug(LoggingLevel.DEBUG, 'error while insert invoice line item ' + exp.getStackTraceString());
                }
            Test.StopTest();
        }
    }
}