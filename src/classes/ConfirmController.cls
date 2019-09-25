/*************************************************************************
 *Controller which confirms the participation of a court reporter
 **************************************************************************/
public class ConfirmController {

    public Boolean isError {
        get;
        set;
    }
    public Boolean isJobOpen {
        get;
        set;
    }
    public Deposition__c deposition {
        get;
        set;
    }
    public Boolean isAccepted {
        get;
        set;
    }
    public String type {
        get;
        set;
    }
    public Attendee__c attendee = new Attendee__c();

    private Contact contact;

    //===============================================//
    //Constructor
    //==============================================//
    public ConfirmController() {
        this.isError = false;
        this.isJobOpen = false;
        this.isAccepted = false;
        type = ApexPages.currentPage().getParameters().get('Type');
          this.contact = loadContact();
        this.deposition = loadDeposition();
        String selectedFirm = deposition.Primary_Court_Reporting_Firm__r.Name;
        system.debug('$$$'+selectedFirm );
        
        Cookie Cookie= new Cookie('firmCookie', null,null,0,false);
        ApexPages.currentPage().setCookies(new Cookie[]{Cookie});
        Cookie= new Cookie('firmCookie', selectedFirm,null,-1,false);
        ApexPages.currentPage().setCookies(new Cookie[]{Cookie});
        
        
    }

