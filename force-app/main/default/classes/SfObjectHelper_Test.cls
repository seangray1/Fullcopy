@istest
public class SfObjectHelper_Test {
    Public static TestMethod void TestsObject()
    {
        List<Account> accounts = TestDataUtil.createAccounts(1, true, new Map<String, Object>{ 'Name' => 'test sObject',
                                               'BillingStreet' => '12345 objectTest',
                                                                       'BillingCity' => 'San Francisco',
                                                                       'BillingCountry' => 'USA',
                                                                       'BillingPostalCode' => '1234',
                                                                       'BillingState' => 'CA' } );

        for(Account account: accounts){
            
            String Name = SfObjectHelper.GetObjectNameById(account.id);
            List<String> fieldsbyName = SfObjectHelper.GetObjectFieldsByName(Name);
            List<String> fieldsbyID = SfObjectHelper.GetObjectFieldsById(account.id);
            sObject acct = SfObjectHelper.getRecordById(account.id);
                       
            system.assertEquals('Account', Name);
            system.assertEquals('Account', acct.getSObjectType().getDescribe().getName());
            
                
        }

    } 

}