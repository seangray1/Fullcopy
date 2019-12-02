/**
 * @author           kanitha Priya P
 * @version          1.0
 * @date             26-07-2017
 * @status           Developed
 * @Description      The purpose of this test class is to test all the possible scenarios for the Apex class MRController.
 **/
@isTest
public class PRLDE_TestMRSummaryController {

    public static testmethod void Test_MRItemListLessThan5() {
        // Fetches the current Logged in user Id
        User usr = PRLDE_TestDataUtility.FetchUser(UserInfo.getUserId());
        
        // Inserts the Trigger setting TriggerStatus__c to insert Opportunity
        System.runAs(usr){
            TriggerStatus__c testSetting = PRLDE_TestDataUtility.InsertTrgSetting(false);
        }
        
        // Fetches Account Record Type
        RecordType AccRecType = PRLDE_TestDataUtility.FetchRecordType('Account', 'Business Account');
        // Inserts Account Record
        Account testAcc = PRLDE_TestDataUtility.InsertAccount(AccRecType, 'AccRecType', 'testAcc', '+911234567890', 'testStreet', 'testCity', 'TN', '600001', 'testCountry');
        // Inserts testCon Record
        Contact testCon = PRLDE_TestDataUtility.InsertContact('FirstName', 'LastName', testAcc.Id, '12345');
        // Inserts Office Record
        Office__c testOff = PRLDE_TestDataUtility.InsertOffice('testName', 'testAddress', 'testRegion', 'testState');
        // Fetches Job Record Type
        RecordType JobRecType = PRLDE_TestDataUtility.FetchRecordType('ATI_Job__c', 'Job (Approved)');
        // Inserts Job Record
        ATI_Job__c testJob = PRLDE_TestDataUtility.InsertJob(JobRecType, 'testJob', testAcc, testOff.Id, 'testJobName', 'testJobNumber', testCon.Id,'testDivision');
        // Inserts MR Record
        Material_Requisition__c testMR = PRLDE_TestDataUtility.InsertMR(testJob.Id, 'In Progress', null, 'MR-testJobName-01');
           
        Material_Requisition_line_item__c item1 = PRLDE_TestDataUtility.InsertMateriallineitem('testMaterial - TOM','testMaterial - TOM',true,2,1,10,testMR.Id);
        Material_Requisition_line_item__c item2 = PRLDE_TestDataUtility.InsertMateriallineitem('testMaterial1 - TIM','testMaterial1 - TIM',false,1,0,10,testMR.Id);
        Material_Requisition_line_item__c item3 = PRLDE_TestDataUtility.InsertMateriallineitem('testMaterial2 - TKM','testMaterial2 - TKM',true,2,0,10,testMR.Id);
        
        
        Test.setCurrentPageReference(new PageReference('Page.MR_Summary_UI'));
        System.currentPageReference().getParameters().put('MRId', testMR.Id);
        
        MRSummaryController LstCtrl = new MRSummaryController();
        system.assertEquals(LstCtrl.MRId,testMR.Id);
        
        LstCtrl.getDetailsByMRFormID();
       // system.assertEquals(LstCtrl.MRLineItem.size(),3);
        
        LstCtrl.Back();
        LstCtrl.Edit();
        LstCtrl.UpdateStatus();
        system.assertEquals(LstCtrl.Status,'Completed');
        
    }
    public static testmethod void Test_MRWithOneItem() {
        // Fetches the current Logged in user Id
        User usr = PRLDE_TestDataUtility.FetchUser(UserInfo.getUserId());
        
        // Inserts the Trigger setting TriggerStatus__c to insert Opportunity
        System.runAs(usr){
            TriggerStatus__c testSetting = PRLDE_TestDataUtility.InsertTrgSetting(false);
        }
        
        // Fetches Account Record Type
        RecordType AccRecType = PRLDE_TestDataUtility.FetchRecordType('Account', 'Business Account');
        // Inserts Account Record
        Account testAcc = PRLDE_TestDataUtility.InsertAccount(AccRecType, 'AccRecType', 'testAcc', '+911234567890', 'testStreet', 'testCity', 'TN', '600001', 'testCountry');
        // Inserts testCon Record
        Contact testCon = PRLDE_TestDataUtility.InsertContact('FirstName', 'LastName', testAcc.Id, '12345');
        // Inserts Office Record
        Office__c testOff = PRLDE_TestDataUtility.InsertOffice('testName', 'testAddress', 'testRegion', 'testState');
        // Fetches Job Record Type
        RecordType JobRecType = PRLDE_TestDataUtility.FetchRecordType('ATI_Job__c', 'Job (Approved)');
        // Inserts Job Record
        ATI_Job__c testJob = PRLDE_TestDataUtility.InsertJob(JobRecType, 'testJob', testAcc, testOff.Id, 'testJobName', 'testJobNumber', testCon.Id,'testDivision');
        // Inserts MR Record
        Material_Requisition__c testMR = PRLDE_TestDataUtility.InsertMR(testJob.Id, 'In Progress', null, 'MR-testJobName-01');
           
        Material_Requisition_line_item__c item1 = PRLDE_TestDataUtility.InsertMateriallineitem('testMaterial - TOM','testMaterial - TOM',true,2,1,10,testMR.Id);
                
        Test.setCurrentPageReference(new PageReference('Page.MR_Summary_UI'));
        System.currentPageReference().getParameters().put('MRId', testMR.Id);
        
        MRSummaryController LstCtrl = new MRSummaryController();
        system.assertEquals(LstCtrl.MRId,testMR.Id);
        
        LstCtrl.getDetailsByMRFormID();
      //  system.assertEquals(LstCtrl.MRLineItem.size(),1);
        
        LstCtrl.Back();
        LstCtrl.Edit();
        LstCtrl.UpdateStatus();
        system.assertEquals(LstCtrl.Status,'Completed');
        
    }
    
