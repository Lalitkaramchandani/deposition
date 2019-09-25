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
              /*for(S3FileModel s3File : cntrl.lstFiles){
                  s3File.isSelected= true;
              }
              //cntrl.saveFiles();  
              cntrl.grantAccess();*/
         }
  }
}