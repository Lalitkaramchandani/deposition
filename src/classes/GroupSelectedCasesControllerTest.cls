@isTest
private class GroupSelectedCasesControllerTest {
 
    @isTest
    private Static void TestGroupSelected(){
        Case_Leads__c case1 = new Case_Leads__c( unicourt_case_id__c= 'HFKCQLBTIBKEMKEVPFAW7CTMNVRCC0998', Case_Name__c = 'testCase',Case_Management_Conference__c = System.Today()+1 );
        Case_Leads__c case2 = new Case_Leads__c( unicourt_case_id__c= 'HFKCQLBTIBKEMKEVPFAW7CTMNVRCC0990', Case_Name__c = 'testCase2',Case_Management_Conference__c = System.Today()+1 );
        Case_Leads__c testParentCase = new Case_Leads__c( unicourt_case_id__c= 'HFKCQLBTIBKEMKEVPFAW7CTMNVRCC0991', Case_Name__c = 'testParentCase',Case_Management_Conference__c = System.Today()+1 );
        List<Case_leads__c> caselist = new List<Case_Leads__c>();
        caselist.add(case1);
        caselist.add(case2);
        caselist.add(testParentCase);
        insert caselist;
        List<Case_Leads__c> selectedCases = new List<Case_Leads__c>{case1,case2};
        ApexPages.StandardSetController stdCont = new ApexPages.StandardSetController(selectedCases);
        stdCont.setSelected(selectedCases);
        GroupSelectedCasesController groupSelected = new GroupSelectedCasesController(stdCont);
        groupSelected.parentGroupName = 'testParentCase';
        Test.startTest();
        groupSelected.findParentCases();
        System.assert(groupSelected.parentCases.size() > 0);
        groupSelected.parentCaseId = testParentCase.Id;
        groupSelected.groupSelectedCaseLeads();
        System.assert(groupSelected.groupingSuccessful);
        groupSelected.gotoParent();
        Test.stopTest();
    }
}