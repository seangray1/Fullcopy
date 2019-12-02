/**
 * @author           kanitha Priya P
 * @version          1.0
 * @date             26-07-2017
 * @status           Developed
 * @Description      The purpose of this test class is to test all the possible scenarios for the Apex class MRController.
 **/
@isTest
public class PRLDE_TestMRController {

    public static testmethod void Test_MRId_Null() {
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
        // Fetches Opportunity Record Type
        RecordType OppRecType = PRLDE_TestDataUtility.FetchRecordType('ATI_Job__c', 'Job (Approved)');
        // Inserts Opportunity Record
        ATI_Job__c testOpp = PRLDE_TestDataUtility.InsertJob(OppRecType, 'testopp', testAcc, testOff.Id, 'testJobName', 'testJobNumber', testCon.Id,'testDivision');
        // Inserts MR Record
        Material_Requisition__c testMR = PRLDE_TestDataUtility.InsertMR(testOpp.Id, 'In Progress', null, 'MR-testJobName-01');
        
        // Inserts Material Records
        Material__c  testMat = PRLDE_TestDataUtility.InsertMaterial('testMaterial','testMaterial',1001,TRUE,TRUE,'TOM',10.00);
        Material__c  testMat1 = PRLDE_TestDataUtility.InsertMaterial('testMaterial1','testMaterial1',1002,FALSE,TRUE,'TIM',10.00);
        Material__c  testMat2 = PRLDE_TestDataUtility.InsertMaterial('testMaterial2','testMaterial2',1003,TRUE,FALSE,'TKM',10.00);
        Material__c  testMat3 = PRLDE_TestDataUtility.InsertMaterial('testMaterial3','testMaterial3',1004,FALSE,FALSE,'TLM',10.00);
        
        MRController LstCtrl = new MRController();
        LstCtrl.SearchText = ''; 
        
        LstCtrl.getMRItemList();
        system.assertEquals(LstCtrl.MaterialList.size(),2);
        
        LstCtrl.AddedToList = true;
        LstCtrl.SearchByMaterialName();
        
        LstCtrl.SearchComplete();
        LstCtrl.ClearSearch();
        system.assertEquals(LstCtrl.SearchText,null);
        
        LstCtrl.QuantityChangeUpdate();
        LstCtrl.FormSave();
        LstCtrl.Cancel();
        
        LstCtrl.getJobDetails();
        system.assertEquals(LstCtrl.JobName,null);
        system.assertEquals(LstCtrl.JobNameList.size(),0);
    }
    
