@isTest
private class TestConfirmEmailCtrl_Test {

	@isTest private static void testConfrim() {
	    TestFactory tFact = new TestFactory();
        List<Deposition__c> depositions = tFact.depositions;
        List<Attendee__c> attendees = tFact.attendees;
        List<Contact> contacts = tFact.contacts;
        for(Contact con : contacts){
            con.Email = '';
        }
        update contacts;
        System.runAs(tFact.communtiyUser){
            TestConfirmEmailCtrl control = new TestConfirmEmailCtrl();
            control.onDepChange();
            
            control.inv.Deposition__c = depositions[0].Id;
            control.onDepChange();
            
            control.selectedAttendees = control.attendees[1].getValue();
            control.onSendConfirmationNotification();
        }
        Deposition__c dep = [SELECT Id, Confirm_Interpreter__c, Confirm_Reporter__c, Confirm_Video_Tech__c 
                            FROM Deposition__c WHERE Id=:depositions[0].Id LIMIT 1];
        // System.assert(dep.Confirm_Interpreter__c != depositions[0].Confirm_Interpreter__c 
        //     || dep.Confirm_Reporter__c != depositions[0].Confirm_Reporter__c
        //     || dep.Confirm_Video_Tech__c!=depositions[0].Confirm_Video_Tech__c);
	}
	@isTest private static void testRecap() {
	    TestFactory tFact = new TestFactory();
        List<Deposition__c> depositions = tFact.depositions;
        List<Attendee__c> attendees = tFact.attendees;
        List<Contact> contacts = tFact.contacts;
        for(Contact con : contacts){
            con.Email = '';
            con.Exempt_From_Automated_Confirmations__c = true;
        }
        update contacts;
        Test.startTest();
        System.runAs(tFact.communtiyUser){
            TestConfirmEmailCtrl control = new TestConfirmEmailCtrl();
            control.onDepChange();
            
            control.inv.Deposition__c = depositions[0].Id;
            control.onDepChange();
            
            control.selectedAttendees = control.attendees[1].getValue();
            control.onSendRecapNotification();
        }
        Test.stopTest();
        Deposition__c dep = [SELECT Id, Confirm_Interpreter__c, Confirm_Reporter__c, Confirm_Video_Tech__c 
                            FROM Deposition__c WHERE Id=:depositions[0].Id LIMIT 1];
        System.assert(dep.Confirm_Interpreter__c != depositions[0].Confirm_Interpreter__c 
            || dep.Confirm_Reporter__c != depositions[0].Confirm_Reporter__c
            || dep.Confirm_Video_Tech__c!=depositions[0].Confirm_Video_Tech__c);
	}

}