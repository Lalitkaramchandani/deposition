trigger AttendeeBeforeTrigger on Attendee__c (Before Insert) {
    if(Trigger.isInsert && Trigger.isBefore)
        AttendeeHelper.beforeInsert(trigger.new);
     
}