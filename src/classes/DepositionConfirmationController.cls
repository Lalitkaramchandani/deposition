/**

    Name            :    DepositionConfirmationController
    Date            :    15 Jan 2019
    Descriptipon    :    Controller to update confirmation for attendee
*/
public class DepositionConfirmationController{
    
    //Constansts
    private static final String COURT_REPORTER = 'Court Reporter';    
    private static final String VIDEOGRAPHER_TECHNICIAN = 'Videographer/Technician';
    private static final String INTERPRETER = 'Interpreter';
    
    //Intsance Variables
    private String depositionId;
    private String contactId;
    
    //public variables
    public String message{get;set;}
    public Firm__c firm{get;set;}
    public boolean isError{get;set;}
    public Deposition__c deposition{get;set;}
    
    //Constructor
    public DepositionConfirmationController(){
    
        depositionId = ApexPages.currentPage().getParameters().get('depositionId');
        contactId = ApexPages.currentPage().getParameters().get('contactId');
        firm = DepositionHelper.fetchFirm( 'NextGen Reporting' );
        isError = FALSE;
        
        if( String.isNotBlank( contactId ) && String.isNotBlank( depositionId ) ){
            List<Deposition__c> depos = [ SELECT Id, Confirm_Reporter__c, Confirm_Video_Tech__c, Confirm_Interpreter__c, Deposition_Date__c,
                           Deposition_Time__c,Event_Location__c, Case_Name__c, Deponent_Name__c, Hiring_Attorney__c, Hiring_Firm__c,
                           Deposition_Services__c, Event_Type__c, Expedite__c, Transcript_Due_From_Reporter_Computed__c,
                           Primary_Court_Reporting_Firm__c ,
                           Event_type_lowercase__c, Time_Zone__c, Location_Contact__c,
                           ( SELECT Id, Role__c  FROM Deposition_Roles__r WHERE Contact__c  =: contactId ) 
                           FROM Deposition__c WHERE Id =: depositionId LIMIT 1];
            
            if(!depos.isEmpty()){
                deposition = depos[0];
            }
            if( deposition != NULL && deposition.Deposition_Roles__r != NULL && 
                deposition.Deposition_Roles__r.size() > 0 ){
                if(deposition.Primary_Court_Reporting_Firm__c !=null)
                    firm = [SELECT Id, Community_Header__c,Community_Footer__c, Web_Page_Footer_HTML__c , Web_Page_Header_HTML__c 
                            FROM Firm__c 
                            WHERE Id=: deposition.Primary_Court_Reporting_Firm__c  LIMIT 1];
                
                for( Attendee__c attendee : deposition.Deposition_Roles__r){
                    if( attendee.Role__c == COURT_REPORTER ){
                        deposition.Confirm_Reporter__c = 'Confirmed' ;
                    }else if( attendee.Role__c == VIDEOGRAPHER_TECHNICIAN ){
                        deposition.Confirm_Video_Tech__c = 'Confirmed';
                    }else if( attendee.Role__c == INTERPRETER ){
                        deposition.Confirm_Interpreter__c = 'Confirmed';
                    }
                } 
            }
        }
    }
    
    //Update Deposition
    public void updateDeposition(){
        isError = TRUE;
        if( deposition != NULL ){
            try{
                UPDATE deposition;
                sendDepositionSMS();
                message = 'We have Updated your Confirmation, Thanks';
                isError = FALSE;
            }catch(Exception excep ){
                message = excep.getMessage();
                
            }
        }
    }
    
    //Send SMS with link
    private void sendDepositionSMS(){
        Map<String, String> toBodyMap = new Map<String, String>();
        //Create SMS message
        if( String.isNotBlank( contactId ) && deposition != NULL ){
            Contact con = [SELECT Id, Alt_Phone__c FROM Contact WHERE Id =: contactId];
            if( con != NULL && String.isNotBlank( con.Alt_Phone__c ) ){
                String msgBody = Label.DepositionConfrimationThanksSMS;
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
                        msgBody = msgBody.replace('[Deposition_c.Deposition_Date__c]', ( deposition.Deposition_Date__c != NULL ? deposition.Deposition_Date__c.format() : '') );
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
                    if( msgBody.containsIgnoreCase( '[Deposition_c.Deponent_Name__c]' ) ){
                        msgBody = msgBody.replace('[Deposition_c.Deponent_Name__c]', ( deposition.Deponent_Name__c != NULL ? deposition.Deponent_Name__c: '') );
                    }
                    
                    if( msgBody.containsIgnoreCase( '[CheckInLink]' ) ){
                        msgBody = msgBody.replace('[CheckInLink]', (Label.SiteURL + '/OnSiteConfirmation?depositionId=' + deposition.Id + '&contactId=' +con.Id ) );
                    }
                    toBodyMap.put( con.Alt_Phone__c, msgBody );
                }
                    
            }
            System.debug('####' + toBodyMap );
            if( toBodyMap != NULL && toBodyMap.size() > 0 ){
                for( String to : toBodyMap.keySet() ){
                    // System.debug(to+'='+ toBodyMap.get(to));
                    TwilioIntegration.sendSMS( to, toBodyMap.get(to) );
                }
            }
            
        }
    }
}