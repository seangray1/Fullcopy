@isTest
private class ContactTrigger_Test{
    static TestMethod void UnitTest1(){
        Account newAcct = TestDataUtil.createAccounts(1, true, 
                                                      new Map<String, Object>{ 'Name' => 'testAcct',
                                                                               'BillingStreet' => 'Street \\\\ 12',
                                                                               'BillingCity' => 'San Francisco',
                                                                               'BillingCountry' => 'USA',
                                                                               'BillingPostalCode' => '1234',
                                                                               'BillingState' => 'CA' })[0];
        
        
        Contact newCont = TestDataUtil.createContacts(1, true, 
                                                      new Map<String, String>{ 'Accountid' => newAcct.Id,
                                                                               'LastName' => 'lname',
                                                                               'MailingStreet' => 'line1\\\\line2'})[0];     
       
    }
    
    static TestMethod void StreetEmpty(){
        Account newAcct = TestDataUtil.createAccounts(1, true, 
                                                      new Map<String, Object>{ 'Name' => 'testAcct',
                                                                               'BillingStreet' => 'Street \\\\ 12',
                                                                               'BillingCity' => 'San Francisco',
                                                                               'BillingCountry' => 'USA',
                                                                               'BillingPostalCode' => '1234',
                                                                               'BillingState' => 'CA' })[0];
        
        
        Contact newCont = TestDataUtil.createContacts(1, true, 
                                                      new Map<String, String>{ 'Accountid' => newAcct.Id,
                                                                               'LastName' => 'lname',
                                                                               'MailingStreet' => '\\\\'})[0];     

    }
    
    static TestMethod void StreetLine1(){
        Account newAcct = TestDataUtil.createAccounts(1, true, 
                                                      new Map<String, Object>{ 'Name' => 'testAcct',
                                                                               'BillingStreet' => 'Street \\\\ 12',
                                                                               'BillingCity' => 'San Francisco',
                                                                               'BillingCountry' => 'USA',
                                                                               'BillingPostalCode' => '1234',
                                                                               'BillingState' => 'CA' })[0];
        
        
        Contact newCont = TestDataUtil.createContacts(1, true, 
                                                      new Map<String, String>{ 'Accountid' => newAcct.Id,
                                                                               'LastName' => 'lname',
                                                                               'MailingStreet' => 'line1\\\\'})[0];            
    }

    static testMethod void testOwnershipUpdate(){
        TestDataUtil.createCustomSettings_TriggerStatus();
        Profile p= [Select id from Profile where Name =: JobAEBonusTriggerHandler.PROFILE_MARKETING_REP LIMIT 1];
        User u = TestDataUtil.createUsers(1, true, new Map<String, Object>{ 'profileId' => p.Id,
                                                                            'AE_Type__c' => 'Local',
                                                                            'ManagerId' => Userinfo.getUserId()})[0];
        Test.startTest();
            Account newAcct;
            Contact cont;
            System.runas( new User(Id = Userinfo.getUserId() ) ){
                newAcct = TestDataUtil.createAccounts(1, true, 
                                                              new Map<String, Object>{ 'Name' => 'testAcct',                                                                               
                                                                                       'BillingStreet' => 'Street 12',
                                                                                       'BillingCity' => 'San Francisco',
                                                                                       'BillingCountry' => 'USA',
                                                                                       'BillingPostalCode' => '1234',
                                                                                       'BillingState' => 'CA' })[0];
                cont = TestDataUtil.createContacts(1, true, new Map<String, String>{ 'AccountId' => newAcct.Id })[0];
            }
            cont.Ownership_Request_Status__c = 'Approved';
            cont.Ownership_Requester_ID__c = u.Id;
        	cont.Lunch_and_Learn_Status__c = 'unapproved';
            update cont;
        Test.stopTest();
    }
}