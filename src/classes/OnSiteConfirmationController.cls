/**
    Name        :        OnSiteConfirmationController
    Date        :        5 Feb 2019
    Description :        Schedule class to send email and sms reminder one day before deposition
    Developer
*/
public class OnSiteConfirmationController{
    private String depositionId;
    private String contactId;
    private Attendee__c attendee;
    
    //Intsance Variables
    public Deposition__c deposition{get;set;}
    public Firm__c firm{get;set;}
    public Boolean isError{get;set;}
    
    public OnSiteConfirmationController(){
        depositionId = ApexPages.currentPage().getParameters().get('depositionId');
        contactId = ApexPages.currentPage().getParameters().get('contactId');
        firm = DepositionHelper.fetchFirm( 'NextGen Reporting' );
        isError = false;
        if( String.isNotBlank( contactId ) && String.isNotBlank( depositionId ) ){
            List<Deposition__c> depos = [ SELECT Id, Confirm_Reporter__c, Confirm_Video_Tech__c, Confirm_Interpreter__c, Deposition_Date__c,
                           Deposition_Time__c,Event_Location__c, Case_Name__c, Deponent_Name__c, Hiring_Attorney__c, Hiring_Firm__c,
                           Deposition_Services__c, Event_Type__c, Expedite__c, Transcript_Due_From_Reporter_Computed__c,
                           Event_type_lowercase__c, Time_Zone__c, Location_Contact__c,
                           Primary_Court_Reporting_Firm__c,
                           ( SELECT Id, Role__c  FROM Deposition_Roles__r WHERE Contact__c  =: contactId ) 
                           FROM Deposition__c WHERE Id =: depositionId LIMIT 1];
            if(!depos.isEmpty()){
                deposition = depos[0];
            }else{
                isError = true;
                return;
            }
            
            firm = [SELECT Id, Name, Community_Header__c,Community_Footer__c, Web_Page_Footer_HTML__c , Web_Page_Header_HTML__c,
                    Scheduling_Email_Address__c, Phone__c
                        FROM Firm__c 
                        WHERE Id=: deposition.Primary_Court_Reporting_Firm__c  LIMIT 1];
                            
            List<Attendee__c> attendees = [SELECT Id, Arrival_Time__c 
                                            FROM Attendee__c WHERE Deposition__c =: depositionId AND Contact__c =: contactId LIMIT 1];
            if(!attendees.isEmpty()){
                attendee = attendees[0];
            }
        }
    }
    
    //Update On site check in date time
    public void manitainAttendee(){
        if( deposition != NULL && attendee != NULL ){
            try{
                attendee.On_site_Check_In__c = System.now();
                UPDATE attendee;
                isError = FALSE;
            }catch(Exception excep ){
                isError = true;
            }
        }
    }
}