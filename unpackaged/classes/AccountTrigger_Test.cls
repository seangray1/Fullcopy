@istest
public class AccountTrigger_Test{
    
    public static TestMethod void myUnitTest(){
        Account newAcct = new Account();
        newAcct.Name = 'testAcct';
        newAcct.BillingStreet = 'Street \\\\ 12';
        newAcct.BillingCity = 'San Francisco';
        newAcct.BillingCountry = 'USA';
        newAcct.BillingPostalCode = '1234';
        newAcct.BillingState = 'CA';
        insert newAcct;
    }
    
    public static TestMethod void myUnitTest2(){
        TestDataUtil.createCustomSettings_TriggerStatus();
        Account newAcct = new Account();
        newAcct.Name = 'testAcct';
        newAcct.BillingStreet = 'Street 12';
        newAcct.BillingCity = 'San Francisco';
        newAcct.BillingCountry = 'USA';
        newAcct.BillingPostalCode = '1234';
        newAcct.BillingState = 'CA';
        insert newAcct;
        
        newAcct = [SELECT Id,BillingCity,Send_To_Timberline__c FROM Account WHERE Id = :newAcct.Id];
        newAcct.Send_To_Timberline__c = true;
        newAcct.BillingCity = 'test city2';
        update newAcct;
    }
    
    public static TestMethod void myUnitTest3(){
        TestDataUtil.createCustomSettings_TriggerStatus();
        Profile p= [Select id from Profile where Name = 'System Administrator' LIMIT 1];
        User u = TestDataUtil.createUsers(1, false, new Map<String, Object>{ 'profileId' => p.Id })[0];
        // system.runas(u){
        Account newAcct = TestDataUtil.createAccounts(1, true, 
                                                      new Map<String, Object>{ 'Name' => 'testAcct',
            																   'BillingStreet' => 'Street 12',
                                                          					   'BillingCity' => 'San Francisco',
                                                          					   'BillingCountry' => 'USA',
                                                          					   'BillingPostalCode' => '1234',
                                                          					   'BillingState' => 'CA' })[0];
        // }
        
    }
    
    public static TestMethod void myUnitTest4(){
        Account newAcct = TestDataUtil.createAccounts(1, true, 
                                                      new Map<String, Object>{ 'Name' => 'testAcct',
            																   'BillingStreet' => 'Street 12',
                                                          					   'BillingCity' => 'San Francisco',
                                                          					   'BillingCountry' => 'USA',
                                                          					   'BillingPostalCode' => '1234',
                                                          					   'BillingState' => 'CA' })[0];
    }
    
    public static TestMethod void myUnitTest5(){
        TestDataUtil.createCustomSettings_TriggerStatus();
        
        Test.startTest();
        Account newAcct = TestDataUtil.createAccounts(1, true, 
                                                      new Map<String, Object>{ 'Name' => 'testAcct',
            																   'BillingStreet' => 'Street 12',
                                                          					   'BillingCity' => 'San Francisco',
                                                          					   'BillingCountry' => 'USA',
                                                          					   'BillingPostalCode' => '1234',
                                                          					   'BillingState' => 'CA',
                                                          					   'Send_To_Timberline__c' => true})[0];
        
        newAcct = [SELECT Id,BillingCity,Send_To_Timberline__c FROM Account WHERE Id = :newAcct.Id];
        update newAcct;
        Test.stopTest();
    }
    /*
    private static testMethod void testAEUpdateOnRelatedOpps(){
        TestDataUtil.createCustomSettings_TriggerStatus();
        Profile p= [Select id from Profile where Name =: OpportunityAEBonusTriggerHandler.PROFILE_MARKETING_REP LIMIT 1];
        User u = TestDataUtil.createUsers(1, true, new Map<String, Object>{ 'profileId' => p.Id,
            																'AE_Type__c' => 'Local',
            																'ManagerId' => Userinfo.getUserId()})[0];
        Test.startTest();
            Account newAcct;
            System.runas( new User(Id = Userinfo.getUserId() ) ){
                newAcct = TestDataUtil.createAccounts(1, true, 
                                                              new Map<String, Object>{ 'Name' => 'testAcct',                                                          					   
                                                                                       'BillingStreet' => 'Street 12',
                                                                                       'BillingCity' => 'San Francisco',
                                                                                       'BillingCountry' => 'USA',
                                                                                       'BillingPostalCode' => '1234',
                                                                                       'BillingState' => 'CA' })[0];
                List<ATI_Job__c> jobs = TestDataUtil.createOpportunity(1, true, new Map<String, String>{ 'AccountId' => newAcct.Id });
                List<ProcessInstance> existingApprovalProcess = [SELECT Id, TargetObjectId,
                                                                 		(SELECT Id, ActorId, ProcessInstanceId FROM Workitems)
                                                                 FROM ProcessInstance 
                                                                 WHERE TargetObjectId =: newAcct.Id
                                                                 	AND Status = 'Pending'];
                if( !existingApprovalProcess.isEmpty() ){
                    Approval.ProcessWorkitemRequest[] prWkItems = New Approval.ProcessWorkItemRequest[]{};
                    for(ProcessInstanceWorkItem workItem : existingApprovalProcess[0].WorkItems){
                        Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
                        req2.setComments('Approving request.');
                        req2.setAction('Approve');
                        req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});
                        req2.setWorkitemId(workItem.Id);
                        prWkItems.add( req2 );
                    }
                    Approval.ProcessResult[] results =  Approval.process(prWkItems);
                }
            }
            system.runas(u){
                newAcct.OwnerId = u.Id;
                update newAcct;
            }
        Test.stopTest();
        List<ATI_Job__c> jobs = [ SELECT Id, Account_Executive_1__c FROM ATI Job where AccountId =: newAcct.Id ];
        for( ATI_Job__c job : jobs ){
            System.assertEquals( u.Id, opp.Account_Executive_1__c, 'AE1 on ATI Job should be updated to account owner if there is no AE1');
        }
    }*/
}