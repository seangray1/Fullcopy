/*
* Test class for the BudgetTrigger  class j
*/
@isTest
private class BudgetFieldUpdate_Test {
   

    //test with office and opportinity assigned
    public static TestMethod void runTestOnOffice()
    {
         TestDataUtil.createCustomSettings_TriggerStatus();
         Office__c off = addOffice();
        //Creating ATI_Job__c
        List<ATI_Job__c> jobs = TestDataUtil.createJob( 1, true, new Map<String,String>{ 'Office2__c' => off.Id });
        
        //Creating Customer Surverys
        List<Budget__c> budget = new list<Budget__c>();
        // for(Integer i=0; i< 50 ; i++){
        //     Budget__c b = runTestOnBudget();
        //     b.ATI_Job__c = jobs[0].id; 
        //     budget.add(b);
        // }
        
//         Test.StartTest();
//             try{
//                 List<Database.SaveResult> results = Database.insert(budget, false);
//                 for(Database.SaveResult result : results){
// //                   system.assert(result.isSuccess()); 
//                 }
//                 string comments = 'test';
//         BudgetFieldUpdate.rejectBudget(budget[0].id, comments);
//             }catch (Exception e){
//                 system.debug(LoggingLevel.DEBUG, 'error while inserting trigger status'+ e.getStackTraceString());
//             }
//         Test.StopTest();
//     }
    }
    //test method without office
    public static TestMethod void runTestOnATIJob()
    {   
        list<ATI_job__c> Jobs;
        Id approvedId;
        
        system.runAs(new User(Id=Userinfo.getUserId())){
            
            Map <String, Schema.RecordTypeInfo> jobRecordTypeMap = Schema.SObjectType.ATI_job__c.RecordTypeInfosByName;
            Id notApprovedId = Schema.SObjectType.ATI_job__c.RecordTypeInfosByName.get('New Job (Not Approved)').RecordTypeId;
            approvedId = Schema.SObjectType.ATI_job__c.RecordTypeInfosByName.get('Job (Approved)').RecordTypeId;
    
            TestDataUtil.createCustomSettings_TriggerStatus();
            //create Account 
            list<Account> lstAccounts = TestDataUtil.createAccounts(2, false, new map<String,Object>());
            lstAccounts[0].type ='Property Owner';             
            insert lstAccounts;
            
            lstAccounts[0].Status__c = 'Approved';
            update lstAccounts;
            
            list<contact> lstContact = TestDataUtil.createContacts(2, false, new map<String,Object>(), lstAccounts[0].Id);
            insert lstContact;
            office__c o = new office__c(Name = 'HQ');
            insert o;
            Jobs = TestDataUtil.createJob(3, false, new map<String,Object>(), lstAccounts[0].Id);
             List<user> users = TestDataUtil.createUsersNew(2, true);
            Jobs[0].contact__c = lstContact[0].id;
            Jobs[0].Project_Site_Contact_Name__c = lstContact[1].id;
            Jobs[0].Insurance_Adjuster_Broker__c = lstContact[0].id;
            Jobs[0].Primary_Account__c = 'Caller Account';
            Jobs[0].Project_Site_Address__c = '7550 st. patrick way';
            Jobs[0].Project_Site_Address_2__c = '';
            Jobs[0].Project_Site_City__c = 'Dublin';
            Jobs[0].Project_Site_State__c = 'CA';
            Jobs[0].Project_Site_Zipcode__c = '94568';
            Jobs[0].Project_Site_Contact_Account__c = lstAccounts[0].id;
            Jobs[0].Project_Site_Record_Id__c = '12345';
            Jobs[0].RecordTypeId = notApprovedId;
            Jobs[0].Job_Name__c ='test';
            jobs[0].office2__c = o.id;
            
    		Jobs[0].Last_Successful_Timberline_Update__c = system.today();
            
            Jobs[1].contact__c = lstContact[0].id;
            Jobs[1].Project_Site_Contact_Name__c = lstContact[1].id;
            Jobs[1].Insurance_Adjuster_Broker__c = lstContact[0].id;
            Jobs[1].Primary_Account__c = 'Insurance';
            Jobs[1].Project_Site_Address__c = '39802 cedar blve';
            Jobs[1].Project_Site_Address_2__c = '';
            Jobs[1].Project_Site_City__c = 'Newark';
            Jobs[1].Project_Site_State__c = 'CA';
            Jobs[1].Project_Site_Zipcode__c = '94560';
            Jobs[1].Project_Site_Contact_Account__c = lstAccounts[0].id;
            Jobs[1].RecordTypeId = approvedId;
            Jobs[1].Job_Name__c ='test1';
            Jobs[1].Last_Successful_Timberline_Update__c = system.today();
            
            Jobs[2].contact__c = lstContact[0].id;
            Jobs[2].Project_Site_Contact_Name__c = lstContact[1].id;
            Jobs[2].Insurance_Adjuster_Broker__c =null;
            Jobs[2].Primary_Account__c = 'Insurance';
            Jobs[2].Project_Site_Address__c = ''; 
            Jobs[2].Project_Site_Address_2__c = '';
            Jobs[2].Project_Site_City__c = '';
            Jobs[2].Project_Site_State__c = '';
            Jobs[2].Project_Site_Zipcode__c = '';
            Jobs[2].Project_Site_Contact_Account__c = lstAccounts[0].id;
            Jobs[2].Job_Name__c ='test2';
            Jobs[2].Last_Successful_Timberline_Update__c = system.today();
            insert Jobs;   
            Forecast__c forecast = new Forecast__c(Revenue_Amount__c = 100, Invoice_date__c = system.today(), Ati_job__c = jobs[0].id);
        	insert forecast;
            Jobs[0].RecordTypeId = approvedId;
            Jobs[0].work_authorization__c = true;
          //  Jobs[0].stage__c = 'Qualified';
            jobs[0].budget_exists__c = true;
            jobs[0].amount__c = 110;
            Jobs[0].stage__c= 'Won';
            jobs[0].project_manager__c = users[0].id;
        jobs[0].project_manager_new__c = users[1].id;
            update Jobs;
        }


    //     TestDataUtil.createCustomSettings_TriggerStatus();
    //     Map <String, Schema.RecordTypeInfo> jobRecordTypeMap = Schema.SObjectType.ATI_job__c.RecordTypeInfosByName;
    //         Id notApprovedId = Schema.SObjectType.ATI_job__c.RecordTypeInfosByName.get('New Job (Not Approved)').RecordTypeId;
    //         Id approvedId = Schema.SObjectType.ATI_job__c.RecordTypeInfosByName.get('Job (Approved)').RecordTypeId;
    //     //Creating ATI_Job__c
    //     List<ATI_Job__c> jobs = TestDataUtil.createJob( 1, true, null);
    //     system.debug('Jobs' + jobs);
    //     List<user> users = TestDataUtil.createUsersNew(2, true);
    //     Forecast__c forecast = new Forecast__c(Revenue_Amount__c = 100, Invoice_date__c = system.today(), Ati_job__c = jobs[0].id);
    //     insert forecast;
    //     Jobs[0].RecordTypeId = approvedId;
    //     Jobs[0].work_authorization__c = true;
    //    // Jobs[0].stage__c = 'Qualified';
    //     jobs[0].budget_exists__c = true;
    //     jobs[0].amount__c = 110;
    //     Jobs[0].stage__c= 'Won';
    //     jobs[0].project_manager__c = users[0].id;
    //     jobs[0].project_manager_new__c = users[1].id;
    //     update jobs;
        //Creating Customer Surverys
        List<Budget__c> budget = new list<Budget__c>();
        //for(Integer i=0; i< 5 ; i++){
            Budget__c b = runTestOnBudget();
            b.name = 'test1';
            b.ATI_Job__c = jobs[0].id; 
            b.GP_Goal__c = '22';
            budget.add(b);
       // }
        Test.StartTest();
            try{
                List<Database.SaveResult> results = Database.insert(budget, false);
                budget[0].budget_status__c = 'approved';
                update budget;
                BudgetFieldUpdate.rejectbudget(budget[0].id, 'Test');
                for(Database.SaveResult result : results){
  //                 system.assert(result.isSuccess()); 
                }
            }catch (Exception e){
                system.debug(LoggingLevel.DEBUG, 'error while inserting trigger status'+ e.getStackTraceString());
            }
        Test.StopTest();
    }

    public static Budget__c runTestOnBudget()
    {
        Budget__c b = new Budget__c();
        //b.name = 'test';
        return b;
    } 

    public static Office__c addOffice()
    {
        List<User> users = [SELECT ID, Name FROM User Where IsActive = true];
        Office__c off = new Office__c();
        off.Name = 'test';
        randomlySetOfficeUsers(off, users);
        insert off;
        return off;
    }
    
   public static void randomlySetOfficeUsers(Office__c off, List<User> users)
    {
        if (users == null || users.size() <= 0)
        {
            return;
        }
        integer userCount = users.size();
        off.Branch_Manager__c = users[randomWithLimit(userCount)].Id;
        off.Regional_Manager__c = users[randomWithLimit(userCount)].Id;
        off.EVP_1__c = users[randomWithLimit(userCount)].Id;
        off.EVP_2__c = users[randomWithLimit(userCount)].Id;
        off.Office_Manager__c = users[randomWithLimit(userCount)].Id;
    }
    
    public static Integer randomWithLimit(Integer upperLimit)
    {
        Integer rand = Math.round(Math.random()*1000);
        return Math.mod(rand, upperLimit);
    } 

}