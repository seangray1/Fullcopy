@isTest(SeeAllData=true)
//Versoin 1.0
//Created by - Prabaharan Periasamy
//Date - 06/30/2016
//Tests email update of job trigger functionality , as upon update of one or bulk jobs objecct.
//
public class EmailUpdateOnJob_Test {
    
    
   /* public static TestMethod void testJobonUpdateActivity(){
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
        //contact acct = [select id from contact where id=: contact.id];
        
        Job__c job = new Job__c();
        job.Account__c = acc.Id;
        job.Job_Number__c = '000-00-00033';
        job.Name = '000-00-00033';  
        job.Job_Name__c = '000-00-00046';  
        //job.Job_Number__c = '00-00-000001';
        job.Stage__c = 'Qualification';
        job.Status__c = 'Opportunity';
        job.Office__c = 'Corporate';
        job.Lead_Source__c = 'AES';
        job.County__c = 'Orange';
        Job.City_of_LA__c = 'No';
        job.Date_Time_Taken__c = system.now().date();
        job.Project_Manager__c = '00570000002rgiK';
        job.Project_Site_Contact_Name__c = contact.id;
        
        insert(job);
        job.Add_Correct_Email__c = 'test123@gmail.com';
        try{
        	Test.startTest();
            Database.SaveResult result = Database.update(job, false);  
        	Test.stopTest();
            System.assert(result.isSuccess());
        } catch(Exception dml){
             system.debug(Logginglevel.WARN, 'exception occured while updating job data' + dml.getStackTraceString());
        }
    }
    
    
     public static TestMethod void testBulkJobonUpdateActivity(){
         List<Job__c> jobLst = new List<Job__c>();
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
        
        
        Job__c job = new Job__c();
        job.Account__c = acc.Id;
        job.Job_Number__c = '000-00-00033';
        job.Name = '000-00-00033';  
        job.Project_Site_Name__c = 'project_site_name';
        job.Job_Name__c = '000-00-00046'; 
        job.Stage__c = 'Qualification';
        job.Status__c = 'Opportunity';
        job.Office__c = 'Corporate';
        job.Lead_Source__c = 'AES';
        job.County__c = 'Orange';
        Job.City_of_LA__c = 'No';
        job.Date_Time_Taken__c = system.now().date();
        job.Project_Manager__c = '00570000002rgiK';
        job.Project_Site_Contact_Name__c = contact.id;
         
         
        Account acc1 = new Account(name= 'prft_offshore_test');
        acc1.BillingStreet = 'Street 12';
        acc1.BillingCity = 'San Francisco';
        acc1.BillingCountry = 'USA';
        acc1.BillingPostalCode = '1234';
        acc1.BillingState = 'CA';
        insert acc1;
         
        Contact contact1 = new Contact();
        contact1.AccountId = acc1.Id;
        contact1.firstname = 'Test';
        contact1.LastName = 'test';
        contact1.Email = 'test@gamil.com';
        Insert contact1;
         
         
         
        Job__c job1 = new Job__c();
        job1.Account__c = acc1.Id;
        job1.Job_Number__c = '000-00-00033';
        job1.Name = '000-00-00033';  
        job1.Job_Name__c = '000-00-00046'; 
        job1.Stage__c = 'Qualification';
        job1.Status__c = 'Opportunity';
        job1.Office__c = 'Corporate';
        job1.Lead_Source__c = 'AES';
        job1.County__c = 'Orange';
        Job1.City_of_LA__c = 'No';
        job1.Date_Time_Taken__c = system.now().date();
        job1.Project_Manager__c = '00570000002rgiK';
        job1.Project_Site_Contact_Name__c = contact1.id;
        jobLst.add(job);
		jobLst.add(job1);         
        insert jobLst;
        
        
        job.Add_Correct_Email__c = 'test123@gmail.com';
       // job.Project_Site_Contact_Name__c =  contact1.id;
        job1.Add_Correct_Email__c ='test_prft_offshore@gmail.com';
		//job1.Project_Site_Contact_Name__c =  contact.id;
         
        jobLst.clear();
        jobLst.add(job);
        jobLst.add(job1);
            
         try{
             Test.startTest();
             List<Database.SaveResult> results = Database.update(jobLst, false);
             Test.stopTest();
             for(Database.SaveResult result : results){
                 system.assert(result.isSuccess());
             }
         }catch(Exception e){
             system.debug(Logginglevel.WARN, 'exception occured while updating list of job datas' + e.getStackTraceString());
         }
        
     }
        
        public static Opportunity runTestOnOpportunity (Office__c off)
    {
        // Add Account
        Account acc = AddAccount();
        
        // Add Opportunity
        
        User user = [select id,name from user where id =:System.label.TestClassRunAsUserId];
        Opportunity opp = AddOpportunity (acc, off, user);
        
        opp.Division__c = 'Construction';
        List<Opportunity> opps = new List<Opportunity>();
        opps.add(opp);
        
        // Run it by the Target method
        OpportunityAssignment.OpportunityAssignment2(opps);
        System.assertEquals(null, opp.Operations_Manager__c);

        return opp;
    }

    
    public static Opportunity AddOpportunity (Account acc, Office__c off, User user)
    {
        Opportunity opp = new Opportunity(); 
        opp.StageName = 'Won';
        opp.AccountId = acc.Id;
        opp.Job_Number__c = '000-00-00546';  
        opp.Amount = 0.1;
        opp.CloseDate = date.today();
        opp.Job_Name__c = '000-00-00000';  
        opp.Project_Manager__c = user.id;
        opp.Office2__c = off.Id;
        opp.Division__c = '';
        
        return opp;
    }
    
    public static Account AddAccount ()
    {
        //Create test Account 
        Account testAcctObj = new Account(); 
        testAcctObj.Name = 'Test Account'; 
        testAcctObj.BillingStreet = 'abc street';
        testAcctObj.billingState = 'CA';
        testAcctObj.billingCountry = 'USA';
        testAcctObj.billingPostalCode = '213';
        testAcctObj.billingCity = 'SFO';
        insert testAcctObj; 
        
        //Create test Contact 
        Contact testContactObj = new Contact(); 
        testContactObj.AccountId = testAcctObj.Id; 
        testContactObj.LastName = 'Test'; 
        insert testContactObj; 
        
        return testAcctObj;
    }
    
        public static Map<string, office__c> addOffices()
    {
        // add each office here
        Map<string, office__c> offs = new Map<string, office__c>();
        
        // need to insert Branch_Manager__c user
        // need to insert Contents_Operations_Manager__c user
        // need to insert Emergency_Services_Operations_Manager__c user
        // need to insert Environmental_Branch_Manager__c users
        // Need to insert ES_and_Contents_Operations_Manager__c user
        // Need to insert Structure_Contents_Branch_Manager__c user
        
        List<User> users = [SELECT ID, Name FROM User Where IsActive = true];
        
        List<string> offNames = new List<string>();
        offNames.add('Corporate');
        offNames.add('San Diego');
        offNames.add('San Francisco');
        offNames.add('San Jose');
        offNames.add('Other');
        
        for (string offName : offNames)
        {
            Office__c off = new Office__c();
            off.Name = offName;
            offs.put(offName, off);
        }
        
        insert offs.values();
        
        return offs;
    }*/

}