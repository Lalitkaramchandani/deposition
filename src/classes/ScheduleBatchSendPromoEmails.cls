global with sharing class ScheduleBatchSendPromoEmails implements Schedulable{
     global void execute(SchedulableContext sc)
     {
            String query='Select End_Date__c, Date__c,contact__r.email,Days_After_Created_Date__c ,'+
                         'Created_Date1__c From Promo_Email__c  where Send_Promo_Email__c=true AND  End_Date__c!=null and'+
                         ' End_Date__c>TODAY  AND Case_Type__c!=\'Multi-party IP Case\' and (Days_After_Created_Date__c= 30 or '+
                         +'Days_After_Created_Date__c=60 or Days_After_Created_Date__c = 90 or Days_After_Created_Date__c=120)';
       
            BatchSendPromoEmails brd = new BatchSendPromoEmails();
            brd.query          = query;
            
            Database.executebatch(brd,1);

     }   
}