    public PageReference updateDeposition() {
        try {
            //Check if there is already a court Reporter for the job
            createAttendee(this.deposition, this.contact);
            //comfirmDepositionReporter();
            this.isAccepted = true;
        } catch (Exception ex) {
            System.debug('Exception ' + ex);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getmessage()));
            this.isError = true;
        }
        return null;
    }

    public PageReference confirmDeposition() {
        try {
            system.debug('$$$'+deposition.Deposition_Roles__r.size());
            if (deposition.Deposition_Roles__r.size() > 0 || deposition.Deposition_Status__c == 'Cancelled') {
                system.debug('$$hello');
                this.isError = false;
              
                sendEmail();
                if (isError == false && isJobOpen == false) {
                    //Contact contact = new Contact(Id=);
                    //contact.Already_Claimed_Job_Number__c = deposition.Name;
                    //contact.Notify_Already_Claimed_Job__c = true;
                    //update contact;

                    List < Messaging.SingleEmailMessage > mailList = new List < Messaging.SingleEmailMessage > ();
                    List < EmailTemplate > lstEmailTemplates = [select id, DeveloperName From EmailTemplate
                        WHERE DeveloperName = 'CR_Already_Claimed_Job_VF'
                    ];
                    
                    String fromEmail = deposition.Primary_Court_Reporting_Firm__r.Scheduling_email_address__c;
                    if(type== 'Videographer/Technician')
                        fromEmail = deposition.Primary_Court_Reporting_Firm__r.Video_Email_Address__c;
                    List < OrgWideEmailAddress > lstOrgWideEmailAddress = [SELECT id, Address
                        FROM OrgWideEmailAddress
                        where Address =:fromEmail
                    ];

                    if (lstEmailTemplates.size() > 0) {
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setTemplateId(lstEmailTemplates[0].id);
                        mail.setTargetObjectId(ApexPages.currentPage().getParameters().get('ctc'));
                        mail.setWhatId(deposition.id);
                        if(lstOrgWideEmailAddress.size()>0){
                            mail.setCCAddresses(new String[] {
                             lstOrgWideEmailAddress[0].Address
                            });
                            mail.setOrgWideEmailAddressId(lstOrgWideEmailAddress[0].id);
                        }
                        mailList.add(mail);
                    }
                    if (mailList.size() > 0) {
                        Messaging.sendEmail(mailList);
                    }
                }
                return null;
            }
           

            this.isJobOpen = true;
            this.isError = false;
        } catch (Exception ex) {
            this.isError = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getmessage()));
            System.debug('Exception' + ex);
        }
        return null;
    }

    private void sendEmail() {

        
        /*
        Task task = new Task(WhatId = this.deposition.Id,Subject = 'Job Already Accepted');
        task.WhoId = contact.Id;
        task.Description = 'The contact tried to accept the job,but it was already booked';
    
        if(!String.isBlank(template.Username__c)) {
          List<User> lstUser = [SELECT Id FROM User WHERE Username = :template.Username__c];
          if(lstUser.size() > 0) {
            task.OwnerId = lstUser[0].Id;
          }  
        }
        insert task;*/
        if (checkIfAttendeeAlreadyExists(this.deposition, contact)) {
            this.isJobOpen = true;
            this.isAccepted = true;
            
        }
        

    }

    //========================================================================//
    //Load contact
    //========================================================================//
    private Contact loadContact() {
        String contactID = ApexPages.currentPage().getParameters().get('ctc');
        return [SELECT Id, Name, Email FROM Contact WHERE Id = : contactID Limit 1];
    }
    public PageReference comfirmDepositionReporter() {
        try {
            this.deposition = loadDeposition();
            /*if (type == 'Videographer/Technician')
                deposition.Confirm_Video_Tech__c = 'Confirmed';
            else
                deposition.Confirm_Reporter__c = 'Confirmed';
            update deposition;*/
        } catch (Exception ex) {
            this.isError = true;
            System.debug('Exception' + ex);
        }
        return null;
    }

    //===============================================================================//
    //Create Attendee record for the Depostion and Contact
    //===============================================================================//
    private void createAttendee(Deposition__c deposition, Contact contact) {
        /*
        //Check if the contact not already exists 
        List<Attendee__c> lstAttendee = [SELECT Id FROM Attendee__c WHERE Deposition__c = :deposition.ID 
                                         AND Contact__c = :contact.ID AND Role__c = 'Court Reporter'];
    
        //If the Contact already exists for the deposition as attendee, do not do anything
        if(lstAttendee.size() != 0) {
          return;
        }    */

        if (checkIfAttendeeAlreadyExists(deposition, contact)) {
            return;
        }

        Attendee__c attendee = new Attendee__c(Deposition__c = deposition.Id, Contact__c = contact.Id);
        attendee.Role__c = type;
        insert attendee;
        String fromEmail = deposition.Primary_Court_Reporting_Firm__r.Scheduling_email_address__c;
        String emailTemplateName = 'Reporter_Has_Accepted_Job_Online_VF';
        if(type== 'Videographer/Technician'){
            emailTemplateName = 'Videographer_Has_Accepted_Job_Online_VF';
            fromEmail = deposition.Primary_Court_Reporting_Firm__r.Video_Email_Address__c;
        }
        List < Messaging.SingleEmailMessage > mailList = new List < Messaging.SingleEmailMessage > ();
        List < EmailTemplate > lstEmailTemplates = [select id, DeveloperName From EmailTemplate
            WHERE DeveloperName = 'Reporter_Has_Accepted_Job_Online'
        ];
        
        
        //if(type!= 'Videographer/Technician'){
             List < OrgWideEmailAddress > lstOrgWideEmailAddress = [SELECT id, Address
                FROM OrgWideEmailAddress
                where Address =:fromEmail
            ];
    
            if (lstEmailTemplates.size() > 0) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTemplateId(lstEmailTemplates[0].id);
                mail.setTargetObjectId(ApexPages.currentPage().getParameters().get('ctc'));
                mail.setWhatId(attendee.id);
                if(lstOrgWideEmailAddress.size()>0){
                    List<String>lstCCEmails = new List<String>();
                    lstCCEmails.add(lstOrgWideEmailAddress[0].Address);
                    if(type== 'Videographer/Technician' && deposition.Primary_Court_Reporting_Firm__r.Scheduling_email_address__c != NULL)
                        lstCCEmails.add(deposition.Primary_Court_Reporting_Firm__r.Scheduling_email_address__c);
                    mail.setCCAddresses(lstCCEmails);
                    mail.setOrgWideEmailAddressId(lstOrgWideEmailAddress[0].id);
                }
                mailList.add(mail);
            }
            if (mailList.size() > 0) {
                try{
                    Messaging.sendEmail(mailList);
                } catch (Exception ex) {
                    this.isError = true;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getmessage()));
                    System.debug('Exception' + ex);
                }
            }
        //}
    }

    private Boolean checkIfAttendeeAlreadyExists(Deposition__c deposition, Contact contact) {
        //Check if the contact not already exists 
        List < Attendee__c > lstAttendee = [SELECT Id FROM Attendee__c WHERE Deposition__c = : deposition.ID
            AND Contact__c = : contact.ID AND Role__c = : type
        ];

        //If the Contact already exists for the deposition as attendee, do not do anything
        if (lstAttendee.size() > 0) {
            return true;
        }
        return false;
    }

    //======================================================================//
    //Load deposition
    //======================================================================//
    private Deposition__c loadDeposition() {
        String depositionId = ApexPages.currentPage().getParameters().get('Dep');
        return [SELECT Id, Name, Primary_Court_Reporting_Firm__r.Name,Primary_Court_Reporting_Firm__r.Phone__c,Confirm_Reporter__c, Deposition_Date__c, Deposition_Time__c, Event_Location__c, Case_Name__c,
            Deponent_Name__c, Hiring_Attorney__c, Hiring_Firm__c, Deposition_Services__c, Event_Type__c, Video_Tech_Instructions__c,
            Expedite__c, Transcript_Due_From_Reporter_Computed__c, Deposition_Status__c, Event_Type_Lowercase__c, Transcript_Due_From_Reporter__c, Time_Zone__c,
            Primary_Court_Reporting_Firm__r.Scheduling_email_address__c,Primary_Court_Reporting_Firm__r.Video_Email_Address__c, (Select Name, Role__c From Deposition_Roles__r WHERE Role__c = : type)
            FROM Deposition__c WHERE Id = : depositionID Limit 1
        ];
    }

    

    //**********************TEST CLASS*******************************************************//
    @isTest
    private static void Test_ConfirmController() {
        Deposition__c deposition = new Deposition__c();
        insert deposition;

        Contact contact = new Contact(LastName = 'ab');
        insert contact;

        Test.setCurrentPage(Page.Confirm);
        ApexPages.currentPage().getParameters().put('Dep', deposition.ID);
        ApexPages.currentPage().getParameters().put('ctc', contact.ID);
        ApexPages.currentPage().getParameters().put('type', 'Court Reporter');
        ConfirmController ctrl = new ConfirmController();
        ctrl.confirmDeposition();
        ctrl.updateDeposition();
        ctrl.comfirmDepositionReporter();
        ctrl = new ConfirmController();
        ctrl.confirmDeposition();
        ctrl.updateDeposition();
        ctrl.comfirmDepositionReporter();
    }

}