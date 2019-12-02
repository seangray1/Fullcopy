@isTest
public class TestSurvey {
    
    public static testmethod void testAsbestos() {
        
        List<ATI_Job__c> job = getOpportunity();
        job[0].division__c = 'Asbestos';
        update job;
        SendSurvey.SmartEmail(job[0].id);    

    }
    public static testmethod void testConstruction() {
        
        List<ATI_Job__c> job = getOpportunity(); 
        job[0].division__c = 'Construction';
        update job;
        SendSurvey.SmartEmail(job[0].id);

    }
    public static testmethod void testDemolition() {
        
        List<ATI_Job__c> job = getOpportunity(); 
        job[0].division__c = 'Demolition';
        update job;
        SendSurvey.SmartEmail(job[0].id);
    }
    public static testmethod void testContents() {
        
        List<ATI_Job__c> job = getOpportunity();
        job[0].division__c = 'Contents';
        update job;
        SendSurvey.SmartEmail(job[0].id);
    }
    public static testmethod void testCatastrophes() {
        
        List<ATI_Job__c> job = getOpportunity();
        job[0].division__c = 'Catastrophes';
        update job;
        SendSurvey.SmartEmail(job[0].id);
    }
    public static testmethod void testConsulting() {
        
        List<ATI_Job__c> job = getOpportunity();
        job[0].division__c = 'Consulting';
        update job;
        SendSurvey.SmartEmail(job[0].id);
    }
    public static testmethod void testTechnicalSvces() {
        
        List<ATI_Job__c> job = getOpportunity();
        job[0].division__c = 'Technical Svces';
        update job;
        SendSurvey.SmartEmail(job[0].id);
    }
    
    public static List<ATI_Job__c> GetOpportunity()
    {
        List<ATI_Job__c> opps;
        System.runAs(new User(Id = userinfo.getUserId())){
            TestDataUtil.createCustomSettings_TriggerStatus();
        }
        List<Account> accounts = TestDataUtil.createAccounts(1, true, new Map<String, Object>{ 'Name' => 'testAcct',
                                               'BillingStreet' => 'Street 12',
                                                                       'BillingCity' => 'San Francisco',
                                                                       'BillingCountry' => 'USA',
                                                                       'BillingPostalCode' => '1234',
                                                                       'BillingState' => 'CA' } );
        List<Contact> con = TestDataUtil.createContacts(1, true, new Map<String, String>{'accountId' => accounts[0].Id});   
     
        opps = TestDataUtil.createJob(10, true, new Map<String, String>{'account__c' => accounts[0].Id} );
        
        List<RecordType> rtypes = [SELECT Id FROM RecordType WHERE SObjectType ='ATI_Job__c' AND DeveloperName = 'Job_Approved'];
        
        for( Integer i=0; i< 10; i++ ){
            ATI_Job__c job = opps[i];
            job.RecordTypeId = rtypes[0].Id;
            job.Project_Site_Contact_Name__c = con[0].id;
            job.Project_Site_Contact_Account__c = accounts[0].Id;
            job.division__c = 'Asbestos';

        }
        update opps; 
        
        return opps;
    }
}