/**************************************************
                Name        : TestConfirmEmailCtrl
                Author      : Lalit karamchandani
                Purpose     : This is used to allow user to select deposition and attendee(s) and send email confirmation/recap
                Created Date: 22 Apr 2019
                
                
*****************************************************/
public class TestConfirmEmailCtrl {

    public Invoice__c inv{get;set;}
    public Deposition__c dep{get;set;}
    public String selectedAttendees{get;set;}
    
    public List<SelectOption> attendees{get;set;}
    public Map<Id, Attendee__c> attendeeMap{get;set;}
    
    public TestConfirmEmailCtrl(){
        inv = new Invoice__c();
        resetAttendees();
    }
    
    void resetAttendees(){
        attendees = new List<SelectOption>{new SelectOption('','--none--')};
        attendeeMap = new Map<Id, Attendee__c>();
        selectedAttendees = '';
    }
    /*
    public void onSendTest(){
        Map<Deposition__c, List<Attendee__c>> depositionAttendeeMap = new Map<Deposition__c, List<Attendee__c>>();
        depositionAttendeeMap.put(new Deposition__c(Id=inv.Deposition__c),new List<Attendee__c>{new Attendee__c(Contact__c = inv.Contact__c)});
        DepositionReminderScheduler reminder = new DepositionReminderScheduler();
        reminder.sendDepositionEmail(depositionAttendeeMap);
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Contact will get an Email, check the email'));
    }
    */
    public void onDepChange(){
        resetAttendees();
        dep = NULL;
        if(inv.Deposition__c!=NULL){
            dep = [SELECT Id, Confirm_Reporter__c, Confirm_Video_Tech__c, Confirm_Interpreter__c, Deposition_Status__C
                    FROM Deposition__c WHERE Id=:inv.Deposition__c];
            
            for(Attendee__c att : [SELECT Id, Contact__c, Contact__r.Name, Role__c 
                                    From Attendee__c WHERE Deposition__c = : inv.Deposition__c
                                    AND Role__c in ('Court Reporter','Videographer/Technician','Interpreter')]){
                attendees.add(new SelectOption(att.Id, att.Contact__r.Name+'('+att.Role__c+')'));
                attendeeMap.put(att.Id,att);
            }
            
        }
    }
    public void onSendConfirmationNotification(){
        // System.debug(selectedAttendees);
        if(String.isNotBlank(selectedAttendees)){
            String conId = attendeeMap.get(selectedAttendees).Contact__c;
            // System.debug(conId);
            DepositionReminderScheduler reminder = new DepositionReminderScheduler();
            reminder.setIncludeTimeZone(false);
            reminder.setContactIds(new Set<Id>{conId});
            reminder.processNotification(new set<Id>{inv.Deposition__c});
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Contact will get an Email AND SMS, check the email'));
        }
    }
    public void onSendRecapNotification(){
        if(String.isNotBlank(selectedAttendees)){
            String conId = attendeeMap.get(selectedAttendees).Contact__c;
            DepositionDayReminderScheduler reminder = new DepositionDayReminderScheduler();
            reminder.setIncludeTimeZone(false);
            reminder.setContactIds(new Set<Id>{conId});
            reminder.processNotification(new set<Id>{inv.Deposition__c});
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Contact will get an Email AND SMS, check the email'));
        }
    }
}