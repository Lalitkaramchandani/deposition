@isTest
private class DepositionReminderSchedulerTest {
    
    private static testMethod void testSchedule() {
        TestFactory tFact = new TestFactory();
        List<Invoice_Item__c> items = tFact.invoiceItems;
        List<Deposition__c> depositions = tFact.depositions;
        Set<Id> depIds = new Set<Id>();
        for(Deposition__c deposition:depositions){
            depIds.add(deposition.Id);
            deposition.Deposition_Date__c = System.today().addDays(1);
        }
        update depositions;
        Test.startTest();
        DepositionReminderScheduler job = new DepositionReminderScheduler();
        String sch = '20 30 8 10 2 ?';
        String jobID = system.schedule('testDepositionReminderScheduler', sch, job);
        
        Test.stopTest();
    }
    
    
    
}