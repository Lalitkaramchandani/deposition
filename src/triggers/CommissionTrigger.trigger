trigger CommissionTrigger on Commission__c (after insert, after update) {

    if(trigger.isInsert && trigger.isAfter){
        CommissionTriggerHepler.onAfterInsert(trigger.new);
    }
    
    if(trigger.isUpdate && trigger.isAfter){
        CommissionTriggerHepler.onAfterUpdate(trigger.new, trigger.oldmap);
    }
    
}