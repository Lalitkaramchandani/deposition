@isTest
private class UploadFileController_Test {
  
  @isTest
  private static void Test_UploadFile(){
    TestUtils tUtils = new TestUtils();
    Deposition__c deposition = tUtils.createDeposition();
    
    UploadFileController fileController = new UploadFileController();
    fileController.validateFile();
    
    fileController.uploadFile.Deposition_Number__c = 'aaaaa';
    fileController.saveFile();
    
    String name = [SELECT Name from Deposition__c WHERE ID = :deposition.Id].Name;
    fileController.uploadFile.Deposition_Number__c = name;
    fileController.getUploadDocument().Name = 'sss';
    fileController.getUploadDocument().Body = Blob.valueOf('hello');
    
    fileController.saveFile();
    
    Account account = tUtils.insertAccount();
    Contact contact = tUtils.insertContact(account.ID);
    tUtils.insertAttendee(contact.Id, deposition.ID);
    
    fileController.uploadFile.Email__c = contact.Email;
    fileController.saveFile();
  }
  
  
  @isTest
  private static void Test_UploadFile2(){
    TestUtils tUtils = new TestUtils();
    Deposition__c deposition = tUtils.createDeposition();
    
    UploadFileController fileController = new UploadFileController();
    String name = [SELECT Name from Deposition__c WHERE ID = :deposition.Id].Name;
    fileController.uploadFile.Deposition_Number__c = name;
    fileController.getUploadDocument().Name = 'sss';
    fileController.getUploadDocument().Body = Blob.valueOf('hello');
    
    Account account = tUtils.insertAccount();
    Contact contact = tUtils.insertContact(account.ID);
    tUtils.insertAttendee(contact.Id, deposition.ID);
    
    fileController.uploadFile.Email__c = contact.Email;
    fileController.saveFile();
    
    Upload_File__c uploadFile = [SELECT Attachment_Check_Time__c FROM Upload_File__c Limit 1];
    uploadFile.Attachment_Check_Time__c = System.now();
    update uploadFile;
    
  }
}