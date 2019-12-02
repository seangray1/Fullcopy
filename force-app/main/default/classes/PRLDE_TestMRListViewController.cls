/**
 * @author           kanitha Priya P
 * @version          1.0
 * @date             19-07-2017
 * @status           Developed
 * @Description      The purpose of this test class is to test all the possible scenarios for the Apex class MRListViewController.
 **/
@isTest
public class PRLDE_TestMRListViewController {
    public static testmethod void Test_onLoadMethod() {
        User usr = PRLDE_TestDataUtility.FetchUser(UserInfo.getUserId());

        System.runAs(usr) {
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


        MRListViewController LstCtrl = new MRListViewController();
        System.assertEquals(LstCtrl.SelectedFormType,'Recently Viewed');
        System.assertEquals(LstCtrl.SearchText,'');
        
        LstCtrl.SearchByMRName();
        LstCtrl.NewMR();
        LstCtrl.beginning();
        LstCtrl.next();

        LstCtrl.SelectedFormType = 'In Progress';
        System.assertEquals(LstCtrl.SelectedFormType,'In Progress');
        
        LstCtrl.LoadMR();
        System.assertEquals(LstCtrl.MRList.size(),1);
        
        LstCtrl.SearchText = '@@@@';
        System.assertEquals(LstCtrl.SearchText,'@@@@');
        LstCtrl.SearchByMRName();
        System.assertEquals(LstCtrl.MRList.size(),0);
        
        LstCtrl.SearchByMRName();
        
    }

    public static testmethod void Test_WithMRList() {
        User usr = PRLDE_TestDataUtility.FetchUser(UserInfo.getUserId());

        System.runAs(usr) {
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
        // Inserts MR Records
        Material_Requisition__c testMR = PRLDE_TestDataUtility.InsertMR(testJob.Id, 'In Progress', null, 'MR-testJobName-01');
        Material_Requisition__c testMR1 = PRLDE_TestDataUtility.InsertMR(testJob.Id, 'In Progress', null, 'MR-testJobName-02');
        Material_Requisition__c testMR2 = PRLDE_TestDataUtility.InsertMR(testJob.Id, 'In Progress', null, 'MR-testJobName-03');
        Material_Requisition__c testMR3 = PRLDE_TestDataUtility.InsertMR(testJob.Id, 'In Progress', null, 'MR-testJobName-04');
        Material_Requisition__c testMR4 = PRLDE_TestDataUtility.InsertMR(testJob.Id, 'In Progress', null, 'MR-testJobName-05');
        Material_Requisition__c testMR5 = PRLDE_TestDataUtility.InsertMR(testJob.Id, 'In Progress', null, 'MR-testJobName-06');
        Material_Requisition__c testMR6 = PRLDE_TestDataUtility.InsertMR(testJob.Id, 'Completed', null, 'MR-testJobName-07');
        Material_Requisition__c testMR7 = PRLDE_TestDataUtility.InsertMR(testJob.Id, 'Completed', null, 'MR-testJobName-08');
        Material_Requisition__c testMR8 = PRLDE_TestDataUtility.InsertMR(testJob.Id, 'Completed', null, 'MR-testJobName-09');
        Material_Requisition__c testMR9 = PRLDE_TestDataUtility.InsertMR(testJob.Id, 'Completed', null, 'MR-testJobName-10');
        Material_Requisition__c testMR10 = PRLDE_TestDataUtility.InsertMR(testJob.Id, 'Completed', null, 'MR-testJobName-11');
        Material_Requisition__c testMR11 = PRLDE_TestDataUtility.InsertMR(testJob.Id, 'In Progress', null, 'MR-testJobName-12');
        Material_Requisition__c testMR12 = PRLDE_TestDataUtility.InsertMR(testJob.Id, 'In Progress', null, 'MR-testJobName-13');
        Material_Requisition__c testMR13 = PRLDE_TestDataUtility.InsertMR(testJob.Id, 'In Progress', null, 'MR-testJobName-14');
        Material_Requisition__c testMR14 = PRLDE_TestDataUtility.InsertMR(testJob.Id, 'In Progress', null, 'MR-testJobName-15');
        Material_Requisition__c testMR15 = PRLDE_TestDataUtility.InsertMR(testJob.Id, 'Sync Successful', null, 'MR-testJobName-16');
        Material_Requisition__c testMR16 = PRLDE_TestDataUtility.InsertMR(testJob.Id, 'Sync Failed', null, 'MR-testJobName-17');
        
        MRListViewController LstCtrl = new MRListViewController();
        System.assertEquals(LstCtrl.SelectedFormType,'Recently Viewed');
        System.assertEquals(LstCtrl.MRList.size(),5);
        
        System.assertEquals(LstCtrl.SearchText,'');
        LstCtrl.SearchByMRName();
        System.assertEquals(LstCtrl.MRList.size(),5);
        LstCtrl.next();
        System.assertEquals(LstCtrl.MRList.size(),5);
        LstCtrl.next();
        System.assertEquals(LstCtrl.MRList.size(),5);
        
        LstCtrl.SelectedFormType = 'In Progress';
        LstCtrl.LoadMR();
        System.assertEquals(LstCtrl.SelectedFormType,'In Progress');
        System.assertEquals(LstCtrl.MRList.size(),5);
        LstCtrl.next();
        System.assertEquals(LstCtrl.MRList.size(),5);
        
        LstCtrl.NewMR();
        LstCtrl.beginning();
        LstCtrl.next();
        LstCtrl.previous();
        LstCtrl.last();
        LstCtrl.getDisableNext();
        LstCtrl.getDisablePrevious();

    }
}