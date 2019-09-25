@isTest
private class TestBatchUpdateFlagLatestDeposition {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        
         TestUtils utils = new TestUtils();
    	 Account account = utils.insertAccount();
         Contact contact = utils.insertContact(account.Id);
         Deposition__c deposition = utils.insertDeposition(account.ID);
         Attendee__c atten=utils.insertAttendee(contact.id,deposition.id);
           	Test.startTest();
	            String query='Select id,lastname from Contact';
	    		Batch_Update_Flag_LatestDeposition brd=new Batch_Update_Flag_LatestDeposition();
	            brd.query=query;
	            Database.executebatch(brd);
            Test.stopTest();
    }
}