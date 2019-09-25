@isTest
private class TestSendConfirmationEmailCtlr {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        Firm__C firm = new Firm__c(Name='NextGen Reporting');
        insert firm;
        Set<String> depIds=new Set<String>();
        TestUtils tUtils = new TestUtils();
        Deposition__c deposition = tUtils.createDeposition();
        deposition.Deposition_Date__c = System.today();
        depIds.add(deposition.id);
        
        Account account = tUtils.insertAccount();
        Contact contact = tUtils.insertContact(account.ID);
        List<Attendee__c>lstAttendees = new List<Attendee__c>();
        lstAttendees.add(new Attendee__c(Contact__c=contact.id,Role__c='Scheduler',Deposition__c=deposition.id));
        lstAttendees.add(new Attendee__c(Contact__c=contact.id,Role__c='Court Reporter',Deposition__c=deposition.id));
        lstAttendees.add(new Attendee__c(Contact__c=contact.id,Role__c='Videographer/Technician',Deposition__c=deposition.id));
        insert lstAttendees;
        
        
        SendConfirmationEmailCtlr cntrl = new SendConfirmationEmailCtlr();
        cntrl.dummydeposition=deposition;
        cntrl.actionmethod();
        cntrl.sendEmail();
        
        Test.startTest();
        BatchSendConfirmationEmail bsm=new BatchSendConfirmationEmail();
        bsm.DepositionSet=depIds;
        Database.executeBatch(bsm);
        Test.stopTest();
    
    }
}