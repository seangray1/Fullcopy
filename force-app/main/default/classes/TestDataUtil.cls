@isTest
public class TestDataUtil {
    
    //create Users
    public static List<User> createUsers(Integer numToInsert,
                                         Boolean doInsert,
                                         Map<String, Object> nameValue) {
                                             List<User> users = new List<User>();
                                             for( Integer i = 0; i < numToInsert; i++ ) {
                                                 User u = new User(
                                                     LastName='LastName_' + i, 
                                                     Alias='User_' + i, 
                                                     Email='test_' + i + '@gmail.com', 
                                                     UserName='testcaseuser_' + i + '@gmail.com',  
                                                     CommunityNickname='NickName_' + i,
                                                     Department = 'Some Department',
                                                     EmailEncodingKey = 'ISO-8859-1',
                                                     TimeZoneSidKey = 'America/Los_Angeles', 
                                                     LocaleSidKey = 'en_US', 
                                                     LanguageLocaleKey = 'en_US',
                                                     IsActive = true);
                                                 for(String key : nameValue.keySet()){
                                                     u.put(key, nameValue.get(key));
                                                 }
                                                 users.add(u);
                                             }
                                             
                                             if( doInsert ) {
                                                 insert users;
                                             }
                                             return users;
                                         }
    
    public static List<User> createUsersNew(Integer numToInsert,
                                         Boolean doInsert) {
                                             Profile p = [Select Id From Profile Where Name = 'System Administrator'];
                                             List<User> users = new List<User>();
                                             for( Integer i = 0; i < numToInsert; i++ ) {
                                                 User u = new User(
                                                     LastName='LastName_' + i, 
                                                     Alias='User_' + i, 
                                                     Email='test_' + i + '@gmail.com', 
                                                     UserName='testcaseuser_' + i + '@gmail.com',  
                                                     CommunityNickname='NickName_' + i,
                                                     Department = 'Some Department',
                                                     EmailEncodingKey = 'ISO-8859-1',
                                                     TimeZoneSidKey = 'America/Los_Angeles', 
                                                     LocaleSidKey = 'en_US', 
                                                     LanguageLocaleKey = 'en_US',
                                                     IsActive = true,
                                                 profileId = p.Id);
                                                 users.add(u);
                                             }
                                             
                                             if( doInsert ) {
                                                 insert users;
                                             }
                                             return users;
                                         }
    
    public static void createCustomSettings_TriggerStatus(){
        // create Triggerstatus Settings
        TriggerStatus__c triggerStatus = new TriggerStatus__c();
        triggerStatus.AccountGenerateCustomerNumber__c =true;
        triggerStatus.AccountSyncToTimberline__c =true;
        triggerStatus.Forecast_Sync_to_Timberline__c =true;
        triggerStatus.InvoiceAutomaticInvoiceNumber__c =true;
        triggerStatus.InvoiceSyncToTimberline__c =true;
        triggerStatus.InvoiceLineItemAutoCreation__c =true;
        triggerStatus.InvoiceLineItemAutomaticNaming__c =true;
        triggerStatus.InvoiceLineItemAutomaticOrder__c =true;
        triggerStatus.InvoiceTaxGroupSetUp__c =true;
        triggerStatus.JobCopyPMToOwner__c =true;
        triggerStatus.Job_Number_Sequence_Group__c =20140;
        triggerStatus.JobOpportunitySync__c =true;
        triggerStatus.JobSetJobNumber__c =true;
        triggerStatus.JobSyncToTimberline__c =true;
        triggerStatus.LeadPMLeadSync__c =true;
        triggerStatus.OpportunityJobSync__c =true;
        triggerStatus.PMLeadCalculateJobNumber__c =true;
        triggerStatus.PMLeadConversion__c =true;
        triggerStatus.PMLeadLeadSync__c =true;
        triggerStatus.TaskTaskSync__c =true;
        triggerStatus.TaxGroupRefreshFromTimberline__c =true;
        triggerStatus.TaxGroupSetName__c =true;
        insert triggerStatus;
    }
    
