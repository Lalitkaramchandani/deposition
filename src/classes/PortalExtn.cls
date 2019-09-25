/**************************************************
                Name        : PortalExtn 
                Author      : Rajendra Rathore
                Purpose     : That class are used Portal VF page in Community for Scheduling for Deposition as well as show them 
                              following things:
                                  A.) Upcomming Depositions
                                  B.) Past Depositions
                Created Date: 18 May 2016
                
                Modification History:
*****************************************************/
public class PortalExtn {
   public Boolean isSuccess{get;set;}
   private Deposition__c webdeposition;
   public Attendee__c todayDeposition{get;set;}
   public Firm__c firm{get;set;}
   public list<CollaborationGroupMember>lstChatterGroups{get;set;}
   public List<SelectOption>lstCasesOptions{get;set;}
   public string selectedCaseId{get;set;}
   public List<Deposition__c>lstConfirmTomorrowDepositions{get;set;}
   public string selectedDepId{get;set;}
   public string depSearchText{get;set;}
   User usr;
   List<Contact>lstContacts ;
   
   
   //Constructor
   public PortalExtn (ApexPages.StandardController stdController) {
       webdeposition = (Deposition__c)stdController.getRecord();
       TimeZone tz = UserInfo.getTimeZone();
       if(tz.getDisplayName().startsWith('Eastern') || tz.getDisplayName().startsWith('Central')
        || tz.getDisplayName().startsWith('Mountain') || tz.getDisplayName().startsWith('Pacific') )
           webdeposition.Time_zone__c =  tz.getDisplayName().split(' ')[0];
       webdeposition.Deposition_Status__c = 'Scheduled';
       lstCasesOptions = new List<SelectOption>();
       lstConfirmTomorrowDepositions = new List<Deposition__c>();
       String firmName = '';
       Cookie firmCookie = ApexPages.currentPage().getCookies().get('firmCookie');
        
       firmName = 'NextGen Reporting';
       if(firmCookie != null)
           firmName = firmCookie.getValue(); 
       firm= DepositionHelper.fetchFirm(firmName );
       
       webdeposition.Primary_Court_Reporting_Firm__c = firm.id;
       isSuccess = false;  
       usr = [select id,ContactId,Contact.Name,Contact.Email,Contact.Phone,Contact.Account.Name,Contact.Account.Phone,Contact.Account.Owner.Email From User Where Id=:Userinfo.getUserId()];  
       todayDeposition = new Attendee__c();
       if(usr.ContactId != NULL){
           lstContacts = [select Id,Account.Industry From Contact WHERE Id=:usr.ContactId];
           List<Attendee__c>lstAttendess = [select id,Deposition__r.Zoom_ID_URL__c,Deposition__r.Event_Type_Lowercase__c,
                                       Deposition__r.Deposition_Time__c,Deposition__r.Time_zone__C ,
                                       Deposition__r.Deponent_Name__c,Deposition__r.Case_Name__c
                                       FROM Attendee__c WHERE Deposition__r.Deposition_Date__c=:System.today() AND 
                                       Deposition__r.Deposition_Services__c includes ('LegalView (Remote Video)')
                                       AND (Contact__c=:usr.ContactId OR Deposition__r.OwnerId=:Userinfo.getUserId())
                                       AND Deposition_Status__c !='Cancelled' ORDER BY CreatedDate DESC LIMIT 1];
          if(lstAttendess.size()>0)
              todayDeposition =lstAttendess[0];
          Set<Id>setCasesIds = new Set<Id>();
          String caseId = Apexpages.currentPage().getParameters().get('caseId');
          if(caseId == '' || caseId == NULL || caseId.trim().length()==0){
              for(Attendee__c attendee : [select id,Deposition__r.Deposition_Group__c From Attendee__c
                                         WHERE Deposition__r.Deposition_Group__c != NULL AND
                                         (Contact__c=:usr.ContactId OR Deposition__r.OwnerId=:Userinfo.getUserId())]){
                  setCasesIds.add(attendee.Deposition__r.Deposition_Group__c);
              }
              if(setCasesIds.size()>0){
                  lstCasesOptions.add(new SelectOption('','--None--'));
                  for(Case__c cse : [select Id,Name From Case__c WHERE ID IN:setCasesIds ORDER BY Name ]){
                      lstCasesOptions.add(new SelectOption(cse.id,cse.name));
                  }
              }
          }
          loadTomorrowDeepositions();
         
             
      }
     
      loadChatterGroup();
   }
   public void confirmDeposition(){
       try{
           Deposition__c dep = new Deposition__c(Id=selectedDepId);
           
           for(Attendee__c attendee : [select id,Role__c,Primary_Attorney__c From Attendee__c WHERE 
                                       Deposition__c=:dep.id AND 
                                       (Role__c='Videographer/Technician' OR Role__c='Court Reporter' OR Role__c='Scheduler' OR Primary_Attorney__c=true)  
                                       AND Contact__c = : usr.ContactId]){
               if(attendee.Role__c=='Scheduler' || attendee.Primary_Attorney__c)                        
                   dep.Confirm_Client__c = 'Confirmed';
               if(attendee.Role__c=='Court Reporter')                        
                   dep.Confirm_Reporter__c = 'Confirmed';
               if(attendee.Role__c=='Videographer/Technician')                        
                   dep.Confirm_Video_Tech__c = 'Confirmed';    
                   
           }
           update dep;
           loadTomorrowDeepositions();
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Deposition successfully confirmed.'));
       }catch(Exception e){
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()));
       }
       
   }
   
   //If someone logs in the day before a deposition (either using Deposition.Next_Business_Day__c or Deposition Date - 1) 
   //please add a line to the top of the main page just like what you created when users have a LegalView deposition today.
   private void loadTomorrowDeepositions(){
      Date todayDate = system.today();
      Date tomorrowDate = System.today().addDays(1);
      String contactId= usr.ContactId;
      String userId = usr.Id;
      String qry = 'select id,Deposition__c FROM Attendee__c WHERE  Deposition__r.Deposition_Status__c != \'Cancelled\' AND ' 
                       +'(Contact__c=:contactId OR Deposition__r.OwnerId=:userId)'+
                       ' AND (Deposition__r.Next_Business_Day__c= :todayDate  OR'+
                       ' Deposition__r.Deposition_Date__c=:tomorrowDate )' +
                       'AND ( (Deposition__r.Confirm_Client__c !=\'Confirmed\' AND (Role__c=\'Scheduler\' OR Primary_Attorney__c=true))'+
                       'OR (Deposition__r.Confirm_Reporter__c !=\'Confirmed\' AND  Role__c=\'Court Reporter\' ) '+
                       'OR (Deposition__r.Confirm_Video_Tech__c !=\'Confirmed\' AND Role__c=\'Videographer/Technician\') )';
                       
                        
                       
      system.debug('###'+qry );
      
      set<Id>setDepositionIds = new Set<Id>();
      for(Attendee__c attendee : Database.Query(qry)){
          setDepositionIds.add(attendee.Deposition__c);
      }
      if(setDepositionIds.size()>0)
          lstConfirmTomorrowDepositions  = [select ID,Name,Event_Type_Lowercase__c,Deposition_Date__c,Deposition_Time__c,Time_Zone__c
                                       FROM Deposition__c WHERE ID IN :setDepositionIds];
      else
          lstConfirmTomorrowDepositions  = new List<Deposition__c >();
     
   }     
   public PageReference saveDeposition() {
       isSuccess= false;
       try {
           if(webdeposition.Deposition_Date__c == NULL){
               ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'To schedule a deposition, please enter a date. Or, to search for a deposition, please use the box at the top of the screen. Any questions? <A style="color:white;" HREF="mailto:'+ Firm.Community_Admin_Email__c+'">Send us an email</A>.'));
               return null;
           }
               
           webdeposition.Hiring_Firm__c = usr.Contact.Account.Name;
           webdeposition.GuestName__c= usr.Contact.Name;
           webdeposition.GuestEmail__c= usr.Contact.Email;
           webdeposition.GuestPhone__c= usr.Contact.Phone != NULL ? usr.Contact.Phone : usr.Contact.Account.Phone;
           upsert(webdeposition);
           addGuestAsScheduler();
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
                    List<String> ccAddresses = new List<String>();
                    if(Firm.Scheduling_email_address__c != NULL){
                        ccAddresses.add(Firm.Scheduling_email_address__c);
                    }
                   /* if(usr.Contact.Account.Owner.Email!= '' && usr.Contact.Account.Owner.Email!= NULL){
                        ccAddresses.add(usr.Contact.Account.Owner.Email);
                    } */
                    Deposition__c depowithComm = [select id, Commission__r.Primary_Rep__r.Email, Commission__r.Secondary_Rep__r.Email  from Deposition__c where id=:webdeposition.id];
                    If(depowithComm != null && String.isNotBlank(depowithComm.Commission__r.Primary_Rep__r.Email))
                    	ccAddresses.add(depowithComm.Commission__r.Primary_Rep__r.Email);
                    If(depowithComm != null &&  String.isNotBlank(depowithComm.Commission__r.Secondary_Rep__r.Email))
                    	ccAddresses.add(depowithComm.Commission__r.Secondary_Rep__r.Email);
                    mail.setTargetObjectId(usr.ContactId);
                    mail.setWhatId(webdeposition.id);
                    mail.setTemplateId(lstEmailTemplate[0].id);
                    if(ccAddresses.size()>0)
                        mail.setCCAddresses(ccAddresses);
                    allmails.add(mail);
                    Messaging.sendEmail(allMails);
               }catch(Exception e){
                   ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
                   return null;
               }
           }
           String firmId = webdeposition.Primary_Court_Reporting_Firm__c ;
           
           webdeposition = new Deposition__c();
           webdeposition.Primary_Court_Reporting_Firm__c = firmId ;
           isSuccess = true;
       }
       catch(System.DMLException e) {
           ApexPages.addMessages(e);
           return null;
       }
       
      
       
       
       return null;
       
   }
   
   private void addGuestAsScheduler() {
      Attendee__c attendee = new Attendee__c(Deposition__c = webDeposition.Id);
      attendee.Role__c = 'Scheduler';
      if(usr.ContactId != null) {
         attendee.Contact__c = usr.ContactId;
         attendee.Email__c = usr.Contact.Email;
         insert attendee;
      }

   }
   
   private void loadChatterGroup(){
       lstChatterGroups = [SELECT CollaborationGroupId,CollaborationGroup.Name From CollaborationGroupMember
                            WHERE CollaborationGroup.CollaborationType='Private' AND MemberId=:UserInfo.getUserId()];
   }
   
   public PageReference searchDepositionsRecord(){
       return new PageReference('/apex/CommunitiesAddAttendeeToDeposition?searchText='+depSearchText);
   }
  
}