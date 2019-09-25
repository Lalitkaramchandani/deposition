/**************************************************
                Name        : TestGrantingFileAccessToUsersExtn
                Author      : Rajendra Rathore
                Purpose     : Test class for GrantingFileAccessToUsersExtn Apex class
                Created Date: 13 JUNE  2016
                
                Modification History:
*****************************************************/
@isTest
public  class TestGrantingFileAccessToUsersExtn{
  @isTest
  private static void Test_GrantingFileAccessToUsersExtn(){
      Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
      Deposition__c dep = TestUtility.createDeposition(null);
      dep.Case_Name__c='Test';
      insert dep;
      
      dep.GOOGLE_DRIVE_FOLDER_ID__C  = 'testFolderId';
      update dep;
      ApexPages.currentPage().getParameters().put('folderId','testfolderId');
      User usr = TestUtility.createCommunityUser();
      
      Contact con = new Contact(LastName='Test',Email='test@gmail.com');
      insert con;
      Attendee__c attendee = TestUtility.createAttendee(con.id,dep.id);
      insert attendee;
      
          ApexPages.currentPage().getParameters().put('searchText','9 day turnaround');
          GrantingFileAccessToUsersExtn cntrl = new GrantingFileAccessToUsersExtn(new ApexPages.StandardController(dep));
          system.runAs(new User(Id=UserInfo.getUserId())){
              Test.startTest();
                  cntrl.init();
                  cntrl = new GrantingFileAccessToUsersExtn(new ApexPages.StandardController(dep));
                  cntrl.callInitFullTextSearch();
                  if( cntrl.lstFiles == NULL){
                       cntrl.lstFiles = new List<S3FileModel >();
                       cntrl.lstFiles.add(new S3FileModel(new AWS_S3_Object__c(File_Name__c='test',File_Id__c='test'),false))   ;
                  }
                  for(S3FileModel s3File : cntrl.lstFiles){
                      s3File.isSelected= true;
                  }
                  cntrl.saveFiles();  
                  cntrl.selectedUsers = new List<SelectOption>();
                  cntrl.selectedUsers.add(new selectOption(attendee.id,attendee.id));
                  cntrl.NotifyRecipients=true;
                  cntrl.fetchUploadBatch();
                  cntrl.grantAccess();
             Test.stoptest();
         }
         
         GrantedFilesCntrl cntrl2 = new GrantedFilesCntrl ();
         cntrl2.getAccessFiles();
         
  }
  
  
  @isTest
  private static void Test_method2(){
      Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
      Deposition__c dep = TestUtility.createDeposition(null);
      dep.Case_Name__c='Test';
      /*insert dep;
      ApexPages.currentPage().getParameters().put('folderId','testfolderId');
      User usr = TestUtility.createCommunityUser();
      
      Contact con = [select id,accountId From Contact LIMIT 1];
      Attendee__c attendee = TestUtility.createAttendee(con.id,dep.id);
      insert attendee;*/
      Test.startTest();
          ApexPages.currentPage().getParameters().put('searchText','9 day turnaround');
          GrantingFileAccessToUsersExtn cntrl = new GrantingFileAccessToUsersExtn(new ApexPages.StandardController(dep));
          system.runAs(new User(Id=UserInfo.getUserId())){
              
              cntrl.init();
              cntrl = new GrantingFileAccessToUsersExtn(new ApexPages.StandardController(dep));
              cntrl.callInitFullTextSearch();
              if( cntrl.lstFiles == NULL)
                   cntrl.lstFiles = new List<S3FileModel >();
              
         }
  }
    @isTest
    private static void Test_manual(){
      Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        TestFactory tFact = new TestFactory();
        List<Invoice_Item__c> items = tFact.invoiceItems;
        List<Contact> contacts = tFact.contacts;
        List<Deposition__c> depositions = tFact.depositions;
        List<Attendee__c> attendees = tFact.attendees;
        
        
        Upload_Files__c upFile = new Upload_Files__c (Contact__c=contacts[0].Id, Deposition__c  = depositions[0].Id);
        insert upFile;
        List<AWS_S3_Object__c> s3 = new List<AWS_S3_Object__c>();
        s3.add(new AWS_S3_Object__c(File_Type__c='Deposition Notice', Deposition__c= depositions[0].Id, 
                                    File_Name__c='test',Upload_Files__c=upFile.id ));
        insert s3;
        File_Access__c fl =  new File_Access__c(Attendee__c=attendees[0].Id, File__c =s3[0].Id);
        insert fl;
        
        Test.startTest();
        ApexPages.currentPage().getParameters().put('fileId',s3[0].Id);
        GrantingFileAccessToUsersExtn cntrl = new GrantingFileAccessToUsersExtn(new ApexPages.StandardController(depositions[0]));
        cntrl.goBack();
        cntrl.callInitFullTextSearch();
        if( cntrl.lstFiles == NULL || cntrl.lstFiles.isEmpty()){
            cntrl.lstFiles = new List<S3FileModel >();
            cntrl.lstFiles.add(new S3FileModel(new AWS_S3_Object__c(File_Name__c='test',File_Id__c='test',Upload_Files__c=upFile.id),false));
            cntrl.lstFiles.add(new S3FileModel(new AWS_S3_Object__c(File_Name__c='test2',File_Id__c='test2',Upload_Files__c=upFile.id),false));
        }
        cntrl.init();
        cntrl.initFullTextSearch(new Set<String>{'s'});
        cntrl.loadS3Files(new Set<String>{'s'});
        for(S3FileModel s3File : cntrl.lstFiles){
            s3File.isSelected= true;
        }
        cntrl.saveFiles();
        cntrl.selectedDepFileIndex=0;
        cntrl.updateDepFileType();
        cntrl.fetchUploadBatch();
        cntrl.grantAccess();
        
        Test.stopTest();
    }
}