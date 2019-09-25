/**
*                                    Name             : CaseAfterTrigger 
*                                    Date             : 06/02/2015
*                                    Description      : Case__c object After Update Trigger
*/
trigger CaseAfterTrigger on Case__c (after update) {
    CaseHelper.updateDepostionInfoFromCase(trigger.newmap,trigger.oldmap);
    CaseHelper.logCaseFieldHistory(trigger.newmap,trigger.oldmap);
}