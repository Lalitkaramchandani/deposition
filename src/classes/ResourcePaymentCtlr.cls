public class ResourcePaymentCtlr {
    public static final Integer QUERY_LIMIT = 10000;
    public static final Integer PAGE_SIZE = (test.isRunningTest() ? 1 : Integer.valueOf(System.label.ManageInvoicePaymentsPageSize));

    public Map<String, List<InvoicePaymentWrapper>> firmToInvoicesMap{get;set;}
    public List<InvoicePaymentWrapper> invoices{get;set;}
    public List<PaymentData> paymentData{get;set;}
    public List<Payment__c> payments{get;set;}
    public String startDate{get;set;}
    public String endDate{get;set;}
    
    public Boolean isPaymentDone{get;set;}
    
    public String sortExp = 'Invoice_Date__c';
    public String sortDirection{
        get{
            //if not column is selected 
            if (sortExpression == null || sortExpression == '')
                sortDirection = 'ASC';
            if( sortDirection == null)
                sortDirection = 'ASC';
            return sortDirection;
        }set;
    }
    public String sortExpression{
        get{
            return sortExp;
        }
        set{
            //if the column is clicked on then switch between Ascending and Descending modes
            if (value == sortExp)
                sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
            else
                sortDirection = 'ASC';
            sortExp = value;
        }
    }
    public String header{
        get{
            return 'Account Name,Invoice #,Deposition #,Contact Name,Date of Deposition,Amount,Unique identifier for this person,Role,Attendee Role,Conga Firm Name,Invoice date, Payment date, Payment Type';
        }set;
    }
    
    public class InvoicePaymentWrapper{
        public boolean isSelect {get;set;}
        public Invoice__c inv{get;set;}
        public InvoicePaymentWrapper(Invoice__c inv){
            isSelect=true;
            this.inv=inv;
        }
    }
    public class PaymentData{
        public String pdate{get;set;}
        public String invName{get;set;}
        public String pType{get;set;}
        public Invoice__c inv{get;set;}
        public PaymentData(String pdate, String invName, String pType, Invoice__c inv){
            this.pdate = pdate;
            this.invName = invName;
            this.pType = pType;
            this.inv = inv;
        }
    }
    
    public ResourcePaymentCtlr() {
        isPaymentDone = false;
        init();
    }
    
    public void init(){
        prepareRecord();
    }
    void prepareRecord(){
        invoices = new List<InvoicePaymentWrapper>();
        
        firmToInvoicesMap = new Map<String, List<InvoicePaymentWrapper>>();
        try{
            for (Invoice__c inv : (List<Invoice__c>)setCon.getRecords()){
                invoices.add(new InvoicePaymentWrapper(inv));
            }
        }catch(Exception excp){
            System.debug(excp.getStackTraceString());
        }
    }
    /** Instantiate the StandardSetController from a query locater*/
    ApexPages.StandardSetController setCon {
        get {
            if (setCon == null) {
                prepareSetCon();
            }
            return setCon;
        }
        set;
    }
    String addInvoiceDateFilter(String val, String op, Boolean isStart){
        String filter ='';
        if(String.isNotBlank(val)){
            List<String> dateParts = val.split('/');
            if(dateParts.size() == 3){
                // 4/26/2019
                //2019-4-26
                Integer day = Integer.valueOf(dateParts[1]);
                Integer mon = Integer.valueOf(dateParts[0]);
                Integer year = Integer.valueOf(dateParts[2]);
                filter+=' AND Invoice_Date__c'+op+year+'-'+(mon<10 ? '0':'')+mon+'-'+ (day<10 ? '0':'')+day;

                if(isStart){
                    InvoiceEmailNotificationQueueable.MIN_DATE = Date.newInstance(year,mon,day);
                }else{
                    InvoiceEmailNotificationQueueable.MAX_DATE = Date.newInstance(year,mon,day);
                }
            }
        }
        return filter;
    }
    void prepareSetCon(){
        String query = 'SELECT Id, Name, Deposition__c, Account__c,Conga_Firm_Name__c,Attendee_Role__c'
                    +', Contact__c, Contact__r.Name,Contact__r.Payment_Method__c, Contact__r.ADP_ID__c,Contact__r.Account.Name '
                    +', Deposition__r.Name, Deposition__r.Deposition_Date__c, Invoice_Date__c, Due_Amount__c  '
                    +', Deposition__r.Primary_Court_Reporting_Firm__r.Name'
                    +', Attendee__c,Attendee__r.Role__c'
                    +' FROM Invoice__c ';
        
        query+=' WHERE Type__c!=\'Client\' AND Payment_Status__c !=\'Paid\' AND Status__c=\'Valid\' AND Deposition__c != NULL'
            +' AND Deposition__r.Primary_Court_Reporting_Firm__c!=null ';
        System.debug(startDate);
        System.debug(endDate);
        InvoiceEmailNotificationQueueable.MIN_DATE = null;
        query += addInvoiceDateFilter(startDate, '>=', true);
        InvoiceEmailNotificationQueueable.MAX_DATE = null;
        query += addInvoiceDateFilter(endDate, '<=', false);
        query += ' ORDER BY ' + sortExpression + ' ' + sortDirection + ' NULLS LAST';
        query +=' LIMIT : QUERY_LIMIT';
        system.debug('query::' + query);
        
        setCon = new ApexPages.StandardSetController(Database.getQueryLocator(query));

        setCon.setPageSize(PAGE_SIZE);
    }
    
    /** indicates whether there are more records after the current page set.*/
    public Boolean hasNext {
        get {
            return setCon.getHasNext();
        }
        set;
    }
    
    /** indicates whether there are more records before the current page set.*/
    public Boolean hasPrevious {
        get {
            return setCon.getHasPrevious();
        }
        set;
    }
    
    /** returns the page number of the current page set*/
    public Integer pageNumber {
        get {
            return setCon.getPageNumber();
        }
        set;
    }
    
    /** return total number of pages for page set*/
    Public Integer getTotalPages(){
        Decimal totalSize = setCon.getResultSize();
        Decimal pageSize = setCon.getPageSize();
        Decimal pages = totalSize/pageSize;
        return (Integer)pages.round(System.RoundingMode.CEILING);
    }
    
    /** returns the first page of the page set*/
    public void first() {
        setCon.first();
        init();
    }
    
    /** returns the last page of the page set*/
    public void last() {
        setCon.last();
        init();
    }
    
    /** returns the previous page of the page set*/
    public void previous() {
        setCon.previous();
        init();
    }
    
    /** returns the next page of the page set*/
    public void next() {
        setCon.next();
        init();
    }
    
    /*public void setSelectedDateforAll(){
        for(List<InvoicePaymentWrapper> InvoiceList : firmToInvoicesMap.values()){
            for(InvoicePaymentWrapper wrapItem :InvoiceList ){
                // wrapItem.payment.Date__c = selectedPaymentDate;
            }
        }
    }*/
    public void doSort (){
        prepareSetCon();
        first();
    }
    public void onSearch(){
        prepareSetCon();
        prepareRecord();
    }
    
    public void onPay(){
        Boolean isSelected = false;
        payments = new List<Payment__c>();
        paymentData = new List<PaymentData>();
        for(InvoicePaymentWrapper invData:invoices){
            if(invData.isSelect){
                isSelected = true;
                Payment__c pay = new Payment__c(Invoice__c = invData.inv.Id, Date__c = System.today(), Amount__c = invData.inv.Due_Amount__c,
                        Paid_in_Full__c = true, Payment_Type__c = invData.inv.Contact__r.Payment_Method__c);
                
                payments.add(pay);
                pay.Invoice__r = invData.inv;
                paymentData.add(new PaymentData(pay.Date__c.format(), invData.inv.Name, pay.Payment_Type__c, invData.inv));
            }
        }
        if(!isSelected){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Select at least one invoice to pay!'));
            return;
        }
        try{
            InvoiceEmailNotificationQueueable.MIN_DATE = null;
            addInvoiceDateFilter(startDate, '>=', true);
            InvoiceEmailNotificationQueueable.MAX_DATE = null;
            addInvoiceDateFilter(endDate, '<=', false);
            insert payments;
            isPaymentDone = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'payment Done!'));

        }catch(Exception excp){
            ApexPages.addMessages(excp);
        }
    }
    
    public PageReference onExport(){
        return new PageReference('/apex/ResourcePayment?isExport=true');
    }
}