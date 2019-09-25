@isTest
private class CommissionTriggerHeplerTest {
    @isTest
    private static void testCommissionInsertUpdate(){
        Commission__c comm = new Commission__c(name='TestCommission', Active__c=true);
        insert comm;
        Case_Leads__c case1 = new Case_Leads__c( unicourt_case_id__c= 'HFKCQLBTIBKEMKEVPFAW7CTMNVRCC0998', Case_Name__c = 'testCase', Commission__c = comm.Id );
        insert case1;
        User testUser = TLS_TestDataFactory.createUser('system administrator');
        insert testUser;
        comm.Primary_Rep__c = testUser.id;
        test.startTest();
        update comm;
        
        Commission__c comm1 = [select id,Primary_Rep__c from Commission__c where id = :comm.Id];
        System.assertEquals(testUser.id, comm1.Primary_Rep__c);
        
        test.stopTest();
    }
}