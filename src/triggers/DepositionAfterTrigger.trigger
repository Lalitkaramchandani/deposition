/**
*                                    Name             : DepositionAfterTrigger
*                                    Date             : 24/07/2015
*                                    Description      : Deposition object after insert,after Update Trigger
*/
trigger DepositionAfterTrigger on Deposition__c  (after insert, after update) {
    DepositionHelper.checkDepositiononAdjacentDaysWithDifferentCrEmail(trigger.newmap,trigger.oldmap,Trigger.IsUpdate);
    DepositionHelper.createDefaultAttendeeFromDepositionGroup(trigger.new,Trigger.oldmap,Trigger.IsUpdate);
    if(trigger.isInsert){
        
        String jsonStr = JSON.serialize(trigger.new);
        DepositionHelper.populateGoogleDriveFolderId(jsonStr );
    }else if(Trigger.isUpdate){
        DepositionHelper.logFieldChanges(trigger.newmap,trigger.oldmap);
    }
    
   
}