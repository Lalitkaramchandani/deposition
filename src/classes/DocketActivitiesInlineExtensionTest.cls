@isTest	
private class DocketActivitiesInlineExtensionTest {
	
    @isTest
    private static void DocketActivitiesInlineTest(){
        Case_leads__c cl = TestUtility.createCaseLead();
        insert cl;
        Docket_Activity__c da = TestUtility.createDocketActivity(cl.id);
        insert da;
        ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(cl);
        DocketActivitiesInlineExtension daInline = new DocketActivitiesInlineExtension(stdCtrlr);
        System.assert(daInline.docketActivities.size() > 0);
        
    }
}