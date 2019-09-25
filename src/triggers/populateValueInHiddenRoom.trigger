trigger populateValueInHiddenRoom on Deposition_Location__c (before insert,before update) {
  
  for(Deposition_Location__c location :Trigger.New) {
    if(isChangedRoom(location)) {
      if(location.Room__c == null) {
        location.Hidden_Room_Value__c = String.valueOf(System.now());
      }
      else {
        location.Hidden_Room_Value__c = location.Room__c;
      }
    }
  }
  
  private Boolean isChangedRoom(Deposition_Location__c location) {
    if(Trigger.isInsert) return true;
    Deposition_Location__c oldLocation = Trigger.oldMap.get(location.Id);
    if(oldLocation.Room__c != location.Room__c) {
      return true;
    }
    return false;
  }
  
}