/**
                                    Name             : TestSendBulkAccountStatementsCntrl
                                    Date             : 06 JULY 2018
                                    Descripition     : Test Class for SendBulkAccountStatementsCntrl  class.
*/                                   
@isTest
private class TestSendBulkAccountStatementsCntrl{

    @isTest
    private static void Test_CreateInvoice() {
        Rate_Sheet__c rateSheet = TestUtility.createRateSheet('Allstate','Reporter');
        insert rateSheet;
        
        Case__c depositionGroup = TestUtility.createDepositionGroup('Test group');
        depositionGroup.Rate_Sheet__c =rateSheet.id; 
        insert depositionGroup;
        
        Account account = TestUtility.createAccount('Test Account','Court Reporting');
        account.Rate_Sheet__c = rateSheet.id;
        account.Accounting_Email_Address__c  = 'jprimuth@nextgenreporting.com';
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
        ApexPages.currentPage().getParameters().put('type', 'Client');
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
        cntrl.newInvoice.Status__c = 'Valid';
        cntrl.CreateInvoice();
        cntrl.previous();
        cntrl.Edit();
        String startDate = System.today().month()+'/'+System.today().day()+'/'+System.today().year();
        String endDate = System.today().month()+'/'+System.today().day()+'/'+System.today().year();
        SendBulkAccountStatementsCntrl cntrl2 = new SendBulkAccountStatementsCntrl();
        String res = SendBulkAccountStatementsCntrl.updateAccounts(account.id+'','',startDate ,endDate);
        cntrl.newInvoice.Invoice_Date__c = system.today().addDays(-100);
        update cntrl.newInvoice;
        
        res = SendBulkAccountStatementsCntrl.updateAccounts(account.id+'','',startDate ,endDate);
        
    }


}