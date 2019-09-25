@isTest
private class HighProfileCasesControllerTest {

    @isTest
    private static void TestHighProfileCase(){
        Commission__c comm = TestUtility.createCommission();
        insert comm;
        Case_leads__c cl = TestUtility.createCaseLead();
        cl.High_Profile_Case__c = true;
        cl.Commission__c = comm.id;
        insert cl;
        Representation__c rep = TestUtility.createRepresentation(cl.id);
        rep.Commission__c = comm.Id;
        rep.Law_Firm_Text__c = 'TestLawFirm';
        rep.Unicourt_Client_Name__c = 'WalmartTest';
        insert rep;
        Test.startTest();
        HighProfileCasesController controller = new HighProfileCasesController();
        System.assertEquals(1, controller.HPCaseList.size());
        controller.getCommissionList();
        controller.filterListByCommission();
        controller.selectedCommission = cl.Commission__c;
        controller.casePartiesMap = null;
        controller.getCasePartiesMap();
        controller.caseFirmsMap = null;
        controller.getCaseFirmsMap();
        controller.filterListByCommission();
        System.assertEquals(1, controller.HPCaseList.size());

        Test.stopTest();
    }
}