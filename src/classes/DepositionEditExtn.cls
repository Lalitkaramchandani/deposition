public class DepositionEditExtn{
    String firm= '';
    private final Deposition__c deposition;
    String oldStatus= '';
    String Deposition_Time = '';
    String Time_Zone= '';
    String Event_Location= '';
    String Case_Name= '';
    Date depDate ;
    
    String eventType='';
    String estimatedDuration = '';
    String matterNumber = ''; 
    String expedite_Level = '';
    String deponentName= '';
    String depositionServices = '';
    String hiringAttorney = '';
    String insuranceClaimInfo = '';
    String claimsProfessional = '';
    String clientNotes = '';
    Date dueDateToClient ;
    public DepositionEditExtn(ApexPages.StandardController cntrl) {
       deposition= (Deposition__c)cntrl.getRecord();
       oldStatus= deposition.Deposition_Status__c;
       Deposition_Time = deposition.Deposition_Time__c;
       Time_Zone= deposition.Time_Zone__c;
       Event_Location= deposition.Event_Location__c;
       Case_Name= deposition.Case_Name__c;
       depDate = deposition.Deposition_Date__c;
       dueDateToClient  = deposition.Due_Date_To_The_Client_Computed__c;
       eventType = deposition.Event_Type__c;
       estimatedDuration = deposition.Estimated_Duration__c;
       matterNumber = deposition.Matter_Number__c;
       expedite_Level = deposition.Expedite__c;
       
       deponentName = deposition.Deponent_Name__c;
       depositionServices = deposition.Deposition_Services__c;
       hiringAttorney = deposition.Hiring_Attorney__c;
       insuranceClaimInfo = deposition.Insurance_Claim_Info__c;
       claimsProfessional = deposition.Claims_Professional__c;
       clientNotes = deposition.Client_Notes__c;
       system.debug('$$$'+oldStatus);
    }
    
    public PageReference saveDeposition() {
       try {
           deposition.Change_Log__c = '';
           if(depDate !=deposition.Deposition_Date__c)
               deposition.Change_Log__c += 'The deposition date has been changed from '+ depDate +' to '+ deposition.Deposition_Date__c+'.\n';
           deposition.Change_Log__c = deposition.Change_Log__c.replaceAll(' 00:00:00','');
           if(Deposition_Time !=deposition.Deposition_Time__c)
               deposition.Change_Log__c += 'The deposition time has been changed from '+ Deposition_Time +' to '+ deposition.Deposition_Time__c+'.\n';
           if(Time_Zone!=deposition.Time_Zone__c)
               deposition.Change_Log__c += 'The deposition time zone has been changed from '+ Time_Zone+' to '+ deposition.Time_Zone__c+'.\n';
           if(Event_Location!=deposition.Event_Location__c )
               deposition.Change_Log__c += 'The event location has been changed from '+ Event_Location+' to '+ deposition.Event_Location__c +'.\n';
           
           if(Case_Name!=deposition.Case_Name__c )
               deposition.Change_Log__c += 'The case name has been changed from '+ Case_Name+' to '+ deposition.Case_Name__c +'.\n';
           if(oldStatus  !=deposition.Deposition_Status__c )
               deposition.Change_Log__c += 'The status has been changed from '+ oldStatus  +' to '+ deposition.Deposition_Status__c +'.\n';
           
           if(eventType!=deposition.Event_Type__c)
               deposition.Change_Log__c += 'The event type has been changed from '+ eventType+' to '+ deposition.Event_Type__c +'.\n';
           if(estimatedDuration!=deposition.Estimated_Duration__c)
               deposition.Change_Log__c += 'The estimated duration has been changed from '+ estimatedDuration+' to '+ deposition.Estimated_Duration__c+'.\n';
           if(matterNumber!=deposition.Matter_Number__c)
               deposition.Change_Log__c += 'The matter  number has been changed from '+ matterNumber+' to '+ deposition.Matter_Number__c+'.\n';
           if(expedite_Level!=deposition.Expedite__c)
               deposition.Change_Log__c += 'The expedite level has been changed from '+ expedite_Level+' to '+ deposition.Expedite__c+'.\n';    
           if(dueDateToClient  !=deposition.Due_Date_To_The_Client_Computed__c)
               deposition.Change_Log__c += 'The due date to the client has been changed from '+ dueDateToClient  +' to '+ deposition.Due_Date_To_The_Client_Computed__c+'.\n';    
           
           deposition.Change_Log__c = deposition.Change_Log__c.replaceAll(' 00:00:00','');
           
           if(deponentName !=deposition.Deponent_Name__c )
               deposition.Change_Log__c += 'The deponent name has been changed from '+ deponentName+' to '+ deposition.Deponent_Name__c +'.\n';
           if(depositionServices!=deposition.Deposition_Services__c )
               deposition.Change_Log__c += 'The deposition services has been changed from '+ depositionServices+' to '+ deposition.Deposition_Services__c +'.\n';
           if(hiringAttorney!=deposition.Hiring_Attorney__c )
               deposition.Change_Log__c += 'The hiring attorney has been changed from '+ hiringAttorney+' to '+ deposition.Hiring_Attorney__c +'.\n';
           if(insuranceClaimInfo!=deposition.Insurance_Claim_Info__c )
               deposition.Change_Log__c += 'The insurance claim info has been changed from '+ insuranceClaimInfo+' to '+ deposition.Insurance_Claim_Info__c +'.\n';
           if(claimsProfessional!=deposition.Claims_Professional__c )
               deposition.Change_Log__c += 'The claims professional has been changed from '+ claimsProfessional+' to '+ deposition.Claims_Professional__c +'.\n';
           if(clientNotes!=deposition.Client_Notes__c )
               deposition.Change_Log__c += 'The client notes has been changed from '+ clientNotes+' to '+ deposition.Client_Notes__c +'.\n';
           
           
           upsert(deposition);
       }
       catch(System.DMLException e) {
           ApexPages.addMessages(e);
           return null;
       }
       String pageURL= '' ;
       if(oldStatus!='Confirmed' && deposition.Deposition_Status__c=='Confirmed')
           pageURL +='&Confirmed=true';
       else if(oldStatus!='Cancelled' && deposition.Deposition_Status__c=='Cancelled'){
           pageURL +='&Cancelled=true';
       }
       
       
       if(Deposition_Time !=deposition.Deposition_Time__c  || Time_Zone!=deposition.Time_Zone__c|| 
          Event_Location!=deposition.Event_Location__c || Case_Name!=deposition.Case_Name__c || 
          (oldStatus !=deposition.Deposition_Status__c  && deposition.Deposition_Status__c!='Confirmed' && 
          deposition.Deposition_Status__c!='Cancelled') || depDate !=deposition.Deposition_Date__c ||
          expedite_Level!=deposition.Expedite__c || dueDateToClient  !=deposition.Due_Date_To_The_Client_Computed__c
           )
           pageURL +='&keyChanges=true';
       
               
       if(pageURL !=''){
           pageURL = '/apex/NotifyDepositionChanges?id='+deposition.id +pageURL ;
           return new PageReference(pageURL ).setRedirect(true);
       }
       return new PageReference ('/'+deposition.id);
    }

}