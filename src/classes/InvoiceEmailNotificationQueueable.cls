/**************************************************
                Name        : InvoiceEmailNotificationQueueable
                Author      : Lalit karamchandani
                Purpose     : Email notification on Invoice amount changes via trigger
                Created Date: 1 May 2019
                
                
*****************************************************/

public class InvoiceEmailNotificationQueueable implements Queueable {
    
    public static Boolean SEND_NOTIFICATION = true;
    public static Date MIN_DATE;
    public static Date MAX_DATE;
    public Date processMinDate;
    public Date processMaxDate;
    
    Set<Id> invIds = new Set<Id>();
    Map<Id, Set<Id>> contactWithInvIds = new Map<Id, Set<Id>>();
    public InvoiceEmailNotificationQueueable(Set<Id> invIds){
        this.invIds = invIds;
    }
    
    public InvoiceEmailNotificationQueueable(Map<Id, Set<Id>> contactWithInvIds){
        this.contactWithInvIds = contactWithInvIds;
    }
    
    public InvoiceEmailNotificationQueueable(Map<Id, Set<Id>> contactWithInvIds,
        Date minDate, Date maxDate){
        InvoiceEmailNotificationQueueable.MIN_DATE = minDate;
        InvoiceEmailNotificationQueueable.MAX_DATE = maxDate;
        processMinDate = minDate;
        processMaxDate = maxDate;
        this.contactWithInvIds = contactWithInvIds;
    }
    
    public void execute(QueueableContext context){
        // processInvoices(invIds);
        InvoiceEmailNotificationQueueable.MIN_DATE = processMinDate;
        InvoiceEmailNotificationQueueable.MAX_DATE = processMaxDate;
        if(!contactWithInvIds.isEmpty()){
            processInvoicesMap(contactWithInvIds);
        }
            
    }
    public static void processInvoicesMap(Map<Id, Set<Id>> contactWithInvIds){
        Set<Id> proceedInds = new Set<Id>();
        String key='';
        for(String mapKey : contactWithInvIds.keyset()){
            proceedInds = contactWithInvIds.get(mapKey);
            key = mapKey;
            break;
        }
        if(contactWithInvIds.containsKey(key)){
            contactWithInvIds.remove(key);
        }
        PrepareEmailListData(proceedInds);
        if(!contactWithInvIds.isEmpty()){
            System.enqueueJob(new InvoiceEmailNotificationQueueable(contactWithInvIds,
                InvoiceEmailNotificationQueueable.MIN_DATE, InvoiceEmailNotificationQueueable.MAX_DATE));
        }
    }
    static void PrepareEmailListData(Set<Id> proceedInvs){
        Messaging.SingleEmailMessage[] mails = new List<Messaging.SingleEmailMessage>();
        
        Set<String> attendeeRoles = new Set<String>{'Court Reporter','Videographer/Technician','Interpreter'};

        List<Invoice__c> invs = [SELECT Id,Name, Deposition__r.Deponent_Name__c, Deposition__r.Deposition_Date__c,
                                 Deposition__r.Event_Type_Lowercase__c, Deposition__r.Event_Type__c,Total_Revenue_After_Credits__c,
                                 Deposition__r.Primary_Court_Reporting_Firm__c,
                                 Deposition__r.Primary_Court_Reporting_Firm__r.Accounting_Email_Address__c,
                                 Deposition__r.Primary_Court_Reporting_Firm__r.Accounting_Phone_Number__c,
                                 Attendee__r.Contact__r.Email, Attendee__r.Contact__r.Name, Attendee__r.Contact__c,
                                 Invoice_Date__c,
                                 (SELECT Id, Item__r.Name, Units_of_Measure__c, Quantity__c, Price__c, Order__c,Total_Price__c, 
                                  Attendee__c, Attendee__r.Contact__r.Name
                                  FROM Invoice_Items__r ORDER BY Order__c)
                                 FROM Invoice__c WHERE Id=:proceedInvs AND Attendee_Role__c in :attendeeRoles];
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.toAddresses = new String[] { invs[0].Attendee__r.Contact__r.Email};
        email.setTargetObjectId( invs[0].Attendee__r.Contact__c );
        
        String eSubject='Payment Receipts – Payment Period from ';
        String uName = invs[0].Attendee__r.Contact__r.Name;
        String htmlText = 'Hi '+uName+',<br/><br/>';
        Decimal totalAmount = 0;
        String inHtml ='';
        Date minDate = InvoiceEmailNotificationQueueable.MIN_DATE;
        Date maxDate = InvoiceEmailNotificationQueueable.MAX_DATE;
        String firmEmail='info@nextgenreporting.com';
        String firmPhone='(844) 359-1173';
        
        for(Invoice__c inv : invs){
            if(inv.Deposition__r.Primary_Court_Reporting_Firm__c!=null){
                if(String.isNotEmpty(inv.Deposition__r.Primary_Court_Reporting_Firm__r.Accounting_Email_Address__c)){
                    firmEmail = inv.Deposition__r.Primary_Court_Reporting_Firm__r.Accounting_Email_Address__c;
                }
                if(String.isNotEmpty(inv.Deposition__r.Primary_Court_Reporting_Firm__r.Accounting_Phone_Number__c)){
                    firmPhone = inv.Deposition__r.Primary_Court_Reporting_Firm__r.Accounting_Phone_Number__c;
                }
            }
            minDate = minDate == null ? inv.Invoice_Date__c : minDate;
            maxDate = maxDate == null ? inv.Invoice_Date__c : maxDate;
            if(inv.Invoice_Date__c<minDate){
                minDate = inv.Invoice_Date__c;
            }
            if(inv.Invoice_Date__c>maxDate){
                maxDate = inv.Invoice_Date__c;
            }
            totalAmount += inv.Total_Revenue_After_Credits__c!=null ? inv.Total_Revenue_After_Credits__c:0;
            inHtml +='<br/><br/>'+ prepareChildEmailMessage(inv);
        }
        minDate = minDate == null ? System.today() : minDate;
        maxDate = maxDate == null ? System.today() : maxDate;
        eSubject+=minDate.format() +' to '+maxDate.format();
        Integer invCnt = invs.size(); 
        
        htmlText+= 'We have just paid you $'+totalAmount+' for '+invCnt+' invoice'+(invCnt>1?'s':'')+' during the dates of '+ minDate.format() +' and '+maxDate.format()+'. The details are listed below.'
            +'<br/>If you have any questions, please email '+firmEmail+' or call '+firmPhone+'.';
        htmlText+=inHtml;
        // System.debug(htmlText);
        email.optOutPolicy = 'FILTER';
        email.subject = eSubject;//'Invoice created: ' + invo[0].Name;
        // email.plainTextBody = 'This is the email body.';
        email.htmlBody = htmlText;
        mails.add(email);
        try{
            List<Messaging.SendEmailResult> results = Messaging.sendEmail(mails);
            for(Integer ind = 0, length = results.size(); ind<length; ind++){
                Messaging.SendEmailResult result = results[ind];
                if(result.isSuccess()){
                    Messaging.SingleEmailMessage sentEmail = mails[ind];
                    Id contactId = sentEmail.getTargetObjectId();
                }else{
                    System.debug('----> failed: '+result.isSuccess() );
                }
            }
        }catch(Exception ex){
            System.debug('-----------------'+ ex.getMessage());
            System.debug('-----------------'+ ex.getStackTraceString());
        }
    }
    
