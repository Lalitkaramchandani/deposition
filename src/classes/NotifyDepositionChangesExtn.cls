public class NotifyDepositionChangesExtn {
    String depId = '';
    public List<Attendee__c>lstAttendees{get;set;}
    public List<Attendee__c>lstAttendeesForCancelled{get;set;}
    String firmSchedulingEmailAddress = '';
    public NotifyDepositionChangesExtn(ApexPages.StandardController cntrl) {
        depId = cntrl.getId();
        loadAttendees();
    }
    
    private void loadAttendees(){
        lstAttendeesForCancelled = new List<Attendee__c>();
        lstAttendees = [select id,Name,Contact__c,Contact__r.Email,Role__c,Account_Name__c,Deposition_Location__c,Primary_Attorney__c
                        ,Standing_Orders_del__c,IsDeleted,deposition__r.Confirm_Client__c,deposition__r.Confirm_Reporter__c,deposition__r.Confirm_Video_Tech__c
                        ,Deposition__r.Primary_Court_Reporting_Firm__r.Scheduling_Email_Address__c
                        FROM Attendee__c
                        WHERE Deposition__c = :depId  AND (Role__c IN('Scheduler','Court Reporter','Videographer/Technician','Attorney','Interpreter')
                              OR Primary_Attorney__c=true) ];
        if(lstAttendees.size()>0)
            firmSchedulingEmailAddress  = lstAttendees[0].Deposition__r.Primary_Court_Reporting_Firm__r.Scheduling_Email_Address__c;
            
        lstAttendeesForCancelled  =         [select id,Name,Contact__c,Contact__r.Email,Role__c,Account_Name__c,Deposition_Location__c,Primary_Attorney__c
                        ,Standing_Orders_del__c,IsDeleted,deposition__r.Confirm_Client__c,deposition__r.Confirm_Reporter__c,deposition__r.Confirm_Video_Tech__c
                         FROM Attendee__c
                        WHERE Deposition__c = :depId  AND (Role__c IN('Scheduler','Court Reporter','Videographer/Technician','Attorney','Interpreter')
                              OR Primary_Attorney__c=true) ];
        
    }
    public PageReference sendEmailForClientConfirm(){
        return sendEmail('CR_VID_Deposition_Details_Changed,Legal_Staff_Deposition_Details_Changed,CR_VID_Deposition_Details_Confirmed,Legal_Staff_Deposition_Details_Confirmed',lstAttendees );
    }
    public PageReference  sendEmailForCancelled(){
        return sendEmail('CR_VID_Cancellation_VF,Cancellation_notice_for_legal_staff_VF',lstAttendeesForCancelled);
    }
    
   
    public  PageReference sendEmail(String templateName,List<Attendee__c>lstAttendeeRecords){
        
        List<Messaging.SingleEmailMessage>lstEmails = new List<Messaging.SingleEmailMessage>();
        List<EmailTemplate>lstEmailTemplate = new List<EmailTemplate>();
        map<String,Id>mapEmailTemplates = new Map<String,Id>();
        
        for(EmailTemplate emailTempl : [select id,DeveloperName From EmailTemplate WHERE DeveloperName  IN : templateName.split(',')]){
            mapEmailTemplates.put(emailTempl.DeveloperName,emailTempl.id);
        }
        
        Boolean isSelected = false;
        Savepoint sp = Database.setSavepoint();
        Deposition__c dep = new Deposition__c(Id=depId);
        Boolean needDepUpdate = false;
        List<OrgWideEmailAddress >lstOrgWideEmailAddress =  [select Id,Address from OrgWideEmailAddress WHERE
                                                            Address = :firmSchedulingEmailAddress];
        
        if(lstEmailTemplate.size()>0 || mapEmailTemplates.size()>0){
            for(Attendee__c attendee : lstAttendeeRecords){
                if((Test.isRunningTest() || attendee.isDeleted) && attendee.Contact__r.Email != NULL){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    
                    mail.setWhatId(depId);  
                    mail.setSaveAsActivity(true);   
                    mail.setTargetObjectId(attendee.Contact__c); 
                    if (lstOrgWideEmailAddress.size()>0) {
                        mail.setOrgWideEmailAddressId(lstOrgWideEmailAddress[0].Id);
                    }       
                    
                    
                    if(templateName  =='CR_VID_Deposition_Details_Changed,Legal_Staff_Deposition_Details_Changed,CR_VID_Deposition_Details_Confirmed,Legal_Staff_Deposition_Details_Confirmed'){
                        if(ApexPages.currentPage().getParameters().get('Confirmed') == 'true'){
                            if(attendee.Role__c == 'Scheduler' || attendee.Primary_Attorney__c){
                                dep.Confirm_Client__c = 'Sent';
                                needDepUpdate = true;
                            }
                            if(attendee.Role__c == 'Court Reporter'){
                                dep.Confirm_Reporter__c= 'Sent'; 
                                needDepUpdate = true;
                            }
                            if(attendee.Role__c == 'Videographer/Technician'){
                                dep.Confirm_Video_Tech__c= 'Sent';   
                                needDepUpdate = true;
                            }  
                            if(attendee.Role__c == 'Court Reporter' || attendee.Role__c == 'Videographer/Technician' || attendee.Role__c=='Interpreter'){
                                if(mapEmailTemplates.containsKey('CR_VID_Deposition_Details_Confirmed'))
                                    mail.setTemplateId(mapEmailTemplates.get('CR_VID_Deposition_Details_Confirmed'));
                            }else{
                                if(mapEmailTemplates.containsKey('Legal_Staff_Deposition_Details_Confirmed'))
                                    mail.setTemplateId(mapEmailTemplates.get('Legal_Staff_Deposition_Details_Confirmed'));
                            }
                        }else{ 
                            if(attendee.Role__c == 'Court Reporter' || attendee.Role__c == 'Videographer/Technician' || attendee.Role__c=='Interpreter'){
                                if(mapEmailTemplates.containsKey('CR_VID_Deposition_Details_Changed'))
                                    mail.setTemplateId(mapEmailTemplates.get('CR_VID_Deposition_Details_Changed'));
                            }else{
                                if(mapEmailTemplates.containsKey('Legal_Staff_Deposition_Details_Changed'))
                                    mail.setTemplateId(mapEmailTemplates.get('Legal_Staff_Deposition_Details_Changed'));
                            }
                      }        
                   }else{
                        if(attendee.Role__c == 'Court Reporter' || attendee.Role__c == 'Videographer/Technician' || attendee.Role__c=='Interpreter'){
                            if(mapEmailTemplates.containsKey('CR_VID_Cancellation_VF'))
                                mail.setTemplateId(mapEmailTemplates.get('CR_VID_Cancellation_VF'));
                        }else{
                            if(mapEmailTemplates.containsKey('Cancellation_notice_for_legal_staff_VF'))
                                mail.setTemplateId(mapEmailTemplates.get('Cancellation_notice_for_legal_staff_VF'));
                        }
                        
                        
                   }
                   lstEmails.add(mail);                
                }
                if(isSelected == false && attendee.isDeleted )
                    isSelected  = true;
            }
            try{
                if(lstEmails.size()>0){
                    Messaging.sendEmail(lstEmails);
                    if(needDepUpdate)
                        update dep;
                    return new PageReference('/'+depId);
                }
                if(isSelected  )
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Email successfully sent to attendeees.'));
                else
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select at least one attendee.'));
            }catch(Exception e){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
                Database.rollback(sp);
            }
        }
        return null; 
        
    }
}