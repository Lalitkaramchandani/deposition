@isTest
private class MassDeleteSelectedCasesControllerTest {
	
    @isTest
    private Static void TestMassDelete(){
        Case_Leads__c case1 = new Case_Leads__c( unicourt_case_id__c= 'HFKCQLBTIBKEMKEVPFAW7CTMNVRCC0998', Case_Name__c = 'testCase',Case_Management_Conference__c = System.Today()+1 );
        List<Case_leads__c> caselist = new List<Case_Leads__c>();
        caselist.add(case1);
        insert caselist;
        ApexPages.StandardSetController stdCont = new ApexPages.StandardSetController(caselist);
        stdCont.setSelected(caselist);
        MassDeleteSelectedCasesController massdelete = new MassDeleteSelectedCasesController(stdCont);
        Test.startTest();
        massdelete.redirectBack();
        List<Case_leads__c> csList = [select id from case_leads__c where id = :case1.Id];
        System.assertEquals(0, csList.size());
    }
}