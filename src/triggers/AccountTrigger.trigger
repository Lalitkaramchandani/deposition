trigger AccountTrigger on Account (Before update) {
    for(account accnt : Trigger.new){
        if(accnt.Assign_Requested_Owner__c  && trigger.oldmap.get(accnt.id).Assign_Requested_Owner__c == false){
            accnt.OwnerId= accnt.Requested_Owner__c;
            accnt.Assign_Requested_Owner__c   = false;
            if(accnt.Requested_Commission__c != NULL)
                accnt.Commission__c = accnt.Requested_Commission__c;
             if(accnt.Requested_Commission_Records__c!= NULL)
                accnt.Commission_Records__c= accnt.Requested_Commission_Records__c;
        }
    }
    if(Trigger.isUpdate && Trigger.isBefore){
        AccountTriggerHandler.onBeforeUpdateRoutine(Trigger.new, Trigger.oldMap);
    }
}