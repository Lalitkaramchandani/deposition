@isTest
public class DocketActivityCalloutMock implements HttpCalloutMock {
 	String json = '{\"error\":false,\"message\":\"OK\",\"data\":{\"docket_entries\":[{\"document_id_list\":[\"PACER_TNMDCE_A_16913976613\",\"PACER_TNMDCE_A_16913976612\",\"PACER_TNMDCE_D_16913976611\"],\"order\":1,\"boundary\":\"last\",\"text\":\"(#1) NOTICE OF REMOVAL by Wesley Dutton, The City of Fairview from Williamson County Circuit Court, case number 94CC1-2018-CV-267. ( Filing fee $ 400 receipt number 0650-2704041) (Attachments: #1 Attachment - Civil Cover Sheet, #2 Exhibit A - State Trial Documents)(am) (Entered: 07\\/06\\/2018)\",\"entryDate\":\"2018-07-06\",\"updated\":\"2018-11-12 20:40:11\"},{\"document_id_list\":[\"PACER_TNMDCE_D_16913976619\"],\"order\":2,\"text\":\"(#2) NOTICE\\/INFORMATION regarding Consent of the Parties to the Magistrate Judge. (am) (Entered: 07\\/06\\/2018)\",\"entryDate\":\"2018-07-06\",\"updated\":\"2018-11-12 20:40:11\"},{\"document_id_list\":[\"PACER_TNMDCE_D_16913976628\"],\"order\":3,\"text\":\"(#3) NOTICE of Business Entity Disclosure Statement filing requirement. (am) (Entered: 07\\/06\\/2018)\",\"entryDate\":\"2018-07-06\",\"updated\":\"2018-11-12 20:40:11\"}],\"last_key\":null}}';
    public HTTPResponse respond(HTTPRequest req) {
        
        System.assertEquals('GET', req.getMethod());
        
        // Create a dummy response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(json);
        res.setStatusCode(200);
        return res;
    }
}