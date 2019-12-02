public with sharing class ValidateCredentialsControler 
{
	
	/* PAGE VARIABLES */
	
	// Variable that keeps track when the credentials are valid or not
	public Boolean validCredentials {public get; public set;}
	public String userName {public get; public set;}
	public String passWord {public get; public set;}
	
	
	/************************************************************************************
	*
	*	ValidateCredentialsControler: Default Constructor
	*
	*
	*************************************************************************************/
	public ValidateCredentialsControler()
	{
		User runUs =  [select id,TUserName__c, TPassword__c, Invalid_Credentials__c, TimberlineCredentialsLastCheck__c from User where id = :UserInfo.getUserId()];
		
		system.debug('runUs.Invalid_Credentials__c: ' + runUs.Invalid_Credentials__c);
		
		validCredentials = !runUs.Invalid_Credentials__c;
		
		system.debug('runUs.Invalid_Credentials__c: ' + validCredentials);
	}
	
	/******************************************************************************************
	*
	*	testCredentials: Method that will make sure we only test credentials every five minutes
	*
	*	PARAMS:
	*			boolean run: variable to overide the logic to run the credentials mechanism
	*
	*	RETURN:
	*			Nothing. However, valid credentials boolean will be set depending on result
	*
	********************************************************************************************/
	public void runCredentials(boolean run)
	{	
		
		system.debug('ENTER runCredentials');
		
		// get the user information
		User runUs =  [select id,TUserName__c, TPassword__c, Invalid_Credentials__c, TimberlineCredentialsLastCheck__c from User where id = :UserInfo.getUserId()];
		
		Double LastMod2 = ADCUtil_Base.getDifferenceDateTime(DateTime.now(),runUs.TimberlineCredentialsLastCheck__c, ADCUtil_Base.GET_DIFFERENCE_DATETIME_MINUTES);
		
		system.debug('LastMod2: ' + LastMod2);
		
		if((LastMod2 == null || LastMod2 > 5) || run)
		{
			// Get the response from Timberland
			Boolean response = TimberlineSynch.checkCredentials(runUs.TUserName__c , runUs.TPassword__c);
			
			system.debug('testCredentials:response ' + response);
			
			// set the result to the page
			validCredentials = response;
			
			// set the last mod in user
			runUs.Invalid_Credentials__c = !response;
			runUs.TimberlineCredentialsLastCheck__c = datetime.now();
			
			// Update the user
			update runUs;

		}
		else
		{
			system.debug('HERE1: NOT Checking credentials');
		}
		
		system.debug('EXIT runCredentials');
	}

	/******************************************************************************************
	*
	*	testCredentials: 	Method that will call the runCredentials method passing true, to run
	*						no matter what
	*
	*	PARAMS:
	*			None
	*
	*	RETURN:
	*			Nothing
	*
	********************************************************************************************/
	public void checkCredentials()
	{
		runCredentials(true);
	}
	
	public String Status {get; set;}
	public PageReference startTaxSynch() {
		
        // Generate a reference code for this refresh (used for notifications)
        String ref = String.valueOf(DateTime.now().getTime());
        
        // Notify email recipients
        TaxGroupControl.refreshBeginNotification(ref);
        
        // Asynchronously refresh tax groups
        TaxGroupControl.taxGroupRefresh(ref);
		
		Status = 'Started';
		return null;
	}
	
	
	/******************************************************************************************
	*
	*	testCredentials: 	Method that will call the runCredentials method passing true, to run
	*						evaluating the criteria
	*
	*	PARAMS:
	*			None
	*
	*	RETURN:
	*			Nothing
	*
	********************************************************************************************/
	public void testCredentials()
	{
		runCredentials(false);
	}

	/******************************************************************************************
	*
	*	newCredentials: Method that will save the new credentials on the user
	*
	*	PARAMS:
	*			None
	*
	*	RETURN:
	*			Nothing
	*
	********************************************************************************************/
	public void newCredentials()
	{
		// Get user
		User runUs =  [select id,TUserName__c, TPassword__c, Invalid_Credentials__c, TimberlineCredentialsLastCheck__c from User where id = :UserInfo.getUserId()];
		
		// Set user name and password
		runUs.TUserName__c = userName;
		runUs.TPassword__c = passWord;
		runUs.Invalid_Credentials__c = false;
		
		update runUs;
	}
	
	
	private static testmethod void t_mainTest() 
	{
		// test controller
        ValidateCredentialsControler t = new ValidateCredentialsControler();
		t.testCredentials();
		t.newCredentials();
		t.checkCredentials();
    }
    
    private static testmethod void t_testCredentials() 
	{
		// test controller
        ValidateCredentialsControler t = new ValidateCredentialsControler();
		t.testCredentials();
    }
    
    private static testmethod void t_newCredentials() 
	{
		// test controller
        ValidateCredentialsControler t = new ValidateCredentialsControler();
		t.newCredentials();
    }
    
    private static testmethod void t_checkCredentials() 
	{
		// test controller
        ValidateCredentialsControler t = new ValidateCredentialsControler();
		t.checkCredentials();
    }
    
    private static testmethod void t_UpdateTaxCodes() 
	{
		// test controller
        ValidateCredentialsControler t = new ValidateCredentialsControler();
        
        Test.StartTest();
		t.startTaxSynch();
		Test.StopTest();
	}
    
	
	
}