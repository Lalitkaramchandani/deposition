@isTest
private class DepositionInvoiceCtrlTest {

	private static testMethod void testInvoices() {
        TestFactory tFact = new TestFactory();
        List<Invoice__c> invoices = tFact.invoices;
        
        System.runAs(tFact.communtiyUser){
            User usr = [SELECT Id, ContactId FROM User Where Id = :UserInfo.getUserId() LIMIT 1];
            Invoice__c inv =[Select Id, Deposition__c FROM Invoice__c WHERE Contact__c =:usr.ContactId LIMIT 1];
            ApexPages.currentPage().getParameters().put('id',inv.Deposition__c);
            ApexPages.currentPage().getParameters().put('invid',inv.Id);
            DepositionInvoiceCtrl control = new DepositionInvoiceCtrl(new ApexPages.StandardController(new Deposition__c(Id = inv.Deposition__c)));
            control.getInvoices();
            control.getInvoiceData();
        }
	}

}