@isTest
private class FollowActionWindowControllerTest {
	
    @isTest
    private static void testAddFollower(){
        Case_Leads__c case1 = new Case_Leads__c(Case_Name__c = 'testCase',Case_Management_Conference__c = System.Today()+1 );
        insert case1;
        ApexPages.StandardController sc = new ApexPages.StandardController(case1);
        FollowActionWindowController FAController = new FollowActionWindowController(sc);
        Test.setMock(HttpCalloutMock.class, new TrackCasesCalloutMock());
        FAController.addFollower();
        
    }
}