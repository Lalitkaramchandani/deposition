public class CreatePaymentExtension {
    public Payment__c payment;
    public Payment__c payment2{get;set;}
    private ApexPages.StandardController stdCtrl;
    public boolean extraPayment{get;set;}
    public String selectedOption {get;set;}
    public String errorMsg {get;set;}
    public decimal extraAmount{get;set;}
    public decimal dueAmount{get;set;}
    public boolean payment2Invoice{get;set;}
    public String afterDueDateMsg {get;set;}
    
    
    public CreatePaymentExtension(ApexPages.StandardController stdController) {
        this.payment = (Payment__c)stdController.getRecord();
        stdCtrl=stdController;
        extraAmount=0;
        afterDueDateMsg='';
    }
    
    public List<SelectOption> getOptionsToShow() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('option1','Edit the payment'));
        options.add(new SelectOption('option2','Add this overpayment as a finance charge'));
        options.add(new SelectOption('option3','Apply the credit to another invoice'));
        
        return options;
    }
    
    public pagereference Save2(){
        List<Invoice__c> lst= [select id,Due_Amount__c,After_Due_Date_Invoice_Amount__c from  Invoice__c where id=:payment.Invoice__c ];
        if(lst.size()>0 && payment.Amount__c!=null && payment.Amount__c!=0 && lst[0].Due_Amount__c<payment.Amount__c  ){
            extraPayment=true; 
            extraAmount=payment.Amount__c-lst[0].Due_Amount__c;
            dueAmount=lst[0].Due_Amount__c;
            
            if(payment.Amount__c==lst[0].After_Due_Date_Invoice_Amount__c){
                afterDueDateMsg='This matches the amount of the late payment penalty on the invoice.';
            }else{
                afterDueDateMsg='This does not match the amount of the late payment penalty on the invoice. The late payment amount on this invoice is '+ lst[0].After_Due_Date_Invoice_Amount__c;
            }
            return null;
        }else{
            return stdCtrl.save();
            
        }
        
    }
    
    public pagereference confirm(){
        system.debug('selectedOption::'+selectedOption);
        payment2Invoice=false;
        if(string.isBlank(selectedOption)){
            errorMsg='please select at least one option.';
        }else{
            errorMsg='';
            afterDueDateMsg='';
            if(selectedOption=='option1'){
                extraPayment=false;
                return null;
            }else if(selectedOption=='option2'){
                payment__c p1=new payment__c(Amount__c=extraAmount, Invoice__c=payment.Invoice__c, 
                                             Date__c=system.today(), Type__c='Finance Charge', Payment_Type__c=payment.Payment_Type__c);
                insert p1;
                payment.Amount__c=dueAmount;
                return stdCtrl.save();                
            }else if(selectedOption=='option3'){
                payment2=new payment__c(Amount__c=extraAmount,  
                                             Date__c=system.today(),Payment_Type__c=payment.Payment_Type__c);
                payment.Amount__c=dueAmount;
                payment2Invoice=true;
                return null;
            }
        }
		return null;        
    }
    
    public pagereference confirm2(){
        insert payment2;
        return stdCtrl.save();  
    }
}