/**
                                    Name             : TestCloneInvoiceExtn
                                    Date             : 07 FEB 2018
                                    Descripition     : Test Class for CloneInvoiceExtn class.
*/                                   
@isTest
private class TestCloneInvoiceExtn{

    @isTest
    private static void Test_CloneInvoice() {
        Rate_Sheet__c rateSheet = TestUtility.createRateSheet('Allstate','Reporter');
        insert rateSheet;
        
        Case__c depositionGroup = TestUtility.createDepositionGroup('Test group');
        depositionGroup.Rate_Sheet__c =rateSheet.id; 
        insert depositionGroup;
        
        Account account = TestUtility.createAccount('Test Account','Court Reporting');
        account.Rate_Sheet__c = rateSheet.id;
        insert account;
        
        Contact contact = TestUtility.createContact(account.ID,'Test Contact', 'test@test.com');
        contact.Rate_Sheet__c = rateSheet.id;
        insert contact;
        
        Deposition__c deposition = TestUtility.createDeposition(account.id);
        deposition.Event_Location__c= 'His Prison Cell Folsom, CA 94123';
        deposition.Corporate_Client_Source__c = 'Allstate';
        deposition.Deposition_Group__c = depositionGroup.Id;
        deposition.State__c = 'Alabama';
        insert deposition;

        
        Attendee__c  attendee = TestUtility.createAttendee(contact.Id, deposition.Id);
        insert attendee ;
        
        State_Rules__c  stateRules= TestUtility.createStateRules('California','Test CA Rule');
        insert stateRules;
        
        Item__c item = TestUtility.createItem('Test Item');
        insert item;
        
        Rate_Sheet_Item__c rateSheetItem = TestUtility.createRateSheetItem(rateSheet.id,item.id,200,'Default Copy');
        insert rateSheetItem;
        
        ApexPages.currentPage().getParameters().put('attendeeId', attendee.id);
        ApexPages.currentPage().getParameters().put('rateSheetId', rateSheet.id);
        ApexPages.currentPage().getParameters().put('type', 'Reporter');
        PrepareInvoice_Ctrl cntrl = new PrepareInvoice_Ctrl();
        for (PrepareInvoice_Ctrl.InvoiceRateSheetItem temp: cntrl.lstInvoiceItems) {
            temp.quantity = 'test';
        }
        cntrl.addRow();
        cntrl.next();
        for (PrepareInvoice_Ctrl.InvoiceRateSheetItem temp: cntrl.lstInvoiceItems) {
            temp.quantity = '3';
        }
        cntrl.next();
        cntrl.CreateInvoice();
        cntrl.previous();
        cntrl.Edit();
        CloneInvoiceExtn extn = new CloneInvoiceExtn( new ApexPages.StandardController(cntrl.newInvoice));
        extn.cloneInvoiceRecord();
        extn = new CloneInvoiceExtn( new ApexPages.StandardController(new Invoice__c()));
        extn.cloneInvoiceRecord();
        
    }


}