    public static testmethod void Test_MRWithTWOItems() {
        // Fetches the current Logged in user Id
        User usr = PRLDE_TestDataUtility.FetchUser(UserInfo.getUserId());
        
        // Inserts the Trigger setting TriggerStatus__c to insert Opportunity
        System.runAs(usr){
            TriggerStatus__c testSetting = PRLDE_TestDataUtility.InsertTrgSetting(false);
        }
        
        // Fetches Account Record Type
        RecordType AccRecType = PRLDE_TestDataUtility.FetchRecordType('Account', 'Business Account');
        // Inserts Account Record
        Account testAcc = PRLDE_TestDataUtility.InsertAccount(AccRecType, 'AccRecType', 'testAcc', '+911234567890', 'testStreet', 'testCity', 'TN', '600001', 'testCountry');
        // Inserts testCon Record
        Contact testCon = PRLDE_TestDataUtility.InsertContact('FirstName', 'LastName', testAcc.Id, '12345');
        // Inserts Office Record
        Office__c testOff = PRLDE_TestDataUtility.InsertOffice('testName', 'testAddress', 'testRegion', 'testState');
        // Fetches Job Record Type
        RecordType JobRecType = PRLDE_TestDataUtility.FetchRecordType('ATI_Job__c', 'Job (Approved)');
        // Inserts Job Record
        ATI_Job__c testJob = PRLDE_TestDataUtility.InsertJob(JobRecType, 'testJob', testAcc, testOff.Id, 'testJobName', 'testJobNumber', testCon.Id,'testDivision');
        // Inserts MR Record
        Material_Requisition__c testMR = PRLDE_TestDataUtility.InsertMR(testJob.Id, 'In Progress', null, 'MR-testJobName-01');
           
        Material_Requisition_line_item__c item1 = PRLDE_TestDataUtility.InsertMateriallineitem('testMaterial - TOM','testMaterial - TOM',true,2,1,10,testMR.Id);
        Material_Requisition_line_item__c item2 = PRLDE_TestDataUtility.InsertMateriallineitem('testMaterial1 - TIM','testMaterial1 - TIM',false,1,0,10,testMR.Id);
                
        Test.setCurrentPageReference(new PageReference('Page.MR_Summary_UI'));
        System.currentPageReference().getParameters().put('MRId', testMR.Id);
        
        MRSummaryController LstCtrl = new MRSummaryController();
        system.assertEquals(LstCtrl.MRId,testMR.Id);
        
        LstCtrl.getDetailsByMRFormID();
      //  system.assertEquals(LstCtrl.MRLineItem.size(),2);
        
        LstCtrl.Back();
        LstCtrl.Edit();
        LstCtrl.UpdateStatus();
        system.assertEquals(LstCtrl.Status,'Completed');
        
    }
    
