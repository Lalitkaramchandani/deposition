@isTest
private class TwilioRestResourceTest {

	private static testMethod void testPost() {
	    
        TestFactory tFact = new TestFactory();
        List<Invoice__c> invoices = tFact.invoices;
        Test.startTest();
   
        //As Per Best Practice it is important to instantiate the Rest Context 
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
             
        req.requestURI = '/twilio/'+invoices[0].Name;
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        
        TwilioRestResource.handleTwilio();
        Test.stopTest();
	}

}