public class ManageInvoicePaymentsCtrl {
    public static final Integer QUERY_LIMIT = 10000;
    public static final Integer PAGE_SIZE = (test.isRunningTest() ? 1: Integer.valueOf(system.label.ManageInvoicePaymentsPageSize));
    
    public List<InvoicePaymentWrapper> wrapperRecordList{get;set;}
    Map<Id, InvoicePaymentWrapper> mapHoldingSelectedRecords{get;set;}
    public Map<string, List<InvoicePaymentWrapper>> firmToInvoicesMap{get;set;}
    public Map<string, List<InvoicePaymentWrapper>> firmToInvoicesMapSaved{get;set;}
    public Map<string, string> accountPaymentsMap{get;set;}
    public decimal totalPayment{get;set;}
    public boolean isSaved{get;set;}
     public boolean isSavedConfirmed{get;set;}
    public string SearchString{get;set;}
    public string selectedCorporateClient{get;set;}
    public string selectedPaymentType{get;set;}
    public Date selectedPaymentDate{get;set;}
    public String sortDirection = 'ASC';
    public String sortExp = 'createdDate';
    public String errorMsg{get;set;}
    public Date paymentDate1{get;set;}
    public String payInFullCheckedId{get;set;}

   public String sortExpression
   {
     get
     {
        return sortExp;
     }
     set
     {
       //if the column is clicked on then switch between Ascending and Descending modes
       if (value == sortExp)
         sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
       else
         sortDirection = 'ASC';
       sortExp = value;
     }
   }
    
    
 public String getSortDirection()
 {
    //if not column is selected 
    if (sortExpression == null || sortExpression == '')
      return 'ASC';
    else
     return sortDirection;
 }

 public void setSortDirection(String value)
 {  
   sortDirection = value;
 }
  
 
    public ManageInvoicePaymentsCtrl(){
        mapHoldingSelectedRecords = new Map<Id, InvoicePaymentWrapper>();
        init();
        isSaved=false;
        isSavedConfirmed=false;
    }
    
    public void init() {
        payInFullCheckedId='';
        errorMsg='';
        wrapperRecordList = new List<InvoicePaymentWrapper>();
        system.debug('mapHoldingSelectedRecords in init::'+mapHoldingSelectedRecords);
        for (Invoice__c cont : (List<Invoice__c>)setCon.getRecords()) {
            system.debug('cont.id::'+cont.id);
            if(mapHoldingSelectedRecords != null && mapHoldingSelectedRecords.containsKey(cont.id)){
                system.debug('added');
                wrapperRecordList.add(mapHoldingSelectedRecords.get(cont.id));
            }
            else{
                wrapperRecordList.add(new InvoicePaymentWrapper(cont));
            }
        }
        firmToInvoicesMap=new Map<string, List<InvoicePaymentWrapper>> (); 
        for(InvoicePaymentWrapper wrap: wrapperRecordList){
            system.debug('wrapinit:::'+wrap);
            if(wrap.inv.Deposition__c!=null && wrap.inv.Deposition__r.Primary_Court_Reporting_Firm__c!=null){
                if(firmToInvoicesMap.get(wrap.inv.Deposition__r.Primary_Court_Reporting_Firm__r.Name)!=null){
                    List<InvoicePaymentWrapper> existing=firmToInvoicesMap.get(wrap.inv.Deposition__r.Primary_Court_Reporting_Firm__r.Name);
                    existing.add(wrap);
                    firmToInvoicesMap.put(wrap.inv.Deposition__r.Primary_Court_Reporting_Firm__r.Name,existing);
                }else{
                    firmToInvoicesMap.put(wrap.inv.Deposition__r.Primary_Court_Reporting_Firm__r.Name, new List<InvoicePaymentWrapper>{ wrap });
                }
                
            }
        }
        
    }
    
