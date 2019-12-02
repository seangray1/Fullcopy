/*
* Test class for the CustomerSurveyTrigger  class- s.jeyarammoorthy - 6/28/2016
*/
@isTest
private class CustomerSurveyFieldUpdate_Test {
   
    //test with office and job assigned
    public static TestMethod void runTestOnOffice()
    {
        TestDataUtil.createCustomSettings_TriggerStatus();
        Office__c off = addOffice();
        //Creating ATI_Job__c
        List<ATI_Job__c> Job = TestDataUtil.createJob( 1, true, new Map<String,String>{ 'Office2__c' => off.Id });
        
        //Creating Customer Surverys
        List<Customer_Survey__c> surveys = new list<Customer_Survey__c>();
        for(Integer i=0; i< 50 ; i++){
           	Customer_Survey__c survey = runTestOnCustomerSurvey();
        	survey.ATI_Job__c = job[0].id; 
            surveys.add(survey);
        }
        Test.StartTest();
            try{
                List<Database.SaveResult> results = Database.insert(surveys, false);
                for(Database.SaveResult result : results){
//                   system.assert(result.isSuccess()); 
				}
            }catch (Exception e){
                system.debug(LoggingLevel.DEBUG, 'error while inserting trigger status'+ e.getStackTraceString());
            }
       	Test.StopTest();
    }
    
    //test method without office
    public static TestMethod void runTestOnJob()
    {
        TestDataUtil.createCustomSettings_TriggerStatus();
        //Creating ATI_Job__c
        List<ATI_Job__c> Job = TestDataUtil.createJob( 1, true, null);
        
        //Creating Customer Surverys
        List<Customer_Survey__c> surveys = new list<Customer_Survey__c>();
        for(Integer i=0; i< 50 ; i++){
           	Customer_Survey__c survey = runTestOnCustomerSurvey();
        	survey.ATI_Job__c = job[0].id; 
            surveys.add(survey);
        }
        Test.StartTest();
            try{
                List<Database.SaveResult> results = Database.insert(surveys, false);
                for(Database.SaveResult result : results){
  //                 system.assert(result.isSuccess()); 
				}
            }catch (Exception e){
                system.debug(LoggingLevel.DEBUG, 'error while inserting trigger status'+ e.getStackTraceString());
            }
       	Test.StopTest();
    }

    public static Customer_Survey__c runTestOnCustomerSurvey()
    {
        Customer_Survey__c survey = new Customer_Survey__c();
        survey.name = 'test';
        return survey;
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
        off.Survey_Recipient__c = users[randomWithLimit(userCount)].Id;
        off.Office_Manager__c = users[randomWithLimit(userCount)].Id;
        off.Customer_Service__c = users[randomWithLimit(userCount)].Id;
    }
    
    public static Integer randomWithLimit(Integer upperLimit)
    {
        Integer rand = Math.round(Math.random()*1000);
        return Math.mod(rand, upperLimit);
    } 

}