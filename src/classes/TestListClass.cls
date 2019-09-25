/**
                    Name             : TestListClass
                    Date             : 03 Apr 2018
                    Descripition     : Test Class for ListClass class.
*/                                   
@isTest
private class TestListClass {

    @isTest
    private static void TestNextPrevious() {
    
        Rate_Sheet__c rateSheet = new Rate_Sheet__c(name='Allstate',Type__c='Reporter');
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
        Firm__c firmrec=new Firm__c(name='abcd');
        insert firmrec;
        Firm__c firmrec2=new Firm__c(name='abcd2');
        insert firmrec2;
        Deposition__c deposition = TestUtility.createDeposition(account.id);
        deposition.Event_Location__c= 'His Prison Cell Folsom, CA 94123';
        deposition.Corporate_Client_Source__c = 'Allstate';
        deposition.Deposition_Group__c = depositionGroup.Id;
        deposition.Primary_Court_Reporting_Firm__c=firmrec.id;
        insert deposition;
        
        Deposition__c deposition2 = TestUtility.createDeposition(account.id);
        deposition2.Event_Location__c= 'His Prison Cell Folsom, CA 94123';
        deposition2.Corporate_Client_Source__c = 'Allstate';
        deposition2.Deposition_Group__c = depositionGroup.Id;
        deposition2.Primary_Court_Reporting_Firm__c=firmrec2.id;
        insert deposition2;
        
        Item__c itemrec=new Item__c(Type__c='Transcript');
        insert itemrec;
        Invoice__c invoiceRec=new Invoice__c(Deposition__c=deposition.id, Deponent_Name__c='testall');
        insert invoiceRec;
        Invoice__c invoiceRec2=new Invoice__c(Deposition__c=deposition2.id, Deponent_Name__c='testall2');
        insert invoiceRec2;
       	string nextId= ListClass.goNext(invoiceRec.Id);
        ListClass.goNext(nextId);
       	string prevId=ListClass.goPrev(invoiceRec.Id);
            }

    
    
}