    public static testmethod void Test_NotNullLocation()
    {
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
        // Fetches Opportunity Record Type
        RecordType OppRecType = PRLDE_TestDataUtility.FetchRecordType('ATI_Job__c', 'Job (Approved)');
        // Inserts Opportunity Record
        ATI_Job__c testOpp = PRLDE_TestDataUtility.InsertJob(OppRecType, 'testopp', testAcc, testOff.Id, 'testJobName', 'testJobNumber', testCon.Id,'testDivision');
        //Inserts Location code
        Location_Code__c testLocCode = PRLDE_TestDataUtility.InsertLocationCode('TESTCODE','TEST Description');
        // Inserts Location
        MRLocation__c MRLoc = PRLDE_TestDataUtility.InsertMRLocation('testLocation',testOff.Id,'testDivision',true,testLocCode.Id);
        MRLocation__c MRLoc1 = PRLDE_TestDataUtility.InsertMRLocation('testLocation1',testOff.Id,'testDivision',false,testLocCode.Id);
        // Inserts MR Record
        Material_Requisition__c testMR = PRLDE_TestDataUtility.InsertMR(testOpp.Id, 'In Progress', testLocCode.Id, 'MR-testJobName-01');
       
        // Inserts Material
        Material__c  testMat = PRLDE_TestDataUtility.InsertMaterial('testMaterial','testMaterial',1001,TRUE,TRUE,'TOM',10.00);
        Material__c  testMat1 = PRLDE_TestDataUtility.InsertMaterial('testMaterial1','testMaterial1',1002,FALSE,TRUE,'TIM',10.00);
        Material__c  testMat2 = PRLDE_TestDataUtility.InsertMaterial('testMaterial2','testMaterial2',1003,TRUE,FALSE,'TKM',10.00);
        Material__c  testMat3 = PRLDE_TestDataUtility.InsertMaterial('testMaterial3','testMaterial3',1004,FALSE,FALSE,'TLM',10.00);
             
        Test.setCurrentPageReference(new PageReference('Page.MR_UI'));
        System.currentPageReference().getParameters().put('MRId', testMR.Id);

        MRController LstCtrl = new MRController();
        
        LstCtrl.SearchText = '';
        LstCtrl.MRId = testMR.Id;
        LstCtrl.getMRItemList();
        system.assertEquals(LstCtrl.MaterialList.size(),2);
        
        LstCtrl.SearchByMaterialName();
        system.assertEquals(LstCtrl.MatLineItemLeftTable.size() > 0,true);
        
        LstCtrl.SearchComplete();
        LstCtrl.ClearSearch();
        LstCtrl.QuantityChangeUpdate();
        
        LstCtrl.JobName = 'JobName';
        LstCtrl.JobNumber = 'JobNumber';
        LstCtrl.DateOrdered = 'DateOrdered';
        LstCtrl.JobLocation = '';
        LstCtrl.Status = 'status';
        LstCtrl.JobId = 'JobId';
        LstCtrl.FormSave();
        
        Material_Requisition_line_item__c item1 = new Material_Requisition_line_item__c(Name = 'testMaterial - TOM',Description__c = 'testMaterial - TOM',IsPicklist__c = true,Shipped__c = 2,Returned__c = 1,Unit_Cost__c = 10);
        Material_Requisition_line_item__c item2 = new Material_Requisition_line_item__c(Name = 'testMaterial1 - TIM',Description__c = 'testMaterial1 - TIM',IsPicklist__c = false,Shipped__c = 1,Returned__c = 0,Unit_Cost__c = 10);
        Material_Requisition_line_item__c item3 = new Material_Requisition_line_item__c(Name = 'testMaterial2 - TKM',Description__c = 'testMaterial2 - TKM',IsPicklist__c = true,Shipped__c = 2,Unit_Cost__c = 10);
  
        LstCtrl.MatLineItemLeftTable.add(item1);
        LstCtrl.MatLineItemLeftTable.add(item2);
        LstCtrl.MatLineItemLeftTable.add(item3);
        
        system.assertEquals(LstCtrl.MatLineItemLeftTable.size(),5);
        
        LstCtrl.FormSave();
        LstCtrl.Cancel();
        LstCtrl.getJobDetails();
        //system.assertEquals(LstCtrl.JobName,'testJobName');
        
        MRController.getMatchedOpportunityList('test');
    
    }
    
