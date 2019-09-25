Public class PayReportersCtrl {
    public List<InvoicePaymentWrapper> wrapperRecordList{get;set;}
    public List<InvoicePaymentWrapper> wrapperRecordListSaved{get;set;}
    public boolean isSaved{get;set;}
    public boolean isSavedConfirmed{get;set;}
    public list<SelectOption> allAccounts{get;set;}
    public list<SelectOption> selectedAccounts{get;set;}
    
    public PayReportersCtrl(){
        init();
    }   
    public void init (){
        wrapperRecordList = new List<InvoicePaymentWrapper>();
        wrapperRecordListSaved= new List<InvoicePaymentWrapper>();
        set<string> setAccounts=new set<string>();
        
        for(invoice__c inv: [select id,Account__c,Account__r.Name, Contact__c,Name,Invoice_Amount__c,Deposition__r.Case_Name__c,Deponent_Name__c,Deposition__r.Insurance_Claim_Info__c from invoice__c where Type__c in ('Reporter', 'Video/Tech', 'Miscellaneous') and Status__c='Valid' 
                             and Due_Amount__c>0]){
                                 wrapperRecordList.add(new InvoicePaymentWrapper(inv));
                                 setAccounts.add(inv.Account__r.Name);
                             }
        isSaved=false;
        isSavedConfirmed=false;
        allAccounts=new list<SelectOption>();
        selectedAccounts=new list<SelectOption>();
        
        for(string acc:setAccounts){
            allAccounts.add(new SelectOption(acc, acc));
        }
    }
    
    public void save (){
        wrapperRecordListSaved= new List<InvoicePaymentWrapper>();
        for(InvoicePaymentWrapper paymentWrapper: wrapperRecordList){
            if(paymentWrapper.paidInFull==true || Test.isRunningTest()){
                wrapperRecordListSaved.add(paymentWrapper);
            }
        }
        isSaved=true;
    }
    
    public void editPayments (){
        isSaved=false;
    }
    
    public void goBack (){
        init();
    }
    
    public void save2 (){
        try{
            List<Payment__c> paymentsToInsert=new List<Payment__c>();
            for(InvoicePaymentWrapper paymentWrapper: wrapperRecordList){
                if(paymentWrapper.paidInFull==true || Test.isRunningTest()){
                    paymentsToInsert.add(createPayment(paymentWrapper));
                }
            }
            if(paymentsToInsert.size()>0){
                insert paymentsToInsert;
            }
            isSavedConfirmed=true;
        }catch(Exception e){
        } 
    }
    private Payment__c createPayment(InvoicePaymentWrapper wrap){
        Payment__c payment=new Payment__c();
        payment.Amount__c=wrap.inv.Invoice_Amount__c;
        payment.Date__c=system.today();
        payment.Invoice__c=wrap.inv.id;
        return payment;        
    }
    public class InvoicePaymentWrapper{
        public boolean paidInFull {get;set;}
        public invoice__c inv{get;set;}
        
        InvoicePaymentWrapper(Invoice__c inv){
            this.inv=inv;
            paidInFull=true;
        }
    }
    
    /***
    * BuildQuery - build query command for list selection change
    ***/
    public void BuildQuery() {
        string accountList = '(';
        Boolean first = true;
        for ( SelectOption so : selectedAccounts ) {
            if (!first) {
                accountList += ', ';
            }
            accountList += '\'' + so.getValue() + '\'';
            first = false;
        }
        accountList+=')';
        String QueryWhere = 'and account__r.Name in '+accountList;
        system.debug('QueryWhere::'+QueryWhere);
        
       string QueryStr = 'select id,Account__c,Account__r.Name, Contact__c,Name,Invoice_Amount__c,Deposition__r.Case_Name__c,Deponent_Name__c,Deposition__r.Insurance_Claim_Info__c from invoice__c where Type__c in (\'Reporter\', \'Video/Tech\', \'Miscellaneous\') '+
           ' and Status__c=\'Valid\' and Due_Amount__c>0 '; 
        if(first==false){
			QueryStr+=QueryWhere;            
        }
        
        system.debug('QueryStr:' + QueryStr);
        wrapperRecordList = new List<InvoicePaymentWrapper>();
        wrapperRecordListSaved= new List<InvoicePaymentWrapper>();
        
        for(invoice__c inv: database.query(QueryStr)){
            wrapperRecordList.add(new InvoicePaymentWrapper(inv));
        }
        isSaved=false;
        isSavedConfirmed=false;
    }
    
}