/**
    Name        :        DepositionReminderScheduler
    Date        :        10 Jan 2019
    Description :        Schedule class to send email and sms reminder one day before deposition
    Developer
*/
global class DepositionReminderScheduler implements Schedulable {  
    
    private static final String COURT_REPORTER = 'Court Reporter';    
    private static final String VIDEOGRAPHER_TECHNICIAN = 'Videographer/Technician';
    private static final String INTERPRETER = 'Interpreter';
    private Map<Id, Deposition__c> depositionMap;
    private Set<Id> contactIds;
    private boolean includeTimeZone = true;
    //Execute method to send SMS and email
    
    public void setIncludeTimeZone(Boolean val){
        this.includeTimeZone = val;
    }
    public void setContactIds(Set<Id> contactIds){
        this.contactIds = contactIds;
    }
    global void execute(SchedulableContext SC){ 
    
        processNotification( NULL );
               
    }
    
    //Get deposition Time zone name according to GMT and time provided(in hours)
    public String getTimeZone( Integer reminderTime ){
        String depositionTimeZone;
        if( reminderTime != NULL ){
            if( System.now().hourGmt() - 7 == reminderTime ){
                depositionTimeZone = 'Pacific';
            } else if( System.now().hourGmt() - 6 == reminderTime ){
                depositionTimeZone = 'Mountain';
            } else if( System.now().hourGmt() - 5 == reminderTime ){
                depositionTimeZone = 'Central';
            } else if( System.now().hourGmt() - 4 == reminderTime ){
                depositionTimeZone = 'Eastern';
            } else if( System.now().hourGmt() - 8 == reminderTime ){
                depositionTimeZone = 'Alaska';
            } else if( System.now().hourGmt() - 10 == reminderTime ){
                depositionTimeZone = 'Hawaii';
            }else{
                depositionTimeZone = '';
            }
        }
        return depositionTimeZone;
    }
    
    
    //Process Notification and send SMS and Email
    public void processNotification( Set<Id> depositionIds ){
    
        List<Deposition__c> depositions = getDepositionWithAttendes( depositionIds );
        Map<Deposition__c, List<Attendee__c>> depositionAttendeeMap = new Map<Deposition__c, List<Attendee__c>>();
        Map<Deposition__c, Map<String, List<Attendee__c>>> exemptedAttendees = new Map<Deposition__c, Map<String, List<Attendee__c>>>();
        
        depositionMap = new Map<Id, Deposition__c>();
        if( depositions != NULL && depositions.size() > 0 ){
            for( Deposition__c deposition : depositions ){
                if( deposition.Deposition_Roles__r != NULL && deposition.Deposition_Roles__r.size() >  0 ){
                    Deposition__c dep = deposition;
                    if(depositionMap.containsKey(deposition.Id)){
                        dep = depositionMap.get(deposition.Id);
                    }
                    for( Attendee__c attendee : deposition.Deposition_Roles__r ){
                        if( attendee.Contact__r.Exempt_From_Automated_Confirmations__c != TRUE && String.isNotBlank( attendee.Contact__r.Email ) ){
                            Attendee__c  tempAttendee;
                            //Put 'Court Reporter' attendess to map
                            if( deposition.Confirm_Reporter__c == 'Not Sent' && attendee.Role__c == COURT_REPORTER ){
                                tempAttendee = attendee;
                                dep.Confirm_Reporter__c = 'Sent';
                                depositionMap.put(dep.Id, dep);
                            }
                            //Put 'Videographer/Technician' attendess to map
                            if( deposition.Confirm_Video_Tech__c == 'Not Sent' && attendee.Role__c == VIDEOGRAPHER_TECHNICIAN ){
                                tempAttendee = attendee;
                                deposition.Confirm_Video_Tech__c = 'Sent';
                                depositionMap.put(dep.Id, dep);
                            }
                            //Put 'Interpreter' attendess to map
                            if( deposition.Confirm_Interpreter__c == 'Not Sent' && attendee.Role__c == INTERPRETER ){
                                tempAttendee = attendee;
                                deposition.Confirm_Interpreter__c = 'Sent';
                                depositionMap.put(dep.Id, dep);
                            }
                            if( tempAttendee != NULL ){
                                if( depositionAttendeeMap != NULL && depositionAttendeeMap.containsKey( deposition ) ){
                                    depositionAttendeeMap.get( deposition ).add( tempAttendee );
                                }else{
                                    depositionAttendeeMap.put( deposition, new List<Attendee__c>{ tempAttendee });
                                }
                            }
                        }else{
                            //populate exempted attendees for manual notification 
                            if( ( deposition.Confirm_Reporter__c == 'Not Sent' && attendee.Role__c == COURT_REPORTER ) || 
                                ( deposition.Confirm_Video_Tech__c == 'Not Sent' && attendee.Role__c == VIDEOGRAPHER_TECHNICIAN ) ||
                                ( deposition.Confirm_Interpreter__c == 'Not Sent' && attendee.Role__c == INTERPRETER ) ){
								
                                exemptedAttendees = populateDepositionAttendeeTypeMap( exemptedAttendees, deposition, attendee, attendee.Role__c );
                                depositionMap.put(dep.Id, dep);
                            }
                        }
                    }
                    
                }
            }
            System.debug(depositionAttendeeMap);
            // if(1==1)
            // return;
            //Send notification for exmpted FALSE
            if( depositionAttendeeMap != NULL && depositionAttendeeMap.size() > 0 ){
                sendDepositionConfrimationNotification( depositionAttendeeMap );
            }
            //Send email to exempted TRUE
            if( exemptedAttendees != NULL && exemptedAttendees.size() > 0 ){
                try{
                    sendExemptedNotification( exemptedAttendees );
                    //Update Depsosition Status
                    updateDeposition();
                }catch( Exception excep ){
                    
                    System.debug( '#####' + excep );
                    System.debug( '#####' + excep.getStackTraceString() );
                }
            }
        } 
    }
    //Method to send ExemptedEmail
    private void sendExemptedNotification( Map<Deposition__c, Map<String, List<Attendee__c>>> exemptedAttendees ){
        String emailBody = '';
        String courtReporter = '<b> ' + COURT_REPORTER  +' </b></br>';
        String videographer =  '<b> ' + VIDEOGRAPHER_TECHNICIAN +' </b></br>';
        String interpreter =  '<b> ' + INTERPRETER +' </b></br>';
        
        if( exemptedAttendees != NULL && exemptedAttendees.size() > 0 ){
            for( Deposition__c deposition : exemptedAttendees.keySet() ){
                Map<String, List<Attendee__c>> attendeeTypeMap = exemptedAttendees.get( deposition );
                if( attendeeTypeMap != NULL && attendeeTypeMap.size() >  0 ){
                    if( attendeeTypeMap.containsKey( COURT_REPORTER ) ){
                        for( Attendee__c attendee : attendeeTypeMap.get( COURT_REPORTER ) ){
                            courtReporter += '<p>-<a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + attendee.Contact__c + '">' + attendee.Contact__r.Name + '</a>';
                            courtReporter += '-' + deposition.Name ;
                            courtReporter += '-' + deposition.Case_Name_Text__c + '</p>';
                            deposition.Confirm_Reporter__c = 'Sent';
                            
                        }
                    }
                    if( attendeeTypeMap.containsKey( VIDEOGRAPHER_TECHNICIAN ) ){
                        for( Attendee__c attendee : attendeeTypeMap.get( VIDEOGRAPHER_TECHNICIAN ) ){
                            videographer += '<p>-<a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + attendee.Contact__c + '">' + attendee.Contact__r.Name + '</a>';
                            videographer += '-' + deposition.Name ;
                            videographer += '-' + deposition.Case_Name_Text__c + '</p>';
                            deposition.Confirm_Video_Tech__c = 'Sent';
                        }
                    }
                    if(  attendeeTypeMap.containsKey( INTERPRETER ) ){
                        for( Attendee__c attendee : attendeeTypeMap.get( INTERPRETER ) ){
                            interpreter += '<p>-<a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + attendee.Contact__c + '">' + attendee.Contact__r.Name + '</a>';
                            interpreter += '-' + deposition.Name;
                            interpreter += '-' + deposition.Case_Name_Text__c + '</p>';
                            deposition.Confirm_Interpreter__c = 'Sent';
                        }
                    }
                }
            }
            emailBody += courtReporter;
            emailBody += videographer;
            emailBody += interpreter;
            List<OrgWideEmailAddress> owea = [select Id, Address from OrgWideEmailAddress where Address = 'schedule@lexitasng.com'];
            if( String.isNotBlank( emailBody ) && owea != NULL && owea.size() > 0 ){
                emailBody = 'Please find list of manual attendees.<br/>' + emailBody + '</br> Thanks'; 
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setSubject('Manual Deposition Attendees');
                mail.setHTMLBody( emailBody );
                mail.setToAddresses( new List<String>{ owea[0].Address } );
                Messaging.sendEmail( new List<Messaging.SingleEmailMessage>{ mail } );
            }
        }
    }
    //populate Attendee Map
    private static Map<Deposition__c, Map<String, List<Attendee__c>>> populateDepositionAttendeeTypeMap( Map<Deposition__c, Map<String, List<Attendee__c>>> exemptedAttendees, 
                                                           Deposition__c deposition, Attendee__c attendee, String attendeeType ){
        System.debug( '##' + attendeeType );
        if( exemptedAttendees != NULL && deposition != NULL && attendee != NULL && String.isNotBlank( attendeeType ) ){
            if( exemptedAttendees.containsKey( deposition ) ){
                Map<String, List<Attendee__c>> attendeeTypeMap = exemptedAttendees.get( deposition );
                if( attendeeTypeMap != NULL ){
                    if( attendeeTypeMap.containsKey( attendeeType ) ){
                        attendeeTypeMap.get( attendeeType ).add( attendee );
                    }else{
                        attendeeTypeMap.put( attendeeType, new List<Attendee__c>{ attendee } );
                    }
                }
            }else{
                Map<String, List<Attendee__c>> attendeeTypeMap = new Map<String, List<Attendee__c>>();
                attendeeTypeMap.put( attendeeType, new List<Attendee__c>{ attendee } );
                exemptedAttendees.put( deposition, attendeeTypeMap );
            }
        }
        return exemptedAttendees;
    }
    
    //Method to reterive all deposition which is on next business day 
    private List<Deposition__c> getDepositionWithAttendes( Set<Id> depositionIds ){
        Set<String> attendesRole = new Set<String>{ COURT_REPORTER, VIDEOGRAPHER_TECHNICIAN, INTERPRETER };
        String status = 'Not Sent';
        //Get Deposition time zone to send email at 3:00 PM one day before deposition
        String depTimeZone = '';
        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE IsDefault = true];
        // upcomming next Business day
        Date nextBusinessDay = getBusinessDate(bh, System.now().dateGMT(),1);
        
        String query = 'SELECT ID, Name, Confirm_Reporter__c, Confirm_Video_Tech__c, Confirm_Interpreter__c, Event_type_lowercase__c, ';
        query += 'Primary_Court_Reporting_Firm__c,Primary_Court_Reporting_Firm__r.Scheduling_Email_Address__c,Deposition_Time__c,Time_Zone__c, Deposition_Date__c, Event_Location__c, Location_Contact__c, Event_type__c, Case_Name_Text__c, ';
        query += '(SELECT ID, Role__c, Contact__c, Contact__r.Alt_Phone__c, Contact__r.Email, Contact__r.Name, ';
        query += 'Contact__r.Exempt_From_Automated_Confirmations__c FROM Deposition_Roles__r WHERE Role__c IN: attendesRole '
            + (contactIds!=NULL ?'AND Contact__c in :contactIds':'')
            + ') ';
        query += 'FROM Deposition__c WHERE ( Confirm_Reporter__c =: status OR Confirm_Video_Tech__c =: status OR Confirm_Interpreter__c =: status) ';
        if( depositionIds != NULL && depositionIds.size() > 0 ){
            query += 'AND Id IN: depositionIds ';
        }else if(includeTimeZone){
            depTimeZone = getTimeZone( 15 );
            if(!Test.isRunningTest()){
                query += ' AND Deposition_Date__c = :nextBusinessDay ';
                query += ' AND Time_zone__c =: depTimeZone ';
            }
        }
        System.debug(query);
        System.debug('AND ( Confirm_Reporter__c =\''+status+'\' OR Confirm_Video_Tech__c =\''+status+'\' OR Confirm_Interpreter__c =\''+status+'\') AND Time_zone__c =\''+depTimeZone+'\'');
        
        return Database.query( query );
    }
    
    //Send SMS and Email for Deposition Confirmation 
    private void sendDepositionConfrimationNotification( Map<Deposition__c, List<Attendee__c>> depositionAttendeeMap ){
        if( depositionAttendeeMap != NULL && depositionAttendeeMap.size() > 0 ){
            try{
                //Send Email
                sendDepositionEmail( depositionAttendeeMap );
                //Send SMS
                sendDepositionSMS( depositionAttendeeMap );
                //Update Depsosition Status
                updateDeposition();
            }catch( Exception excep ){
                System.debug( '#####' + excep );
                System.debug( '#####' + excep.getStackTraceString() );
            }
        }
        
    }
    
    //Update Deposition
    private void updateDeposition(){
        if( depositionMap != NULL && depositionMap.size() > 0 ){
            update depositionMap.values() ;
        }
    }
    
    //Send Email with link
    public void sendDepositionEmail( Map<Deposition__c, List<Attendee__c>> depositionAttendeeMap ){
    
        //Variable to get Email teamplates and create mail list
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        Set<String> templateNames = new Set<String>{'Deposition_Confirmation_Reminder1'};
        Map<String,EmailTemplate> emailTemplateMap = getEmailTemplates( templateNames );
        String fromEmail =System.Label.Deposition_Confirmation_From_Email;
        Map<String, String> emailMap = DepositionDayReminderScheduler.prepareOrgEmailMap(depositionAttendeeMap);
        System.debug('emailMap'+emailMap);
        //Create email message
        if( emailTemplateMap != NULL && emailTemplateMap.size() > 0 && 
            depositionAttendeeMap != NULL && depositionAttendeeMap.size() > 0 &&
            emailTemplateMap.containsKey( 'Deposition_Confirmation_Reminder1' ) ){
            
            for(Deposition__c deposition : depositionAttendeeMap.keySet() ){
                String depEmail = DepositionDayReminderScheduler.defaultEmail; // default email
                if(deposition.Primary_Court_Reporting_Firm__c!=null && String.isNotBlank(deposition.Primary_Court_Reporting_Firm__r.Scheduling_Email_Address__c) ){
                    depEmail = deposition.Primary_Court_Reporting_Firm__r.Scheduling_Email_Address__c.toLowerCase();
                }
                for( Attendee__c attendee : depositionAttendeeMap.get( deposition ) ){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setWhatId( attendee.Id );  
                    mail.setSaveAsActivity( true );   
                    mail.setTargetObjectId( attendee.Contact__c );
                    mail.setTemplateId( emailTemplateMap.get('Deposition_Confirmation_Reminder1').Id ); 
                    if(emailMap.get(depEmail)!=null){
                        mail.setOrgWideEmailAddressId(emailMap.get(depEmail));
                    }else if(emailMap.get(fromEmail)!=null){
                        system.debug(';0');
                        mail.setOrgWideEmailAddressId(emailMap.get(fromEmail));
                    }
                    emails.add( mail );
                }
            }
            if( emails != NULL && emails.size() > 0){
                Messaging.sendEmail( emails );
            }
        }
    }
    
    //Send SMS with link
    private void sendDepositionSMS( Map<Deposition__c, List<Attendee__c>> depositionAttendeeMap ){
        Map<String, String> toBodyMap = new Map<String, String>();
        //Create SMS message
        if( depositionAttendeeMap != NULL && depositionAttendeeMap.size() > 0 ){
            
            for(Deposition__c deposition : depositionAttendeeMap.keySet() ){
                for( Attendee__c attendee : depositionAttendeeMap.get( deposition ) ){
                    if( String.isNotBlank( attendee.Contact__r.Alt_Phone__c ) ){
                        String msgBody = Label.DepositionConfrimationSMS;
                        if( String.isNotBlank(msgBody) ){
                            if( msgBody.containsIgnoreCase( '[Deposition_c.Event_type_lowercase__c]' ) ){
                                msgBody = msgBody.replace('[Deposition_c.Event_type_lowercase__c]', ( deposition.Event_type_lowercase__c != NULL ? deposition.Event_type_lowercase__c : '') );
                            }
                            if( msgBody.containsIgnoreCase( '[Deposition_c.Deposition_Time__c]' ) ){
                                msgBody = msgBody.replace('[Deposition_c.Deposition_Time__c]',( deposition.Deposition_Time__c != NULL ? deposition.Deposition_Time__c : '') );
                            }
                            if( msgBody.containsIgnoreCase( '[Deposition_c.Time_Zone__c]' ) ){
                                msgBody = msgBody.replace('[Deposition_c.Time_Zone__c]', ( deposition.Time_Zone__c != NULL ? deposition.Time_Zone__c : ''));
                            }
                            if( msgBody.containsIgnoreCase( '[Deposition_c.Deposition_Date__c]' ) ){
                                msgBody = msgBody.replace('[Deposition_c.Deposition_Date__c]', ( deposition.Deposition_Date__c != NULL ? String.valueOf(deposition.Deposition_Date__c) : '') );
                            }
                            if( msgBody.containsIgnoreCase( '[Deposition_c.Event_type__c]' ) ){
                                msgBody = msgBody.replace('[Deposition_c.Event_type__c]',( deposition.Event_type__c != NULL ? deposition.Event_type__c : '') );
                            }
                            if( msgBody.containsIgnoreCase( '[Deposition_c.Event_Location__c]' ) ){
                                msgBody = msgBody.replace('[Deposition_c.Event_Location__c]', ( deposition.Event_Location__c != NULL ? deposition.Event_Location__c : '') );
                            }
                            if( msgBody.containsIgnoreCase( '[Deposition_c.Location_Contact__c]' ) ){
                                msgBody = msgBody.replace('[Deposition_c.Location_Contact__c]', ( deposition.Location_Contact__c != NULL ? deposition.Location_Contact__c: '') );
                            }
                            if( msgBody.containsIgnoreCase( '[Link]' ) ){
                                msgBody = msgBody.replace('[Link]', (Label.SiteURL + '/DepositionConfirmation?depositionId=' + deposition.Id + '&contactId=' + attendee.Contact__c) );
                            }
                            toBodyMap.put( attendee.Contact__r.Alt_Phone__c, msgBody );
                        }
                    }
                }
            }
            System.debug('####' + toBodyMap );
            if( toBodyMap != NULL && toBodyMap.size() > 0 ){
                for( String to : toBodyMap.keySet() ){
                    TwilioIntegration.sendSMS( to, toBodyMap.get(to) );
                }
            }
            
        }
    }
    
    //Get email template map
    private Map<String,EmailTemplate> getEmailTemplates( Set<String> templateNames ){
        if( templateNames != NULL && templateNames.size() > 0 ){
            Map<String,EmailTemplate> templateMap = new Map<String,EmailTemplate>();
            for( EmailTemplate template : [SELECT Id, DeveloperName From EmailTemplate WHERE DeveloperName IN :templateNames ] ){
                templateMap.put( template.DeveloperName, template );
            }
            return templateMap;
        }
        return NULL;
    }
    
    /* Use this code if needed to execute on specific timezone
     Datetime sysTime = System.now().addMinutes(30);
     String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
     System.schedule('Send Water Inspection Email ' + sysTime, chronExpression, new ScheduleWaterInspectionReport() );
     
     //Abort current schedule if it is associate child job
     System.abortJob( SC.getTriggerId());    */ 
     
     
    // Get Business date with respect to days;
    private Date getBusinessDate(BusinessHours bh, Date inputDate, Integer days) {
        if (inputDate == null) {
            return null;
        }
        /*
        if (days < 0) {
            return getBusinessDateBackwards(bh, inputDate, days * -1);
        }
        */
        DateTime input = DateTime.newInstanceGMT(inputDate.Year(), inputDate.Month(), inputDate.Day(), 0, 0, 1);
        System.debug('*******Input*****' + input);
        Integer expand = days > 0 ? 1 : -1;
        Long hours = (days * 24) + expand;
        System.debug('********************Hours************' + hours);
        System.debug('************' + hours * 60L * 60L * 1000L);
        DateTime dtComputedTime = BusinessHours.addGMT(bh.id,
            input,
            hours * 60L * 60L * 1000L);
        System.debug('*********dtComputedTime****' + dtComputedTime);
        System.debug('***********DATEGMT*****' + dtComputedTime.dateGMT());
        return dtComputedTime.dateGMT();
    }
/*    
    // Get Business date with respect to past days;
    private Date getBusinessDateBackwards(BusinessHours bh, Date inputDate, Integer days) {
        DateTime input = DateTime.newInstanceGMT(inputDate.Year(), inputDate.Month(), inputDate.Day(), 0, 0, 0);
        DateTime backDate = input.addDays(days * -1);
        System.debug('**************backDate**********' + backDate);
        System.debug('************inputDate**********' + input);
        Long hours = days * 24 * 60L * 60L * 1000L;
        System.debug('***********hours**********' + hours);
        Long diffHours = BusinessHours.diff(bh.id, backDate, inputDate);
        while (diffHours < hours) {
            backDate = backDate.addDays(-1);
            diffHours = BusinessHours.diff(bh.id, backDate, inputDate);
            System.debug('***********Diff Hours**********' + diffHours);
            System.debug('***********back Date**********' + backDate);
        }
        return backDate.dateGMT();

    }
*/
}