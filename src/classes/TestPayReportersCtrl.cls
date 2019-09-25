@isTest
public class TestPayReportersCtrl {
@isTest
    private static void TestPayReporters() {
    
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
        Invoice__c invoiceRec=new Invoice__c(account__c=account.id, Deposition__c=deposition.id, Deponent_Name__c='testall', Type__c='Reporter', Status__c='Valid');
        insert invoiceRec;
        Invoice__c invoiceRec2=new Invoice__c(account__c=account.id,Deposition__c=deposition2.id, Deponent_Name__c='testall2');
        insert invoiceRec2;
        
        
        Invoice_Item__c invItem=new Invoice_Item__c(Item__c=itemrec.id,Invoice__c=invoiceRec.id, Price__c=10, Quantity__c=3);
        insert invItem;
        Invoice_Item__c invItem2=new Invoice_Item__c(Item__c=itemrec.id,Invoice__c=invoiceRec2.id, Price__c=10, Quantity__c=3);
        insert invItem2;

        PayReportersCtrl ctrl=new PayReportersCtrl();
        ctrl.save();
        ctrl.editPayments();
         ctrl.goBack();
         ctrl.save2();
         ctrl.goBack();
        ctrl.BuildQuery();
    }
}