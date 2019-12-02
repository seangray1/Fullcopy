/**
 * @author           Kirankumar
 * @version          1.0
 * @date             26-07-2017
 * @status           Developed
 * @Description      Test class for UpdateMRStatus Trigger
 **/
@isTest
public class UpdateMRStatus_Test
{
    public static testmethod void BatchUpdate()
    {
        DateTime d = Date.today();
        
        User usrRec = PRLDE_TestDataUtility.FetchUser(UserInfo.getUserId());

        System.runAs(usrRec) 
        {
            TriggerStatus__c testSetting = PRLDE_TestDataUtility.InsertTrgSetting(false);
        }
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
        ATI_Job__c testJob = PRLDE_TestDataUtility.insertJob(OppRecType, 'testJob', testAcc, testOff.Id, 'testJobName', 'testJobNumber', testCon.Id,'testDivision');
        // Inserts MR Records
        Material_Requisition__c testMR = PRLDE_TestDataUtility.InsertMR(testJob.Id, 'Completed', null, 'MR-testJobName-01');
        //Inserts Batch record
        Batch__c batch = PRLDE_TestDataUtility.InsertBatch(false,'New',d);
        
        System.assertEquals('New',batch.Batch_Status__c);
        System.assertEquals(d,batch.Batch_Sync_Date__c);
        
        System.assertEquals('Completed',testMR.status__c);
        
        //Inserts Material Req Batch record
        Material_Req_Batch__c MRReq = PRLDE_TestDataUtility.InsertMRBatch(batch,testMR.Id);
        
        DateTime dt = Date.today()+1;
        // Updates the batch record with new status
        batch = PRLDE_TestDataUtility.UpdateBatch('Sync Successful',batch.Id,dt);
        
        System.assertEquals('Sync Successful',batch.Batch_Status__c);
        System.assertEquals(dt,batch.Batch_Sync_Date__c);
        
        List<Material_Requisition__c> MRFetched = PRLDE_TestDataUtility.FetchMR(testMR.Id);
        
        if(MRFetched.size() > 0)
        {
            System.assertEquals('Sync Successful',MRFetched[0].status__c);
            System.assertEquals(dt,MRFetched[0].Batch_Date__c);
        }
    }
    
    public static testmethod void BatchUpdateWithListOfMRReqs()
    {
        DateTime d = Date.today();
        
        User usrRec = PRLDE_TestDataUtility.FetchUser(UserInfo.getUserId());

        System.runAs(usrRec) 
        {
            TriggerStatus__c testSetting = PRLDE_TestDataUtility.InsertTrgSetting(false);
        }
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
        ATI_Job__c testJob = PRLDE_TestDataUtility.insertJob(OppRecType, 'testJob', testAcc, testOff.Id, 'testJobName', 'testJobNumber', testCon.Id,'testDivision');
        // Inserts MR Records
        Material_Requisition__c testMR = PRLDE_TestDataUtility.InsertMR(testJob.Id, 'Completed', null, 'MR-testJobName-01');
        Material_Requisition__c testMR1 = PRLDE_TestDataUtility.InsertMR(testJob.Id, 'Completed', null, 'MR-testJobName-02');
        
        System.assertEquals('Completed',testMR.status__c);
        System.assertEquals('Completed',testMR1.status__c);
        
        //Inserts Batch record
        Batch__c batch = PRLDE_TestDataUtility.InsertBatch(false,'New',d);
        
        System.assertEquals('New',batch.Batch_Status__c);
        System.assertEquals(d,batch.Batch_Sync_Date__c);
        
        System.assertEquals('Completed',testMR.status__c);
        
        //Inserts Material Req Batch record
        Material_Req_Batch__c MRReq = PRLDE_TestDataUtility.InsertMRBatch(batch,testMR.Id);
        Material_Req_Batch__c MRReq1 = PRLDE_TestDataUtility.InsertMRBatch(batch,testMR1.Id);
        
        DateTime dt = Date.today()+1;
        // Updates the batch record with new status
        batch = PRLDE_TestDataUtility.UpdateBatch('Sync Failed',batch.Id,dt);
        
        System.assertEquals('Sync Failed',batch.Batch_Status__c);
        System.assertEquals(dt,batch.Batch_Sync_Date__c);
        
        List<Material_Requisition__c> MRFetched = PRLDE_TestDataUtility.FetchMR(testMR.Id);
        
        if(MRFetched.size() > 0)
        {
            System.assertEquals('Sync Failed',MRFetched[0].status__c);
            System.assertEquals(dt,MRFetched[0].Batch_Date__c);
        }
        
    }
    
