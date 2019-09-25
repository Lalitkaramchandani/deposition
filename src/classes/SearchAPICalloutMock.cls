@isTest
public class SearchAPICalloutMock implements HttpCalloutMock {
	 public HTTPResponse respond(HTTPRequest req) {
        
        System.assertEquals('https://api.unicourt.com/rest/v1/search/?token=2a8c48f7019a286dae3ddd7f43a96622a9ccc669', req.getEndpoint());
        System.assertEquals('POST', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"error":false,"message":"OK","data":{"result":[{"case":{"case_type":"Other Small Claim","case_type_category":"Civil","case_type_group":"Small Claim","case_status_category":"Pending","case_status_name":"Trial","courthouse":"Central Courthouse","state":"CA","jurisdiction":"San Diego County Superior Courts","last_updated_date":"2018-09-20","case_name":"Amelia Hardy vs. Wallmart","filing_date":"2018-08-23","case_id":"GFGCAJBLDRGEIJ34HQ4WPELLNBJRK0927","case_number":"37-2018-00042329-SC-SC-CTL","docket":"By Hardy Amelia"},"attorneys":[],"parties":[{"representation_type":"Unrepresented","party_type":"Defendant","fullname":"WALLMART","entity_type":"Company"}],"judges":[]}],"total_matches":"1","post_data":{"query":[{"search_terms":["Wallmart"]}],"page":1},"criteria":"(0)"}}');
        res.setStatusCode(200);
        return res;
    }
}