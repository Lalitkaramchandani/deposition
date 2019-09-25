/**
                                    Name             : TestCreateInvoice_Ctrl
                                    Date             : 03 Dec 2015
                                    Descripition     : Test Class for CreateInvoice_Ctrl class.
*/                                   
@isTest
private class TestCreateInvoice_Ctrl{

    @isTest
    private static void Test_CreateInvoice() {
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
        insert deposition;

        
        Attendee__c  attendee = TestUtility.createAttendee(contact.Id, deposition.Id);
        insert attendee ;
        
        State_Rules__c  stateRules= TestUtility.createStateRules('California','Test CA Rule');
        insert stateRules;
        
        Item__c item = TestUtility.createItem('Test Item');
        insert item;
        
        Rate_Sheet_Item__c rateSheetItem = TestUtility.createRateSheetItem(rateSheet.id,item.id,200,'Default Copy');
        insert rateSheetItem;
        
        ApexPages.currentPage().getParameters().put('id', attendee.id);
        CreateInvoice_Ctrl cntrl = new CreateInvoice_Ctrl();
        cntrl.getRateSheets();
        cntrl.deSelectPicklistRateSheet();
        cntrl.deSelectLookupRateSheet();
        cntrl.PrepareInvoice();
        cntrl.selectedRateSheet = rateSheet.id;
        cntrl.PrepareInvoice();
        cntrl.Cancel();
        cntrl.selectedRateSheet = 'Other';
        cntrl.tempContact.Rate_Sheet__c = rateSheet.id;
        cntrl.deSelectPicklistRateSheet();
        cntrl.deSelectLookupRateSheet();
        
        Test.StartTest();
            cntrl = new CreateInvoice_Ctrl();
            account.Industry = 'Law Firm';
            update account;
            cntrl.getRateSheets();
            
            cntrl = new CreateInvoice_Ctrl();
            account.Industry = 'Videography';
            update account;
            cntrl.getRateSheets();
            cntrl.saveDeposition();
            cntrl.dep = new Deposition__c();
            cntrl.saveDeposition();
       Test.StopTest();
    }


}