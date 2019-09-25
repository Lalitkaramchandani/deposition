trigger ContactTrigger on Contact(Before update) {
    for(Contact cont: Trigger.new){
        if(cont.Assign_Requested_Owner__c  && trigger.oldmap.get(cont.id).Assign_Requested_Owner__c == false){
            cont.OwnerId= cont.Requested_Owner__c;
            cont.Assign_Requested_Owner__c   = false;
            if(cont.Requested_Commission__c != NULL)
                cont.Commission__c = cont.Requested_Commission__c;
            if(cont.Requested_Commission_Records__c!= NULL)
                cont.Commission_Records__c= cont.Requested_Commission_Records__c;
        }
    }
    if(Trigger.isUpdate && Trigger.isBefore){
        ContactTriggerHandler.onBeforeUpdateRoutine(Trigger.new, Trigger.oldMap);
    }
}