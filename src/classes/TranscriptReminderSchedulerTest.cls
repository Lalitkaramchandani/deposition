@isTest
private class TranscriptReminderSchedulerTest {
    
    private static testMethod void testSchedule() {
        TestFactory tFact = new TestFactory();
        List<Invoice_Item__c> items = tFact.invoiceItems;
        List<Deposition__c> depositions = tFact.depositions;
        Integer index= -1;
        for(Deposition__c deposition:depositions){
            deposition.Deposition_Date__c = System.today().addDays(index++);
            deposition.Transcript_Status__c = 'Not Received';
        }
        update depositions;
        Test.startTest();
        TranscriptReminderScheduler job = new TranscriptReminderScheduler();
        String sch = '00 00 00 6 9 ?';
        String jobID = system.schedule('testTranscriptReminderScheduler', sch, job);
        Test.stopTest();
        
    }
    private static testMethod void testScheduleManual() {
        TestFactory tFact = new TestFactory();
        List<Invoice_Item__c> items = tFact.invoiceItems;
        List<Deposition__c> depositions = tFact.depositions;
        List<Attendee__c> attendees = tFact.attendees;
        Set<Id> depositionIds =new Set<ID>();
        Integer index= -1;
        for(Deposition__c deposition:depositions){
            deposition.Deposition_Date__c = System.today().addDays(index++);
            deposition.Transcript_Status__c = 'Not Received';
        }
        update depositions;
        for(Deposition__c dep : depositions){
            depositionIds.add(dep.Id);
        }
        List<Deposition__c> depositionss=TranscriptReminderScheduler.getDepositionWithAttendes(depositionIds);
        
        Map<Deposition__c, List<Attendee__c>> depAttMap  = new Map<Deposition__c, List<Attendee__c>>();
        for(Deposition__c dep : depositionss){
            depAttMap.put(dep,dep.Deposition_Roles__r);
        }
        Test.startTest();
        new TranscriptReminderScheduler().sendDepositionTurnInRequestNotification(depAttMap);
        new TranscriptReminderScheduler().sendDepositionSMS(depAttMap);
        Test.stopTest();
        
    }
    private static testMethod void testScheduleManual2() {
        TestFactory tFact = new TestFactory();
        List<Invoice_Item__c> items = tFact.invoiceItems;
        List<Deposition__c> depositions = tFact.depositions;
        List<Attendee__c> attendees = tFact.attendees;
        Set<Id> depositionIds =new Set<ID>();
        Integer index= -1;
        for(Deposition__c deposition:depositions){
            deposition.Deposition_Date__c = System.today().addDays(index++);
            deposition.Transcript_Status__c = 'Not Received';
        }
        update depositions;
        for(Deposition__c dep : depositions){
            depositionIds.add(dep.Id);
        }
        Test.startTest();
        new TranscriptReminderScheduler().processNotification(depositionIds);
        Test.stopTest();
        
    }
}