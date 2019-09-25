public class SendConfirmationEmailCtlr {
    
    public list<DepositionModel>lstDepositionsModel{ get; set; }
    public Deposition__c dummydeposition{get;set;}
    public list<SelectOption>firmOptions{get;set;}
    public string selectedFirm{get;set;}
    public SendConfirmationEmailCtlr(){
         dummydeposition = new Deposition__c(Deposition_Date__c=System.today()+1);
         /*DateTime myDateTime = (DateTime) dummydeposition.Deposition_Date__c;
         String dayOfWeek = myDateTime.format('E');
         system.debug('$$$'+dayOfWeek );
         if(dayOfWeek =='Sun')
             dummydeposition.Deposition_Date__c = dummydeposition.Deposition_Date__c.addDays(1);
         else if(dayOfWeek =='Sat')
             dummydeposition.Deposition_Date__c = dummydeposition.Deposition_Date__c.addDays(2);    
         */
         lstDepositionsModel=new list<DepositionModel>();
         firmOptions = new List<SelectOption>();
         for(Firm__c firm : [select id,Name From Firm__c ]){
            firmOptions.add(new SelectOption(firm.Name,Firm.Name));
         }
         selectedFirm = Apexpages.currentPage().getParameters().get('firm');
         if(selectedFirm== NULL || selectedFirm.trim().length()==0)
             selectedFirm = 'NextGen Reporting';
    }
     
    public void actionmethod(){
        lstDepositionsModel=new list<DepositionModel>();
        
        system.debug('$$$'+dummydeposition.Deposition_Date__c);
        if(dummydeposition.Deposition_Date__c!=null){
             for(Deposition__c dep:[select name,Event_Type__c,Deposition_Status__c,Deposition_Time__c,Deposition_Date__c,Time_Zone__c,Event_Location__c
                 ,(select id,Name,Contact__c,Contact__r.Name,Contact__r.Email,Role__c,Deposition__r.Confirm_Reporter__c,
                 Deposition__r.Confirm_Client__c,Deposition__r.Confirm_Video_Tech__c,IsDeleted,Primary_Attorney__c 
                  From Deposition_Roles__r WHERE Role__c IN ('Scheduler','Court Reporter','Videographer/Technician') AND Contact__r.Email!= NULL)
                 from Deposition__c where Deposition_Date__c=:dummydeposition.Deposition_Date__c and Deposition_Status__c !='Confirmed'
                 and Deposition_Status__c !='Cancelled' AND Primary_Court_Reporting_Firm__r.Name=:selectedFirm]){
                 lstDepositionsModel.add(new DepositionModel(dep));
             }

        }
  }
  
  public PageReference cancel(){
      return new PageReference('/'+Deposition__c.sobjecttype.getDescribe().getKeyPrefix()+'/o');
  }

  public void sendEmail()
  {
       try{
           List<Messaging.SingleEmailMessage>lstEmails = new List<Messaging.SingleEmailMessage>();
            List<EmailTemplate>lstEmailTemplate = new List<EmailTemplate>();
            map<String,Id>mapEmailTemplates = new Map<String,Id>();
            String templateName = 'CR_Confirmation_Tomorrow_VF,Videographer_Confirmation_Tomorrow_VF,Confirmation_for_legal_staff_tomorrow_VF';
            for(EmailTemplate emailTempl : [select id,DeveloperName From EmailTemplate WHERE DeveloperName  IN : templateName.split(',')]){
                mapEmailTemplates.put(emailTempl.DeveloperName,emailTempl.id);
            }
            
            
            Savepoint sp = Database.setSavepoint();
            List<Deposition__c>lstNeedDepUpdate = new List<Deposition__c>();
            
            
            //List<OrgWideEmailAddress >lstOrgWideEmailAddress =  [select Id,Address from OrgWideEmailAddress WHERE
            //                                                    Address = :firmSchedulingEmailAddress];
            
            if(lstEmailTemplate.size()>0 || mapEmailTemplates.size()>0){
                for(DepositionModel depModel : lstDepositionsModel){
                    Boolean needDepUpdate = false;
                    for(Attendee__c attendee : depModel.dep.Deposition_Roles__r){
                        if((Test.isRunningTest() || attendee.isDeleted) && attendee.Contact__r.Email != NULL){
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            
                            mail.setWhatId(depModel.dep.id);  
                            mail.setSaveAsActivity(true);   
                            mail.setTargetObjectId(attendee.Contact__c); 
                            //if (lstOrgWideEmailAddress.size()>0) {
                            //    mail.setOrgWideEmailAddressId(lstOrgWideEmailAddress[0].Id);
                            //}       
                            if(attendee.Role__c == 'Scheduler' || attendee.Primary_Attorney__c ){
                                depModel.dep.Confirm_Client__c = 'Sent';
                                needDepUpdate = true;
                            }
                            if(attendee.Role__c == 'Court Reporter'){
                                depModel.dep.Confirm_Reporter__c= 'Sent'; 
                                needDepUpdate = true;
                            }
                            if(attendee.Role__c == 'Videographer/Technician'){
                                depModel.dep.Confirm_Video_Tech__c= 'Sent';   
                                needDepUpdate = true;
                            }  
                            
                           
                            if(attendee.Role__c == 'Scheduler' ||attendee.Primary_Attorney__c  ){
                                if(mapEmailTemplates.containsKey('Confirmation_for_legal_staff_tomorrow_VF'))
                                    mail.setTemplateId(mapEmailTemplates.get('Confirmation_for_legal_staff_tomorrow_VF'));
                            }else if(attendee.Role__c == 'Videographer/Technician' && mapEmailTemplates.containsKey('Videographer_Confirmation_Tomorrow_VF')){
                                mail.setTemplateId(mapEmailTemplates.get('Videographer_Confirmation_Tomorrow_VF'));
                            }else if(attendee.Role__c == 'Court Reporter' && mapEmailTemplates.containsKey('CR_Confirmation_Tomorrow_VF')){
                                mail.setTemplateId(mapEmailTemplates.get('CR_Confirmation_Tomorrow_VF'));
                            }
                              
                           lstEmails.add(mail);                
                        }
                        
                    }
                    
                    if(needDepUpdate){
                         depModel.dep.Last_Email_Sent__c=Date.Today();
                         lstNeedDepUpdate.add(depModel.dep);
                    
                    }
                }
                try{
                    if(lstEmails.size()>0){
                        Messaging.sendEmail(lstEmails);
                        if(lstNeedDepUpdate.size()>0)
                            update lstNeedDepUpdate;
                        
                    }
                    //actionmethod();
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Confirmation Email Sent Successfully'));
                    
                }catch(Exception e){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
                    Database.rollback(sp);
                }
            }
       
       }catch(Exception e){
       
       }
       
   }
   public class DepositionModel{
         public Deposition__c dep{ get; set;}
         public List<Attendee__c>lstAttendees{ get; set;}
         public DepositionModel(Deposition__c dep){
             this.dep=dep;
             this.lstAttendees = dep.Deposition_Roles__r;
         }
    }
 
    

}