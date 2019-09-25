public class SelectFirmExtn {
    public List<SelectOption>lstFirms{get;set;}
    public String selectedFirm{get;set;}
    public Account accnt = new Account();
    public SelectFirmExtn(ApexPages.StandardController controller) {
        lstFirms = new List<SelectOption>();
        accnt = (account)controller.getRecord();
        //User usr = [select Default_CR_Firm__c FROM User WHERE Id=:Userinfo.getUserid()];
        for(Firm__c firm: [select id,Name
                                 FROM Firm__c ]){
            lstFirms.add(new SelectOption(firm.id,firm.Name));
            if(firm.Name =='Lexitas')
                selectedFirm = firm.id;
        }
    }
    public void updateAccountDueAmountsFromInvoice(){
        try{
            accnt.X0_30__c = 0;
            accnt.X30_60__c= 0;
            accnt.X60_90__c= 0;
            accnt.X90_120__c= 0;
            accnt.X120_150__c = 0;
            accnt.X150_180__c= 0;
            accnt.Over_180__c= 0;
            for(Invoice__c invoice:[select Id,Due_Amount__c,Days_Past_Due_Bucket__c FROM Invoice__c WHERE 
                                 Type__c='Client' AND  Account__c =:accnt.id AND Due_Amount__c >=0 AND Status__c='Valid'
                                 AND Payment_Status__c!='Paid']){
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
            update accnt;
        }Catch(Exception e){
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
        }
    }

}