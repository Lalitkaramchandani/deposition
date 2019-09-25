trigger CaseLeadTrigger on Case_Leads__c (before Insert, before update) {
    
    if(trigger.isInsert && trigger.isBefore){
        CaseLeadTriggerHelper.onBeforeInsert(trigger.new);
    }
    if(trigger.isUpdate && trigger.isBefore){
        CaseLeadTriggerHelper.onBeforeUpdate(trigger.new, trigger.oldMap);
    }

}