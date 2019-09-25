/**
                                Name             : VideoLinkExtn
                                Date             : 10 MARCH 2016
                                Description      : That class is used by VideoLink VF Page for redirect user to ZOOM ID URL
                                                   IF deposition date = today
*/
public class VideoLinkExtn {
    public Boolean isAttendeeFound{get;set;}
    public VideoLinkExtn(ApexPages.StandardController sc) {
        isAttendeeFound = false;
        
        List<Attendee__c>lstAttendees = new List<Attendee__c>();
        String attendeeId = ApexPages.CurrentPage().getParameters().get('attendeeId');
        String contactid = ApexPages.CurrentPage().getParameters().get('contactid');
        if(contactid != NULL && contactid.trim().length()>0){
             lstAttendees = [select Id From Attendee__c 
                           WHERE Deposition__c =: sc.getId() AND 
                           Contact__c=:contactid ];
        }else{
            lstAttendees = [select Id From Attendee__c 
                           WHERE Deposition__c =: sc.getId() AND 
                           Name=:attendeeId ];
        }                         
        if(lstAttendees.size()>0)
           isAttendeeFound = true;
      
    }

}