    public static testmethod void Test_MRId_NotNull()
    {
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
        // Fetches Opportunity Record Type
        RecordType OppRecType = PRLDE_TestDataUtility.FetchRecordType('ATI_Job__c', 'Job (Approved)');
        // Inserts Opportunity Record
        ATI_Job__c testOpp = PRLDE_TestDataUtility.InsertJob(OppRecType, 'testopp', testAcc, testOff.Id, 'testJobName', 'testJobNumber', testCon.Id,'testDivision');
        //Inserts Location code
        Location_Code__c testLocCode = PRLDE_TestDataUtility.InsertLocationCode('TESTCODE','TEST Description');
        // Inserts Location
        MRLocation__c MRLoc = PRLDE_TestDataUtility.InsertMRLocation('testLocation',testOff.Id,'testDivision',true,testLocCode.Id);
        MRLocation__c MRLoc1 = PRLDE_TestDataUtility.InsertMRLocation('testLocation1',testOff.Id,'testDivision',false,testLocCode.Id);
        // Inserts MR Record
        Material_Requisition__c testMR = PRLDE_TestDataUtility.InsertMR(testOpp.Id, 'In Progress', null, 'MR-testJobName-01');
        // Inserts Material
        Material__c  testMat = PRLDE_TestDataUtility.InsertMaterial('testMaterial','testMaterial',1001,TRUE,TRUE,'TOM',10.00);
        Material__c  testMat1 = PRLDE_TestDataUtility.InsertMaterial('testMaterial1','testMaterial1',1002,FALSE,TRUE,'TIM',10.00);
        Material__c  testMat2 = PRLDE_TestDataUtility.InsertMaterial('testMaterial2','testMaterial2',1003,TRUE,FALSE,'TKM',10.00);
        Material__c  testMat3 = PRLDE_TestDataUtility.InsertMaterial('testMaterial31','testMaterial31',1004,FALSE,FALSE,'TLM',10.00);
        Material__c  testMat4 = PRLDE_TestDataUtility.InsertMaterial('testMaterial3','testMaterial3',1004,FALSE,FALSE,'TLM',10.00);
        Material__c  testMat5 = PRLDE_TestDataUtility.InsertMaterial('testMaterial4','testMaterial4',1004,FALSE,FALSE,'TLM',10.00);
        Material__c  testMat6 = PRLDE_TestDataUtility.InsertMaterial('testMaterial5','testMaterial5',1004,FALSE,FALSE,'TLM',10.00);
        Material__c  testMat7 = PRLDE_TestDataUtility.InsertMaterial('testMaterial6','testMaterial6',1004,FALSE,FALSE,'TLM',10.00);
        Material__c  testMat8 = PRLDE_TestDataUtility.InsertMaterial('testMaterial7','testMaterial7',1004,FALSE,FALSE,'TLM',10.00);
             
        Test.setCurrentPageReference(new PageReference('Page.MR_UI'));
        System.currentPageReference().getParameters().put('MRId', testMR.Id);

        MRController LstCtrl = new MRController();
        system.assertEquals(LstCtrl.MRId,testMR.Id);
         
        Material_Requisition_line_item__c item1 = new Material_Requisition_line_item__c(Name = 'testMaterial - TOM',Description__c = 'testMaterial - TOM',IsPicklist__c = true,Shipped__c = 2,Returned__c = 1,Unit_Cost__c = 10);
        Material_Requisition_line_item__c item2 = new Material_Requisition_line_item__c(Name = 'testMaterial1 - TIM',Description__c = 'testMaterial1 - TIM',IsPicklist__c = false,Shipped__c = 1,Returned__c = 0,Unit_Cost__c = 10);
        Material_Requisition_line_item__c item3 = new Material_Requisition_line_item__c(Name = 'testMaterial2 - TKM',Description__c = 'testMaterial2 - TKM',IsPicklist__c = true,Shipped__c = 2,Unit_Cost__c = 10);
  
        LstCtrl.MatLineItemLeftTable.add(item1);
        LstCtrl.MatLineItemLeftTable.add(item2);
        LstCtrl.MatLineItemRightTable.add(item3);
        
        system.assertEquals(LstCtrl.MatLineItemLeftTable.size(),3);
        
        LstCtrl.SearchText = '';
        LstCtrl.MRId = testMR.Id;
        LstCtrl.getMRItemList();
        LstCtrl.SearchByMaterialName();
        
        LstCtrl.SearchComplete();
        LstCtrl.ClearSearch();
        LstCtrl.QuantityChangeUpdate();
        
        LstCtrl.FormSave();
        LstCtrl.Cancel();
        LstCtrl.getJobDetails();
        //system.assertEquals(LstCtrl.JobName,'testJobName');
        
        MRController.getMatchedOpportunityList('test');
    
    }
    
