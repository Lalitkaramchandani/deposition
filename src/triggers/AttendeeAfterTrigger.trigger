trigger AttendeeAfterTrigger on Attendee__c (after Insert,After Update,After Delete) {
    if(AttendeeHelper.isDespositonUpdatedCalled == false)
        AttendeeHelper.updateDepostionVIPLevel(Trigger.isDelete?trigger.old:trigger.new);
    /*if(Trigger.isInsert)
         AttendeeHelper.sendEmailAlertToReporterAndVideographer(trigger.new);
      */ 
   if(trigger.isinsert || Trigger.isUpdate ){
       AttendeeHelper.updateDepositionPostEventNotes(trigger.new,trigger.oldmap,trigger.isUpdate);  
   } 
   
   if(Trigger.isAfter && Trigger.isInsert)
       AttendeeHelper.sendEmailAlertForMultipleJobsOnSameDay(trigger.new);
    
    //Send Email and SMS
    if( Trigger.isAfter && Trigger.isInsert ){
        AttendeeHelper.sendDepositionNotification( Trigger.new );
    }
}