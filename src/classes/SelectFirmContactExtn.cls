public class SelectFirmContactExtn {
    public List<SelectOption>lstFirms{get;set;}
    public String selectedFirm{get;set;}
    public Contact cont= new Contact();
    public SelectFirmContactExtn (ApexPages.StandardController controller) {
        lstFirms = new List<SelectOption>();
        cont= (Contact)controller.getRecord();
        //User usr = [select Default_CR_Firm__c FROM User WHERE Id=:Userinfo.getUserid()];
        for(Firm__c firm: [select id,Name
                                 FROM Firm__c ]){
            lstFirms.add(new SelectOption(firm.id,firm.Name));
            if(firm.Name =='Lexitas')
                selectedFirm = firm.id;
        }
    }
    public void updateContactDueAmountsFromInvoice(){
        try{
            cont.put('X0_30__c', 0);
            cont.put('X30_60__c', 0);
            cont.put('X60_90__c', 0);
            cont.put('X90_120__c',  0);
            cont.put('X120_150__c',  0);
            cont.put('X150_180__c',  0);
            cont.put('Over_180__c',  0);
            for(Invoice__c invoice:[select Id,Due_Amount__c,Days_Past_Due_Bucket__c FROM Invoice__c
                         WHERE (Attendee__r.Contact__c=:cont.id OR Contact__c=:cont.id) AND Due_Amount__c >=0]){
                if(invoice.Days_Past_Due_Bucket__c == '0-30')
                    cont.put('X0_30__c' , (Decimal)cont.get('X0_30__c')+invoice.Due_Amount__c);
                else if(invoice.Days_Past_Due_Bucket__c == '30-60')
                    cont.put('X30_60__c',(Decimal)cont.get('X30_60__c')+ invoice.Due_Amount__c);
                else if(invoice.Days_Past_Due_Bucket__c == '60-90')
                    cont.put('X60_90__c',(Decimal)cont.get('X60_90__c')+ invoice.Due_Amount__c);
                else if(invoice.Days_Past_Due_Bucket__c == '90-120')
                    cont.put('X90_120__c', (Decimal)cont.get('X90_120__c')+invoice.Due_Amount__c);
                else if(invoice.Days_Past_Due_Bucket__c == '120-150')
                    cont.put('X120_150__c',(Decimal)cont.get('X120_150__c')+invoice.Due_Amount__c);
                else if(invoice.Days_Past_Due_Bucket__c == '150-180')
                    cont.put('X150_180__c',(Decimal)cont.get('X150_180__c')+ invoice.Due_Amount__c);
                else if(invoice.Days_Past_Due_Bucket__c == 'Over 180')
                    cont.put('Over_180__c', (Decimal)cont.get('Over_180__c')+invoice.Due_Amount__c);
                
            }
            update cont;
        }Catch(Exception e){
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
        }
    }

}