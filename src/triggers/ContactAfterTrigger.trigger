trigger ContactAfterTrigger on Contact (after update) {
    ContactHelper.updateContactAttendee(trigger.new,trigger.oldmap);
}