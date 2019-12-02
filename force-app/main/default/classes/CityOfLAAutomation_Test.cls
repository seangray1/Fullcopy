@isTest
public class CityOfLAAutomation_Test {
    
    static List<ATI_Job__c> jobs;
      
    public static testmethod void testcounty(){
    
        //map<id, opportunity> oldmap = new map<id, opportunity>();
        
        //create opportunity with an address
        testDataSetup();
         
          
        //should return No
        jobs[0].Project_Site_Address__c = '210 w baywood ave';
        jobs[0].Project_Site_Zipcode__c = '92865';
        
        //should return yes
        jobs[1].Project_Site_Address__c = '1735 n kingsley Dr.';
        jobs[1].Project_Site_Zipcode__c = '90027';
        
        //empty
        jobs[2].Project_Site_Address__c = '';
        jobs[2].Project_Site_Zipcode__c = '';
        
        update jobs;

        List<ATI_Job__c> newList = [select id, ZIPcodecheck_cityofLA__c, Project_Site_Address__c, Project_Site_Address_2__c, Project_Site_City__c, 
                                    Project_Site_State__c, Project_Site_Zipcode__c from ATI_Job__c where ID IN: jobs and ZIPcodecheck_cityofLA__c = true];
        
        system.debug('THE LIST IS EMPTY?'+ newList.isEmpty());        
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        //pass the opportunity to the class
        CityOfLAAutomation.CountySearch(null, newList);
        test.stopTest();
    }
    
    public class MockHttpResponseGenerator implements HttpCallOutMock{
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
        
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"example":"test"}');
            res.setStatusCode(200);
            return res;
        
        }
    }
    
    //don't probably need this.
    public static void testDataSetup(){
        
        System.runAs(new User(Id = userinfo.getUserId())){
            TestDataUtil.createCustomSettings_TriggerStatus();
        }
        List<Account> accounts = TestDataUtil.createAccounts(1, true, new Map<String, Object>{ 'Name' => 'testAcct',
                                               'BillingStreet' => 'Street 12',
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
      
        
    }
}