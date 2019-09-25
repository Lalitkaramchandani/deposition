trigger AccountAfterTrigger on Account(after update) {
    AccountHelper.updateAccountAttendee(trigger.new,trigger.oldmap);
}