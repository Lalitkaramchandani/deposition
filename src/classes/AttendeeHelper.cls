public class AttendeeHelper{
    public static Boolean isDespositonUpdatedCalled = false;
    public static void sendEmailAlertForMultipleJobsOnSameDay(List<Attendee__c>lstAttendees){
        set<Id>setContactIds = new Set<Id>();
        set<Id>setDepIds = new Set<Id>();
        List<Date>lstDates= new List<Date>();
        List<Attendee__c>lstCourtAndVideoAttendees = new List<Attendee__c>();
        for(Attendee__c attendee : lstAttendees){
            if(attendee.Deposition_Date__c != NULL && attendee.Deposition_Status__c != 'Cancelled'
             && (attendee.Role__c=='Court Reporter' || attendee.Role__c =='Videographer/Technician') && 
            (attendee.Industry__c == 'Court Reporting' || 
                attendee.Industry__c == 'Videography')){
                setContactIds.add(attendee.Contact__c);    
                lstDates.add(attendee.Deposition_Date__c);
                setDepIds.add(attendee.Deposition__c);
                lstCourtAndVideoAttendees.add(attendee);
            }
        }
        if(setContactIds.size()>0){
            Map<String,Attendee__c>mapDateWithAttendee = new Map<String,Attendee__c>();
            for(Attendee__c attendee : [select id,Deposition_Date__c,Contact__c,Deposition__r.LastModifiedById,Deposition__c   FROM Attendee__c
                                         WHERE Id NOT IN :lstCourtAndVideoAttendees  AND Contact__c 
                                         IN:setContactIds AND Deposition_Date__c IN : lstDates AND Deposition__c NOT IN :setDepIds
                                         AND Deposition_Status__c !='Cancelled']){
                mapDateWithAttendee.put(attendee.Deposition_Date__c.format()+'-'+attendee.Contact__c ,attendee);    
            }
            if(mapDateWithAttendee.size()>0){
                List<Attendee__c>lstAttendeeNeedUpdate = new List<Attendee__c>();
                for(Attendee__c  attendee : lstCourtAndVideoAttendees){
                    String keyValue = attendee.Deposition_Date__c.format()+'-'+attendee.Contact__c;
                    if(mapDateWithAttendee.containsKey(keyValue)){
                        Attendee__c newAttendee = new Attendee__c(id=attendee.id);
                        newAttendee.Deposition_Last_Modified_By__c = mapDateWithAttendee.get(keyValue).Deposition__r.LastModifiedById;
                        newAttendee.Send_Multiple_Jobs_On_Same_Day__c = true;
                        lstAttendeeNeedUpdate.add(newAttendee );
                    }
                        
                }
                if(lstAttendeeNeedUpdate.size()>0)
                    update lstAttendeeNeedUpdate;
            }
           
        }
        
    }
    public static void sendEmailAlertToReporterAndVideographer(List<Attendee__c>lstAttendees){
        lstAttendees = [select Id, Name,Role__c,Contact_Email__c,Deposition__c,Contact__c FROM Attendee__c WHERE ID IN :lstAttendees];
        Map<string,Id>mapEmailTemplate = new Map<String,Id>();
        for(EmailTemplate email : [select id,DeveloperName  From EmailTemplate
                                  WHERE DeveloperName IN ('Videographer_Confirmation_Tomorrow_WF','CR_Confirmation_Tomorrow_WF')]){
            mapEmailTemplate.put(email.DeveloperName,email.id);
        }
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        List<OrgWideEmailAddress >lstOrgWideEmailAddress = [SELECT id, Address 
                                                            FROM OrgWideEmailAddress 
                                                            where Address ='depos@wilfet.com'];
                                                            
        for(Attendee__c attendee : lstAttendees){
            if(attendee.Contact_Email__c != NULL && attendee.Contact_Email__c !='' &&
              (attendee.Role__c=='Court Reporter' || attendee.Role__c =='Videographer/Technician')){
                  Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                  if(attendee.Role__c=='Court Reporter' )
                      mail.setTemplateId(mapEmailTemplate.get('CR_Confirmation_Tomorrow_WF'));
                  else
                      mail.setTemplateId(mapEmailTemplate.get('Videographer_Confirmation_Tomorrow_WF'));
                  mail.setTargetObjectId(attendee.Contact__c);
                  mail.setWhatId(attendee.Deposition__c); 
                  if(lstOrgWideEmailAddress.size()>0)
                      mail.setOrgWideEmailAddressId(lstOrgWideEmailAddress[0].id);
                  mailList.add(mail);
                 
            }
        }
        if(mailList.size()>0){
             Messaging.sendEmail(mailList);
        }
    }
    public static void updateDepostionVIPLevel(List<Attendee__c>lstAttendees){
        AttendeeHelper.isDespositonUpdatedCalled = true;
        set<Id>setDespositionIds = new Set<Id>();
        for(Attendee__c attendee : lstAttendees){
            setDespositionIds.add(attendee.Deposition__c);
        }
        if(setDespositionIds.size()>0){
            map<id,Boolean>mapDepostionVIP1 = new Map<Id,Boolean>();
            for(Attendee__c attendee : [select id,Deposition__c, VIP_Level__c From Attendee__c  WHERE Deposition__c IN : setDespositionIds AND VIP_Level__c='VIP 1']){
                mapDepostionVIP1.put(attendee.Deposition__c,true);
            }
            
            map<id,Boolean>mapDepostionVIP2 = new Map<Id,Boolean>();
            for(Attendee__c attendee : [select id,Deposition__c, VIP_Level__c From Attendee__c  WHERE Deposition__c IN : setDespositionIds AND VIP_Level__c='VIP 2']){
                mapDepostionVIP2.put(attendee.Deposition__c,true);
            }
            
            List<Deposition__c>lstNeedUpdateDespostions = new List<Deposition__c>();
            for(Deposition__c depostion : [select id,Name,VIP_Level__c From Deposition__c WHERE Id in : setDespositionIds ]){
                if(mapDepostionVIP1.containsKey(depostion.id) && depostion.VIP_Level__c != 'VIP 1' ){
                    depostion.VIP_Level__c = 'VIP 1';
                    lstNeedUpdateDespostions.add(depostion);
                }
                if(mapDepostionVIP1.containsKey(depostion.id) == false && mapDepostionVIP2.containsKey(depostion.id) && depostion.VIP_Level__c != 'VIP 2' ){
                    depostion.VIP_Level__c = 'VIP 2';
                    lstNeedUpdateDespostions.add(depostion);
                }
            }
            
            if(lstNeedUpdateDespostions.size()>0)
                update lstNeedUpdateDespostions;
        }
    }
    
    public static void beforeInsert(List<Attendee__c> lstAttendee){
        for(Attendee__c att: lstAttendee){
            if(att.email_parent_account_owner__c!=null && !String.isblank(att.email_parent_account_owner__c)){
                att.Email_of_Parent_Account__c=att.email_parent_account_owner__c;
            }
        }
    
    }
    
    public static void updateDepositionPostEventNotes(List<Attendee__c>lstAttendees, map<Id,Attendee__c>oldmap,Boolean isUpdate){
        
        set<Id>setDespositionIds = new Set<Id>();
        List<Attendee__c>lstAttendeesNeedUpdateToDep= new List<Attendee__c>();
        for(Attendee__c attendee : lstAttendees){
            if((attendee.Role__c =='Videographer/Technician' || attendee.Role__c =='Court Reporter'  )
               && attendee.Recap_Notes__c !=NULL && (isUpdate==false || (attendee.Role__c != oldmap.get(attendee.id).Role__c || 
               attendee.Recap_Notes__c != oldmap.get(attendee.id).Recap_Notes__c ))){
                setDespositionIds.add(attendee.Deposition__c);
                lstAttendeesNeedUpdateToDep.add(attendee);
            }
        }
        if(setDespositionIds.size()>0){
            Map<Id,Deposition__c>mapDepositions = new Map<Id,Deposition__c>([select id,Post_event_Notes__c FROM Deposition__c WHERE ID IN:setDespositionIds]);
            for(Attendee__c attendee : lstAttendeesNeedUpdateToDep){
                Deposition__c dep = mapDepositions.get(attendee.Deposition__c);
                if(dep.Post_event_Notes__c == NULL)
                    dep.Post_event_Notes__c = '';
                if(attendee.Role__c =='Videographer/Technician'){
                   dep.Post_event_Notes__c += '\n '+ attendee.Contact_Name__c + ' Technician:'+ attendee.Recap_Notes__c;
                }else if(attendee.Role__c =='Court Reporter'){
                   dep.Post_event_Notes__c += '\n '+ attendee.Contact_Name__c + ' Court Reporter:'+ attendee.Recap_Notes__c;
                }
                mapDepositions.put(attendee.Deposition__c,dep );
            }
            if(mapDepositions.size()>0)
                update mapDepositions.values();
        }
    }
}