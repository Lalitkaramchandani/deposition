public class DepositionInvoiceCtrl {
    
    public Boolean isValidEntry{get;set;}
    public Deposition__c depositionRec{get;set;}
    public Firm__c firm{get;set;}
    private User usr;
    private String deposId;
    private String invId;
    
    public class InvoiceData{
        public Invoice__c inv{get;set;}
        public List<Invoice_Item__c> invItems{get;set;}
        public InvoiceData(Invoice__c inv){
            this.inv = inv;
            invItems = new List<Invoice_Item__c>();
        }
    }
    public DepositionInvoiceCtrl(ApexPages.StandardController controller) {
        init();
    }
    
    private void init(){
        usr = [SELECT Id, ContactId, Contact.Account.COD_Warning__c, Contact.Email From User WHERE ID =:Userinfo.getUserId()];
        if(usr.ContactId==null){
            isValidEntry= false;
        }
        deposId = ApexPages.currentPage().getParameters().get('id');
        invId = ApexPages.currentPage().getParameters().get('invid');
        if(String.isEmpty(deposId) || String.isEmpty(invId)){
            return;
        }
        firm = DepositionHelper.fetchFirm( 'Lexitas' );
        depositionRec=getDeposition(deposId);
        if(depositionRec!=null && depositionRec.Primary_Court_Reporting_Firm__c!=null){
            firm = [SELECT Id, Name, Community_Header__c,Community_Footer__c, Web_Page_Footer_HTML__c , Web_Page_Header_HTML__c,
                    Scheduling_Email_Address__c, Phone__c
                    FROM Firm__c 
                    WHERE Id=: depositionRec.Primary_Court_Reporting_Firm__c  LIMIT 1];
            
            Cookie Cookie= new Cookie('firmCookie', null,null,0,false);
            ApexPages.currentPage().setCookies(new Cookie[]{Cookie});
            Cookie= new Cookie('firmCookie', firm.Name,null,-1,false);
            ApexPages.currentPage().setCookies(new Cookie[]{Cookie});
        }
        isValidEntry = true;
    }
    
    private Deposition__c getDeposition(Id did){
        List<Deposition__c> depositions=new List<Deposition__c>();
        depositions=[Select id, Name,Firm_Name__c, Expedite__c ,Deponent_Name__c,Deposition_Services__c, Deposition_Date__c ,
                    Event_Type_Lowercase__c,Primary_Court_Reporting_Firm__c,
                    Transcript_page_count__c, Exhibit_page_count__c, Errata_Notes__c, Errata_Needed__c,Portal_Deposition_Services__c,
                    State_Rule__c, State_Rule__r.Read_and_Sign_Required__c, Start_Time__c, Stop_Time__c, Starts_Time__c,Ends_Time__c
                    from Deposition__c where id=:did];
        if(depositions!=null && depositions.size()>0){
            return depositions[0];
        }else{
            return null;
        }
    }
    public List<Invoice__c> getInvoices(){
        if(usr.ContactId==null){
            return new List<Invoice__c> ();
        }
        String query = 'SELECT Id, Name, Deposition__c, Account__c, Payment_Status__c'
                    +', Contact__c, Contact__r.Name,Contact__r.Payment_Method__c, Contact__r.ADP_ID__c '
                    +', Deposition__r.Name, Deposition__r.Deposition_Date__c, Invoice_Date__c, Due_Amount__c  '
                    +', Deposition__r.Primary_Court_Reporting_Firm__r.Name'
                    +', Attendee__c,Attendee__r.Role__c'
                    +', (SELECT Id, Item__c, Item__r.Name, Invoice_Text__c, Quantity__c, Price__c, Units_of_Measure__c FROM Invoice_Items__r)'
                    +' FROM Invoice__c '
                    +' WHERE Deposition__c=: deposId AND Contact__c =\''+usr.ContactId +'\''
                    +' AND Id=:invId'
                    +' ORDER BY Invoice_Date__c desc';
        return Database.query(query);
    }
    public InvoiceData getInvoiceData(){
        if(usr.ContactId==null){
            isValidEntry = false;
            return null;
        }
        
        String query = 'SELECT Id, Name, Deposition__c, Account__c, Payment_Status__c'
                    +', Contact__c, Contact__r.Name,Contact__r.Payment_Method__c, Contact__r.ADP_ID__c '
                    +', Deposition__r.Name, Deposition__r.Deposition_Date__c, Invoice_Date__c, Due_Amount__c  '
                    +', Deposition__r.Primary_Court_Reporting_Firm__r.Name'
                    +', Attendee__c,Attendee__r.Role__c'
                    +', (SELECT Id, Item__c, Item__r.Name, Total_Price__c, Modification__c, Invoice_Text__c, Quantity__c, Price__c, Units_of_Measure__c FROM Invoice_Items__r)'
                    +' FROM Invoice__c '
                    +' WHERE Deposition__c=: deposId AND Contact__c =\''+usr.ContactId +'\''
                    +' AND Id=:invId'
                    +' ORDER BY Invoice_Date__c desc';
        List<Invoice__c> invs = Database.query(query);
        if(!invs.isEmpty()){
            InvoiceData inv = new InvoiceData(invs[0]);
            if(!invs[0].Invoice_Items__r.isEmpty()){
                inv.invItems = invs[0].Invoice_Items__r;
            }
            return inv;
        }
        isValidEntry = false;
        return null;
    }
}