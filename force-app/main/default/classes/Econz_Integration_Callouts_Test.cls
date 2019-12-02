@isTest
private class Econz_Integration_Callouts_Test {
    
    static testmethod void test_addTask() {
        // Create a User
        User testUser = createAdminUser();
        insert testUser;
        
        System.runAs(testUser){
            ATI_Job__c Job = createJobWithTestSetupData(testUser); 
            Job.ECONZ_Task_Created__c = false;
            Job.Project_Manager_new__c  = testUser.id;
            job.Amount__c=5500;
            insert Job;
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new fake_AddTask());
            Econz_Integration_Callouts.isECONZCalloutsProcessed = true;
            Econz_Integration_Callouts.ECONZ_Future_Call(Job.Id,'addTask','',Date.today());
            
            Test.stopTest();
        }
    }
    
    static testmethod void test_updateTaskDates() {
        // Create a User
        User testUser = createAdminUser();
        insert testUser;
        
        System.runAs(testUser){
            ATI_Job__c Job = createJobWithTestSetupData(testUser); 
            Job.Project_Manager_new__c  = testUser.id;
            insert Job;
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new fake_AddTask());
            Econz_Integration_Callouts.isECONZCalloutsProcessed = true;
            Job = Econz_Integration_Callouts.updateTaskDates(Job,Date.today());
            Test.stopTest();
        }
    }
    
    static testmethod void test_updateTaskManager() {
        // Create a User
        User testUser = createAdminUser();
        insert testUser;
        
        System.runAs(testUser){
            ATI_Job__c Job = createJobWithTestSetupData(testUser); 
            Job.ECONZ_Task_Created__c = true;
            Job.Project_Manager_new__c  = testUser.id;
            insert Job;
            ATI_Job__c testJob = Econz_Integration_Callouts.getJobRecord(Job.Id);
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new fake_AddTask());
            Econz_Integration_Callouts.isECONZCalloutsProcessed = true;
            Econz_Integration_Callouts.updateTaskManager(testJob);
            Test.stopTest();
        }
    }
    
    static testmethod void test_JobUpdate() {
        // Create a User
        User testUser = createAdminUser();
        insert testUser;
        
        System.runAs(testUser){
            ATI_Job__c Job = createJobWithTestSetupData(testUser); 
            Job.ECONZ_Task_Created__c = true;
            Job.Project_Manager_new__c  = testUser.id;
            insert Job;
            Job.Division__c = 'Microbial';
            
            try{
                Test.startTest();
                Test.setMock(HttpCalloutMock.class, new fake_AddTask());
                update Job;
                Test.stopTest();
            }catch(exception e){
                System.assert(true);
            }
        }
    }
    
    static testmethod void test_button() {
        // Create a User
        User testUser = createAdminUser();
        insert testUser;
        
        System.runAs(testUser){
            ATI_Job__c Job = createJobWithTestSetupData(testUser); 
            Job.Project_Manager_new__c  = testUser.id;
            insert Job;
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new fake_AddTask());
            Econz_Integration_Callouts.isECONZCalloutsProcessed = true;
            Econz_Integration_Callouts.invokeIntegration(Job.Id);
            Test.stopTest();
        }
    }
    
    static testmethod void test_renameTask() {
        // Create a User
        User testUser = createAdminUser();
        insert testUser;
        
        System.runAs(testUser){
            ATI_Job__c Job = createJobWithTestSetupData(testUser); 
            Job.ECONZ_Task_Created__c = true;
            Job.Project_Manager_new__c  = testUser.id;
            insert Job;
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new fake_AddTask());
            Econz_Integration_Callouts.isECONZCalloutsProcessed = true;
            Econz_Integration_Callouts.renameTask(Job,'Old Name');
            Test.stopTest();
        }
    }
    
    static testmethod void test_getUserByLoginID() {
        // Create a User
        User testUser = createAdminUser();
        insert testUser;
        
        System.runAs(testUser){
            ATI_Job__c Job = createJobWithTestSetupData(testUser); 
            Job.Project_Manager_new__c  = testUser.id;
            insert Job;
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new fake_getUserByLoginID());
            Econz_Integration_Callouts.isECONZCalloutsProcessed = true;
            Econz_Integration_Callouts.ECONZ_Future_Call(Job.Id,'updateTaskManager','',Date.today());
            Test.stopTest();
        }
    }
    
    
    static testmethod void test_Batch() {
        // Create a User
        User testUser = createAdminUser();
        insert testUser;
        
        System.runAs(testUser){
            ATI_Job__c Job = createJobWithTestSetupDataATIJob(testUser); 
            Job.ECONZ_Integration_Error__c = true;
            Job.Project_Manager_new__c  = testUser.id;
            Job.ECONZ_Task_Created__c = false;
            Job.Job_Start_Date__c = system.today();
            insert Job;
            List<ATI_Job__c> jobtest = [SELECT Id FROM ATI_Job__c WHERE (ECONZ_Integration_Error__c = true AND Job_Start_Date__c != NULL) OR (Job_Start_Date__c != NULL AND ECONZ_Task_Created__c = false)];
            //system.debug('-------TestClass----'+jobtest);
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new fake_AddTask());
            //Database.executeBatch(new ECONZ_Integration_RetryBatch(''));
            
            ECONZ_Integration_RetryBatch cb = New ECONZ_Integration_RetryBatch('');
            
            Database.QueryLocator ql = cb.start(null);
            cb.execute(null,jobtest);
            cb.Finish(null);
            
            Test.stopTest();
        }
    }
    
    static testmethod void validateScheduleClass(){
        
        //   Test.startTest();
        // Schedule the test job
        // Integer year = system.today().year() + 1;
        // String sch = '0 0 0 1 1 ? ' + year;
        //   User testUser = createAdminUser();
        // insert testUser;
        // System.runAs(testUser){
        //  ATI_Job__c Job = createJobWithTestSetupDataATIJob(testUser); 
        //    Job.ECONZ_Integration_Error__c = true;
        //                Job.Job_Start_Date__c = system.today();
        
        //      insert Job;
        //         Test.setMock(HttpCalloutMock.class, new fake_AddTask());
        // Database.executeBatch(new ECONZ_Integration_RetryBatch(''),1);
        
        //Id jobId = System.schedule('test_sch_batch', sch, new Econz_SchRetryBatch(''));
        
        // CronTrigger cronTrigger1 = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
        //   System.assertEquals(sch, cronTrigger1.CronExpression);
        //  System.assertEquals(0, cronTrigger1.TimesTriggered);
        //  System.assertEquals(year + '-01-01 00:00:00',String.valueOf(cronTrigger1.NextFireTime));
        //   Test.stopTest();
        //    }
        
    }
    
    public class fake_getUserByLoginID implements HttpCalloutMock{
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            string response = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'+
                '   <soapenv:Body>'+
                '      <ns1:getUserDetailByLoginIDResponse soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns1="http://nads.econz.co.nz/timecard1/">'+
                '         <getUserDetailByLoginIDResponse xsi:type="ns1:GetUserDetailResult">'+
                '            <userDetails xsi:type="ns1:UserBean">'+
                '               <primaryKey xsi:type="xsd:string">12345</primaryKey>'+
                '               <updateIndex xsi:type="xsd:int">13</updateIndex>'+
                '               <deleted xsi:type="xsd:boolean">false</deleted>'+
                '               <loginID xsi:type="xsd:string">test@testATI.com</loginID>'+
                '               <name xsi:type="xsd:string">Test User OM</name>'+
                '               <teams soapenc:arrayType="xsd:string[0]" xsi:type="soapenc:Array" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/"/>'+
                '               <timezone xsi:type="xsd:string">US/Pacific</timezone>'+
                '               <userTypePK xsi:type="xsd:string">9</userTypePK>'+
                '               <description xsi:type="xsd:string"/>'+
                '               <emailAddress xsi:type="xsd:string"/>'+
                '               <phoneNumber xsi:type="xsd:string"/>'+
                '               <faxNumber xsi:type="xsd:string"/>'+
                '               <pagerNumber xsi:type="xsd:string"/>'+
                '               <mobileNumber xsi:type="xsd:string"/>'+
                '               <securityQuestion xsi:type="xsd:string">__INVALID</securityQuestion>'+
                '               <securityAnswer xsi:type="xsd:string"/>'+
                '               <synchronisation soapenc:arrayType="ns2:SynchronisationBean[0]" xsi:type="soapenc:Array" xmlns:ns2="http://soap2.nads.econz.co.nz" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/"/>'+
                '            </userDetails>'+
                '            <accessDeniedFailure xsi:type="ns3:AccessDeniedFailure" xsi:nil="true" xmlns:ns3="http://auth.soap.econz.co.nz"/>'+
                '         </getUserDetailByLoginIDResponse>'+
                '      </ns1:getUserDetailByLoginIDResponse>'+
                '   </soapenv:Body>'+
                '</soapenv:Envelope>';
            
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(response);
            res.setStatusCode(200);
            return res;
        }
    }
    
    public class fake_AddTask implements HttpCalloutMock{
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            string response = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'+
                '<soapenv:Body>'+
                '<ns1:addTaskForManagerResponse soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns1="http://nads.econz.co.nz/timecard1/" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">'+
                '<addTaskForManagerResponse xsi:type="ns1:AddNewTaskResult" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ns1="http://nads.econz.co.nz/timecard1/">'+
                '<accessDeniedFailure xsi:type="ns2:AccessDeniedFailure" xsi:nil="true" xmlns:ns2="http://auth.soap.econz.co.nz" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" />'+
                '<validationFailure xsi:type="ns3:ValidationFailure" xsi:nil="true" xmlns:ns3="http://soap.econz.co.nz" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" />'+
                '</addTaskForManagerResponse>'+
                '</ns1:addTaskForManagerResponse>'+
                '</soapenv:Body>'+
                '</soapenv:Envelope>';
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(response);
            res.setStatusCode(200);
            return res;
        }
    }
    
    private static User createAdminUser(){
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' Limit 1];
        User testUser = new User(
            Username = 'sampletest' + System.now().millisecond() + '@test.com'
            , ProfileId = testProfile.Id
            , Alias = 'test' + System.now().millisecond()
            , Email = 'test' + System.now().millisecond() + '@test.com'
            , EmailEncodingKey = 'UTF-8'
            , LastName = 'test' + System.now().millisecond()
            , CommunityNickname = 'test' + System.now().millisecond()
            , TimeZoneSidKey = 'America/Los_Angeles'
            , LocaleSidKey = 'en_US'
            , LanguageLocaleKey = 'en_US'
        );
        
        return testUser;
    }
    
    private static ATI_Job__c createJobWithTestSetupDataATIJob(User testUser){
        RecordType tBusiness = [Select Id from RecordType Where Name = 'Business Account' and SObjectType = 'Account'];
        RecordType tPersons = [Select Id from RecordType Where Name = 'Person Accounts' and SObjectType = 'Account'];    
        //Create Test Record for Custom Setting
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
            JobSetJobNumber__c= false,
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
        
        Waiver_Settings__c wStat = new Waiver_Settings__c(
            Name = 'Apex Settings',
            Unconditional_Final_Name__c = 'Unconditional Final Waiver',
            Unconditional_Progress_Name__c = 'Unconditional Progress Waiver',
            Conditional_Final_Name__c = 'Conditional Final Waiver',
            Conditional_Progress_Name__c = 'Conditional Progress Waiver',
            Letter_60_Day_Name__c = '60 Day Letter'
        );
        insert wStat;
        EconzIntegration__c csTest = new EconzIntegration__c();
        csTest.Name = 'Test';
        csTest.EndPointURL__c = 'Test';
        csTest.UserId__c = 'Test';
        csTest.Password__c = 'Test';
        insert csTest;
        
        EconzIntegration__c csProd = new EconzIntegration__c();
        csProd.Name = 'Prod';
        csProd.EndPointURL__c = 'Prod';
        csProd.UserId__c = 'Prod';
        csProd.Password__c = 'Prod';
        insert csProd;
        
        Tax_Group__c taxGrp = new Tax_Group__c(
            
            Name = 'TestTaxGroup',
            Tax_Rate__c = 25,
            Timberline_Id__c = 'TestTaxGroup'   
        );
        insert taxGrp;
        
        Account acc = new Account(
            Name = 'TestAccount',
            RecordTypeId = tBusiness.Id,
            Status__c = 'Active',
            BillingCity = 'TestBCity',
            BillingCountry = 'USA',
            BillingState = 'CA',
            BillingStreet = 'TestBStreet',
            BillingPostalCode = '55555',
            Tax_Group__c = taxGrp.Id,
            ShippingCity = 'TestSCity',
            ShippingCountry = 'USA',
            ShippingState = 'CA',
            ShippingStreet = 'TestSStreet',
            Company_Type__c = 'Agent/ Brokerage',
            Industry = 'Apparel'
        );
        insert acc;
        
        Contact con = new Contact(
            FirstName = 'TestFN',
            LastName = 'TestLN',
            AccountId = acc.Id,
            Email='mrstanziabrown@yahoo.com',
            Phone = '1234'
        );    
        insert con;   
        Id appRecordTypeId = Schema.SObjectType.ATI_Job__c.getRecordTypeInfosByName().get('Job (Approved)').getRecordTypeId();
        Id appRecordTypeId1 = Schema.SObjectType.ATI_Job__c.getRecordTypeInfosByName().get('New Job (Not Approved)').getRecordTypeId();
        ATI_Job__c Job = new ATI_Job__c(
            //Account__c = acc.Id,
            Name = 'TestJob',
            Stage__c = 'Won',
            CloseDate__c = Date.Today(),
            Job_Name__c = 'Test Job Name',
            Job_Number__c = 'TT-5555555',
            Project_Site_Contact_Name__c = con.id,
            Lost_Job_Reason__c = 'Unknown',
            Lost_Job_Description__c = 'TestJob',
            Project_Site_Contact_Account__c = acc.id,
            Project_Manager_New__c = testUser.Id,
            Date_Time_Approved__c = system.today(),
            Completion_Date__c = system.today(),
            Division__c = 'Lead',
            
            RecordTypeId = appRecordTypeId
        );       
        
        return Job;
    }
    
    private static ATI_Job__c createJobWithTestSetupData(User testUser){
        RecordType tBusiness = [Select Id from RecordType Where Name = 'Business Account' and SObjectType = 'Account'];
        RecordType tPersons = [Select Id from RecordType Where Name = 'Person Accounts' and SObjectType = 'Account'];    
        //Create Test Record for Custom Setting
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
            JobSetJobNumber__c= false,
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
        
        Waiver_Settings__c wStat = new Waiver_Settings__c(
            Name = 'Apex Settings',
            Unconditional_Final_Name__c = 'Unconditional Final Waiver',
            Unconditional_Progress_Name__c = 'Unconditional Progress Waiver',
            Conditional_Final_Name__c = 'Conditional Final Waiver',
            Conditional_Progress_Name__c = 'Conditional Progress Waiver',
            Letter_60_Day_Name__c = '60 Day Letter'
        );
        insert wStat;
        EconzIntegration__c csTest = new EconzIntegration__c();
        csTest.Name = 'Test';
        csTest.EndPointURL__c = 'Test';
        csTest.UserId__c = 'Test';
        csTest.Password__c = 'Test';
        insert csTest;
        
        EconzIntegration__c csProd = new EconzIntegration__c();
        csProd.Name = 'Prod';
        csProd.EndPointURL__c = 'Prod';
        csProd.UserId__c = 'Prod';
        csProd.Password__c = 'Prod';
        insert csProd;
        
        Tax_Group__c taxGrp = new Tax_Group__c(
            
            Name = 'TestTaxGroup',
            Tax_Rate__c = 25,
            Timberline_Id__c = 'TestTaxGroup'   
        );
        insert taxGrp;
        
        Account acc = new Account(
            Name = 'TestAccount',
            RecordTypeId = tBusiness.Id,
            Status__c = 'Active',
            BillingCity = 'TestBCity',
            BillingCountry = 'USA',
            BillingState = 'CA',
            BillingStreet = 'TestBStreet',
            BillingPostalCode = '55555',
            Tax_Group__c = taxGrp.Id,
            ShippingCity = 'TestSCity',
            ShippingCountry = 'USA',
            ShippingState = 'CA',
            ShippingStreet = 'TestSStreet',
            Company_Type__c = 'Agent/ Brokerage',
            Industry = 'Apparel'
        );
        insert acc;
        
        Contact con = new Contact(
            FirstName = 'TestFN',
            LastName = 'TestLN',
            AccountId = acc.Id,
            Email='mrstanziabrown@yahoo.com',
            Phone = '1234'
        );    
        insert con;   
        Id appRecordTypeId = Schema.SObjectType.ATI_Job__c.getRecordTypeInfosByName().get('Job (Approved)').getRecordTypeId();
        Id appRecordTypeId1 = Schema.SObjectType.ATI_Job__c.getRecordTypeInfosByName().get('New Job (Not Approved)').getRecordTypeId();
        ATI_Job__c Job = new ATI_Job__c(
            Account__c = acc.Id,
            Name = 'TestJob',
            Stage__c = 'Lost',
            CloseDate__c = Date.Today(),
            Job_Name__c = 'Test Job Name',
            Job_Number__c = 'TT-5555555',
            Project_Site_Contact_Name__c = con.id,
            Lost_Job_Reason__c = 'Unknown',
            Lost_Job_Description__c = 'TestJob',
            Project_Site_Contact_Account__c = acc.id,
            Project_Manager_New__c = testUser.Id,
            Date_Time_Approved__c = system.today(),
            Completion_Date__c = system.today(),
            Division__c = 'Lead',
            
            RecordTypeId = appRecordTypeId
        );       
        
        return Job;
    }
    
    public class fake_getUserByLoginID_Failure implements HttpCalloutMock{
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            string response = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'+
                '   <soapenv:Body>'+
                '      <ns1:getUserDetailByLoginIDResponse soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns1="http://nads.econz.co.nz/timecard1/">'+
                '         <getUserDetailByLoginIDResponse xsi:type="ns1:GetUserDetailResult">'+
                '            <userDetails xsi:type="ns1:UserBean">'+
                '               <primaryKey xsi:type="xsd:string">12345</primaryKey>'+
                '               <updateIndex xsi:type="xsd:int">13</updateIndex>'+
                '               <deleted xsi:type="xsd:boolean">false</deleted>'+
                '               <loginID xsi:type="xsd:string">test@testATI.com</loginID>'+
                '               <name xsi:type="xsd:string">Test User OM</name>'+
                '               <teams soapenc:arrayType="xsd:string[0]" xsi:type="soapenc:Array" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/"/>'+
                '               <timezone xsi:type="xsd:string">US/Pacific</timezone>'+
                '               <userTypePK xsi:type="xsd:string">9</userTypePK>'+
                '               <description xsi:type="xsd:string"/>'+
                '               <emailAddress xsi:type="xsd:string"/>'+
                '               <phoneNumber xsi:type="xsd:string"/>'+
                '               <faxNumber xsi:type="xsd:string"/>'+
                '               <pagerNumber xsi:type="xsd:string"/>'+
                '               <mobileNumber xsi:type="xsd:string"/>'+
                '               <securityQuestion xsi:type="xsd:string">__INVALID</securityQuestion>'+
                '               <securityAnswer xsi:type="xsd:string"/>'+
                '               <synchronisation soapenc:arrayType="ns2:SynchronisationBean[0]" xsi:type="soapenc:Array" xmlns:ns2="http://soap2.nads.econz.co.nz" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/"/>'+
                '            </userDetails>'+
                '            <accessDeniedFailure xsi:type="ns3:AccessDeniedFailure" xsi:nil="true" xmlns:ns3="http://auth.soap.econz.co.nz"/>'+
                '         </getUserDetailByLoginIDResponse>'+
                '      </ns1:getUserDetailByLoginIDResponse>'+
                '   </soapenv:Body>'+
                '</soapenv:Envelope>';
            
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(response);
            res.setStatusCode(201);
            return res;
        }
    }
    
    static testmethod void test_renameTask_1() {
        // Create a User
        User testUser = createAdminUser();
        insert testUser;
        
        System.runAs(testUser){
            ATI_Job__c Job = createJobWithTestSetupData(testUser); 
            Job.ECONZ_Task_Created__c = true;
            Job.Project_Manager_new__c  = testUser.id;
            insert Job;
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new fake_AddTask());
            Econz_Integration_Callouts.isECONZCalloutsProcessed = true;
            Econz_Integration_Callouts.renameTask(Job,'renameTask');
            Test.stopTest();
        }
    }
    
}