    //create Accounts 
    public static List<Account> createAccounts(Integer numToInsert,
                                               Boolean doInsert,
                                               Map<String, Object> nameValue) {
                                                   List<Account> accounts = new List<Account>();
                                                   for( Integer i = 0; i < numToInsert; i++ ) {
                                                       Account a = new Account( Name='Test Account'+String.valueOf(i) );
                                                       a.billingStreet = String.valueOf(i) +'Test Street';
                                                       a.billingcity = 'Test City';
                                                       a.billingstate = 'CT';
                                                       a.billingpostalcode = '0001';
                                                       a.BillingCountry = 'USA';
                                                       a.phone = '8000000000';
                                                       for(String key : nameValue.keySet()){
                                                           a.put(key, nameValue.get(key));
                                                       }
                                                       accounts.add(a);
                                                   }
                                                   
                                                   if( doInsert ) {
                                                       insert accounts;
                                                   }
                                                   return accounts;
                                               }
    
    
    public static List<Contact> createContacts( Integer numToInsert, boolean doInsert, Map<String, String> nameValueMap ){                 
        List<Contact> cts = new List<Contact>(); 
        for( Integer i=0; i<numToInsert; i++ ){
            Contact c = new Contact(LastName='Test Contact'+String.valueOf(i)  );
            c.contact_type__c = 'Adjustor';
            c.firstname = 'semira'+String.valueOf(i);
            c.Lastname = 'roy'+String.valueOf(i);
            c.email = 'test' + String.valueOf(i) + '@gmail.com';
            cts.add(c);
        }       
        return createRecords( cts, doInsert, nameValueMap );
    }
    //create contacts
    public static List<Contact> createContacts(Integer numToInsert,
                                               Boolean doInsert,
                                               Map<String, Object> nameValue,
                                               Id accountId) {
                                                   List<Contact> contacts = new List<Contact>();
                                                   for( Integer i = 0; i < numToInsert; i++ ) {
                                                       Contact c = new Contact( LastName='Test Contacts'+String.valueOf(i)  );
                                                       c.contact_type__c = 'Adjustor';
                                                       c.firstname = 'semira'+String.valueOf(i);
                                                       c.Lastname = 'roy'+String.valueOf(i);
                                                       c.email = 'test' + String.valueOf(i) + '@gmail.com';
                                                       c.accountId = accountId;
                                                       for(String key : nameValue.keySet()){
                                                           c.put(key, nameValue.get(key));
                                                       }
                                                       contacts.add(c);
                                                   }
                                                   
                                                   if( doInsert ) {
                                                       insert contacts;
                                                   }
                                                   return contacts;
                                               }
    
    //create ATI_Job__c 
    public static List<ATI_Job__c> createJob (Integer numToInsert,Boolean doInsert, Map<String, String> nameValueMap ) {
        List<ATI_Job__c> Jobs  = new List<ATI_Job__c >();
        
        Account acc = TestDataUtil.createAccounts(1, true, 
                                                  new Map<String, Object>{ 'Name' => 'testAcctTax',
                                                      'BillingStreet' => 'Street 12',
                                                      'Status__c' => 'Active',
                                                      'BillingCity' => 'San Francisco',
                                                      'BillingCountry' => 'USA',
                                                      'BillingPostalCode' => '1234',
                                                      'BillingState' => 'CA',
                                                      'Type' => 'Consultant' })[0];
        List<Contact> Contact = createContacts(1, true, new Map<String, String>{'accountId' => acc.Id});
        
        for( Integer i = 0; i < numToInsert; i++ ) {
            ATI_Job__c  j = new ATI_Job__c(Name='Test ATI_Job__c '+String.valueOf(i)  );
            j.Name = 'semira234';
            j.Job_Name__c = 'test';
            j.Project_Site_Contact_Name__c = contact[0].id;
            j.Project_Site_Contact_Account__c = acc.id;
            j.Project_Site_Address__c = 'Test Street';
            j.Project_Site_City__c = 'Los Angeles';
            j.Project_Site_state__c = 'CA';
            j.Project_Site_zipcode__c ='90027';
            //j.County__c = 'LA';
            //j.City_of_LA__c = 'Yes';
            j.Stage__c ='Qualification';
            j.CloseDate__c = System.today().addDays(90); 
            j.office2__c = null;
            j.Division__c = 'test';         
            Jobs.add(j);
        }
        
        return createRecords( Jobs, doInsert, nameValueMap );
    }
    
