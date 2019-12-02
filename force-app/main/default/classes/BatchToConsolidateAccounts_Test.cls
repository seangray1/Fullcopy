@isTest
private class BatchToConsolidateAccounts_Test {
    static testmethod void testContactsConsolidation(){
        List<Account> accounts = TestDataUtil.createAccounts(10, true, 
                                                             new Map<String, Object>{ 'Name' => 'testAcct',
            																   'BillingStreet' => 'Street \\\\ 12',
                                                          					   'BillingCity' => 'San Francisco',
                                                          					   'BillingCountry' => 'USA',
                                                          					   'BillingPostalCode' => '1234',
                                                          					   'BillingState' => 'CA' });
        List<Contact> contacts = TestDataUtil.createContacts(10, false, null);
        for( Integer i=0; i<accounts.size(); i++ ){
            contacts[i].AccountId = accounts[i].Id;
        }
        insert contacts;
        
        for( Integer i=0; i<accounts.size()-1; i++ ){
            accounts[i].Master_Account__c = accounts[9].Id;
        }
        update accounts;
        
        List<Task> tasks = new List<Task>();
                
        for( Contact con : contacts ){
            Task t = new Task( Subject = 'test', whoId = con.Id );
            tasks.add( t );
        }
        insert tasks;
         Attachment attach=new Attachment(); 
    attach.Name='Unit Test Attachment'; 
    Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body'); 
    attach.body=bodyBlob; attach.parentId=accounts[0].id;
    insert attach;
	        
        Test.startTest();
        	BatchToConsolidateAccounts b = new BatchToConsolidateAccounts( 'Contact', 'AccountId');
			database.executeBatch(b);
            b = new BatchToConsolidateAccounts( 'Attachment', 'parentId');
        	database.executeBatch(b);           
        Test.stopTest();
    }
}