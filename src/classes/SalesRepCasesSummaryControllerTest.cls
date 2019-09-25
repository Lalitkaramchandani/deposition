@isTest
private class SalesRepCasesSummaryControllerTest {
	
    
    @isTest
    private static void testShowDetail(){
        Case_leads__c case1 = new Case_Leads__c(Case_Name__c = 'testCase',Case_Management_Conference__c = System.Today()+1 );
        insert case1;
        Case_Follower__c cf = new Case_Follower__c(Case_Lead__c=case1.Id, User__c = Userinfo.getUserId());
        insert cf;
        Commission__c comm = new Commission__c(name='testCommission', Primary_Rep__c=Userinfo.getUserId() );
        insert comm;
        Deposition__c dep = new Deposition__c(Commission__c = comm.id,Deposition_Date__c=System.Today()+1);
        insert dep;
        Test.startTest();
        SalesRepCasesSummaryController controller = new SalesRepCasesSummaryController();
        controller.rId = case1.Id;
        controller.showDetail();
        Test.stopTest();
    }
}