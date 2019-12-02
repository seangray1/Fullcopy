/**
 * @File Name          : Mica_integration_callout_estimate_Mock.cls
 * @Description        : 
 * @Author             : Sean Gray
 * @Group              : 
 * @Last Modified By   : Sean Gray
 * @Last Modified On   : 10/4/2019, 4:33:17 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    10/4/2019   Sean Gray     Initial Version
**/
@isTest
global class Mica_integration_callout_estimate_Mock implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest request) {
        // Create the mock response based on a static resource
        //StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        HttpResponse response = new HttpResponse();
        response.setBody('<?xml version="1.0" encoding="UTF-8"?><soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><UploadEstimateResponse xmlns="https://nextgearsolutions.com/"><UploadEstimateResult><ReviewId>188142</ReviewId><ReviewUrl>https://micaexchange.com/qast/ReviewLogin.event?id=AAEAAAD%2f%2f%2f%2f%2fAQAAAAAAAAAGAQAAAAYxODgxNDIL</ReviewUrl><IsReviewSuccessful>true</IsReviewSuccessful><ErrorMessage></ErrorMessage><ErrorCode /><ReviewDetails><NumberViolations>3</NumberViolations></ReviewDetails></UploadEstimateResult></UploadEstimateResponse></soap:Body></soap:Envelope>');
        response.setStatusCode(200);
        response.setHeader('Content-Type', 'application/soap+xml; charset=utf-8');
        // Associate the callout with a mock response
        return response;
    }
}