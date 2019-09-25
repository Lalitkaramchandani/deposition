@isTest
private class SObjectLookupCtrlTest {

	private static testMethod void testLookup() {
        
        TestFactory tFact = new TestFactory();
        List<Contact> contacts = tFact.contacts;
        Test.startTest();
        Test.setCurrentPage(Page.sObjectLookup);
        ApexPages.currentPage().getParameters().put('lkObject','Account');
        ApexPages.currentPage().getParameters().put('lkField','Name');
        ApexPages.currentPage().getParameters().put('lksrch','test');
        
        SObjectLookupCtrl control = new SObjectLookupCtrl();
        Test.stopTest();
	}

}