@isTest
public class SubmitForApprovalExtension_Test {
    static List<ATI_Job__c> jobs;
    public static testmethod void method1(){
        TestDataUtil.createCustomSettings_TriggerStatus();
        List<Account> accounts = TestDataUtil.createAccounts(1, true, new Map<String, Object>{ 'Name' => 'testAcct',
            'BillingStreet' => 'Street 12',
            'BillingCity' => 'San Francisco',
            'BillingCountry' => 'USA',
            'BillingPostalCode' => '1234',
            'BillingState' => 'CA' } );
        Contact c = new Contact();
        c.LastName = 'Test';
        c.AccountId = accounts[0].id;
        c.Contact_Type__c = 'Agent';
        insert c;
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
        insert j;
        SubmitForApprovalExtension obj = new SubmitForApprovalExtension();
        obj.submitForApproval();
        SubmitForApprovalExtension.getsObject(j.id);
        SubmitForApprovalExtension.getsObject(c.id);
    }
}