    //create ATI_Job__c 
    public static List<ATI_Job__c> createJob (Integer numToInsert,
                                                      Boolean doInsert, 
                                                      Map<String, Object> nameValue,
                                                      Id accountId) {
                                                          List<Contact> Contact = createContacts(1, true, new Map<String, String>{'accountId' => accountId});
                                                          List<ATI_Job__c> Jobs  = new List<ATI_Job__c >();
                                                          for( Integer i = 0; i < numToInsert; i++ ) {
                                                              ATI_Job__c  j = new ATI_Job__c(Name='Test ATI_Job__c '+String.valueOf(i)  );
                                                              j.Account__c = accountId;
                                                              // j.Name = 'semira';
                                                              j.Job_Name__c = 'test';
                                                              j.Project_Site_Contact_Name__c = contact[0].id;
                                                              j.Project_Site_Contact_Account__c = accountId;
                                                              j.Project_Site_Address__c = 'Test Street';
                                                              j.Project_Site_City__c = 'Los Angeles';
                                                              j.Project_Site_state__c = 'CA';
                                                              j.Project_Site_zipcode__c ='90027';
                                                              //j.County__c = 'LA';
                                                              //j.City_of_LA__c = 'Yes';
                                                              j.Stage__c ='Qualification';
                                                              j.CloseDate__c = System.today().addDays(90);
                                                              j.office2__c = null;
                                                              j.Division__c = 'test';
                                                              system.debug('ketset'+nameValue.keySet());
                                                              for(String key : nameValue.keySet()){
                                                                  j.put(key, nameValue.get(key));
                                                                  system.debug('Maps--'+j);
                                                              }
                                                              Jobs.add(j);
                                                          }
                                                          system.debug('Jobs--'+Jobs);
                                                          if( doInsert ) {
                                                              insert Jobs;
                                                          }
                                                          return Jobs;
                                                      }
    
    //create Budget Line Item
    public static List<Budget_Line_Item__c> createLineItem( Integer numToInsert, boolean doInsert, Map<String, String> nameValueMap){                 
        List<Budget_Line_Item__c> lineitem = new List<Budget_Line_Item__c>(); 
        for( Integer i=0; i<numToInsert; i++ ){
            Budget_Line_Item__c item = new Budget_Line_Item__c();
            item.Trade__c = 'CLN Cleaning';
            item.Revenue__c = 100;
            item.Subcontractor__c = 'test';
            item.Subcontractor_Bid__c = 16;
            item.In_House_Hours__c = 1;
            item.In_House_Rate__c = 234;
            item.Materials__c = 34;
            item.Fees__c = 45;
            lineitem.add(item);
        }       
        return createRecords( lineitem, doInsert, nameValueMap );
    }
    //create contacts
    public static List<Budget_Line_Item__c> createLineItem(Integer numToInsert,
                                                           Boolean doInsert,
                                                           Map<String, Object> nameValue,
                                                           ID jobId) {
                                                               List<Budget_Line_Item__c> lineitem = new List<Budget_Line_Item__c>();
                                                               Budget__c budget = new Budget__c(ATI_Job__c = jobId);
                                                               for( Integer i = 0; i < numToInsert; i++ ) {
                                                                   Budget_Line_Item__c item = new Budget_Line_Item__c();
                                                                   item.Trade__c = 'CLN Cleaning';
                                                                   item.Revenue__c = 45;
                                                                   item.Subcontractor__c = 'test';
                                                                   item.Subcontractor_Bid__c = 34;
                                                                   item.In_House_Hours__c = 1;
                                                                   item.In_House_Rate__c = 245;
                                                                   item.Materials__c = 100;
                                                                   item.Fees__c = 454;
                                                                   item.Budget__c = budget.Id;
                                                                   for(String key : nameValue.keySet()){
                                                                       item.put(key, nameValue.get(key));
                                                                   }
                                                                   lineitem.add(item);
                                                               }
                                                               
                                                               if( doInsert ) {
                                                                   insert lineitem;
                                                               }
                                                               return lineitem;
                                                           }
    
   
    
