/**
 * @File Name          : Mica_integration_callout_mock.cls
 * @Description        : 
 * @Author             : Sean Gray
 * @Group              : 
 * @Last Modified By   : Sean Gray
 * @Last Modified On   : 10/4/2019, 3:26:51 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    10/4/2019   Sean Gray     Initial Version
**/
@isTest
global class Mica_integration_callout_mock implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest request) {
        // Create the mock response based on a static resource
        //StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        HttpResponse response = new HttpResponse();
        response.setBody('<?xml version="1.0" encoding="UTF-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><UploadProjectInfoResponse xmlns="http://buildfusion.com/"><UploadProjectInfoResult><DocumentElement><ReturnMessage><Status>True</Status><Message>Success</Message><ProjectID>a77P00000000ABzIAM</ProjectID><ProjectGuid>c36aceed-0aa2-4b82-9bf2-36ee1f9a40e8</ProjectGuid><ErrCd /><SvrMsg /><Prd /><SvrTs /><ResponseUrl /><ResponseMsg /></ReturnMessage></DocumentElement></UploadProjectInfoResult></UploadProjectInfoResponse></soap:Body></soap:Envelope>');
        response.setStatusCode(200);
        response.setHeader('Content-Type', 'text/xml; charset=utf-8');
        // Associate the callout with a mock response
        return response;
        // Call method to test

        //Make a new job etc
        
        // Verify mock response is not null
        // System.assertNotEquals(null,result,
        //     'The callout returned a null response.');
        // // Verify status code
        // System.assertEquals(200,result.getStatusCode(),
        //   'The status code is not 200.');
        // // Verify content type   
        // System.assertEquals('Content-Type', 'text/xml; charset=utf-8',
        //   result.getHeader('Content-Type'),
        //   'The content type value is not expected.');  
        // Verify the array contains 3 items     
        /*Map<String, Object> results = (Map<String, Object>) 
            JSON.deserializeUntyped(result.getBody());
        List<Object> animals = (List<Object>) results.get('animals');
        System.assertEquals(3, animals.size(),
          'The array should only contain 3 items.');      */    
    }   
}