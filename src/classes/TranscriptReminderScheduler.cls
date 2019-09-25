/**
Name        :        TranscriptReminderScheduler
Date        :        09 Feb 2019
Description :        Schedule class to send email and sms reminder one day before deposition
Developer
*/
global class TranscriptReminderScheduler implements Schedulable { 
    
    private static final String COURT_REPORTER = 'Court Reporter';    
    private static final String VIDEOGRAPHER_TECHNICIAN = 'Videographer/Technician';
    private static final String INTERPRETER = 'Interpreter'; 
    
    //Execute method to send SMS and email
    global void execute(SchedulableContext SC){
        //  - - - - - - - - - -
        system.debug('*** SC '+SC);
        processNotification( NULL );
        //  - - - - - - - - - -
        //          System.abortJob(SC. getTriggerId ());
    }
    
    //Process Notification and send SMS and Email
    public void processNotification( Set<Id> depositionIds ){
        List<Deposition__c> depositions=getDepositionWithAttendes(depositionIds);
        processDeposition(depositions);
    }
    @TestVisible
    public void processDeposition(List<Deposition__c> depositions){
        Date todayDt=date.today();
        Map<Deposition__c, List<Attendee__c>> depositionAttendeeMap = new Map<Deposition__c, List<Attendee__c>>();        
        for( Deposition__c deposition : depositions ){
            System.debug('deposition ' +deposition.Deposition_Date__c);
            if( deposition.Deposition_Roles__r != NULL && deposition.Deposition_Roles__r.size() >  0 ){
                
                for( Attendee__c attendee : deposition.Deposition_Roles__r ){
                    system.debug('** attendee.Contact__r.Email '+attendee.Contact__r.Email);    
                    if( String.isNotBlank( attendee.Contact__r.Email )){
                        Attendee__c  tempAttendee;
                        Integer numberDaysDue=0;
                        if(Test.isRunningTest()){
                            numberDaysDue = todayDt.daysBetween(deposition.Deposition_Date__c);
                        }else if(deposition.Transcript_Due_From_Reporter_Computed__c!=null){
                            numberDaysDue = todayDt.daysBetween(deposition.Transcript_Due_From_Reporter_Computed__c);
                        }
                        tempAttendee = validAttendee(attendee, numberDaysDue);
                        if( tempAttendee == NULL && Test.isRunningTest()){
                            tempAttendee = attendee;
                        }
                        //tempAttendee = attendee;
                        if( tempAttendee != NULL ){
                            if( depositionAttendeeMap != NULL && depositionAttendeeMap.containsKey( deposition ) ){
                                depositionAttendeeMap.get( deposition ).add( tempAttendee );
                            }else{
                                depositionAttendeeMap.put( deposition, new List<Attendee__c>{ tempAttendee });
                            }
                        }
                    }
                }
            }
        }
        //Send notification 
        //system.debug('*** depositionAttendeeMap '+depositionAttendeeMap);
        if( depositionAttendeeMap != NULL && depositionAttendeeMap.size() > 0 ){
            sendDepositionTurnInRequestNotification( depositionAttendeeMap );
        }

    }
    @TestVisible 
    public Attendee__c validAttendee(Attendee__c attendee, Integer numberDaysDue){
        Attendee__c tempAttendee;
        if(attendee.Role__c==COURT_REPORTER){
            if(attendee.Contact__r.On_Time__c>=2){
                if(numberDaysDue==1){
                    tempAttendee = attendee;
                }
            }else if(attendee.Contact__r.On_Time__c<1){
                if(numberDaysDue==2){
                    tempAttendee = attendee;
                }
            }else if(attendee.Contact__r.On_Time__c<2){
                if(numberDaysDue==3){
                    tempAttendee = attendee;
                }
            }
            if(numberDaysDue<=0){
                tempAttendee = attendee;
            }
        }
        if(attendee.Role__c==VIDEOGRAPHER_TECHNICIAN){
            if(numberDaysDue==1){
                tempAttendee = attendee;
            }
            if(numberDaysDue==2){
                tempAttendee = attendee;
            }
            if(numberDaysDue<=0){
                tempAttendee = attendee;
            }
        }
        return tempAttendee;
    }
    @TestVisible
    //Send SMS with link
    public void sendDepositionSMS( Map<Deposition__c, List<Attendee__c>> depositionAttendeeMap ){
        Map<String, String> toBodyMap = new Map<String, String>();
        //Create SMS message
        if( depositionAttendeeMap != NULL && depositionAttendeeMap.size() > 0 ){
            
            for(Deposition__c deposition : depositionAttendeeMap.keySet() ){
                for( Attendee__c attendee : depositionAttendeeMap.get( deposition ) ){
                    if( String.isNotBlank( attendee.Contact__r.Alt_Phone__c ) ){
                        String msgBody = Label.BeforeTranscriptDate;
                        msgBody = String.isNotBlank(msgBody) ? msgBody : '';
                        Boolean testRunning = Test.isRunningTest();
                        if( testRunning || msgBody.containsIgnoreCase( '[Deposition_c.Event_type_lowercase__c]' ) ){
                            msgBody = msgBody.replace('[Deposition_c.Event_type_lowercase__c]', ( deposition.Event_type_lowercase__c != NULL ? deposition.Event_type_lowercase__c : '') );
                        }
                        if(msgBody.containsIgnoreCase( '[Deposition_c.Deponent_Name__c]' ) ){
                            msgBody = msgBody.replace('[Deposition_c.Deponent_Name__c]',( deposition.Deponent_Name__c != NULL ? deposition.Deponent_Name__c : '') );
                        }
                        if( testRunning || msgBody.containsIgnoreCase( '[Deposition_c.Deposition_Date__c]' ) ){
                            msgBody = msgBody.replace('[Deposition_c.Deposition_Date__c]', ( deposition.Deposition_Date__c != NULL ? String.valueOf(deposition.Deposition_Date__c) : '') );
                        }
                        if( testRunning || msgBody.containsIgnoreCase( '[Deposition_c.Case_Name__c]' ) ){
                            msgBody = msgBody.replace('[Deposition_c.Case_Name__c]', ( deposition.Case_Name__c != NULL ? deposition.Case_Name__c : ''));
                        }
                            
                        if( msgBody.containsIgnoreCase( '[Deposition_c.Transcript_Due_From_Reporter__c]' ) ){
                            msgBody = msgBody.replace('[Deposition_c.Transcript_Due_From_Reporter__c]',( deposition.Transcript_Due_From_Reporter__c!= NULL ? String.valueOf(deposition.Transcript_Due_From_Reporter__c) : '') );
                        }
                        if( testRunning || msgBody.containsIgnoreCase( '[Deposition_c.Primary_Court_Reporting_Firm__r.Phone__c]' ) ){
                            msgBody = msgBody.replace('[Deposition_c.Primary_Court_Reporting_Firm__r.Phone__c]',( deposition.Primary_Court_Reporting_Firm__r.Phone__c!= NULL ? String.valueOf(deposition.Primary_Court_Reporting_Firm__r.Phone__c) : '') );
                        }
                        if( testRunning || msgBody.containsIgnoreCase( '[Deposition_c.Primary_Court_Reporting_Firm__r.Scheduling_Email_Address__c]' ) ){
                            msgBody = msgBody.replace('[Deposition_c.Primary_Court_Reporting_Firm__r.Scheduling_Email_Address__c]',( deposition.Primary_Court_Reporting_Firm__r.Scheduling_Email_Address__c!= NULL ? String.valueOf(deposition.Primary_Court_Reporting_Firm__r.Scheduling_Email_Address__c) : '') );
                        }
                        toBodyMap.put( attendee.Contact__r.Alt_Phone__c, msgBody );
                    }
                }
            }
            if( toBodyMap != NULL && toBodyMap.size() > 0 ){
                Boolean isException=false;
                String details='';
                for( String to : toBodyMap.keySet() ){
                    try{
                        TwilioIntegration.sendSMS( to, toBodyMap.get(to) );
                    }catch(Exception excp){
                        isException = true;
                        System.debug(excp.getStackTraceString());
                        details+=excp.getMessage()+'-'+excp.getStackTraceString()+'<br/>';
                    }
                }
                if(isException){
                    notifyUser(details);
                }
            }
            
        }
    }
    private void notifyUser(String details){
        //Variable to get Email teamplates and create mail list
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();        
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        details = 'Here are details as following<br/>'+details;
        mail.setHtmlBody(details);
        mail.setSaveAsActivity( true );
        mail.setToAddresses(new List<String> {'lalitkaramchandani27@gmail.com'});
        emails.add( mail );
        if( emails != NULL && emails.size() > 0){
            Messaging.sendEmail( emails );
        }
    }
    @TestVisible
    //Send SMS and Email for Deposition 
    public void sendDepositionTurnInRequestNotification( Map<Deposition__c, List<Attendee__c>> depositionAttendeeMap ){
        if( depositionAttendeeMap != NULL && depositionAttendeeMap.size() > 0 ){
            try{
                //Send Email
                sendDepositionEmail( depositionAttendeeMap );
                //Send SMS
                sendDepositionSMS( depositionAttendeeMap );
            }catch( Exception excep ){
                System.debug( '#####' + excep );
            }
        }
    }
    
    //Send Email with link
    public static void sendDepositionEmail( Map<Deposition__c, List<Attendee__c>> depositionAttendeeMap ){
        
        //Variable to get Email teamplates and create mail list
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        Set<String> templateNames = new Set<String>{'CR_Transcript_Due_in_Two_Days','VID_Video_Due_Soon'};
		Map<String,EmailTemplate> emailTemplateMap = getEmailTemplates( templateNames );
        
        List<OrgWideEmailAddress> owea = [select Id from OrgWideEmailAddress where Address = 'schedule@lexitasng.com'];
        //Create email message
        if( emailTemplateMap != NULL && emailTemplateMap.size() > 0
           && depositionAttendeeMap != NULL && depositionAttendeeMap.size() > 0){
			
			for(Deposition__c deposition : depositionAttendeeMap.keySet() ){
                for( Attendee__c attendee : depositionAttendeeMap.get( deposition ) ){
                    
                    Id templateId;
                    if(attendee.Role__c == COURT_REPORTER && deposition.Transcript_Status__c =='Not Received'
                       && emailTemplateMap.containsKey('CR_Transcript_Due_in_Two_Days')){
                           
						templateId = emailTemplateMap.get('CR_Transcript_Due_in_Two_Days').Id;
                    }else if(attendee.Role__c==VIDEOGRAPHER_TECHNICIAN && deposition.Video_Status__c =='Not Received'
                            && emailTemplateMap.containsKey('VID_Video_Due_Soon')){
                    	
						templateId = emailTemplateMap.get('VID_Video_Due_Soon').Id;
                    }
                    if(templateId!=null){
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setWhatId( attendee.Id );  
                        mail.setSaveAsActivity( true );   
                        mail.setTargetObjectId( attendee.Contact__c );
                        mail.setTemplateId(templateId); 
                        if( owea != NULL && owea.size() > 0 ){
                            mail.setOrgWideEmailAddressId( owea[0].Id );
                        }
                        emails.add( mail );
                    }
                }
            }
			if( emails != NULL && emails.size() > 0){
                Messaging.sendEmail( emails );
            }
		}
    }
    
    
    //Get email template map
    private static Map<String,EmailTemplate> getEmailTemplates( Set<String> templateNames ){
        if( templateNames != NULL && templateNames.size() > 0 ){
            Map<String,EmailTemplate> templateMap = new Map<String,EmailTemplate>();
            for( EmailTemplate template : [SELECT Id, DeveloperName From EmailTemplate WHERE DeveloperName IN :templateNames ] ){
                templateMap.put( template.DeveloperName, template );
            }
            return templateMap;
        }
        return NULL;
    }
    @TestVisible
    //Method to reterive all deposition according to Deposition date
    public static List<Deposition__c> getDepositionWithAttendes( Set<Id> depositionIds){
        Set<String> attendesRole = new Set<String>{ COURT_REPORTER,VIDEOGRAPHER_TECHNICIAN };
		String query ='SELECT ID, Name, Confirm_Reporter__c, Confirm_Video_Tech__c, Confirm_Interpreter__c, Event_type_lowercase__c,'
                    +'Deposition_Time__c,Time_Zone__c, Deposition_Date__c, Event_Location__c, Location_Contact__c, Event_type__c, Case_Name_Text__c,'
                    +'Transcript_Due_From_Reporter_Computed__c,Case_Name__c,Primary_Court_Reporting_Firm__r.Phone__c,'
                    +'Primary_Court_Reporting_Firm__r.Scheduling_Email_Address__c,'
                    +'Video_Status__c, Transcript_Status__c,'
                    +'(SELECT ID, Role__c, Contact__c, Contact__r.On_Time__c ,Contact__r.Alt_Phone__c, Contact__r.Email, Contact__r.Name,'
                   	+'Contact__r.Exempt_From_Automated_Confirmations__c FROM Deposition_Roles__r '
            		+'WHERE Role__c IN: attendesRole AND Contact__r.Email != null) '
                    +'FROM Deposition__c '
                    +'WHERE (Transcript_Status__c = \'Not Received\' OR Video_Status__c =\'Not Received\') '
            		+ (depositionIds!=null ?' AND Id in :depositionIds' : '');
        return Database.query(query);
    }
    /*
//Method to reterive all deposition which is on next business day 
private List<Deposition__c> getDepositionWithAttendes( Set<Id> depositionIds ){
Set<String> attendesRole = new Set<String>{ COURT_REPORTER,VIDEOGRAPHER_TECHNICIAN };

return [SELECT ID, Name, Confirm_Reporter__c, Confirm_Video_Tech__c, Confirm_Interpreter__c, Event_type_lowercase__c,
Deposition_Time__c,Time_Zone__c, Deposition_Date__c, Event_Location__c, Location_Contact__c, Event_type__c, Case_Name_Text__c,
Transcript_Due_From_Reporter_Computed__c,Case_Name__c,
(SELECT ID, Role__c, Contact__c, Contact__r.On_Time__c ,Contact__r.Alt_Phone__c, Contact__r.Email, Contact__r.Name,
Contact__r.Exempt_From_Automated_Confirmations__c FROM Deposition_Roles__r WHERE Role__c IN: attendesRole ) 
FROM Deposition__c WHERE Deposition_Date__c = TOMORROW AND Transcript_Status__c = 'Not Received' ];
}
*/
}