@isTest
private class ContractTrigger_Test {

    static testMethod void testContractActivation() {
        Account acc = TestDataUtil.createAccounts(1, true, new Map<String, Object>{ 'Name' => 'testAcct',
                                                                               'BillingStreet' => 'Street \\\\ 12',
                                                                               'BillingCity' => 'San Francisco',
                                                                               'BillingCountry' => 'USA',
                                                                               'BillingPostalCode' => '1234',
                                                                               'BillingState' => 'CA' })[0];
        Contract cont = new Contract( AccountId = acc.Id, StartDate = Date.today(), Status = 'Draft', ContractTerm = 12);
        insert cont;
        acc.ERA__c = false; //DemandBlue:11/09/2018 -->  Changed to false from true
        update acc;
        Test.startTest();
            cont.status = 'Activated';
        cont.AE_Name__c = userinfo.getUserid();
            update cont;
        Test.stopTest();
        acc = [ SELECT Id, ERA__c FROM Account WHERE Id =: acc.Id ];
        System.assert(acc.ERA__c);
        
    }
    
    static testMethod void testContractActivationOnUpdate(){
       //DemandBlue:11/09/2018 -->  Added below code to get code coverage
        Account acc1 = TestDataUtil.createAccounts(1, true, new Map<String, Object>{ 'Name' => 'testAcct',
                                                                               'BillingStreet' => 'Street \\\\ 12',
                                                                               'BillingCity' => 'San Francisco',
                                                                               'BillingCountry' => 'USA',
                                                                               'BillingPostalCode' => '1234',
                                                                               'BillingState' => 'CA' })[0];
        
        acc1.ERA__c = true;
        update acc1;
       
        Contract cont1 = new Contract( AccountId = acc1.Id, StartDate = Date.today(), Status = 'Draft', ContractTerm = 12);
        insert cont1;
        Test.startTest();
            cont1.status = 'Activated';
        cont1.AE_Name__c = userinfo.getUserid();
            update cont1;       
        Test.stopTest();

        acc1 = [ SELECT Id, ERA__c FROM Account WHERE Id =: acc1.Id ];
        System.assert(acc1.ERA__c);    
        
		}

}