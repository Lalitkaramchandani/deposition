/*****************************************************************
*Created on : July 23rd, 2012
*Purpose : Deposition date is used on Attendee as formula field,
           hence any time date is changed we need to udpate Attendee records
           Secondly since Depostion and Attendee are master detail
           upon deletion of Depostion, there will be no trigger on attendee, handle that as well
******************************************************************/
trigger computeContactSummary_Deposition on Deposition__c (after update,before delete,after delete,after undelete) {
  
  //Deletion needs special handling, because before contains the Contact ID that will need to be processed
  if(Trigger.isDelete) {
    if(Trigger.isBefore) {
      ContactRollUp.setRelatedContacts(Trigger.Old);
    }
    else {
   	  ContactRollUp.computeSummaryForDeletedDeposition(); //Processedd the saved ids
    }
    return;
  }
  
  //Handle undelete and update operations
  List<Deposition__c> lstDeposition = new List<Deposition__c>();
  for(Deposition__c deposition :Trigger.New) {
    if(Trigger.isUnDelete) {
       lstDeposition.add(deposition);
       continue;
    }
    
    Deposition__c oldDeposition = Trigger.oldMap.get(deposition.Id);
    if(oldDeposition.Deposition_Date__c != deposition.Deposition_Date__c) {
      lstDeposition.add(deposition);
    }
  }
 
  
  if(lstDeposition.size() > 0) {
    ContactRollup contactRollup = new ContactRollup();
    contactRollup.computeSummaryForDeposition(lstDeposition);  
  }

}