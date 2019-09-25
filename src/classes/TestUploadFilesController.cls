@isTest
private class TestUploadFilesController {
  
  @isTest
  private static void Test_UploadFiles(){
    Amazon_S3_Configuration__c awsKey = new Amazon_S3_Configuration__c(Key__c='test',Secret__c='test');  
    insert awsKey;
    AWS_S3_ExampleController c = new AWS_S3_ExampleController();
    
    c.constructor();
    c.createBucket();
    Upload_Email_Notification__c emailNotification = new Upload_Email_Notification__c(Email_For_All_File_Type__c='test@gmail.com',Email_For_Invoice__c='test@gmail.com');
    insert emailNotification ;
    TestUtils tUtils = new TestUtils();
    Deposition__c deposition = tUtils.createDeposition();
    
    UploadFilesController fileController = new UploadFilesController();
    fileController.initForUploadPage();
    
    fileController.uploadFiles.Deposition_Number__c = 'aaaaa';
    fileController.SaveFiles();
    
    String name = [SELECT Name from Deposition__c WHERE ID = :deposition.Id].Name;
    fileController.uploadFiles.Deposition_Number__c = name;
    
    fileController.SaveFiles();
    
    Account account = tUtils.insertAccount();
    Contact contact = tUtils.insertContact(account.ID);
    tUtils.insertAttendee(contact.Id, deposition.ID);
    
    
     
    
    fileController.uploadFiles.Email__c = contact.Email;
    fileController.SaveFiles();
     ApexPages.currentPage().getParameters().put('id',fileController.uploadFiles.id);
    fileController.dragDropUploadInit();
    UploadFilesController.fetchFileNameWithVersionRemote('Test.jpg','testBucket');
    UploadFilesController.createAwsS3Object('Test.jpg','testfolder', 'test123', fileController.uploadFiles.id,'', 'test',
                                          100,1);
    UploadFilesController.createAwsS3Object('Test.jpg','testfolder', 'test124', fileController.uploadFiles.id,'', 'test',
                                          100,1);
    UploadFilesController.createAwsS3Object('Test.jpg','testfolder',  'test125', fileController.uploadFiles.id,'', 'test',
                                          100,1);                                                                    
    UploadFilesController.fetchFileNameWithVersionRemote('Test.jpg','testBucket');
    fileController.fetchAWSS3Objects();
    Integer i= 1;
    for(AWS_S3_Object__c obj : fileController.lstAWSS3Objects){
        if(i==1 ) obj.File_Type__c = 'Invoices';
        if(i==2 ) obj.File_Type__c = 'Transcript';
        if(i==3 ) obj.File_Type__c = 'Exhibit';
        i++;
    }
    List<Attendee__c> lstAttendee =[SELECT Id,Email__c,Role__c FROM Attendee__c WHERE Deposition__c = :deposition.ID];
    if(lstAttendee.size()>0){
        lstAttendee[0].Role__c = 'Videographer/Technician';
        update lstAttendee;
    }
    fileController.saveAndSendEmail();
    if(lstAttendee.size()>0){
        lstAttendee[0].Role__c = 'Court Reporter';
        update lstAttendee;
    } 
    
    fileController.saveAndSendEmail();
    fileController.SaveFiles();
    
    ApexPages.currentPage().getParameters().put('id',name );
    ApexPages.currentPage().getParameters().put('email',contact.Email);
    fileController = new UploadFilesController();
    fileController.initForUploadPage();
  }
  
  
  @isTest
  private static void Test_UploadFile(){
    Amazon_S3_Configuration__c awsKey = new Amazon_S3_Configuration__c(Key__c='test',Secret__c='test');  
    insert awsKey;
    AWS_S3_ExampleController c = new AWS_S3_ExampleController();
    
    c.constructor();
    c.createBucket();
    Upload_Email_Notification__c emailNotification = new Upload_Email_Notification__c(Email_For_All_File_Type__c='test@gmail.com',Email_For_Invoice__c='test@gmail.com');
    insert emailNotification ;
    TestUtils tUtils = new TestUtils();
    
    
    UploadFilesController fileController = new UploadFilesController();
    fileController.init();
    fileController.initForUploadPageWithoutTemplate();
    
    
    fileController.SaveFiles();
    
    
    fileController.SaveFiles();
    
    Account account = tUtils.insertAccount();
    Contact contact = tUtils.insertContact(account.ID);
    
    fileController.uploadFiles.Email__c = 'test12@gmail.com';
    fileController.SaveFiles();
    ApexPages.currentPage().getParameters().put('id',fileController.uploadFiles.id);
    fileController.dragDropUploadInit();
    UploadFilesController.fetchFileNameWithVersionRemote('Test.jpg','testBucket');
    UploadFilesController.createAwsS3Object('Test.jpg','testfolder', 'test123', fileController.uploadFiles.id,'', 'test',
                                          100,1);
    UploadFilesController.createAwsS3Object('Test.jpg','testfolder', 'test124', fileController.uploadFiles.id,'', 'test',
                                          100,1);
    UploadFilesController.createAwsS3ObjectAmazon('Test.jpg','testfolder',  'test125', fileController.uploadFiles.id,'', 'test',
                                          100,1);                                      
    UploadFilesController.fetchFileNameWithVersionRemote('Test.jpg','testBucket');
    fileController.fetchAWSS3Objects();
    Integer i= 1;
    for(AWS_S3_Object__c obj : fileController.lstAWSS3Objects){
        if(i==1 ) obj.File_Type__c = 'Invoices';
        if(i==2 ) obj.File_Type__c = 'Transcript';
        if(i==3 ) obj.File_Type__c = 'Exhibit';
        i++;
    }
    fileController.saveAndSendEmail();
    fileController.SaveFiles();
  }
}