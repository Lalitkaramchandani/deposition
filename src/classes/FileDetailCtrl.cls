public class FileDetailCtrl {
    
    ApexPages.StandardController controller ;
    public Firm__c firm{get;set;}
    public FileDetailCtrl(ApexPages.StandardController controller) {
        this.controller  = controller ;
        
        Cookie firmCookie = ApexPages.currentPage().getCookies().get('firmCookie');
        
        String firmName = 'Lexitas';
        if(firmCookie != null)
            firmName = firmCookie.getValue(); 
        firm = DepositionHelper.fetchFirm(firmName );
    }
    
}