    public static testmethod void Test_MRItemListEquals5() {
        // Fetches the current Logged in user Id
        User usr = PRLDE_TestDataUtility.FetchUser(UserInfo.getUserId());
        
        // Inserts the Trigger setting TriggerStatus__c to insert Opportunity
        System.runAs(usr){
            TriggerStatus__c testSetting = PRLDE_TestDataUtility.InsertTrgSetting(false);
        }
        
        // Fetches Account Record Type
        RecordType AccRecType = PRLDE_TestDataUtility.FetchRecordType('Account', 'Business Account');
        // Inserts Account Record
        Account testAcc = PRLDE_TestDataUtility.InsertAccount(AccRecType, 'AccRecType', 'testAcc', '+911234567890', 'testStreet', 'testCity', 'TN', '600001', 'testCountry');
        // Inserts testCon Record
        Contact testCon = PRLDE_TestDataUtility.InsertContact('FirstName', 'LastName', testAcc.Id, '12345');
        // Inserts Office Record
        Office__c testOff = PRLDE_TestDataUtility.InsertOffice('testName', 'testAddress', 'testRegion', 'testState');
        // Fetches Job Record Type
        RecordType JobRecType = PRLDE_TestDataUtility.FetchRecordType('ATI_Job__c', 'Job (Approved)');
        // Inserts Job Record
        ATI_Job__c testJob = PRLDE_TestDataUtility.InsertJob(JobRecType, 'testJob', testAcc, testOff.Id, 'testJobName', 'testJobNumber', testCon.Id,'testDivision');
        // Inserts MR Record
        Material_Requisition__c testMR = PRLDE_TestDataUtility.InsertMR(testJob.Id, 'In Progress', null, 'MR-testJobName-01');
        
        Material_Requisition_line_item__c item1 = PRLDE_TestDataUtility.InsertMateriallineitem('testMaterial - TOM','testMaterial - TOM',true,2,1,10,testMR.Id);
        Material_Requisition_line_item__c item2 = PRLDE_TestDataUtility.InsertMateriallineitem('testMaterial1 - TIM','testMaterial1 - TIM',false,1,0,10,testMR.Id);
        Material_Requisition_line_item__c item3 = PRLDE_TestDataUtility.InsertMateriallineitem('testMaterial2 - TKM','testMaterial2 - TKM',true,2,0,10,testMR.Id);
        Material_Requisition_line_item__c item4 = PRLDE_TestDataUtility.InsertMateriallineitem('testMaterial3 - TOM','testMaterial3 - TOM',true,0,1,10,testMR.Id);
        Material_Requisition_line_item__c item5 = PRLDE_TestDataUtility.InsertMateriallineitem('testMaterial4 - TIM','testMaterial4 - TIM',false,1,5,20,testMR.Id);
        
        Test.setCurrentPageReference(new PageReference('Page.MR_Summary_UI'));
        System.currentPageReference().getParameters().put('MRId', testMR.Id);
        
        MRSummaryController LstCtrl = new MRSummaryController();
        system.assertEquals(LstCtrl.MRId,testMR.Id);
        
        LstCtrl.getDetailsByMRFormID();
       // system.assertEquals(LstCtrl.MRLineItem.size(),5);
        
        LstCtrl.Back();
        LstCtrl.Edit();
        LstCtrl.UpdateStatus();
     //   system.assertEquals(LstCtrl.Status,'In Progress');
    }
    
