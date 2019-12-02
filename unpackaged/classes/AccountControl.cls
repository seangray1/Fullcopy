public with sharing class AccountControl {
    
    public static void setCustomerNumber(List<Account> accounts) {
    	//test
    	// Need to determine the maximum sequential number to use
    	Integer customerSequence = null;
    	try{
	    	Account a = [SELECT Id, Timberline_Customer_Number_Sequence_New__c
	    	             FROM Account
                         WHERE Timberline_Customer_Number_Sequence_New__c != null
	    	             ORDER BY Timberline_Customer_Number_Sequence_New__c DESC
	    	             LIMIT 1];
	    	if (a.Timberline_Customer_Number_Sequence_New__c != null) {
	    		customerSequence = a.Timberline_Customer_Number_Sequence_New__c.intValue();
	    	}
    	} catch (Exception e) {
    		// Keep the customer sequence null which will be handled later
    		customerSequence = null;
    	}
    	
    	System.debug('customerSequence1 : ' + customerSequence );
    	
    	// Increment the customer sequence number
    	if (customerSequence == null) {
    		customerSequence = 0;
    	} else {
    		customerSequence += 1;
    	}
    	
    	System.debug('customerSequence2 : ' + customerSequence );
    	
    	// Go through each of the accounts and update the account number
    	for (Account a : accounts) {
    		if (String.isBlank(a.Timberline_Customer_Number__c) && a.Send_to_Timberline__c ) 
    		{
	    		a.Timberline_Customer_Number__c = AccountControl.generateCustomerNumberText(customerSequence);
	    		System.debug('a.Timberline_Customer_Number__c : ' + a.Timberline_Customer_Number__c );
	    		customerSequence += 1;
    		}
    	}
    	
    }
    
    
    public Static String generateCustomerNumberText(Integer sequential) {
    	String str = ADCUtil_Base.forceStringLength(String.valueOf(sequential), 6, '0', false);
    	//return str += '-000';
    	//return str.substring(0, 5) + '-' + str.substring(5, 8);
    	return str;
    }
    
}