/*********************************************************************************
* Created On : 24th July,2012
* Purpose : Every contact record should show 
           a)total number of times that they have been an attendee
           b)most recent time they have been an attendee

 * Pseudo Code :
   Every a new attendee is created, and contact != null, collect contact ID
   If a Attendee is updated and contact changed, collect contactID
   if a Attendee record is deleted, collect contact record ID
   if a Attendee record is undeleted, collect contact record ID
   
  *Invoke the common class for computing summary on Contact
**********************************************************************************/
trigger computeContactSummary on Attendee__c (after insert,after update,after delete,after undelete) {
  
  Set<ID> setContactId = new Set<ID>();
  //The List which is to iterated
  List<Attendee__c> lstAttendee = new List<Attendee__c>();
  //Except for Delete all have Trigger.New records
  //lstAttendee = 
  
  for(Attendee__c attendee : Trigger.isDelete ? Trigger.Old : Trigger.New) {
  	//For update trigger, check if the contact value has changed, if not, no computation is needed
  	if(Trigger.isUpdate) {
  	  Attendee__c oldAttendee = Trigger.oldMap.get(attendee.Id);
  	  if(oldAttendee.Contact__c ==  attendee.Contact__c) {
  	    continue; 
  	  }
  	  addContact(oldAttendee);
  	}
  	addContact(attendee);
  }
  
  //Call method for computation on Contact
  if(setContactId.size() > 0) {
    ContactRollup contactRollup = new ContactRollup();
    contactRollup.computeCountAndMaxDate(setContactId);
  }
  
  
  private void addContact(Attendee__c attendee) {
    if(attendee.Contact__c != null) {
     setContactId.add(attendee.Contact__c);
    }
  }
  
}