    public static testmethod void BatchBulkUpdate()
    {
        DateTime d = Date.today();
        
        User usrRec = PRLDE_TestDataUtility.FetchUser(UserInfo.getUserId());

        System.runAs(usrRec) 
        {
            TriggerStatus__c testSetting = PRLDE_TestDataUtility.InsertTrgSetting(false);
        }
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
        ATI_Job__c testJob = PRLDE_TestDataUtility.InsertJob(OppRecType, 'testJob', testAcc, testOff.Id, 'testJobName', 'testJobNumber', testCon.Id,'testDivision');
        // Inserts MR Records
        Material_Requisition__c testMR = PRLDE_TestDataUtility.InsertMR(testJob.Id, 'Completed', null, 'MR-testJobName-01');
        Material_Requisition__c testMR1 = PRLDE_TestDataUtility.InsertMR(testJob.Id, 'Completed', null, 'MR-testJobName-02');
        
        System.assertEquals('Completed',testMR.status__c);
        System.assertEquals('Completed',testMR1.status__c);
        
        //Inserts Batch record
        Batch__c batch = PRLDE_TestDataUtility.InsertBatch(false,'New',d);
        Batch__c batch1 = PRLDE_TestDataUtility.InsertBatch(false,'New',d);
        
        System.assertEquals('New',batch.Batch_Status__c);
        System.assertEquals(d,batch.Batch_Sync_Date__c);
        System.assertEquals('New',batch1.Batch_Status__c);
        System.assertEquals(d,batch1.Batch_Sync_Date__c);
        
        //Inserts Material Req Batch record
        Material_Req_Batch__c MRReq = PRLDE_TestDataUtility.InsertMRBatch(batch,testMR.Id);
        Material_Req_Batch__c MRReq1 = PRLDE_TestDataUtility.InsertMRBatch(batch1,testMR1.Id);
        
        List<Batch__c> BatchList = new List<Batch__c>();
        
        DateTime dt = Date.today()+1;
        // Updates the batch record with new status
        Batch__c batchRec = new Batch__c(Id = batch.Id,Batch_Status__c = 'Sync Successful',Batch_Sync_Date__c = dt);
        Batch__c batchRec1 = new Batch__c(Id = batch1.Id,Batch_Status__c = 'Sync Failed',Batch_Sync_Date__c = dt);
        
        BatchList.add(batchRec);
        BatchList.add(batchRec1);
        update BatchList;
        
        System.assertEquals('Sync Successful',batchRec.Batch_Status__c);
        System.assertEquals('Sync Failed',batchRec1.Batch_Status__c);
        
        System.assertEquals(dt,batchRec.Batch_Sync_Date__c);
        System.assertEquals(dt,batchRec1.Batch_Sync_Date__c);
        
        List<Material_Requisition__c> MRFetched = PRLDE_TestDataUtility.FetchMR(testMR.Id);
        
        if(MRFetched.size() > 0)
        {
            System.assertEquals('Sync Successful',MRFetched[0].status__c);
            System.assertEquals(dt,MRFetched[0].Batch_Date__c);
        }
        
        MRFetched = PRLDE_TestDataUtility.FetchMR(testMR1.Id);
        
        if(MRFetched.size() > 0)
        {
            System.assertEquals('Sync Failed',MRFetched[0].status__c);
            System.assertEquals(dt,MRFetched[0].Batch_Date__c);
        }
    }
}