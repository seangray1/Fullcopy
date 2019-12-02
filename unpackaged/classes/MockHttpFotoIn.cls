@isTest
public class MockHttpFotoIn implements HttpCalloutMock{

	protected Integer code;
	protected String status;
	protected String body;
	protected Map<String, String> responseHeaders;

	public MockHttpFotoIn() {

	}

	public MockHttpFotoIn(Integer code, String status, String body, Map<String, String> responseHeaders) {
	    this.code = code;
	    this.status = status;
	    this.body = body;
	    this.responseHeaders = responseHeaders;
	}

	public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(body);
        res.setStatusCode(code);
        System.debug('Response is ...' + res.getBody());
        return res;
    }

}