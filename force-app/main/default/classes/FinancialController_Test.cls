@isTest
public class FinancialController_Test {
    static List<ATI_Job__c> jobs;
    
   
   public static testmethod void FinancialController_Test(){
        TestDataUtil.createCustomSettings_TriggerStatus();
       boolean editSection=true;
        System.runAs(new User(Id = userinfo.getUserId())){
            
        
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
       system.debug('ATI_Job_Id--'+jobs[0].id);
       
    ATI_Job__c jobrec = [SELECT id FROM ATI_Job__c WHERE id =: jobs[0].id];
       system.debug('ATI_Job_Id -*-*-'+jobrec.id);


     Financial__c  frecord = [SELECT Id FROM Financial__c WHERE ATI_Job__c =: jobrec.id limit 1]; 
       system.debug('Finance -*-*-'+frecord.id);
       
       ApexPages.CurrentPage().getparameters().put('id', jobrec.id); 
       ApexPages.StandardController sc = new ApexPages.StandardController(jobrec);
       FinancialController fc=new FinancialController(sc);
       PageReference pageRef = Page.FinancialDetailSection;
       pageRef.getParameters().put('Id', String.valueOf(jobrec.Id));
       Test.setCurrentPage(pageRef); 
       fc.EdittheSection();
       fc.saveChanges();
       fc.RecID = frecord.id;
        }
    }
}