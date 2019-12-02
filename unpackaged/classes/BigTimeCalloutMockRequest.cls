/**
 * @File Name          : BigTimeCalloutMockRequest.cls
 * @Description        : 
 * @Author             : sean.gray@atirestoration.com
 * @Group              : 
 * @Last Modified By   : Sean Gray
 * @Last Modified On   : 11/10/2019, 3:50:59 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    11/8/2019   sean.gray@atirestoration.com     Initial Version
**/
@isTest(SeeAllData=true)
private class BigTimeCalloutMockRequest {
    /*@isTest static void BigTimeCalloutsTest() {
        // Create the mock response based on a static resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('credentialsMockResource');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        // Associate the callout with a mock response
        Test.setMock(HttpCalloutMock.class, mock);
        // Call method to test
        HttpResponse result = BigTime_Callout_Integration.GetProject();

        System.assertEquals(200,result.getStatusCode(),
          'The status code is not 200.');

        System.assertEquals('application/json;charset=UTF-8',
          result.getHeader('Content-Type'),
          'The content type value is not expected.');  
        // Verify the array contains 3 items     
        Map<String, Object> results = (Map<String, Object>) 
            JSON.deserializeUntyped(result.getBody());
        List<Object> animals = (List<Object>) results.get('animals');
        System.assertEquals(3, animals.size(),
          'The array should only contain 3 items.');          
    }  */ 
    @isTest static void testPostCallout2(){
        Test.setMock(HttpCalloutMock.class, new BigtimeCalloutMockGenerator());
        ATI_Job__c j = [Select Id, Name, division__c, bigtimeSId__c FROM Ati_Job__c WHERE bigtimeSid__c = '123' Limit 1];
        //string method = 'Update';
        BigTime_Callout_Integration.invokeCallout(j.Id);
    }
    @isTest static void testPostCallout() {
    Test.setMock(HttpCalloutMock.class, new BigTimeCalloutMockGenerator()); 
    BigTime_Callout_Integration.resetCredentials();
    /*String contentType = response.getHeader('Content-Type');
    System.assert(contentType == 'application/json');
    String actualValue = response.getBody();
    System.debug(response.getBody());
    String expectedValue = '{"Token":"123abc", "Firm":"abc123"}';
    System.assertEquals(actualValue, expectedValue);
    System.assertEquals(200, response.getStatusCode());*/

}
   @isTest static void testPostCallout3(){
        Test.setMock(HttpCalloutMock.class, new BigTimeInvoiceMockGenerator());
        //ATI_Job__c j = [Select Id, Name, division__c, bigtime_Id__c FROM Ati_Job__c WHERE bigtime_id__c != null Limit 1];
        //string method = 'Update';
        system.enqueueJob(new BigTime_Integration_Invoices());
    
}
@isTest static void testPostCallout4(){
String sch = '20 30 8 10 2 ?';
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new BigTimeInvoiceMockGenerator());
        String jobId = System.schedule('Test', sch, new BigTimeScheduler());
        test.stopTest();
}

}