    // Generic method to create Records for sobjects
    public static List<SObject> createRecords( List<SObject> records, Boolean doInsert, Map<String, Object> attributes ){
        Integer i = 0;
        if( attributes != null ){
            for ( Integer j =0; j < records.size(); j ++ ) {
                Sobject record = records[j];
                for (String key : attributes.keySet()) {
                    // to increment the name by 1
                    if( key.equalsIgnoreCase( 'name' ) ) {
                        record.put( key, String.valueof( attributes.get( key ) ) + j );
                    }else {
                        Object value = attributes.get(key);
                        if (value instanceof List<Object>) {
                            object obj =  ((List<Object>) value).get(i);
                            if( obj instanceof Sobject ){
                                Id sObjectId = ((SObject) obj).Id;
                                record.put( key,sObjectId );
                            }
                            else {
                                record.put(key,obj);
                            }
                        } else {
                            record.put(key, value);
                        }
                    }
                }
                i++;
            }
        }
        
        if (doInsert) {
            // insert records;
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.AllowSave = true; 
            Account duplicateAccount = new Account(Name='dupe'); 
            List<Database.SaveResult> results = Database.insert(records, dml); 
        }
        return records;
    }
    
    public static void createOldJobs()
    {
        Account acc = new Account(name= 'prft_offshore_test');
        acc.BillingStreet = 'Street 12';
        acc.BillingCity = 'San Francisco';
        acc.BillingCountry = 'USA';
        acc.BillingPostalCode = '1234';
        acc.BillingState = 'CA';
        insert acc;
        
        Contact contact = new Contact();
        contact.AccountId = acc.Id;
        contact.firstname = 'Test';
        contact.LastName = 'test';
        contact.Email = 'test@gamil.com';
        Insert contact;
        
       
    }
       
    public static void createExpenseApprReq()
    {
        Expense__c expense = new Expense__c(name = 'test', date__c = system.today(), Status__c = 'Submitted', Date_Submitted__c = system.today());
        insert expense; 
        
        // Create an approval request for the account
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(expense.id);
        
        // Submit the approval request for the account
        Approval.ProcessResult result = Approval.process(req1);
        
        // Verify the result
        System.assert(result.isSuccess());
        
        System.assertEquals('Pending', result.getInstanceStatus(), 'Instance Status'+result.getInstanceStatus());
        
        // Approve the submitted request
        // First, get the ID of the newly created item
        List<Id> newWorkItemIds = result.getNewWorkitemIds();
        
        // Instantiate the new ProcessWorkitemRequest object and populate it
        Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
        req2.setComments('Approving request.');
        req2.setAction('Approve');
        req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        
        // Use the ID from the newly created item to specify the item to be worked
        req2.setWorkitemId(newWorkItemIds.get(0));
        
        // Submit the request for approval
        Approval.ProcessResult result2 =  Approval.process(req2);
        
        // Verify the results
        System.assert(result2.isSuccess(), 'Result Status:'+result2.isSuccess());
        System.assertEquals('Approved', result2.getInstanceStatus(), 'Instance Status'+result2.getInstanceStatus());       
    }
    
    
    public static void setUpAccount()
    {
        Account acc = TestDataUtil.createAccounts(1, true, 
                                                  new Map<String, Object>{ 'Name' => 'testAcctTax',
                                                      'BillingStreet' => 'Street 12',
                                                      'Status__c' => 'Active',
                                                      'BillingCity' => 'San Francisco',
                                                      'BillingCountry' => 'USA',
                                                      'BillingPostalCode' => '1234',
                                                      'BillingState' => 'CA',
                                                      'Type' => 'Consultant' })[0];
        
        
        Contact con = new Contact();
        con.accountid = acc.id;
        con.contact_type__c = 'Consultant';
        con.FirstName = 'Test';
        con.lastname = 'Contact';
        insert con;
        
        TriggerStatus__c trigStatus = new TriggerStatus__c();
        trigStatus.SetupOwnerId = UserInfo.getUserId();
        trigStatus.TaxGroupSetName__c = true;
        insert trigStatus;
        TriggerConfig.raw = TriggerStatus__c.getInstance( UserInfo.getUserId());    
    }
    
