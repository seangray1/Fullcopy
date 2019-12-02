/**
 * @File Name          : BigTimeCalloutMockGenerator.cls
 * @Description        : 
 * @Author             : sean.gray@atirestoration.com
 * @Group              : 
 * @Last Modified By   : sean.gray@atirestoration.com
 * @Last Modified On   : 11/8/2019, 9:22:38 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    11/8/2019   sean.gray@atirestoration.com     Initial Version
**/
@isTest
global class BigTimeCalloutMockGenerator implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest req) {
        //System.assertEquals('https://iq.bigtime.net/BigTimeData/api/v2/session', req.getEndpoint());
        //System.assertEquals('POST', req.getMethod());
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"Token":"123abc", "Firm":"abc123"}');
        res.setStatusCode(200);
        return res;
    }
}