    public static testmethod void Test_MRId_WithItems()
    {
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
        // Fetches Opportunity Record Type
        RecordType OppRecType = PRLDE_TestDataUtility.FetchRecordType('ATI_Job__c', 'Job (Approved)');
        // Inserts Opportunity Record
        ATI_Job__c testOpp = PRLDE_TestDataUtility.InsertJob(OppRecType, 'testopp', testAcc, testOff.Id, 'testJobName', 'testJobNumber', testCon.Id,'testDivision');
        //Inserts Location code
        Location_Code__c testLocCode = PRLDE_TestDataUtility.InsertLocationCode('TESTCODE','TEST Description');
        // Inserts Location
        MRLocation__c MRLoc = PRLDE_TestDataUtility.InsertMRLocation('testLocation',testOff.Id,'testDivision',true,testLocCode.Id);
        MRLocation__c MRLoc1 = PRLDE_TestDataUtility.InsertMRLocation('testLocation1',testOff.Id,'testDivision',false,testLocCode.Id);
        // Inserts MR Record
        Material_Requisition__c testMR = PRLDE_TestDataUtility.InsertMR(testOpp.Id, 'In Progress', null, 'MR-testJobName-01');
        // Inserts Material
        Material__c  testMat = PRLDE_TestDataUtility.InsertMaterial('testMaterial','testMaterial',1001,TRUE,TRUE,'TOM',10.00);
        Material__c  testMat1 = PRLDE_TestDataUtility.InsertMaterial('testMaterial1','testMaterial1',1002,FALSE,TRUE,'TIM',10.00);
        Material__c  testMat2 = PRLDE_TestDataUtility.InsertMaterial('testMaterial2','testMaterial2',1003,TRUE,FALSE,'TKM',10.00);
        Material__c  testMat3 = PRLDE_TestDataUtility.InsertMaterial('testMaterial31','testMaterial31',1004,FALSE,FALSE,'TLM',10.00);
        Material__c  testMat4 = PRLDE_TestDataUtility.InsertMaterial('testMaterial3','testMaterial3',1004,TRUE,TRUE,'TLM',10.00);
        Material__c  testMat5 = PRLDE_TestDataUtility.InsertMaterial('testMaterial4','testMaterial4',1004,TRUE,TRUE,'TLM',10.00);
        Material__c  testMat6 = PRLDE_TestDataUtility.InsertMaterial('testMaterial5','testMaterial5',1004,TRUE,TRUE,'TLM',10.00);
        Material__c  testMat7 = PRLDE_TestDataUtility.InsertMaterial('testMaterial6','testMaterial6',1004,TRUE,TRUE,'TLM',10.00);
        Material__c  testMat8 = PRLDE_TestDataUtility.InsertMaterial('testMaterial7','testMaterial7',1004,TRUE,TRUE,'TLM',10.00);
         
        Material_Requisition_line_item__c item1 = PRLDE_TestDataUtility.InsertMateriallineitem('testMaterial - TOM','testMaterial - TOM',true,2,1,10,testMR.Id);
        Material_Requisition_line_item__c item2 = PRLDE_TestDataUtility.InsertMateriallineitem('testMaterial1 - TIM','testMaterial1 - TIM',false,1,0,10,testMR.Id);
        Material_Requisition_line_item__c item3 = PRLDE_TestDataUtility.InsertMateriallineitem('testMaterial2 - TKM','testMaterial2 - TKM',true,2,null,10,testMR.Id);
        Material_Requisition_line_item__c item4 = PRLDE_TestDataUtility.InsertMateriallineitem('testMaterial3 - TOM','testMaterial3 - TOM',true,0,1,10,testMR.Id);
        Material_Requisition_line_item__c item5 = PRLDE_TestDataUtility.InsertMateriallineitem('testMaterial4 - TIM','testMaterial4 - TIM',false,1,5,20,testMR.Id);
        Material_Requisition_line_item__c item6 = PRLDE_TestDataUtility.InsertMateriallineitem('testMaterial31 - TLM','testMaterial31 - TLM',false,1,5,10,testMR.Id);
         
        Test.setCurrentPageReference(new PageReference('Page.MR_UI'));
        System.currentPageReference().getParameters().put('MRId', testMR.Id);

        MRController LstCtrl = new MRController();
        system.assertEquals(LstCtrl.MRId,testMR.Id);
        
        LstCtrl.SearchText = '';
        LstCtrl.MRId = testMR.Id;
        LstCtrl.getMRItemList();
        LstCtrl.SearchByMaterialName();
        
        LstCtrl.SearchComplete();
        LstCtrl.ClearSearch();
        LstCtrl.QuantityChangeUpdate();
        
        LstCtrl.FormSave();
        LstCtrl.Cancel();
        LstCtrl.getJobDetails();
        //system.assertEquals(LstCtrl.JobName,'testJobName');
        //system.assertEquals(LstCtrl.JobId,testOpp.Id);
        
        MRController.getMatchedOpportunityList('test');
    
    }
}