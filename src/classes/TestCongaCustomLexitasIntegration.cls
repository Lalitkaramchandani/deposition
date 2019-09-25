@isTest
private class TestCongaCustomLexitasIntegration {

    @isTest
    private static void Test_CongaCustomLexitasIntegration() {

        TestUtils tUtils = new TestUtils();

        Account acc = tUtils.insertAccount();
        Contact con = tUtils.insertContact(acc.id);
        Deposition__c deposition = tUtils.insertDeposition(acc.id);
        Attendee__c attende = tUtils.insertAttendee(con.id, deposition.id);

        APXTConga4__Conga_Merge_Query__c conquery = new APXTConga4__Conga_Merge_Query__c(APXTConga4__Name__c = 'deposition', APXTConga4__Query__c = 'select id, Deposition__r.Name, Deposition__r.Deposition_Date__c, Deposition__r.Deponent_Name__c, Deposition__r.Case_Name__c,Contact__r.name from Attendee__c where id = {pv0}');
        insert conquery;

        APXTConga4__Conga_Template__c congaTem = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'conga temp', APXTConga4__Template_Type__c = 'Document');
        insert congaTem;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        CongaCustomLexitasIntegration.congaSendMailBackgroundMode(deposition.id, con.id, congaTem.id, '', 'Test Subject', 'Test file', '', con.id, conquery.id, attende.id);
        Test.stopTest();
    }
}