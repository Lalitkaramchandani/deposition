trigger InvoiceTrigger on Invoice__c (after update) {
    if(InvoiceEmailNotificationQueueable.SEND_NOTIFICATION){
        Set<String> attendeeRoles = new Set<String>{'Court Reporter','Videographer/Technician','Interpreter'};
        
        Set<Id> invIdsForNotification = new Set<Id>();
        Map<Id, Set<Id>> contactWithInvIds = new Map<Id, Set<Id>>();
        for(Invoice__c inv : trigger.new){
            // if changes made in amount and role is specific role then need to send email.
            if((inv.Paid_Amount__c != trigger.oldmap.get(inv.Id).Paid_Amount__c 
                || inv.Due_Amount__c != trigger.oldmap.get(inv.Id).Due_Amount__c
                ) && inv.Due_Amount__c ==0 && inv.Payment_Status__c=='Paid'
                ){
                
                if(inv.Attendee_Role__c!=NULL && attendeeRoles.contains(inv.Attendee_Role__c)){
                    invIdsForNotification.add(inv.Id);
                    if(!contactWithInvIds.containsKey(inv.Contact__c)){
                        contactWithInvIds.put(inv.Contact__c,new Set<Id>());
                    }
                    contactWithInvIds.get(inv.Contact__c).add(inv.Id);
                }
            }
        }
        if(!contactWithInvIds.isEmpty()){
            // System.enqueueJob(new InvoiceEmailNotificationQueueable(invIdsForNotification));
            // sending details by merging contacts
            System.enqueueJob(new InvoiceEmailNotificationQueueable(
                contactWithInvIds, InvoiceEmailNotificationQueueable.MIN_DATE,
                InvoiceEmailNotificationQueueable.MAX_DATE));
        }
    }
}