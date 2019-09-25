@isTest
private class BatchSendConfirmationEmailTest {

	@isTest
    static void testScheduler(){
        Set<String> depIds=new Set<String>();
        TestFactory tFact = new TestFactory();
        List<Deposition__c> depositions = tFact.depositions;
        for(Deposition__c dep:depositions){
            depIds.add(dep.Id);
        }
        BatchSendConfirmationEmail bsm=new BatchSendConfirmationEmail();
        bsm.DepositionSet=depIds;
        Test.startTest();
        Database.executeBatch(bsm);
        Test.stopTest();
    }

}