/**
 * @File Name          : mica_integration_callout_test.cls
 * @Description        : 
 * @Author             : Sean Gray
 * @Group              : 
 * @Last Modified By   : Sean Gray
 * @Last Modified On   : 10/15/2019, 7:18:00 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    10/4/2019   Sean Gray     Initial Version
**/
@isTest(SeeAllData=true)
private class mica_integration_callout_test {
@isTest static void mica_integration_callout_test() {
   
    Test.setMock(HttpCalloutMock.class, new Mica_integration_callout_mock()); 
    // This causes a fake response to be sent
    // from the class that implements HttpCalloutMock. 
    ATI_Job__c j = [Select Id FROM ATI_Job__c Where name = '000-00-00002 | Test Job 1'];
    
    MICA_Integration_Callout.invokeIntegration(j.id, true, 'Main', '1', '1');
    
    test.startTest();
    MICASync.executeJobWithoutWater(j.id, true, 'Main', '1', '1');
    
    
    MICASync.executeJobWithWater(j.id, true, 'Main', '1', '1');
    
    
    MICASync.executeUploadEstimate(j.id, 'Main', '1', '1', true);
    
    
    MICASync.getClassCategory(j.id);
    
    
    MICASync.queryDivision(j.id);
    
    
    MICASync.queryRecordType(j.id);
    
    
    MICASync.StartWithMain(j.id);
    test.stopTest();
    

}
@isTest static void mica_integration_callout_test1() {

Test.setMock(HttpCalloutMock.class, new MICA_Estimate_Mock()); 
    // This causes a fake response to be sent
    // from the class that implements HttpCalloutMock. 
    ATI_Job__c j = [Select Id FROM ATI_Job__c Where name = '000-00-00002 | Test Job 1'];    
MICA_Integration_Callout.invokeUploadEstimate(j.id, 'Main', '1', '1', 'UploadEstimate', true);

}

}