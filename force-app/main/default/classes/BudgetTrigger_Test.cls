@isTest()
public class BudgetTrigger_Test {
    
    static List<ATI_Job__c> jobs;
    
    public static TestMethod void UnitTest(){
        
        System.runAs(new User(Id = userinfo.getUserId())){
            TestDataUtil.createCustomSettings_TriggerStatus();
        }
        List<Account> accounts = TestDataUtil.createAccounts(1, true, new Map<String, Object>{ 'Name' => 'testAcct',
                                               'BillingStreet' => 'Street 12',
                                                                       'BillingCity' => 'San Francisco',
                                                                       'BillingCountry' => 'USA',
                                                                       'BillingPostalCode' => '1234',
                                                                       'BillingState' => 'CA' } );
        jobs = TestDataUtil.createJob(10, true, new Map<String, String>{'Account__c' => accounts[0].Id} );
     
        List<RecordType> rtypes = [SELECT Id FROM RecordType WHERE SObjectType ='ATI_Job__c' AND DeveloperName = 'Job_Approved'];
        for( Integer i=0; i< 10; i++ ){
            ATI_Job__c job = jobs[i];
            job.RecordTypeId = rtypes[0].Id;

        }
        update jobs;
  
        
        Budget__c budget = new Budget__c();
        budget.ATI_Job__c = jobs[0].Id;
        budget.Allocations__c = '2';
        
        budget.GP_Goal__c = '22';
        
        upsert budget; 
        budget.budget_status__c = 'Approved';
        update budget;

        
    }
    
}