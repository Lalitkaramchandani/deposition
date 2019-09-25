@isTest
private class TrackCaseWebhookControllerTest {
	
    @isTest
    private static void initTest(){
        Case_Leads__c case1 = new Case_Leads__c( unicourt_case_id__c= 'EVABIGA7FJADEFEBMUWWDBDBK5GAM1014', Case_Name__c = 'testCase',Case_Management_Conference__c = System.Today()+1 );
        insert case1;
        Case_Follower__c cf = new Case_Follower__c(Case_Lead__c=case1.Id , User__c = Userinfo.getUserId());
        insert cf;
        TrackCaseWebhookController controller = new TrackCaseWebhookController();
        PageReference pr = Page.TrackCaseWebhookVF;
        Test.setCurrentPage(pr);
        String json = '{\"result\": [{\"tracking_schedule_id\": \"1\", \"tracking_name\": \"Daily\", \"tracked_date\": \"2018-08-31 15:30:38\", \"folder\": [{\"folder_id\": \"2\", \"folder_name\": \"My Folder\", \"case_ids\": [\"EZARKGJAFNATGFMCMYXFZASZMNEQU1006\"]}]}]}';
        pr.getParameters().put('data',json);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.Class, new caseAPICalloutMock());
        controller.init();
        Test.stopTest();
    }
}