public class UploadFilesThanksExtn {
    public Firm__c firm{get;set;}
    public UploadFilesThanksExtn(ApexPages.StandardController controller) {
       
       firm = DepositionHelper.fetchFirm(ApexPages.currentPage().getParameters().get('firm'));
       
    }

}