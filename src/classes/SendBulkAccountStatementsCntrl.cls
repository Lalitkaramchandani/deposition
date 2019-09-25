global class SendBulkAccountStatementsCntrl {
    public Transient List<AccountModel>lstAccounts{get;set;}
    public List<SelectOption>lstFirms{get;set;}
    public String selectedFirm{get;set;}
    
    public Account accnt{get;set;}
    public SendBulkAccountStatementsCntrl(){
        lstFirms = new List<SelectOption>();
        
        accnt = new Account(End_Date__c=System.today().addDays((System.today().day()*-1)));
        for(Firm__c firm: [select id,Name
                                 FROM Firm__c ]){
            lstFirms.add(new SelectOption(firm.id,firm.Name));
            if(firm.Name =='Lexitas')
                selectedFirm = firm.id;
        }
        set<String>setAccountIds = new Set<String>() ;
        string AggregateQuery = 'Select count(id), Account__c accId From Invoice__c WHERE Account__c != NULL AND '+
                        'Due_Amount__c>0 AND Type__c=\'Client\' AND Status__c=\'Valid\' AND Payment_Status__c!=\'Paid\' AND Account__r.Accounting_Email_Address__c != NULL AND '+ 
                        'Account__r.Accounting_Email_Address__c != \'\' AND '+ 
                        'Account__r.Exclude_from_Bulk_Statements__c =false GROUP BY Account__c';
         
        
        for(AggregateResult result : Database.Query(AggregateQuery )){
            String accId = (String)result.get('accId');
            setAccountIds.add(accId);
        }
        lstAccounts = new List<AccountModel>();
        for(Account accnt: [select Id,Name,Last_Statement_Sent__c,Accounting_Email_Address__c,(Select Id, Due_Amount__c From Invoices__r 
                        WHERE  Due_Amount__c>0 AND Type__c='Client' AND Status__c='Valid' AND Payment_Status__c!='Paid' ) From Account WHERE ID IN : setAccountIds ]){
            lstAccounts.add(new AccountModel(accnt));
        }
        
    }
    @RemoteAction
    global static String updateAccounts(String accountIds,String firmId,String startDate,String endDate) {
        String queryStr = '';
        List<String>lstAccountIds = accountIds.split(',');
        
        queryStr +='SELECT Id,(select Id,Due_Amount__c,Days_Past_Due_Bucket__c FROM Invoices__r '+
                   '                 WHERE Type__c=\'Client\' AND  Due_Amount__c >=0 AND Status__c=\'Valid\' AND Payment_Status__c!=\'Paid\'';
        
        Date startDateForInvoice ; 
        Date endDateForInvoice;         
        if(startDate != NULL && startDate!= '' ){
            startDateForInvoice = date.parse(startDate);
            queryStr +=' AND Invoice_Date__c >=:startDateForInvoice ';
        }               
        
        if(endDate!= NULL && endDate!=''){
            endDateForInvoice = date.parse(endDate);
            queryStr +=' AND Invoice_Date__c <=:endDateForInvoice  ';  
        
        }
        queryStr +='    )             FROM Account WHERE ID IN:lstAccountIds';                         
        List<account>lstAccounts = Database.Query(queryStr);
        String selectedAccIds = '';
        for(Account accnt: lstAccounts){
            accnt.X0_30__c = 0;
            accnt.X30_60__c= 0;
            accnt.X60_90__c= 0;
            accnt.X90_120__c= 0;
            accnt.X120_150__c = 0;
            accnt.X150_180__c= 0;
            accnt.Over_180__c= 0;
            accnt.Start_Date__c = startDateForInvoice ;
            accnt.End_Date__c = endDateForInvoice ;
            accnt.Selected_Firm_Id__c = firmId;
            for(Invoice__c invoice:accnt.Invoices__r){
                if(invoice.Days_Past_Due_Bucket__c == '0-30')
                    accnt.X0_30__c += invoice.Due_Amount__c;
                else if(invoice.Days_Past_Due_Bucket__c == '30-60')
                    accnt.X30_60__c+= invoice.Due_Amount__c;
                else if(invoice.Days_Past_Due_Bucket__c == '60-90')
                    accnt.X60_90__c+= invoice.Due_Amount__c;
                else if(invoice.Days_Past_Due_Bucket__c == '90-120')
                    accnt.X90_120__c+= invoice.Due_Amount__c;
                else if(invoice.Days_Past_Due_Bucket__c == '120-150')
                    accnt.X120_150__c += invoice.Due_Amount__c;
                else if(invoice.Days_Past_Due_Bucket__c == '150-180')
                    accnt.X150_180__c+= invoice.Due_Amount__c;
                else if(invoice.Days_Past_Due_Bucket__c == 'Over 180')
                    accnt.Over_180__c+= invoice.Due_Amount__c;
                
            }
            if(accnt.X0_30__c != 0 || accnt.X30_60__c!= 0 || accnt.X60_90__c!= 0 || accnt.X90_120__c!= 0 || accnt.X120_150__c != 0 
              || accnt.X150_180__c!= 0 || accnt.Over_180__c!= 0){
                selectedAccIds  += accnt.Id+',';
            }
                
                
        }
        selectedAccIds= selectedAccIds.removeEnd(',');

        if(lstAccounts.size()>0){
            try{
                
                update lstAccounts;
             }Catch(Exception e){
                 return 'Error:'+e.getMessage();
            }
        }
        return selectedAccIds  ;
    }
    public Class AccountModel{
        public Transient Account accnt{get;set;}
        public Transient Decimal dueAmount{get;set;}
        public Transient String accountingEmailAddress{get;set;}
        public AccountModel(Account accnt){
            this.Accnt = accnt;
            dueAmount = 0;
            accountingEmailAddress = '';
            for(Invoice__c inv : accnt.Invoices__r){
                dueAmount += inv.Due_Amount__c;
                
            }
        }
    }
}