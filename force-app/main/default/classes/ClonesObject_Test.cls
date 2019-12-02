@istest
public class ClonesObject_Test {
    Public static TestMethod void TestJob()
    {
        List<ATI_Job__c> jobs = getJob();
        
       
        sObject jobid = ClonesObject.getsObject(jobs[0].Id);
        system.assertEquals(true, jobid != null); 
    } 
    Public static TestMethod void TestInvoice()
    {
        List<ATI_Job__c> jobs = getJob();
        
        Invoice__c inv = new Invoice__c();
        inv.ATI_Job__c = jobs[0].Id;
        inv.Due_Date__c = date.today();
        inv.Status__c = 'Ready for Billing';
        
        insert inv;
        
        Invoice_Line_Item__c item = new Invoice_Line_Item__c();
        item.Invoice__c = inv.id;
        item.Description__c = 'Testing lineItem';
        item.Amount__c = 100;
        item.Order__c = 1;
        
        insert item;
                
        sObject invoiceid = ClonesObject.getsObject(inv.Id);
        system.assertEquals(true, invoiceid != null); 
        system.assertEquals('Invoice__c', invoiceid.getSObjectType().getDescribe().getName()); 
        system.assertEquals('Invoice__c', ClonesObject.getObjectName(inv.Id));
    } 
    public static TestMethod void TestWaiver()
    {
        
        List<ATI_Job__c> jobs = getJob();
        
        Invoice__c inv = new Invoice__c();
        inv.ATI_Job__c = jobs[0].Id;
        inv.Due_Date__c = date.today();
        inv.Status__c = 'Ready for Billing';
        
        insert inv;
        
        List<RecordType> rtypesWaiver = [SELECT Id FROM RecordType WHERE SObjectType ='Waiver__c' AND DeveloperName = 'waiver'];
        Waiver__c waiver = new Waiver__c();
        waiver.Invoice__c = inv.Id;
        waiver.ATI_Job__c = jobs[0].Id;
        waiver.RecordTypeId = rtypesWaiver[0].id;
        
        insert waiver;
        
        //sObject waiverid = ClonesObject.cloneWaiver(waiver.Id); 
        sObject waiverid = ClonesObject.getsObject(waiver.Id);
        system.assertEquals(true, waiverid != null); 
        system.assertEquals('Waiver__c', waiverid.getSObjectType().getDescribe().getName()); 
        system.assertEquals('Waiver__c', ClonesObject.getObjectName(waiver.Id));
        
    }

    public static List<ATI_Job__c> GetJob()
    {
        List<ATI_Job__c> jobs;
        System.runAs(new User(Id = userinfo.getUserId())){
            TestDataUtil.createCustomSettings_TriggerStatus();
        }
        List<Account> accounts = TestDataUtil.createAccounts(1, true, new Map<String, Object>{ 'Name' => 'testAcct12344',
                                                                       'BillingStreet' => 'Street 12345',
                                                                       'BillingCity' => 'San Francisco',
                                                                       'BillingCountry' => 'USA',
                                                                       'BillingPostalCode' => '1234',
                                                                       'BillingState' => 'CA' } );
        List<Contact> con = TestDataUtil.createContacts(1, true, new Map<String, String>{'accountId' => accounts[0].Id,
                                                                       'firstName' => 'test',
                                                                       'lastname' => 'clone',
                                                                       'MailingStreet' => 'Street 12345',
                                                                       'MailingCity' => 'San Francisco',
                                                                       'MailingCountry' => 'USA',
                                                                       'MailingPostalCode' => '1234',
                                                                       'MailingState' => 'CA',
                                                                       'phone' => '5455535' });   
     
        jobs = TestDataUtil.createJob(10, true, new Map<String, String>{'account__c' => accounts[0].Id} );
        
        List<RecordType> rtypes = [SELECT Id FROM RecordType WHERE SObjectType ='ATI_Job__c' AND DeveloperName = 'Job_Approved'];
        
        for( Integer i=0; i< 10; i++ ){
            ATI_Job__c job = jobs[i];
            job.id = jobs[i].id;
            job.RecordTypeId = rtypes[0].Id;
            job.Project_Site_Contact_Name__c = con[0].id;
            job.Project_Site_Contact_Account__c = accounts[0].Id;
            

        }
     //   update jobs; 
        
        return jobs;
    }
    
}