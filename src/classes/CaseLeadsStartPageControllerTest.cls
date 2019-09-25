@isTest
private class CaseLeadsStartPageControllerTest {

    @isTest
    private static void CaseLeadStartPageTest(){
        Case_Leads__c case1 = new Case_Leads__c( unicourt_case_id__c= 'HFKCQLBTIBKEMKEVPFAW7CTMNVRCC0998', Case_Name__c = 'testCase',Case_Management_Conference__c = System.Today()+1 );
        insert case1;
        Case_Follower__c cf = new Case_Follower__c(Case_Lead__c=case1.Id , User__c = Userinfo.getUserId());
        insert cf;
        String token = 'HFKCQLBTIBKEMKEVPFAW7CTMNVRCC'; // dummy case docket token
        Map<String, String> docketmap = new Map<String,String>();
        docketmap.put(case1.unicourt_case_id__c, token);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DocketActivityCalloutMock());
        CaseLeadCommonRoutine.createDocketEntries(docketmap);
        List<Case_Follower__c> cfList = [select id, Case_Lead__c from Case_Follower__c where User__c = :Userinfo.getUserId()];
        System.assert(cfList.size() > 0);
        CaseLeadsStartPageController CLS = new CaseLeadsStartPageController();
        cls.caseUpdateSince = Date.newInstance(2018, 07, 01);// Date before docket entry date i.e. 2018-07-06 (from mock response)
        cls.getCaseUpdates();
           
        System.assert(CLS.myCaseList.size() > 0);
        Test.stopTest();
    }
}