    public static Tax_Group__c createTaxGroup()
    {
        Tax_Group__c tg = new Tax_Group__c();
        tg.name = 'taxgrp637';
        tg.Tax_Rate__c = 20;  
        tg.Timberline_Id__c = 'taxgrp6';
        tg.Tax1Name__c = 'tax1';
        tg.Tax1Rate__c=20;
        tg.Tax2Name__c = 'tax2';
        tg.Tax2Rate__c = 10;
        tg.Tax3Name__c = 'tax3';
        tg.Tax3Rate__c = 30;
        tg.Tax4Name__c = 'tax4';
        tg.Tax4Rate__c = 40;
        tg.Tax5Name__c = 'tax5';
        tg.Tax5Rate__c = 5;
        tg.Tax6Name__c = 'tax6';
        tg.Tax6Rate__c = 3;
        tg.Tax7Name__c = 'tax7';
        tg.Tax7Rate__c = 3;
        tg.Tax8Name__c = 'tax8';
        tg.Tax8Rate__c = 3;
        tg.Tax9Name__c = 'tax9';
        tg.Tax9Rate__c = 3;
        tg.Refresh_Tax_Groups__c = true;   
        return tg; 
    }
    
    public static List<Tax_Group__c> createBulkTaxGroups()
    {
        Tax_Group__c tg = new Tax_Group__c();
        tg.name = 'taxgrp637';
        
        tg.Tax_Rate__c = 20;  
        
        tg.Timberline_Id__c = 'taxgrp6';
        tg.Tax1Name__c = 'tax1';
        tg.Tax1Rate__c=20;
        tg.Tax2Name__c = 'tax2';
        tg.Tax2Rate__c = 10;
        tg.Tax3Name__c = 'tax3';
        tg.Tax3Rate__c = 30;
        tg.Tax4Name__c = 'tax4';
        tg.Tax4Rate__c = 40;
        tg.Tax5Name__c = 'tax5';
        tg.Tax5Rate__c = 5;
        tg.Tax6Name__c = 'tax6';
        tg.Tax6Rate__c = 3;
        tg.Tax7Name__c = 'tax7';
        tg.Tax7Rate__c = 3;
        tg.Tax8Name__c = 'tax8';
        tg.Tax8Rate__c = 3;
        tg.Tax9Name__c = 'tax9';
        tg.Tax9Rate__c = 3;
        tg.Refresh_Tax_Groups__c = true;
        
        Tax_Group__c tg1 = new Tax_Group__c();
        tg1.name = 'taxgrp6376';
        tg1.Tax_Rate__c = 20;  
        tg1.Timberline_Id__c = 'taxgrp61';
        tg1.Tax1Name__c = 'tax11';
        tg1.Tax1Rate__c=20;
        tg1.Tax2Name__c = 'tax2';
        tg1.Tax2Rate__c = 10;
        tg1.Tax3Name__c = 'tax3';
        tg1.Tax3Rate__c = 30;
        tg1.Tax4Name__c = 'tax4';
        tg1.Tax4Rate__c = 40;
        tg1.Tax5Name__c = 'tax5';
        tg1.Tax5Rate__c = 5;
        tg1.Tax6Name__c = 'tax6';
        tg1.Tax6Rate__c = 3;
        tg1.Tax7Name__c = 'tax7';
        tg1.Tax7Rate__c = 3;
        tg1.Tax8Name__c = 'tax8';
        tg1.Tax8Rate__c = 3;
        tg1.Tax9Name__c = 'tax9';
        tg1.Tax9Rate__c = 3;
        tg1.Refresh_Tax_Groups__c = true;
        
        List<Tax_Group__c> tgs = new List<Tax_Group__c>();
        tgs.add(tg);
        tgs.add(tg1); 
        return tgs;
    }
}