@isTest
public class OpportunityAEBonusTriggerHandler_Test {
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
        User u3 = new User(Alias = 'standt', Email='demandTestDividerUser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='testUserDBlue', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='demandTestDividerUser@testorg.com');
        insert u;
        insert u2;
        insert u3;
        System.runAs(new User(Id = userinfo.getUserId())) {
            Id newJobId =  Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Job (Not Approved)').getRecordTypeId();
            Id approvedJobId =  Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Job (Approved)').getRecordTypeId();
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
            
            ATI_Job__c j1 = new ATI_Job__c();
            j1.Name = 'testJob';
            j1.Project_Site_Address__c = 'testSite';
            j1.Project_Site_State__c = 'Az';
            j1.Project_Site_Zipcode__c = '000000';
            j1.County__c = 'Tes';
            j1.City_of_LA__c = 'No';
            j1.Project_Site_City__c = 'ASDD';
            j1.Primary_Account__c = 'Customer';
            j1.Job_Name__c = 'TestJobName';
            j1.Account_Executive_1__c = u.Id;
            j1.Account_Executive_2__c = Userinfo.getUserId();
           // j1.RecordTypeId = newJobId;
            j1.Credit_Request_Status__c = 'Unapproved';
            j1.Credit_Request_Submitter_Email__c = 'demandUser@testorg.com';
            j1.Stage__c = 'Qualification';
            insert j1;
            
            Opportunity j = new Opportunity();
            j.Name = 'testJob';
            j.AccountId = accounts[0].id ;
            j.Contact__c = con[0].id;
            j.Project_Site_Address__c = 'testSite';
            j.Project_Site_State__c = 'Az';
            j.Project_Site_Zipcode__c = '000000';
            j.County__c = 'Tes';
            j.City_of_LA__c = 'No';
            j.Project_Site_City__c = 'ASDD';
            j.Primary_Account__c = 'Customer';
            j.Job_Name__c = 'TestJobName';
            j.Account_Executive_1__c = u.Id;
            j.Account_Executive_2__c = u.id;
         //   j.Account_Executive_2__c = Userinfo.getUserId();
            j.RecordTypeId = newJobId;
            j.Credit_Request_Status__c = 'Unapproved';
            j.Credit_Request_Submitter_Email__c = 'demandUser@testorg.com';
            j.StageName = 'Qualification';
            j.CloseDate = Date.newInstance(2019, 06, 05);
            j.OwnerId = u3.id;
            insert j;
            Invoice__c invoice = new Invoice__c();
            invoice.Name = 'Invoice 001';
            invoice.Opportunity__c = j.id ;
            invoice.ATI_Job__c = j1.id;
            invoice.Due_Date__c = System.now().date();
            invoice.status__c = 'Ready for Billing';
            insert invoice;
            
            Forecast__c f = new Forecast__c();
            f.Opportunity__c = j.Id;
            f.ATI_Job__c = j1.id;
            f.Revenue_Amount__c = 10000;
            f.Invoice_Date__c = date.today();
            insert f;
            Test.setCreatedDate(j.Id, DateTime.now().addMonths(-6));  
            system.debug('id--'+J.createdDate);
          //  List<Opportunity> jobs = TestDataUtil.createJob(10, true, new Map<String, String>{'account__c' => accounts[0].Id} );
            List<Opportunity> jobs = new List<Opportunity>();
            jobs.add(j);
            Map<id,Opportunity> oldmap = new Map<id,Opportunity>();
            Map<id,Opportunity> newmap = new Map<id,Opportunity>();
            List<Opportunity> newJob = new List<Opportunity>();
            set<Id> jobId = new set<Id>();
            set<Id> userId = new set<Id>();
            userId.add(u.Id);
            
            oldmap.put(j.id, j);
            j.RecordTypeId = approvedJobId;
            j.Account_Executive_2__c = u.Id;
            j.Credit_Request_Status__c = 'Approved';
            j.RecordTypeId = newJobId;
            update j;
            newmap.put(j.id, j);
            newJob.add(j);
            jobId.add(j.Id);
            system.debug('CD--'+newJob[0].CreatedDate);
            test.startTest();
            OpportunityAEBonusTriggerHandler obj = new OpportunityAEBonusTriggerHandler();
            OpportunityAEBonusTriggerHandler.getCurrentQuarter();
            OpportunityAEBonusTriggerHandler.getCurrentQuarter(date.today());
            OpportunityAEBonusTriggerHandler.getCurrentQuarter(Date.Today().addDays(120));
            OpportunityAEBonusTriggerHandler.updateLastPreviousJobDateOnAccount(jobs);
            OpportunityAEBonusTriggerHandler.getRelatedInvoices(jobId);
            OpportunityAEBonusTriggerHandler.getRelatedForecasts(jobId);
            OpportunityAEBonusTriggerHandler.createOppPrimaryContactRoles(oldmap,jobs);        
            OpportunityAEBonusTriggerHandler.getOpportunityContacts(jobs);
            OpportunityAEBonusTriggerHandler.updateTeamMembersOnAEChange(oldmap, newmap); 
            OpportunityAEBonusTriggerHandler.populateAEOnApprovedOpps(oldmap, newmap); 
            OpportunityAEBonusTriggerHandler.populateAEs(oldmap, jobs); 
            OpportunityAEBonusTriggerHandler.getOpportunityAccounts(jobs);
            OpportunityAEBonusTriggerHandler.updateTeamMembersAndAESplits(jobs);
            test.stopTest();
        }
    }
}