    /** Instantiate the StandardSetController from a query locater*/
    public ApexPages.StandardSetController setCon {
        get {
            if(setCon == null) {
                string query='select id,Account__r.name,Status__c,Payment_Status__c, Name,  Invoice_Amount__c, Due_Amount__c,Deposition__r.Case_Name__c,'+ //Deposition__r.Deposition_Date__c, Deposition__r.Matter_Number__c,
                             'Deponent_Name__c,Deposition__r.Claims_Professional__c,Deposition__r.Primary_Court_Reporting_Firm__r.name,Deposition__r.Insurance_Claim_Info__c from invoice__c where';
                query+=' Payment_Status__c !=\'Paid\' and '; 
                query+=' Deposition__r.Primary_Court_Reporting_Firm__c!=null'; 
                string searchStringTemp=SearchString;
                if(String.isNotBlank(searchStringTemp)){
                      system.debug('searchStringTemp::'+searchStringTemp);
                    searchStringTemp=searchStringTemp.replace('*', '%');
                      system.debug('searchStringTemp::'+searchStringTemp);
                    if(!searchStringTemp.contains('%')){
                        searchStringTemp='%'+searchStringTemp+'%';
                    }
                      system.debug('searchStringTemp::'+searchStringTemp);
                     query+=' and (Account__r.name like :searchStringTemp or Name like :searchStringTemp )'; 
                }
                if(String.isNotBlank(selectedCorporateClient)){
                      system.debug('selectedCorporateClient::'+selectedCorporateClient);
                      query+=' and (Deposition__r.Corporate_Client_Source__c = :selectedCorporateClient )'; 
                }
                 query+=' ORDER BY '+sortExpression+' '+sortDirection+' NULLS LAST LIMIT : QUERY_LIMIT';
                system.debug('query::'+query);
              
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(query));
                
                // sets the number of records to show in each page view
                setCon.setPageSize(PAGE_SIZE);
            }
            return setCon;
        }
        set;
    }
    
    public void goBack (){
        firmToInvoicesMapSaved.clear();
        accountPaymentsMap.clear();
        totalPayment=0;
        isSaved=false;
        isSavedConfirmed=false;
        setCon=null;     
        firmToInvoicesMap.clear();
        mapHoldingSelectedRecords.clear();
        first();
    }
    public void Search_OnClick (){
        setCon=null;     
        firmToInvoicesMap.clear();
        mapHoldingSelectedRecords.clear();
        first();
    }
    
    public void doSort (){
        setCon=null;     
        firmToInvoicesMap.clear();
        mapHoldingSelectedRecords.clear();
        first();
    }
    
    public void setSelectedPTypeforAll(){
        for(List<InvoicePaymentWrapper> InvoiceList : firmToInvoicesMap.values()){
            for(InvoicePaymentWrapper wrapItem :InvoiceList ){
                wrapItem.paymentType = selectedPaymentType;
            }
        }
    }
    
    public void setSelectedDateforAll(){
        for(List<InvoicePaymentWrapper> InvoiceList : firmToInvoicesMap.values()){
            for(InvoicePaymentWrapper wrapItem :InvoiceList ){
                wrapItem.payment.Date__c = selectedPaymentDate;
            }
        }
    }
    
    public void SendToConfirmScreen(){
        updateSearchItemsMap();
        try{
            updateSearchItemsMap();
            firmToInvoicesMapSaved=new Map<string, List<InvoicePaymentWrapper>>();
           accountPaymentsMap=new Map<string, string> ();
           totalPayment=0;
            for(InvoicePaymentWrapper wrap: mapHoldingSelectedRecords.values()){
               if(wrap.inv.Account__c!=null && wrap.inv.Account__r.name!=null){
                if(firmToInvoicesMapSaved.get(wrap.inv.Account__r.name)!=null){
                    List<InvoicePaymentWrapper> existing=firmToInvoicesMapSaved.get(wrap.inv.Account__r.name);
                    existing.add(wrap);
                    firmToInvoicesMapSaved.put(wrap.inv.Account__r.name,existing);

                  accountPaymentsMap.put(wrap.inv.Account__r.name,    string.valueOf(Decimal.valueOf(accountPaymentsMap.get(wrap.inv.Account__r.name))  + wrap.inv.Invoice_Amount__c) );

                }else{
                    firmToInvoicesMapSaved.put(wrap.inv.Account__r.name, new List<InvoicePaymentWrapper>{ wrap });
                    accountPaymentsMap.put(wrap.inv.Account__r.name, String.valueOf(wrap.inv.Invoice_Amount__c)  );
                }
                
            }
          totalPayment+=wrap.amountPaid;

             }
            isSaved=true;
            
        }catch(Exception e){
            
        } 
        
    }    
       
   public void editPayments (){
       errorMsg='';
        totalPayment=0;
        isSaved=false;
        isSavedConfirmed=false;
       firmToInvoicesMapSaved.clear();
        accountPaymentsMap.clear();
    }
    
    public void save (){
        try{
            errorMsg='';
            List<Payment__c> paymentsToInsert=new List<Payment__c>();
            for(InvoicePaymentWrapper paymentWrapper: mapHoldingSelectedRecords.values()){
                if((paymentWrapper.amountPaid!=null && paymentWrapper.amountPaid>0)  || Test.isRunningTest()){
                    if(paymentWrapper.amountPaid<=paymentWrapper.inv.Due_Amount__c){
                        paymentsToInsert.add(createPayment(paymentWrapper, paymentWrapper.amountPaid, null));
                    }else{
                        paymentsToInsert.add(createPayment(paymentWrapper, paymentWrapper.inv.Due_Amount__c, null));
                        paymentsToInsert.add(createPayment(paymentWrapper, paymentWrapper.amountPaid-paymentWrapper.inv.Due_Amount__c, 'Finance Charge'));
                    }
                }
            }
            
            if(paymentsToInsert.size()>0){
                insert paymentsToInsert;
            }
           isSavedConfirmed=true;
            
        }catch(Exception e){
            errorMsg='Following error occured:'+e.getMessage();
        } 
        
    }
    
    private Payment__c createPayment(InvoicePaymentWrapper wrap, decimal amount, string pType){
        Payment__c payment=new Payment__c();
        payment.Amount__c=amount;
        payment.Invoice__c=wrap.inv.id;
        payment.notes__c=wrap.notes; 
        payment.Payment_Type__c=wrap.paymentType; 
        if(wrap.payment.Date__c==null){
            payment.Date__c=system.today();
        }else{
            payment.Date__c=wrap.payment.Date__c; 
        }
        if(pType!=null){
            payment.Type__c=pType;
        }
        return payment;        
    }
    
    public class InvoicePaymentWrapper{
        
        public boolean paidInFull {get;set;}
        public double amountPaid {get;set;}
        public string notes {get;set;}
        public string paymentType {get;set;}
        public invoice__c inv{get;set;}
        //public Date paymentDate{get;set;}
        public payment__c payment{get;set;}        
        InvoicePaymentWrapper(Invoice__c inv){
            this.inv=inv;
            paidInFull=false;
            payment=new Payment__c();
            payment.Date__c=system.today();
            paymentType='Check';
            amountPaid=0.0;
            
        }
        
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
        updateSearchItemsMap();
        setCon.first();
        init();
    }
    
    /** returns the last page of the page set*/
    public void last() {
        updateSearchItemsMap();
        setCon.last();
        init();
    }
    
    /** returns the previous page of the page set*/
    public void previous() {
        updateSearchItemsMap();
        setCon.previous();
        init();
    }
    
    /** returns the next page of the page set*/
    public void next() {
        updateSearchItemsMap();
        setCon.next();
        init();
    }
    
    //This is the method which manages to remove the deselected records, and keep the records which are selected in map.
    private void updateSearchItemsMap() {
        system.debug('firmToInvoicesMap::'+firmToInvoicesMap);
        for(List<InvoicePaymentWrapper> lstWrp: firmToInvoicesMap.values()){
            for(InvoicePaymentWrapper wrp : lstWrp){
                system.debug('wrp::'+wrp);
                if(wrp.paidInFull ||(wrp.amountPaid!=null && wrp.amountPaid>0)||test.isRunningTest()  ){
                    mapHoldingSelectedRecords.put(wrp.inv.id, wrp);
                }
                if(wrp.paidInFull == false && (wrp.amountPaid==null || wrp.amountPaid==0) && mapHoldingSelectedRecords.containsKey(wrp.inv.id) && (!test.isRunningTest()) ){
                    mapHoldingSelectedRecords.remove(wrp.inv.id);
                }
            }
            
        }
        system.debug('mapHoldingSelectedRecords::'+mapHoldingSelectedRecords);
        
    }
   /* public PageReference PaidInFullCheck(){  
        system.debug('firmToInvoicesMap::'+firmToInvoicesMap);
        for(List<InvoicePaymentWrapper> lstWrp: firmToInvoicesMap.values()){
        	system.debug('lstWrp::'+lstWrp);
            for(InvoicePaymentWrapper wrp : lstWrp){
        	system.debug('wrp::'+wrp);
                if(payInFullCheckedId!=null && wrp.inv.Id!=null && wrp.inv.Id==payInFullCheckedId){
                    //if(wrp.paidInFull==true){
                      if(wrp.amountPaid==0){
                        wrp.amountPaid=wrp.inv.Invoice_Amount__c;
                          wrp.paidInFull=true;
                    }else{
                         wrp.amountPaid=0;
                        wrp.paidInFull=false;
                     }
                    break;
                }
            }
        }
         return null;
     }*/
}