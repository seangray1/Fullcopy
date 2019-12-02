@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"status": "OK", "body": {"67440": "OK"}, "code": "0", "detail": "Account insert and Update successful"}');
        res.setStatusCode(200);
        return res;
    }
}