public class InvoiceNotification_ext {
	public Invoice__c inv; 
    public InvoiceNotification_ext(ApexPages.StandardController controller){
        Id invId = controller.getId();
        inv = new Invoice__c(Id = invId);
    }
    
    public void resetCloneFlag(){
        inv.Clone__c = false;
        update inv;
    }
}