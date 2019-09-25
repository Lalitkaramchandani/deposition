@isTest
private class RestInvoiceAmountDueTest {

	private static testMethod void testGet() {
	    
        TestFactory tFact = new TestFactory();
        List<Invoice__c> invoices = tFact.invoices;
        Test.startTest();
   
        //As Per Best Practice it is important to instantiate the Rest Context 
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
             
        req.requestURI = '/invoice/amountdue/'+invoices[0].Name;
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response= res;
        
        Decimal amount = RestInvoiceAmountDue.doGet();
        Test.stopTest();
	}

}