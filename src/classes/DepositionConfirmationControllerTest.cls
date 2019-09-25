@isTest
private class DepositionConfirmationControllerTest {

	private static testMethod void testConfirmation() {
        TestFactory tFact = new TestFactory();
        List<Deposition__c> depositions = tFact.depositions;
        List<Attendee__c> attendees = tFact.attendees;
        
        List<Attendee__c> atts = [Select Id, Deposition__c, Contact__c From Attendee__c WHERE Deposition__c=:depositions[0].Id];
        
        Test.startTest();
        ApexPages.currentPage().getParameters().put('depositionId',atts[0].Deposition__c);
        ApexPages.currentPage().getParameters().put('contactId',atts[0].Contact__c);
        
        DepositionConfirmationController control = new DepositionConfirmationController();
        control.updateDeposition();
        Test.stopTest();
        
	}

}