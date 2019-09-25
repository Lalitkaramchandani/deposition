@isTest
private class DepositionDayReminderSchedulerTest {

	private static testMethod void testSchedule() {
        TestFactory tFact = new TestFactory();
        List<Invoice_Item__c> items = tFact.invoiceItems;
        List<Deposition__c> depositions = tFact.depositions;
        Set<Id> depIds = new Set<Id>();
        for(Deposition__c deposition:depositions){
            depIds.add(deposition.Id);
            deposition.Deposition_Date__c = System.today();
        }
        update depositions;
        Test.startTest();
        DepositionDayReminderScheduler job = new DepositionDayReminderScheduler();
        String sch = '20 30 8 10 2 ?';
        String jobID = system.schedule('testDepositionDayReminderScheduler', sch, job);
        
        Test.stopTest();
    }

}