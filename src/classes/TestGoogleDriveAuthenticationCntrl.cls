/**************************************************
                Name        : TestGoogleDriveAuthenticationCntrl
                Author      : Rajendra Rathore
                Purpose     : Test class for GoogleDriveAuthenticationCntrl Apex class
                Created Date: 12 JUNE  2016
                
                Modification History:
*****************************************************/
@isTest
public  class TestGoogleDriveAuthenticationCntrl{
  @isTest
  private static void Test_GoogleDriveAuthenticationCntrl(){
      Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
      Deposition__c dep = TestUtility.createDeposition(null);
      dep.Case_Name__c='Test';
      //insert dep;
      
      
      Test.startTest();
      ApexPages.currentPage().getParameters().put('searchText','9 day turnaround');
      GoogleDriveAuthenticationCntrl cntrl = new GoogleDriveAuthenticationCntrl(new ApexPages.StandardController(dep));
      cntrl = new GoogleDriveAuthenticationCntrl();
      system.runAs(new User(Id=UserInfo.getUserId())){
          GoogleDriveAuthenticationCntrl.getAccessToken();
          GoogleDriveAuthenticationCntrl.getFileInfo('/drive/v2/files/','test');
          cntrl.loadFilesInDataTable();
          cntrl.folderId= 'testfolder';
          cntrl.loadFilesInDataTable();
          cntrl.saveFiles();
          cntrl.searchDepositions();
          List<AWS_S3_Object__c>lstFiles = [select id from AWS_S3_Object__c LIMIT 1];
          if(lstFiles.size()>0)
              ApexPages.currentPage().getParameters().put('id',lstFiles[0].id);
          cntrl.requestFileAccess();
          
     }
      
  }
}