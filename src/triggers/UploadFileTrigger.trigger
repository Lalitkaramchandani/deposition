/***********************************************************
*Upload File Trigger fired on Update
************************************************************/
trigger UploadFileTrigger on Upload_File__c (before update) {

  Set<String> setAttachmentID = new Set<String>();
 
  for(Upload_file__c uploadFile :Trigger.New) {
    Upload_File__c oldUploadFile = Trigger.oldMap.get(uploadFile.Id);
    if(oldUploadFile.Attachment_Check_Time__c != uploadFile.Attachment_Check_Time__c) {
      setAttachmentID.add(uploadFile.Attachment_ID__c);
    } 
  }
  
  setAttachmentID.remove(null);
  
  if(setAttachmentID.size() == 0) return;
  
  //Query Map of Attachment
  Map<Id,Attachment> mpAttachment = new Map<Id,Attachment>([SELECT Id 
                                                            FROM Attachment 
                                                            WHERE Id IN :setAttachmentID]);
  
  //Remove Attachment ID reference from the Upload File Record
  for(Upload_File__c uploadFile :Trigger.New) {
    if(!mpAttachment.containsKey(uploadFile.Attachment_ID__c)) {
      uploadFile.Attachment_ID__c = null;
    }
  } 
}