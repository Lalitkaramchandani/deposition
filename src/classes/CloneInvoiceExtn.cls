public class CloneInvoiceExtn {
    ApexPages.StandardController sc;
    public CloneInvoiceExtn(ApexPages.StandardController controller) {
        sc = controller;
    }
    public PageReference cloneInvoiceRecord(){
        Savepoint mysavepointt = Database.setSavepoint();
        try{
            Sobject clonedRec = CloneHelper.cloneObject('Invoice__c', sc.getId(), 'Invoice__c', 'Invoice_Item__c');
            return new PageReference ('/'+clonedRec.id);
        }Catch(Exception e){
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Fatal,e.getMessage()));
             Database.rollback(mysavepointt);
             return null;
        }
    }
}