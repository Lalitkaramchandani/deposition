//==========================================================================//
//Populate Account Owner Email address in the Email field
//==========================================================================//
trigger PromoEmailTrigger on Promo_Email__c(before insert, before update, after insert, after update) {

    Active_Trigger__c activeTrigger = Active_Trigger__c.getInstance();
    if (activeTrigger != null && activeTrigger.Promo_Email__c == false) {
        return;
    }

    if (Trigger.isAfter && Trigger.isInsert) {
        List < Messaging.SingleEmailMessage > lstEmailMessage = new List < Messaging.SingleEmailMessage > ();
        Map<String,String>mapEmailTemplates = new Map<String,String>();
        for(EmailTemplate emailTemplate : [SELECT Id,DeveloperName FROM EmailTemplate
                                        WHERE DeveloperName = 'Promo_Email_Standard'
                                        OR DeveloperName = 'Promo_Email_0_Day' OR DeveloperName ='Plaintiff_Email'
                                        OR DeveloperName ='IP_Case']){
            mapEmailTemplates.put(emailTemplate.DeveloperName,emailTemplate.id);                            
        }
        if (mapEmailTemplates.size() == 0) return;
        List<Promo_Email__c>lstPromoEmailsNeedUpdate = new List<Promo_Email__c>();
        map<String,OrgWideEmailAddress>mapOrgWideEmailAddresses = new Map<String,OrgWideEmailAddress>();
        for(OrgWideEmailAddress orgEmail : [select Id,Address from OrgWideEmailAddress WHERE
                                           Address IN ('ekerpius@nextgenreporting.com','jfeggins@nextgenreporting.com','mjohnson@nextgenreporting.com', 'btucker@nextgenreporting.com')]){
            mapOrgWideEmailAddresses.put(orgEmail.Address,orgEmail);
        }
        for (Promo_Email__c promoEmail: Trigger.New) {

            if (promoEmail.Send_Promo_Email__c && (promoEmail.Case_Type__c == 'Multi-party IP Case' || promoEmail.Case_Type__c == 'Discovery Alert from CL' || promoEmail.Case_Type__c =='Traditional' || promoEmail.Case_Type__c=='Plaintiff Special Offer')) {
                if (isSentStatusChanged(promoEmail)) {
                    Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
                    String emailTemplateName = promoEmail.Case_Type__c == 'Discovery Alert from CL' ?'Promo_Email_0_Day':'Promo_Email_Standard';
                    if(promoEmail.Case_Type__c == 'Plaintiff Special Offer')
                        emailTemplateName = 'Plaintiff_Email';
                    if(promoEmail.Case_Type__c == 'Multi-party IP Case'){
                        msg.setCCAddresses(new List<String>{'ekerpius@nextgenreporting.com'});
                        emailTemplateName = 'IP_Case';
                    }
                        
                    if(mapEmailTemplates.containsKey(emailTemplateName)){
                        msg.setTemplateID(mapEmailTemplates.get(emailTemplateName));
                        msg.setWhatId(promoEmail.Id);
                        msg.setSaveAsActivity(true);
                        msg.setTargetObjectId(promoEmail.Contact__c);
                        if (promoEmail.Contact__c != null) {
                            if (promoEmail.From_Email__c != NULL && mapOrgWideEmailAddresses.containsKey(promoEmail.From_Email__c)) {
                                msg.setOrgWideEmailAddressId(mapOrgWideEmailAddresses.get(promoEmail.From_Email__c).Id);
                            }
                            lstEmailMessage.add(msg);
                            lstPromoEmailsNeedUpdate.add(new Promo_Email__c(Id=promoEmail.id,Sent__c=true));
                        }
                    }
                }
            }
        }
        if(lstEmailMessage.size()>0){
            Messaging.sendEmail(lstEmailMessage);
            update lstPromoEmailsNeedUpdate;
        }
    }

    private Boolean isSentStatusChanged(Promo_Email__c promoEmail) {
        if (Trigger.isInsert) {
            return (promoEmail.Sent__c == false);
        }
        Promo_Email__c oldPromoEmail = Trigger.oldMap.get(promoEmail.Id);
        if (oldPromoEmail.Sent__c == false && promoEmail.Sent__c == false) {
            return true;
        }
        return false;
    }

    if (Trigger.isBefore) {
        Map < Id, Contact > mpContact = new Map < Id, Contact > ();
        List < Promo_Email__c > lstPromoEmail = new List < Promo_Email__c > ();

        //Check the Records which have their promo Email changed
        for (Promo_Email__c promoEmail: Trigger.New) {
            if (isContactChanged(promoEmail)) {
                mpContact.put(promoEmail.Contact__c, null);
                lstPromoEmail.add(promoEmail);
            }
            if (promoEmail.Contact__c == null) {
                promoEmail.Account_Owner_Email__c = null;
            }
            if(promoEmail.Case_Type__c == 'Multi-party IP Case')
                promoEmail.From_Email__c= 'ekerpius@nextgenreporting.com';
        }

        if (mpContact.size() == 0) return;

        //Query Contacts
        mpContact = new Map < Id, Contact > ([SELECT Account.Owner.Email FROM Contact WHERE Id IN: mpContact.keyset()]);

        //Loop over and populate the values
        for (Promo_Email__c promoEmail: lstPromoEmail) {
            Contact contact = mpContact.get(promoEmail.Contact__c);
            if (contact != null) {
                promoEmail.Account_Owner_Email__c = contact.Account.Owner.Email;
            }
        }
    }

    //===================================================================//
    //Check if Contact Changed
    //===================================================================//
    private Boolean isContactChanged(Promo_Email__c promoEmail) {
        if (Trigger.isInsert) {
            return (promoEmail.Contact__c != null);
        }
        Promo_Email__c oldPromoEmail = Trigger.oldMap.get(promoEmail.Id);
        if (oldPromoEmail.Contact__c != promoEmail.Contact__c) {
            return true;
        }
        return false;
    }

}