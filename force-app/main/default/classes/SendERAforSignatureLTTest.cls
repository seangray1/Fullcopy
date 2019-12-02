@isTest
public class SendERAforSignatureLTTest {
    
	public static TestMethod void testSendERAforSignatureLT(){
 	
        TestDataUtil.createCustomSettings_TriggerStatus();
        
        list<Account> lstAccounts = TestDataUtil.createAccounts(1, false, new map<String,Object>());
        insert lstAccounts;
        
        Contract ctrt = new Contract();
        ctrt.AccountId = lstAccounts[0].Id;
        ctrt.AE_Name__c  = UserInfo.getUserId();
        
        insert ctrt;
        
        Test.startTest();
        SendERAforSignatureLT.getContract(ctrt.Id);
        Test.stopTest();
            
    }
}