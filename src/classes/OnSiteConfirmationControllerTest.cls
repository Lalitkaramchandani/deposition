@isTest
private class OnSiteConfirmationControllerTest {
    
    private static testMethod void testOnSite() {
        
        TestFactory tFact = new TestFactory();

        List<Attendee__c> attendees = tFact.attendees;

        Test.startTest();
        ApexPages.currentPage().getParameters().put('depositionId',attendees[0].Deposition__c);
        ApexPages.currentPage().getParameters().put('contactId',attendees[0].Contact__c);
        OnSiteConfirmationController control = new OnSiteConfirmationController();
        control.manitainAttendee();
        Test.stopTest();
    }

}