    public static testmethod void Test_MRItemListGreterThan5() {
        // Fetches the current Logged in user Id
        User usr = PRLDE_TestDataUtility.FetchUser(UserInfo.getUserId());
        
        // Inserts the Trigger setting TriggerStatus__c to insert Opportunity
        System.runAs(usr){
            TriggerStatus__c testSetting = PRLDE_TestDataUtility.InsertTrgSetting(false);
        }
        
        // Fetches Account Record Type
        RecordType AccRecType = PRLDE_TestDataUtility.FetchRecordType('Account', 'Business Account');
        // Inserts Account Record
        Account testAcc = PRLDE_TestDataUtility.InsertAccount(AccRecType, 'AccRecType', 'testAcc', '+911234567890', 'testStreet', 'testCity', 'TN', '600001', 'testCountry');
        // Inserts testCon Record
        Contact testCon = PRLDE_TestDataUtility.InsertContact('FirstName', 'LastName', testAcc.Id, '12345');
        // Inserts Office Record
        Office__c testOff = PRLDE_TestDataUtility.InsertOffice('testName', 'testAddress', 'testRegion', 'testState');
        // Fetches Job Record Type
        RecordType JobRecType = PRLDE_TestDataUtility.FetchRecordType('ATI_Job__c', 'Job (Approved)');
        // Inserts Job Record
        ATI_Job__c testJob = PRLDE_TestDataUtility.InsertJob(JobRecType, 'testJob', testAcc, testOff.Id, 'testJobName', 'testJobNumber', testCon.Id,'testDivision');
        // Inserts MR Record
        Material_Requisition__c testMR = PRLDE_TestDataUtility.InsertMR(testJob.Id, 'Completed', null, 'MR-testJobName-01');
        
        Material_Requisition_line_item__c item0 = PRLDE_TestDataUtility.InsertMateriallineitem('testMaterial0 - TOM','testMaterial - TOM',true,null,2,10,testMR.Id);
        Material_Requisition_line_item__c item1 = PRLDE_TestDataUtility.InsertMateriallineitem('testMaterial - TOM','testMaterial - TOM',true,1,2,10,testMR.Id);
        Material_Requisition_line_item__c item2 = PRLDE_TestDataUtility.InsertMateriallineitem('testMaterial1 - TIM','testMaterial1 - TIM',false,1,0,10,testMR.Id);
        Material_Requisition_line_item__c item3 = PRLDE_TestDataUtility.InsertMateriallineitem('testMaterial2 - TKM','testMaterial2 - TKM',true,2,null,10,testMR.Id);
        Material_Requisition_line_item__c item4 = PRLDE_TestDataUtility.InsertMateriallineitem('testMaterial3 - TOM','testMaterial3 - TOM',true,0,1,10,testMR.Id);
        Material_Requisition_line_item__c item5 = PRLDE_TestDataUtility.InsertMateriallineitem('testMaterial4 - TIM','testMaterial4 - TIM',false,1,5,20,testMR.Id);
        Material_Requisition_line_item__c item6 = PRLDE_TestDataUtility.InsertMateriallineitem('testMaterial5 - TKM','testMaterial5 - TKM',true,2,1,30,testMR.Id);
        Material_Requisition_line_item__c item7 = PRLDE_TestDataUtility.InsertMateriallineitem('testMaterial6 - TKM','testMaterial6 - TKM',true,2,1,30,testMR.Id);
        Material_Requisition_line_item__c item8 = PRLDE_TestDataUtility.InsertMateriallineitem('testMaterial7 - TKM','testMaterial7 - TKM',true,null,0,30,testMR.Id);
        Material_Requisition_line_item__c item9 = PRLDE_TestDataUtility.InsertMateriallineitem('testMaterial8 - TOM','testMaterial - TOM',true,null,2,10,testMR.Id);

        Test.setCurrentPageReference(new PageReference('Page.MR_Summary_UI'));
        System.currentPageReference().getParameters().put('MRId', testMR.Id);
        
        MRSummaryController LstCtrl = new MRSummaryController();
        system.assertEquals(LstCtrl.MRId,testMR.Id);
        
        LstCtrl.getDetailsByMRFormID();
      //  system.assertEquals(LstCtrl.MRLineItem.size(),10);
        
        LstCtrl.Back();
        LstCtrl.Edit();
        LstCtrl.UpdateStatus();
        system.assertEquals(LstCtrl.Status,'In Progress');
    }
    
    public static testmethod void Test_WithNullMRId() {
        
        MRSummaryController LstCtrl = new MRSummaryController();
        system.assertEquals(LstCtrl.MRId,null);
        
        LstCtrl.getDetailsByMRFormID();
        
        LstCtrl.Back();
        LstCtrl.Edit();
        LstCtrl.UpdateStatus();
    }
    
}