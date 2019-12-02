/*
 * @Auhtor: Narasimha (Perficient)
 * @Created: 17.MAR.2015
 * @Desc : Controller class for the NewJob Page.
 *         To create a new job and related records
 * 
 *
 */
public without sharing class CreateNewJobInquiry2 {
    public static final String NO_DUPLICATE_RECORDS = 'No Duplicate Records';
    public String SelectPrimaryAccount { get; set; }
    
    public Boolean SameAsCaller { get; set; }
    
    
    public Boolean showNewCaller {get;set;}
    public Boolean showNewAccount {get;set;}
    public Boolean showNewCustomerPerson {get;set;}
    public Boolean showNewCustomerBusiness {get;set;}
    public Boolean showNewProjectSiteContact {get;set;}
    public Boolean showNewProjectSiteContactAccount {get;set;}
    public Boolean showNewInsuranceCompany {get;set;}
    public Boolean showNewAdjuster {get;set;}
    public Boolean showNewAdjusterAccount {get;set;}
    
    public Contact newCaller {get;set;}
    public Contact newProjectSiteContact {get;set;}
    public Contact newAdjuster {get;set;}
    public Contact newCustomerPerson {get;set;}
    
    public Account newProjectSiteAccount {get;set;}
    public Account newAccount {get;set;}
    public Account newCustomerAccount {get;set;}
    public Account newCustomerBusiness {get;set;}
    public Account newAdjusterAccount {get;set;}
    public Account newInsuranceCompany {get;set;}

    public String contextProjectSiteContactStreet {get;set;}
    public String contextProjectSiteContactCity {get;set;}
    public String contextProjectSiteContactState {get;set;}
    public String contextProjectSiteContactZip {get;set;}
    public string contextProjectSiteContactCounty { get; set; }

    
    List<Job_Account__c> jobAccts = new List<Job_Account__c>();
    List<Job_Contact__c> jobContacts = new List<Job_Contact__c>();
    
    public ATI_Job__c job { get; set;}

    public CreateNewJobInquiry2(ApexPages.StandardController sc){
        this(); //calling defalut constructor
        showNewCaller = false;
        showNewAccount = false;
        showNewProjectSiteContact = false;
        showNewProjectSiteContactAccount = false;
        showNewCustomerPerson = false;
        showNewCustomerBusiness = false;
        showNewInsuranceCompany = false;
        showNewAdjuster = false;
        showNewAdjusterAccount = false;
    }
    
    public CreateNewJobInquiry2() {
         //Comment out as it is not be used anywhere
         //Id id = ApexPages.currentPage().getParameters().get('id');
        
        job = new ATI_Job__c(Stage__c='Qualification');  
        System.debug('Job ...' + job);
    }
        
    public PageReference cancel() {
        return null;
    }
    //assigne contact address info to job address info

    public void assign2ProjectSiteContactInfo() {
        job.Project_Site_Address__c = contextProjectSiteContactStreet;
        job.Project_Site_City__c = contextProjectSiteContactCity;
        job.Project_Site_State__c = contextProjectSiteContactState;
        job.Project_Site_Zipcode__c = contextProjectSiteContactZip;
        job.County__c = contextProjectSiteContactCounty;
    }

    public void showOrHideNewCaller(){
        if(showNewCaller){
            showNewCaller = false;
            newCaller = null;
        }else{
            showNewCaller = true;
            newCaller = new Contact();
        }
    }

    public void showOrHideNewAccount(){
        if(showNewAccount){
            showNewAccount = false;
            newAccount = null;
        }else{
            showNewAccount = true;
            newAccount = new Account();
        }
    }

    public void showOrHideNewProjectSiteContactAccount(){
        if(showNewProjectSiteContactAccount){
            showNewProjectSiteContactAccount = false;
            newProjectSiteAccount = null;
        }else{
            showNewProjectSiteContactAccount = true;
            newProjectSiteAccount = new Account();
        }
    }

    public void showOrHideNewProjectSiteContact() {
        if(showNewProjectSiteContact){
            showNewProjectSiteContact = false;
            newProjectSiteContact = null;
        }else{
            showNewProjectSiteContact = true;
            newProjectSiteContact = new Contact();
        }
    }

    public void showOrHideNewCustomerPerson() {
        if(showNewCustomerPerson){
            showNewCustomerPerson = false;
            newCustomerPerson = null;
        }else{
            showNewCustomerPerson = true;
            newCustomerPerson = new Contact();
        }
    }
    
    public void showOrHideNewCustomerBusiness() {
        if(showNewCustomerBusiness){
            showNewCustomerBusiness = false;
            newCustomerBusiness = null;
        }else{
            showNewCustomerBusiness = true;
            newCustomerBusiness = new Account();
        }
    }
    
    public void showOrHideNewAdjuster() {
        if(showNewAdjuster){
            showNewAdjuster = false;
            newAdjuster = null;
        }else{
            showNewAdjuster = true;
            newAdjuster = new Contact();
            newAdjuster.Contact_Type__c = 'Adjuster';
        }
    }

    public void showOrHideNewAdjusterAccount() {
        if(showNewAdjusterAccount){
            showNewAdjusterAccount = false;
            newAdjusterAccount = null;
        }else{
            showNewAdjusterAccount = true;
            newAdjusterAccount = new Account();
        }
    }

    public void showOrHideNewInsuranceCompany() {
        if(showNewInsuranceCompany){
            showNewInsuranceCompany = false;
            newInsuranceCompany = null;
        }else{
            showNewInsuranceCompany = true;
            newInsuranceCompany = new Account();
        }
    }

    /**
     * Account match duplication check
     * @param  name             [description]
     * @param  account          [description]
     * @param  contactAccountId [description]
     * @param  message          [description]
     * @return                  [description]
     */
    private String matchValidation(String name, Account account, Contact contact, String message) {
        if(message != NO_DUPLICATE_RECORDS) {
            return message;
        }
        if(contact == null) {
            return message;
        }
        if(account != null && contact.AccountId == null){
            System.debug(name + 'account is ....' + account);
            List<CRMfusionDBR101.DB_Api.Matches> matcheAccounts = CRMfusionDBR101.DB_Api.findMatches(getPersonAccount(account));
            if(!matcheAccounts.isEmpty()){
                System.debug('matcheAccounts ...' + matcheAccounts);
                List<String> parameters = new List<String>();
                parameters.add(name);
                if( account.Name != null ){
                    parameters.add(account.Name);
                }else if( account.FirstName != null && account.LastName != null ){
                    parameters.add( account.FirstName + ' ' + account.LastName );
                }
                parameters.add('');
                return String.format(Label.Duplicate_Record_Message, parameters);
                //return 'A duplicate record was found for ' + name + ' section called ' + account.Name;
            }
        }
        return NO_DUPLICATE_RECORDS;
    }

    private String matchValidation(String name, Account account, Id jobAccountId, String message){
        if(message != NO_DUPLICATE_RECORDS){
            return message;
        }

        if(account != null && jobAccountId == null){
            System.debug(name + 'account is ....' + account);
            List<CRMfusionDBR101.DB_Api.Matches> matcheAccounts = CRMfusionDBR101.DB_Api.findMatches(getPersonAccount(account));
            if(!matcheAccounts.isEmpty()){
                System.debug('matcheAccounts ...' + matcheAccounts);
                List<String> parameters = new List<String>();
                parameters.add(name);
                parameters.add(account.Name);
                parameters.add('');
                return String.format(Label.Duplicate_Record_Message, parameters);
                //return 'A duplicate record was found for ' + name + ' section called ' + account.Name;
            }
        }
        return NO_DUPLICATE_RECORDS;

    }

   @testvisible private Account getPersonAccount(Account personAccount){
        String accountString = JSON.serialize( personAccount );
        accountString = accountString.subString( 0, accountString.length() - 1 ) + ',"IsPersonAccount":false}';
        personAccount = (Account)JSON.deserialize( accountString, Account.class );
        return personAccount;
    }
    

    /**
     * Contact match duplication check
     * @param  name         [description]
     * @param  contact      [description]
     * @param  jobContactId [description]
     * @param  message      [description]
     * @return              [description]
     */
    private String matchValidation(String name, Contact contact, Id jobContactId, String message){
        if(message != NO_DUPLICATE_RECORDS) {
            return message;
        }
        if(contact != null && jobContactId == null){
            List<CRMfusionDBR101.DB_Api.Matches> matcheContacts = CRMfusionDBR101.DB_Api.findMatches(contact);
            if(!matcheContacts.isEmpty()){
                System.debug('matcheContacts ...' + matcheContacts);
                List<String> parameters = new List<String>();
                parameters.add(name);
                parameters.add(contact.firstName);
                parameters.add(contact.lastName);
                return String.format(Label.Duplicate_Record_Message, parameters);
                //return 'A duplicate record was found for ' + name + ' section called ' + contact.firstName + ' ' + contact.lastName;
            }
        }
        return NO_DUPLICATE_RECORDS;
    }

    private void afterMatchValidation(Account account, Contact contact){
        if(account != null && account.id == null && contact != null && contact.AccountId == null){
            insert account;
            contact.accountId = account.Id;
            //associateBillingAddress(account.id);
        }
    }

    private void afterMatchValidation(Account account, Id jobAccountId){
        if(account != null && account.id == null && jobAccountId == null){
            insert account;
            //associateBillingAddress(account.id);
        }
    }

   @testvisible private void associateBillingAddress(Id accountId){
        List<Account> businessAccounts = [Select Id, IsPersonAccount, BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode From Account where Id=: accountId  and IsPersonAccount = false limit 1];
        if(!businessAccounts.isEmpty()){
            Billing_Address__c billingAddress = new Billing_Address__c();
            billingAddress.Account__c = businessAccounts[0].id;
            billingAddress.Billing_City__c = businessAccounts[0].BillingCity;
            billingAddress.Billing_Country__c = businessAccounts[0].BillingCountry;
            billingAddress.Billing_State__c = businessAccounts[0].BillingState;
            billingAddress.Billing_Street__c = businessAccounts[0].BillingStreet;
            billingAddress.Billing_Zipcode__c = businessAccounts[0].BillingPostalCode;
            insert billingAddress;
            //billingAddress.Building_Suite__c = businessAccounts[0].id;
        }
    }

    private void afterMatchValidation(Contact contact, Id jobContactId){
        if(contact != null && jobContactId == null){
            System.debug('insert new contact ...' + contact);
            insert contact;
        }
    }
    // added the line from 242 to 306 by Fred.Dai Perficient on 01/11/2016
    public PageReference Save() {
        if(newCaller != null ) newCaller.Id = null;
        if( newProjectSiteContact != null ) newProjectSiteContact.Id = null;
        if( newAdjuster != null ) newAdjuster.Id = null;
        if( newProjectSiteAccount != null ) newProjectSiteAccount.Id = null;
        if( newAccount != null ) newAccount.id = null;
        if( newCustomerPerson != null ) newCustomerPerson.iD = null;
        if( newCustomerBusiness != null ) newCustomerBusiness.iD = null;
        if( newAdjusterAccount != null ) newAdjusterAccount.id = null;
        if( newInsuranceCompany != null ) newInsuranceCompany.id = null;
        if( job != null ) job.id = null;
        jobContacts = new List<Job_Contact__c>();
        jobAccts = new List<Job_Account__c>();
        Savepoint sp = Database.setSavepoint();
        try{
            List<String> messages = new List<String>();
            String msg = '';
            //New Caller Match validation
            String resultMessage = NO_DUPLICATE_RECORDS;
            // for property owner create a person account
            RecordType recType = [SELECT id,name,sobjectType,ispersontype 
                                  FROM recordType 
                                  WHERE ispersontype=true AND sobjectType='account' limit 1];
            System.debug(newCaller);
            if( newCaller != null && newCaller.contact_type__c == 'property owner'){
                 newAccount = new Account(recordtypeid = recType.ID, type = newCaller.contact_type__c, firstname = newCaller.firstname, 
                                          lastname = newCaller.lastname, personemail = newCaller.email, phone = newCaller.phone, 
                                          Phone_Ext__c = newCaller.Phone_Ext__c, BillingStreet = newCaller.MailingStreet,
                                          BillingCity = newCaller.MailingCity, BillingState = newCaller.MailingState, 
                                          BillingPostalCode = newCaller.MailingPostalCode, BillingCountry = newCaller.MailingCountry);              
            }
            if( newProjectSiteContact != null && newProjectSiteContact.contact_type__c == 'property owner'){
                 newProjectSiteAccount = new Account(recordtypeid = recType.ID, type = newProjectSiteContact.contact_type__c, 
                                                     firstname = newProjectSiteContact.firstname, lastname = newProjectSiteContact.lastname, 
                                                     personemail = newProjectSiteContact.email, phone = newProjectSiteContact.phone, 
                                                     Phone_Ext__c = newProjectSiteContact.Phone_Ext__c, 
                                                     BillingStreet = newProjectSiteContact.MailingStreet,
                                                     BillingCity = newProjectSiteContact.MailingCity, 
                                                     BillingState = newProjectSiteContact.MailingState, 
                                                     BillingPostalCode = newProjectSiteContact.MailingPostalCode, 
                                                     BillingCountry = newProjectSiteContact.MailingCountry);                
            }
            System.debug(newCustomerPerson);
            if( newCustomerPerson != null){
                 newCustomerBusiness = new Account(recordtypeid = recType.ID, type = 'Property Owner', firstname = newCustomerPerson.firstname, 
                                          lastname = newCustomerPerson.lastname, personemail = newCustomerPerson.email, phone = newCustomerPerson.phone, 
                                          Phone_Ext__c = newCustomerPerson.Phone_Ext__c, BillingStreet = newCustomerPerson.MailingStreet,
                                          BillingCity = newCustomerPerson.MailingCity, BillingState = newCustomerPerson.MailingState, 
                                          BillingPostalCode = newCustomerPerson.MailingPostalCode, BillingCountry = newCustomerPerson.MailingCountry);              
            }
            
            msg = matchValidation(Label.Caller_Information, newCaller, Job.Contact__c, resultMessage);
            if( msg != resultMessage ){
                messages.add( msg );
            }
            msg = matchValidation(Label.Caller_Information, newAccount, newCaller, resultMessage);
            if( msg != resultMessage ){
                messages.add( msg );
            }
            //New Project Site Contact match validation
            msg = matchValidation(Label.Project_Site_Contact_Information, newProjectSiteContact, Job.Project_Site_Contact_Name__c, resultMessage);
            if( msg != resultMessage ){
                messages.add( msg );
            }
            msg = matchValidation(Label.Project_Site_Contact_Information, newProjectSiteAccount, newProjectSiteContact, resultMessage);
            if( msg != resultMessage ){
                messages.add( msg );
            }
            //New Adjuster Contact match validation
            msg = matchValidation(Label.Insurance_Information, newAdjuster, Job.Insurance_Adjuster_Broker__c, resultMessage);
            if( msg != resultMessage ){
                messages.add( msg );
            }
            msg = matchValidation(Label.Insurance_Information, newAdjusterAccount, newAdjuster, resultMessage);
            if( msg != resultMessage ){
                messages.add( msg );
            }
            //New Customer match validation
            msg = matchValidation(Label.Customer_Information, newCustomerBusiness, newCustomerPerson, resultMessage);
            if( msg != resultMessage ){
                messages.add( msg );
            }
            //New Customer match validation
            msg = matchValidation(Label.Customer_Information, newCustomerBusiness, Job.Owner__c, resultMessage);
            if( msg != resultMessage ){
                messages.add( msg );
            }
            Job_Account__c customerJobAccount;
            //New Insurance Company match validation
            msg = matchValidation(Label.Insurance_Information, newInsuranceCompany, Job.Account__c, resultMessage);
                        if( msg != resultMessage ){
                messages.add( msg );
            }
            if( !messages.isEmpty() ){
                for( String m : messages ){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, m));                
                }
                return null;
            }else{
                if(Job.Contact__c == null){
                    afterMatchValidation(newAccount, newCaller);
                    if( newCaller.Contact_Type__c != 'property owner'){
                        afterMatchValidation(newCaller, Job.Contact__c);
                    }                    
                    
                    System.debug('new caller is ...' + newCaller);
                    if(newCaller != null && newCaller.id !=null){
                        Job.Contact__c = newCaller.id;
                    }
                    if( newCaller.Contact_Type__c == 'property owner'){
                        newAccount = [ SELECT PersonContactId, Id FROM Account WHERE Id =: newAccount.Id ];
                        Job.Contact__c = newAccount.PersonContactId;
                    }
                }
                
                if(Job.Project_Site_Contact_Name__c == null){
                    afterMatchValidation(newProjectSiteAccount, newProjectSiteContact);
                    if( newProjectSiteContact != null && newProjectSiteContact.Contact_Type__c != 'property owner'){
                        afterMatchValidation(newProjectSiteContact, Job.Project_Site_Contact_Name__c);
                    }                    
                    
                    System.debug('new Project Site Contact is ...' + newProjectSiteContact);
                    if(newProjectSiteContact != null && newProjectSiteContact.id != null){
                        Job.Project_Site_Contact_Name__c = newProjectSiteContact.id;
                    }
                    if( newProjectSiteContact != null && newProjectSiteContact.Contact_Type__c == 'property owner'){
                        newProjectSiteAccount = [ SELECT PersonContactId, Id FROM Account WHERE Id =: newProjectSiteAccount.Id ];
                        Job.Project_Site_Contact_Name__c = newProjectSiteAccount.PersonContactId;
                    }
                }
                if(Job.Insurance_Adjuster_Broker__c == null) {
                    afterMatchValidation(newAdjusterAccount, newAdjuster);
                    afterMatchValidation(newAdjuster, Job.Insurance_Adjuster_Broker__c);
                    System.debug('new Adjuster is ...' + newAdjuster);
                    if(newAdjuster != null && newAdjuster.id != null){
                        Job.Insurance_Adjuster_Broker__c = newAdjuster.id;
                    }
                }
                if(job.Owner__c == null){
                    afterMatchValidation(newCustomerBusiness, newCustomerPerson);
                    if(newCustomerPerson != null && newCustomerPerson.id != null){
                        Job.Owner__c = newCustomerPerson.id;
                    }
                    afterMatchValidation(newCustomerBusiness, Job.Owner__c);
                    System.debug('new newCustomer is ...' + newCustomerBusiness);
                    if(newCustomerBusiness != null && newCustomerBusiness.id != null){
                        Job.Owner__c = newCustomerBusiness.id;
                    }

                }
                afterMatchValidation(newInsuranceCompany, Job.Account__c);
                System.debug('new Insurance Company is ...' + newInsuranceCompany);
                if(newInsuranceCompany != null && newInsuranceCompany.id != null){
                    Job.Account__c = newInsuranceCompany.id;
                }
            }

            if(Job.Contact__c == null && newCaller == null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please create new Caller or select one caller.'));
                return null;
            }
            Id acctid = Job.Account__c;
            Job_Contact__c c1; 
            Job_Account__c a1;
            Contact con = [select id, accountid, account.type from Contact where id =:Job.Contact__c limit 1];
            System.debug( con );
            c1 = new Job_Contact__c(contact__c = con.id);
            a1 = new Job_Account__c(account__c = con.accountid);
            System.debug( job );
            if(job.Primary_Account__c == 'Caller Account'){
                job.Account__c = con.accountid;
            }
            system.debug(sameAscaller);
            Job_Contact__c c2; 
            Job_Account__c a2; 
            Contact con2 = null;
            if(SameAsCaller != true && job.Project_Site_Contact_Name__c != null){
                con2 = [select id, accountid, account.type from Contact where id =:job.Project_Site_Contact_Name__c limit 1];           
                System.debug('THIS IS THE SAME AS CALLER:::::::::::::::::::::::::::::' + sameascaller);
                job.Project_Site_Contact_Account__c = con2.accountid;
                c2 = new Job_Contact__c(contact__c = con2.id);
                a2 = new Job_Account__c(account__c = con2.accountid);
                System.debug('THIS IS THE 2ND CONTACT:::::::::::::::::::::::::::::' + c2.contact__c);
                System.debug('THIS IS THE Contact 2:::::::::::::::::::::::::::::' + con2.id);
                if(job.Primary_Account__c == 'Project Site Contact'){
                    job.contact__c = job.Project_Site_Contact_Name__c;
                    job.Account__c = con2.accountid;
                }
            }
            else {
                job.Project_Site_Contact_Name__c = con.id;
                job.Project_Site_Contact_Account__c = con.accountid;
                job.Account__c = con.accountid;
            }
            system.debug( '495' + job );
            Job_Account__c account4; 
            Job_Contact__c contact4;
            Account account;
            
            if(SameAsCaller != true && job.Owner__c != null)
            {
                system.debug( '502' + job );
                 account = [select id, PersonContactId from Account where id =:job.Owner__c limit 1];
                 account4 = new Job_Account__c(account__c = account.id);
                 contact4 = new Job_Contact__c(contact__c = account.PersonContactId);
                if(job.Primary_Account__c == 'Customer')
                {
                    job.contact__c = account.PersonContactId;
                    job.Account__c = job.Owner__c;
                 }
            }
            system.debug( '511' + job );
            if(job.owner__c == con.accountId)
            {                
                system.debug( SameAsCaller + '-' + job.owner__c );
                //job.owner__c = con.accountid;
                system.debug( con.accountId);
            }
            else {
                system.debug('521');
                job.owner__c = null;
            }
            
            system.debug( '522' + job );
            Job_Contact__c c3; 
            Job_Account__c a3; 
            Contact con3 = null;
            if(job.Insurance_Adjuster_Broker__c != null){
                system.debug( '527' + job );
                con3 = [select id, accountid, account.type from Contact where id =:job.Insurance_Adjuster_Broker__c limit 1];
                c3 = new Job_Contact__c(contact__c = con3.id);
                a3 = new Job_Account__c(account__c = con3.accountid);
                if(job.Primary_Account__c == 'Insurance'){
                    job.contact__c = job.Insurance_Adjuster_Broker__c;
                    job.Account__c = con3.accountid;
                }
            }
            else{
                system.debug( '537' + job );
                if(acctid != null){
                    a3 = new Job_Account__c(account__c = acctid);
                    if(job.Primary_Account__c == 'Insurance'){
                        job.Account__c = acctid;
                        job.contact__c = null;}
                }
            }
        job.Taken_by__c = UserInfo.getUserId();
       // job.created_by__c = UserInfo.getUserId();
       // if(job.Division__c.equalsIgnoreCase('Emergency Svces')){
        //job.CloseDate=date.today();
       //} else {
       // job.CloseDate=date.today().adddays(5);
       //}
        job.CloseDate__c=date.today().adddays(5);
        job.name=job.Job_Name__c; 
        insert job;
        //add by fred for new relationship from custom to job_account and job_contact
        if(customerJobAccount != null){
            customerJobAccount.ATI_Job__c = job.id;
             jobAccts.add(customerJobAccount);
        }
      

       //inserting the Job Account and Job Contact related list
        
        c1.ATI_Job__c = job.id;
        a1.ATI_Job__c = job.id;
        jobContacts.add(c1);
        jobAccts.add(a1);
            
        if(con2 != null && (con2.id != con.id)){
            System.debug('THIS IS THE INSIDE THE LOOP:::::::::::::::::::::::::::::' + c2.id);
            c2.ATI_Job__c = job.id;
            jobContacts.add(c2);
            if(con2.AccountId != con.AccountId){
                a2.ATI_Job__c = job.id; 
                jobAccts.add(a2);
            }
        }
        
        if(account4 != null && (account4.Account__r.id != con.AccountId || (con2 != null && account4.Account__r.id != con2.AccountId)))
       {
           system.debug('THIS IS ACCOUNT 4:::::::::::::::::::::::::::::' + account4.Account__r.id);
            account4.ATI_Job__c = job.id; 
            jobAccts.add(account4);
       }
            
        if(a3 != null){
            if(acctid != null && (acctid != con.AccountId || (con2 != null && acctid != con2.AccountId || (account4 != null && acctid != account4.Account__r.id)))){
                system.debug('THIS IS ACCOUNT 3:::::::::::::::::::::::::::::' + a3.Account__r.id);
                a3.ATI_Job__c = job.id; 
                jobAccts.add(a3);
            }
            else{
                if(con3 != null && (con3.id != con.id || (con2 != null && con3.id != con2.id))){
                c3.ATI_Job__c = job.id;
                a3.ATI_Job__c = job.id;
                jobContacts.add(c3); 
                jobAccts.add(a3);
                }
            }
        }   
        insert jobContacts;
        insert jobAccts;
        System.debug('THIS IS THE 2ND CONTACT:::::::::::::::::::::::::::::' + jobContacts);
        //System.debug('THIS IS THE 3rd CONTACT:::::::::::::::::::::::::::::' + c2.id);
        //PageReference returnPage = new PageReference('/' + job.id + '/e?retURL=%2F'+job.id); 
        //PageReference returnPage = new PageReference('/apex/EditJob2?id='+job.id);
        PageReference returnPage = new PageReference('/'+job.id);
        returnPage.setRedirect(true);
        return returnPage;
        
        } catch (Exception e) {
            Database.rollback( sp );
            system.debug(e);
            ApexPages.addMessages(e);
            return null;
        }
    }

}