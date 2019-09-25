@isTest
private class ManageCaseFollowersTest {
    
	@isTest
    private static void testAddFollowers(){
        Case_Leads__c case1 = new Case_Leads__c(Case_Name__c = 'testCase',Case_Management_Conference__c = System.Today()+1 );
        insert case1;
        Test.setMock(HttpCalloutMock.class, new TrackCasesCalloutMock());
        ManageCaseFollowers.addFollower(case1.id, UserInfo.getUserId());
    }
    
    @isTest(seeAllData=true)
    private static void testUpdateUnicourtCase(){
        Case_Leads__c case1 = [select id from Case_leads__c limit 1];
        
        Test.setMock(HttpCalloutMock.class, new TrackCasesCalloutMock());
        ManageCaseFollowers.updateUnicourtCase(case1.id);
    }
    @isTest
    private static void testRemoveCaseTracking(){
        Case_Leads__c case1 = new Case_Leads__c(Case_Name__c = 'testCase',Case_Management_Conference__c = System.Today()+1 );
        insert case1;
         Case_Follower__c cf = new Case_Follower__c(Case_Lead__c=case1.Id, User__c = Userinfo.getUserId());
        insert cf;
        Test.setMock(HttpCalloutMock.class, new TrackCasesCalloutMock());
        ManageCaseFollowers.removeCaseTracking(new List<string>{case1.id});
    }
}