global with sharing class BatchSendPromoEmails implements Database.Stateful, Database.Batchable < sObject > {

    Date todayDate = system.today();
    global string query;
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }



    global void execute(Database.BatchableContext BC, List < promo_email__c > promoEmailRecList) {
        EmailTemplate et = new EmailTemplate();
        if (!promoEmailRecList.isEmpty()) {
            
            map<String,OrgWideEmailAddress>mapOrgWideEmailAddresses = new Map<String,OrgWideEmailAddress>();
            for(OrgWideEmailAddress orgEmail : [select Id,Address from OrgWideEmailAddress WHERE
                                               Address IN ('jfeggins@nextgenreporting.com','mjohnson@nextgenreporting.com', 'btucker@nextgenreporting.com')]){
                mapOrgWideEmailAddresses.put(orgEmail.Address,orgEmail);
            }
            promo_email__c promoRec = promoEmailRecList[0];
            if (promoRec.Days_After_Created_Date__c == 120) {
                System.debug('=============test 0===');
                et = [Select id, body from EmailTemplate where name = : 'Promo Email 120 Day'];
            }
            if (promoRec.Days_After_Created_Date__c == 90) {
                et = [Select id, body from EmailTemplate where name = : 'Promo Email 90 Day'];
            }
            if (promoRec.Days_After_Created_Date__c == 60) {
                et = [Select id, body from EmailTemplate where name = : 'Promo Email 60 Day'];
            }
            if (promoRec.Days_After_Created_Date__c == 30) {
                et = [Select id, body from EmailTemplate where name = : 'Promo Email 30 Day'];
            }


            if (et != null) {
                List < Messaging.SingleEmailMessage > allMails = new List < Messaging.SingleEmailMessage > ();
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                if (promoRec.From_Email__c != NULL && mapOrgWideEmailAddresses.containsKey(promoRec.From_Email__c)) {
                    mail.setOrgWideEmailAddressId(mapOrgWideEmailAddresses.get(promoRec.From_Email__c).Id);
                }
                mail.setTargetObjectId(promoRec.contact__c);
                mail.setTemplateId(et.id);
                mail.setWhatId(promoRec.id);
                mail.setSaveAsActivity(true);
                allmails.add(mail);
                if (!test.isRunningTest())
                    Messaging.sendEmail(allMails);
            }
        }
    }

    global void finish(Database.BatchableContext BC) {

    }


}