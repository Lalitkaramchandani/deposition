public class Web2DepositionExtension {
    String firmStr= '';
    Firm__c firm = new Firm__c();
    String accountOwnerEmail = '';
    
    private final Deposition__c webdeposition;
    
       public Web2DepositionExtension(ApexPages.StandardController stdController) {
           webdeposition = (Deposition__c)stdController.getRecord();
           
           webDeposition.Event_Type__c='Deposition';
           firmStr= ApexPages.currentPage().getParameters().get('firm');
          
           system.debug('$$$'+firm);
           firm= DepositionHelper.fetchFirm(firmStr);
           webdeposition.Primary_Court_Reporting_Firm__c = firm.id;
               
         
       }
           
       public PageReference saveDeposition() {
          Savepoint sp = Database.setSavepoint();
           try {
               upsert(webdeposition);
           
              Attendee__c  attendee = addGuestAsScheduler();
              List<OrgWideEmailAddress >lstOrgWideEmails = [select Id,Address from OrgWideEmailAddress WHERE
                                Address =:Firm.Scheduling_email_address__c];
               List<EmailTemplate>lstEmailTemplate = [select Id From EmailTemplate WHERE DeveloperName='Deposition_Booking_Email_Notification'];
               if(lstEmailTemplate.size()>0){
                    try{
                        List < Messaging.SingleEmailMessage > allMails = new List < Messaging.SingleEmailMessage > ();
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        if (lstOrgWideEmails.size()>0) {
                            mail.setOrgWideEmailAddressId(lstOrgWideEmails[0].Id);
                        }
                        
                        mail.setSaveAsActivity(false);
                        List<String> toAddresses = new List<String>();
                        List<String> ccAddresses = new List<String>();
                        Savepoint spForContact = Database.setSavepoint();
                        Contact Cont = new Contact(); 
                        
                        cont.Lastname='Do Not Delete';
                        cont.Email=webdeposition.GuestEmail__c != NULL ? webdeposition.GuestEmail__c+'.donotdelete': 'schedule@nextgenreporting.com'+'.donotdelete';
                        insert cont;
                        
                        Messaging.SingleEmailMessage email = 
                            Messaging.renderStoredEmailTemplate(lstEmailTemplate[0].Id,cont.id, webdeposition.id);
                        Database.rollback(spForContact );
                        mail.setSubject(email.getSubject());
                        mail.setHtmlBody(email.getHtmlBody());
                        //if(attendee.Contact__c != NULL)
                        //    mail.setTargetObjectId(Userinfo.getUserId());
                        if(Attendee.Email__c!= NULL ){
                            toAddresses.add(Attendee.Email__c);
                        }
                        
                        if(toAddresses.size()>0)
                            mail.setToAddresses(toAddresses );
                            
                        if(Firm.Scheduling_email_address__c != NULL){
                            ccAddresses.add(Firm.Scheduling_email_address__c);
                        }
                        /*if(accountOwnerEmail != ''){
                            ccAddresses.add(accountOwnerEmail);
                        } */
                        Deposition__c depowithComm = [select id, Commission__r.Primary_Rep__r.Email, Commission__r.Secondary_Rep__r.Email  from Deposition__c where id=:webdeposition.id];
                        if(depowithComm != null && String.isNotBlank(depowithComm.Commission__r.Primary_Rep__r.Email))
                        	ccAddresses.add(depowithComm.Commission__r.Primary_Rep__r.Email);
                        if(depowithComm != null && String.isNotBlank(depowithComm.Commission__r.Secondary_Rep__r.Email))
                        	ccAddresses.add(depowithComm.Commission__r.Secondary_Rep__r.Email);
                        if(ccAddresses.size()>0)
                            mail.setCCAddresses(new String[] {Firm.Scheduling_email_address__c});
                        mail.setsaveasactivity(true);
                        allmails.add(mail);
                        Messaging.sendEmail(allMails);
                    }catch(Exception e){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
                        Database.rollback(sp);
                        return null;
                    }
               }
           }
           catch(Exception ex) {
               ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
               Database.rollback(sp);
           }
           PageReference p = Page.ThankYouNextGenReporting;
           if(firmStr=='Wilcox & Fetzer')
               p = Page.ThankYouWilcoxAndFetzer;
           
           p.SetRedirect(true);
           return p;
       }
    
    private Attendee__c addGuestAsScheduler() {
        Attendee__c attendee = new Attendee__c(Deposition__c = webDeposition.Id);
        attendee.Role__c = 'Scheduler';
        accountOwnerEmail ='';
        Contact contact = findContact();
        if(contact!=null )
            if(contact != null) {
                attendee.Contact__c = contact.Id;
                if(contact.Account.Owner.Email != NULL)
                    accountOwnerEmail ='';
            }
        attendee.Email__c = webdeposition.GuestEmail__c;
        insert attendee;
        return attendee;
    }
    
    
    private Contact findContact() {
        
        String email = webdeposition.GuestEmail__c;
        String phone = webdeposition.GuestPhone__c;
        String name = webdeposition.GuestName__c;
        
        //If all fields are blank there is nothing we can do
        if(String.isBlank(email) && String.isBlank(phone) && String.isBlank(name)){
            return null;
        } 
        
        Map<String,String> mpFldVal = new Map<String,String>();
        mpFldVal.put('Name',name);
        mpFldVal.put('Phone',phone);
        mpFldVal.put('Email',email);
        
        Contact contact = searchContactUsing(mpFldVal);
        if(contact != null) return contact;
        
        mpFldVal.remove('Name');
        contact = searchContactUsing(mpFldVal);
        if(contact != null) return contact;
        
        mpFldVal.remove('Phone');
        contact = searchContactUsing(mpFldVal);
        if(contact != null) return contact;
        
        return contact; 
    } 
    
    private Contact searchContactUsing(Map<String,String> mpFieldValues) {
        List<String> lstCondition = new List<String>();
        
        for(String key : mpFieldValues.keyset()){
            String val = mpFieldValues.get(key);
            
            if(String.isBlank(val)) {
                continue;  
            } 
            lstCondition.add(key + ' = \'' + String.escapeSingleQuotes(val) + '\'');      
        }
        
        if(lstCondition.size() == 0) {
            return null;
        }
        String query = ' SELECT Id,Account.Owner.Email FROM Contact WHERE ' + String.join(lstCondition,' AND ');
        System.debug('****Query****' + query);
        
        List<Contact> lstContact = (List<Contact>)Database.query(query);
        
        if(lstContact.size() == 0 || lstContact.size() > 1) {
            return null;
        }
        return lstContact[0]; 
    }
    
    
    static testmethod void runTest(){
        Deposition__c depo = new Deposition__c();
        depo.GuestEmail__c = 'a@a.com';
        depo.GuestPhone__c = '123456789';
        depo.GuestName__c = 'aaa';
        insert depo;
        
        PageReference pageRef = new PageReference('/apex/deposition');
        ApexPages.currentPage().getParameters().put('id', depo.id);
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController SCont = new ApexPages.StandardController(depo);
        
        Web2DepositionExtension ext = new Web2DepositionExtension(SCont);
        ext.saveDeposition();
    }
    
    
}