/**
*                                    Name             : DepositionBeforeTrigger
*                                    Date             : 06/02/2015
*                                    Description      : Deposition object before insert,Before Update Trigger
*/
trigger DepositionBeforeTrigger on Deposition__c  (before insert, before update,before delete) {
    if(Trigger.isDelete)
        DepositionHelper.blockDelete(trigger.old);
    else{
        DepositionHelper.updateDepostionVIPLevel(trigger.new,trigger.oldmap,Trigger.IsUpdate);
        DepositionHelper.updateDepostionFirm(trigger.new,trigger.oldmap,Trigger.IsUpdate);
        DepositionHelper.updateDepostionAdminORBossEmail(trigger.new,trigger.oldmap,Trigger.IsUpdate);
        DepositionHelper.populateStateRule(trigger.new,trigger.oldmap,Trigger.IsUpdate);
        DepositionHelper.updateCaseNameText(trigger.new);
   }
}