    static String prepareChildEmailMessage(Invoice__c inv){
        String htmlText = '<b>Invoice</b>&nbsp;'+inv.Name+'&nbsp;'
                +'- <b>Deponent Name</b>: '+ (String.isNotBlank(inv.Deposition__r.Deponent_Name__c ) ? inv.Deposition__r.Deponent_Name__c : '')
                +'&nbsp;- <b>Deposition Date</b>: ' + inv.Deposition__r.Deposition_Date__c.format();
        
        if(!inv.Invoice_Items__r.isEmpty()){
            
            htmlText+='<br/> ';//Here are related items:<br/><br/>
                    // <th>Order No</th>
            htmlText+='<table><thead> <tr><th>Attendee</th><th> Item Name </th><th> Quantity</th><th> Total Price</th></tr> </thead>'
                +'<tbody>';
            Decimal total=0;
            for(Invoice_Item__c inItem : inv.Invoice_Items__r){
                htmlText+='<tr>'
                // +'<td>'+inItem.Order__c+'</td>'
                +'<td>'+(inItem.Attendee__c !=null? inItem.Attendee__r.Contact__r.Name:'')+'</td>'
                +'<td>'+inItem.Item__r.Name+'</td>'
                +'<td style="text-align: center;">'+inItem.Quantity__c+'</td>'
                +'<td style="text-align: right">$'+inItem.Total_Price__c+'</td>'
                +'</tr> ';
                total+=inItem.Total_Price__c;
            }
            htmlText+='<tr>'
            +'<td colspan="3"><b>Total</b></td>'
            +'<td style="text-align: right">$'+total+'</td>'
            +'</tr> ';
            htmlText+='</tbody></table>';
        }
        return htmlText;
    }
    /*
    public static void processInvoices(Set<Id> invoiceIds){
        Set<Id> proceedInds = new Set<Id>();
        for(Id invId : invoiceIds){
            if(proceedInds.size()>9){
                break;
            }
            proceedInds.add(invId);
            invoiceIds.remove(invId);
        }
        prepareEmailData(proceedInds);
        if(!invoiceIds.isEmpty()){
            System.enqueueJob(new InvoiceEmailNotificationQueueable(invoiceIds));
        }
    }
    static void prepareEmailData(Set<Id> proceedInvs){
        Messaging.SingleEmailMessage[] mails = new List<Messaging.SingleEmailMessage>();
        Set<String> attendeeRoles = new Set<String>{'Court Reporter','Videographer/Technician','Interpreter'};

        List<Invoice__c> invs = [SELECT Id,Name, Deposition__r.Deponent_Name__c, Deposition__r.Deposition_Date__c,
                                    Deposition__r.Event_Type_Lowercase__c, Deposition__r.Event_Type__c,
                                    Attendee__r.Contact__r.Email, Attendee__r.Contact__r.Name, Attendee__r.Contact__c,
                                    (SELECT Id, Item__r.Name, Units_of_Measure__c, Quantity__c, Price__c, Order__c,Total_Price__c 
                                        FROM Invoice_Items__r ORDER BY Order__c)
                                    FROM Invoice__c WHERE Id=:proceedInvs AND Attendee_Role__c in :attendeeRoles];
        for(Invoice__c inv : invs){
            mails.add(prepareEmailMessage(inv));
        }
        try{
            List<Messaging.SendEmailResult> results = Messaging.sendEmail(mails);
            for(Integer ind = 0, length = results.size(); ind<length; ind++){
                Messaging.SendEmailResult result = results[ind];
                if(result.isSuccess()){
                    Messaging.SingleEmailMessage email = mails[ind];
                    Id contactId = email.getTargetObjectId();
                }else{
                    System.debug('----> failed: '+result.isSuccess() );
                }
            }
        }catch(Exception ex){
            System.debug('-----------------'+ ex.getMessage());
            System.debug('-----------------'+ ex.getStackTraceString());
        }
    }
    
    static Messaging.SingleEmailMessage prepareEmailMessage(Invoice__c inv){
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.toAddresses = new String[] { inv.Attendee__r.Contact__r.Email};
        email.setTargetObjectId( inv.Attendee__r.Contact__c );
        
        String eSubject='Updated Payment Receipt';
        String uName = inv.Attendee__r.Contact__r.Name;
        
        if(String.isNotEmpty(inv.Deposition__r.Event_Type__c)){
            eSubject+=' - ' + inv.Deposition__r.Event_Type__c;
        }
        if(String.isNotEmpty(inv.Deposition__r.Deponent_Name__c)){
            eSubject+=' of '+ inv.Deposition__r.Deponent_Name__c;
        }
        if(inv.Deposition__r.Deposition_Date__c!=null){
            eSubject+=' on '+ inv.Deposition__r.Deposition_Date__c.format();
        }
        
        String htmlText='Hi '+uName +',<br/><br/>'
                // Invoice 00003740 has been updated as follows:
                +'Invoice '+inv.Name+' has been updated as follows:<br/><br/>'
                +'<b>Deponent Name</b>: '+ (String.isNotBlank(inv.Deposition__r.Deponent_Name__c ) ? inv.Deposition__r.Deponent_Name__c : '')
                +', <b>Deposition Date</b>: ' + inv.Deposition__r.Deposition_Date__c.format();
        
        if(!inv.Invoice_Items__r.isEmpty()){
            
            htmlText+='<br/><br/> ';//Here are related items:<br/><br/>
                    // <th>Order No</th>
            htmlText+='<table><thead> <tr><th> Item Name </th><th> Quantity</th><th> Total Price</th></tr> </thead>'
                +'<tbody>';
            Decimal total=0;
            for(Invoice_Item__c inItem : inv.Invoice_Items__r){
                htmlText+='<tr>'
                // +'<td>'+inItem.Order__c+'</td>'
                +'<td>'+inItem.Item__r.Name+'</td>'
                +'<td style="text-align: center;">'+inItem.Quantity__c+'</td>'
                +'<td style="text-align: right">$'+inItem.Total_Price__c+'</td>'
                +'</tr> ';
                total+=inItem.Total_Price__c;
            }
            htmlText+='<tr>'
            +'<td colspan="2"><b>Total</b></td>'
            +'<td style="text-align: right">$'+total+'</td>'
            +'</tr> ';
            htmlText+='</tbody></table>';
        }
        
        email.optOutPolicy = 'FILTER';
        email.subject = eSubject;//'Invoice created: ' + invo[0].Name;
        // email.plainTextBody = 'This is the email body.';
        email.htmlBody = htmlText;
        return email;
    }
    
    */
}