@isTest
private class updateCaseWebhookControllerTest {

    @isTest
    private static void initTest(){
        Case_Leads__c case1 = new Case_Leads__c( unicourt_case_id__c= 'EVABIGA7FJADEFEBMUWWDBDBK5GAM1014', Case_Name__c = 'testCase',Case_Management_Conference__c = System.Today()+1 );
        insert case1;
        
        updateCaseWebhookController controller = new updateCaseWebhookController();
        PageReference pr = Page.updateCaseWebhookVF;
        Test.setCurrentPage(pr);
        String json = '{\"result\": {\"requested_case_id\": \"EVABIGA7FJADEFEBMUWWDBDBK5GAM1014\", \"is_moved\": false, \"case_id\": \"EVABIGA7FJADEFEBMUWWDBDBK5GAM1014\", \"status\": \"has_update\", \"updated_time\": \"2019-01-03 22:33:55\"}}';
        pr.getParameters().put('data',json);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.Class, new caseAPICalloutMock());
        controller.init();
        Test.stopTest();
    }
    
    @isTest
    private static void initNoUpdateTest(){
        Case_Leads__c case1 = new Case_Leads__c( unicourt_case_id__c= 'EVABIGA7FJADEFEBMUWWDBDBK5GAM1014', Case_Name__c = 'testCase',Case_Management_Conference__c = System.Today()+1 );
        insert case1;
        
        updateCaseWebhookController controller = new updateCaseWebhookController();
        PageReference pr = Page.updateCaseWebhookVF;
        Test.setCurrentPage(pr);
        String json = '{\"result\": {\"requested_case_id\": \"EVABIGA7FJADEFEBMUWWDBDBK5GAM1014\", \"is_moved\": false, \"case_id\": \"EVABIGA7FJADEFEBMUWWDBDBK5GAM1014\", \"status\": \"has_no_update\", \"updated_time\": \"2019-01-03 22:33:55\"}}';
        pr.getParameters().put('data',json);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.Class, new caseAPICalloutMock());
        controller.init();
        Test.stopTest();
    }
}