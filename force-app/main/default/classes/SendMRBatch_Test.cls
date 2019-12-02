/**
 * @author           Gangadhar R.
 * @version          1.0 
 * @date             14/07/2017
 * @Status           Developed
 * @description      This class is used to unit test the SendMRBatch class.
 *                   
*/
@isTest 
public class SendMRBatch_Test 
{
    static testMethod void Batch_Test() 
    {
         /*User usr = PRLDE_TestDataUtility.FetchUser(UserInfo.getUserId());
      
        System.runAs(){
        TriggerStatus__c testSetting = PRLDE_TestDataUtility.InsertTrgSetting(false);
        }*/
        
      
      RecordType AccRecType = PRLDE_TestDataUtility.FetchRecordType('Account','Business Account');
      Account testAcc = PRLDE_TestDataUtility.InsertAccount(AccRecType,'AccRecType','testAcc','+911234567890','testStreet','testCity','TN','600001','testCountry');
      Contact testCon = PRLDE_TestDataUtility.InsertContact('FirstName','LastName',testAcc.Id,'12345');
      
      Office__c testOff = PRLDE_TestDataUtility.InsertOffice('testName','testAddress','testRegion','testState');
      
     //RecordType jobRecType = PRLDE_TestDataUtility.FetchRecordType('ATI_Job__c','Job (Approved)');
     //ATI_Job__c testJob = PRLDE_TestDataUtility.InsertJob(jobRecType,'testJob',testAcc,testOff.Id,'testJobName','testJobNumber',testCon.Id);
      
     Material_Requisition__c testMR = PRLDE_TestDataUtility.InsertMR(null,'In Progress',null,'MR-testJobName-01');
     Material_Requisition__c testMR1 = PRLDE_TestDataUtility.InsertMR(null,'In Progress',null,'MR-testJobName-02');
     Material_Requisition__c testMR2 = PRLDE_TestDataUtility.InsertMR(null,'In Progress',null,'MR-testJobName-03');
     Material_Requisition__c testMR3 = PRLDE_TestDataUtility.InsertMR(null,'In Progress',null,'MR-testJobName-04');
     Material_Requisition__c testMR4 = PRLDE_TestDataUtility.InsertMR(null,'In Progress',null,'MR-testJobName-05');
     Material_Requisition__c testMR5 = PRLDE_TestDataUtility.InsertMR(null,'In Progress',null,'MR-testJobName-06');
     Material_Requisition__c testMR6 = PRLDE_TestDataUtility.InsertMR(null,'Completed',null,'MR-testJobName-07');
     Material_Requisition__c testMR7 = PRLDE_TestDataUtility.InsertMR(null,'Completed',null,'MR-testJobName-08');
     Material_Requisition__c testMR8 = PRLDE_TestDataUtility.InsertMR(null,'Completed',null,'MR-testJobName-09');
     Material_Requisition__c testMR9 = PRLDE_TestDataUtility.InsertMR(null,'Completed',null,'MR-testJobName-10');
     Material_Requisition__c testMR10 = PRLDE_TestDataUtility.InsertMR(null,'Completed',null,'MR-testJobName-11');
        
        Test.startTest();

        SendMRBatch obj = new SendMRBatch();
        DataBase.executeBatch(obj,100); 
        
        Test.stopTest();
        
    }
}