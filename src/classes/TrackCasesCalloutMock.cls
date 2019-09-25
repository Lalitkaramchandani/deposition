@isTest
public class TrackCasesCalloutMock implements HttpCalloutMock {
    
    public HTTPResponse respond(HTTPRequest req) {
        
        System.assertEquals('POST', req.getMethod());
        
        // Create a dummy response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        res.setBody('success');
        res.setStatusCode(200);
        return res;
    }
}