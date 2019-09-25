@
isTest
private class TestPortalReportersAndvideographersCntrl {

    @
    isTest
    private static void Test_PortalReportersAndvideographers() {

        TestUtils tUtils = new TestUtils();
        Deposition__c deposition = tUtils.createDeposition();


        String name = [SELECT Name from Deposition__c WHERE ID = : deposition.Id].Name;


        Account account = tUtils.insertAccount();
        Contact contact = tUtils.insertContact(account.ID);
        tUtils.insertAttendee(contact.Id, deposition.ID);

        PortalReportersAndvideographersCntrl cntrl = new PortalReportersAndvideographersCntrl(new ApexPages.StandardController(new Deposition__c()));
        cntrl.validatePageParameters();
        cntrl.saveDeposition();
        ApexPages.currentPage().getParameters().put('contactId', contact.id);
        ApexPages.currentPage().getParameters().put('type', 'r');
        cntrl = new PortalReportersAndvideographersCntrl(new ApexPages.StandardController(deposition));
        cntrl.validatePageParameters();
       
        ApexPages.currentPage().getParameters().put('type', 'x');
        cntrl = new PortalReportersAndvideographersCntrl(new ApexPages.StandardController(deposition));
        cntrl.validatePageParameters();
        cntrl.deposition.Post_event_Notes__c = 'test';
        cntrl.saveDeposition();

    }


}