trigger TaskTriggers on Task (after insert,after update) {
  TaskManagement.updateAccount(Trigger.New);
}