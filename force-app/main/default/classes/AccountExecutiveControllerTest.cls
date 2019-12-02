@istest
public class AccountExecutiveControllerTest {

    static List<ATI_Job__c> jobs;
    static List<ATI_Job__c> updatejobs;
    
    public  testmethod static void AccountExecutiveControllerTest(){    
    TestDataUtil.createCustomSettings_TriggerStatus();
    Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
    User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');
    
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
            job.Account_Executive_1__c = u.id;
            job.Account_Executive_2__c = u.id;

        }
        update jobs;
        
        
        List<Forecast__c> forecast = new  List<Forecast__c>();
        Forecast__c  BillingForecastObj =  new Forecast__c();
        BillingForecastObj.ATI_Job__c = jobs[0].id;
        BillingForecastObj.Invoice_Date__c = Date.today();
        BillingForecastObj.Revenue_Amount__c = 4500;
        insert BillingForecastObj; 
       // forecast.add(BillingForecastObj);
       // insert forecast;
        
        string jobID = jobs[0].id;
        string jobNumber = jobs[0].job_number__c;
        string ForecastID = BillingForecastObj.id;
        Date ForecastDate = Date.today();
        Date JobDate = Date.today();
        Decimal Amount = 4500;
        string username = u.UserName;
        string uid = u.id;
        
        list<Account_Executive_Revenue__c> AccExeRev = new list<Account_Executive_Revenue__c>(); 
        
        Account_Executive_Revenue__c AccountExecutiveRevenueObj = new Account_Executive_Revenue__c();
        AccountExecutiveRevenueObj.Account_Executive__c = u.id;
        AccountExecutiveRevenueObj.Billing_Forecast__c = BillingForecastObj.id;
        AccountExecutiveRevenueObj.Job__c = jobs[0].id;
        AccountExecutiveRevenueObj.Type__c = 'Account Executive 1';
        AccountExecutiveRevenueObj.IsActive__c = true;
        AccountExecutiveRevenueObj.Name = jobs[0].Job_Number__c + '|' + 'AccountExecutiveName 1';
        AccExeRev.add(AccountExecutiveRevenueObj);
       // insert AccountExecutiveRevenueObj;
        
        Account_Executive_Revenue__c AccountExecutiveRevenueObj1 = new Account_Executive_Revenue__c();
        AccountExecutiveRevenueObj1.Account_Executive__c = u.id;
        AccountExecutiveRevenueObj1.Billing_Forecast__c = BillingForecastObj.id;
        AccountExecutiveRevenueObj1.Job__c = jobs[0].id;
        AccountExecutiveRevenueObj1.Type__c = 'Account Executive 2';
        AccountExecutiveRevenueObj1.IsActive__c = true;
        AccountExecutiveRevenueObj1.Name = jobs[0].Job_Number__c + '|' + 'AccountExecutiveName 2';
       AccExeRev.add(AccountExecutiveRevenueObj1);
        
      //  insert AccountExecutiveRevenueObj1;
       insert  AccExeRev;
      
        List<Account_Executive_Revenue__c> AccExeRevList = new List<Account_Executive_Revenue__c>([SELECT Account_Executive__c,Id,IsActive__c,Job__c,Name,Billing_Forecast__c,Type__c FROM Account_Executive_Revenue__c]);
        List<Forecast__c> ForecastList = new List<Forecast__c>([SELECT ATI_Job__c,Id,Invoice_Date__c,Name,Revenue_Amount__c FROM Forecast__c where ATI_Job__c in: Jobs]);
        system.debug('#####'+AccExeRevList); 
        
        
        AccountExecutiveController.UpdateAccountExecutives(jobs);
        AccountExecutiveController.FilterAccountExecutive(AccExeRevList, JobID);
        AccountExecutiveController.FilterRevenueAccountExecutiveForForecast(AccExeRevList,JobID,ForecastID);
        AccountExecutiveController.FilterAccountExecutiveForForecast(AccExeRevList,JobID,ForecastID);
        AccountExecutiveController.GetInsertableBillingForecastAccountRevenueRecord(JobID,ForecastID,jobNumber,uid,username);
        test.startTest();
        AccountExecutiveController.SeperateAccountExecutiveUpdateList(AccExeRevList);
        //AccountExecutiveController.GetUpdatedForecastAccountExecutives(AccExeRevList[0],uid);
         test.stopTest();
       
       }
    }

}