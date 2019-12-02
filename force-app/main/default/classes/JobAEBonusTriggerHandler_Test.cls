@isTest
public class JobAEBonusTriggerHandler_Test {
    public static testmethod void jobAEBonusTest(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='demandUser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='TestDBlue', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='demandBlue@testorg.com');
         User u2 = new User(Alias = 'standt', Email='demandTestUser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='testUserDBlue', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='demandTestBlue@testorg.com');
        insert u;
        insert u2;
        System.runAs(new User(Id = userinfo.getUserId())) {
            Id newJobId =  Schema.SObjectType.ATI_Job__c.getRecordTypeInfosByName().get('New Job (Not Approved)').getRecordTypeId();
            Id approvedJobId =  Schema.SObjectType.ATI_Job__c.getRecordTypeInfosByName().get('Job (Approved)').getRecordTypeId();
            system.debug('newJobId--'+newJobId);
            system.debug('approvedJobId--'+approvedJobId);
            TestDataUtil.createCustomSettings_TriggerStatus();
            List<Account> accounts = TestDataUtil.createAccounts(1, true, new Map<String, Object>{ 'Name' => 'testAcct',
                'BillingStreet' => 'Street 12',
                'BillingCity' => 'San Francisco',
                'BillingCountry' => 'USA',
                'BillingPostalCode' => '1234',
                'BillingState' => 'CA' } );
            List<Contact> con = TestDataUtil.createContacts(1, true, new Map<String, String>{'accountId' => accounts[0].Id});   
            ATI_Job__c j = new ATI_Job__c();
            j.Name = 'testJob';
            j.Project_Site_Address__c = 'testSite';
            j.Project_Site_State__c = 'Az';
            j.Project_Site_Zipcode__c = '000000';
            j.County__c = 'Tes';
            j.City_of_LA__c = 'No';
            j.Project_Site_City__c = 'ASDD';
            j.Primary_Account__c = 'Customer';
            j.Job_Name__c = 'TestJobName';
            j.Account_Executive_1__c = u.Id;
            j.Account_Executive_2__c = Userinfo.getUserId();
            j.RecordTypeId = newJobId;
            j.Credit_Request_Status__c = 'Unapproved';
            j.Credit_Request_Submitter_Email__c = 'demandUser@testorg.com';
            j.Stage__c = 'Qualification';
            insert j;
            Invoice__c invoice = new Invoice__c();
            invoice.Name = 'Invoice 001';
            invoice.ATI_Job__c = j.id ;
            invoice.Due_Date__c = System.now().date();
            invoice.status__c = 'Ready for Billing';
            insert invoice;
            
            Forecast__c f = new Forecast__c();
            f.ATI_Job__c = j.Id;
            f.Revenue_Amount__c = 10000;
            f.Invoice_Date__c = date.today();
            insert f;
            Test.setCreatedDate(j.Id, DateTime.now().addMonths(-6));  
            system.debug('id--'+J.createdDate);
            List<ATI_Job__c> jobs = TestDataUtil.createJob(10, true, new Map<String, String>{'account__c' => accounts[0].Id} );
            
            Map<id,ATI_Job__c> oldmap = new Map<id,ATI_Job__c>();
            Map<id,ATI_Job__c> newmap = new Map<id,ATI_Job__c>();
            Map<id,ATI_Job__c> testmap = new Map<id,ATI_Job__c>();
            List<ATI_Job__c> newJob = new List<ATI_Job__c>();
            set<Id> jobId = new set<Id>();
            set<Id> userId = new set<Id>();
            userId.add(u.Id);
            
            oldmap.put(j.id, j);
            j.RecordTypeId = approvedJobId;
            j.Account_Executive_2__c = u.Id;
            j.Credit_Request_Status__c = 'Approved';
            j.Account__c = accounts[0].id;
            j.Contact__c =con[0].id;
            update j;
            newmap.put(j.id, j);
            newJob.add(j);
            jobId.add(j.Id);
            testmap.putall(newmap);
            
            ati_job__c atijobobj = new ati_job__c();
            atijobobj.id = j.id;
            atijobobj.RecordTypeId = newJobId;
            atijobobj.Credit_Request_Status__c = 'Unapproved';
            j.Account_Executive_1__c = Userinfo.getUserId();
            j.Account_Executive_2__c = u.Id;
            testmap.put(atijobobj.id,atijobobj);
            system.debug(oldmap);
            system.debug(newmap);
            system.debug('CD--'+newJob[0].CreatedDate);
            test.startTest();
            JobAEBonusTriggerHandler obj = new JobAEBonusTriggerHandler();
            JobAEBonusTriggerHandler.getCurrentQuarter();
            JobAEBonusTriggerHandler.getCurrentQuarter(date.today());
            JobAEBonusTriggerHandler.getCurrentQuarter(Date.Today().addDays(120));
            JobAEBonusTriggerHandler.updateLastPreviousJobDateOnAccount(jobs);
            JobAEBonusTriggerHandler.getRelatedInvoices(jobId);
            JobAEBonusTriggerHandler.getRelatedForecasts(jobId);
            JobAEBonusTriggerHandler.getJobContacts(jobs);
            JobAEBonusTriggerHandler.populateAEOnApprovedJobs(testmap, newmap);
            JobAEBonusTriggerHandler.getJobAccounts(jobs);
            JobAEBonusTriggerHandler.addTeamMembersJobSplitsOnInsert(jobs);
            JobAEBonusTriggerHandler.afterCreditRequestApproved(testmap, newmap);
             JobAEBonusTriggerHandler.updateTeamMembersOnAEChange(testmap, newmap);
            test.stopTest();
        }
    }
}