/**************************************************
                Name        : TestS3FileModel
                Author      : Rajendra Rathore
                Purpose     : Test class for S3FileModel Apex class
                Created Date: 10 JULY 2016
                
                Modification History:
*****************************************************/
@isTest
public  class TestS3FileModel{
  @isTest
  private static void Test_S3FileModel(){
      S3FileModel cntrl = new S3FileModel(new AWS_S3_Object__c(),false);
      cntrl.FileSize =100;
      cntrl.UploadedDate = System.now();
      cntrl.modifiedDate= System.now();
      cntrl.lastModifiedBy= 'Test';
      cntrl.fileType = 'Test';
      cntrl.OwnerName= 'Test';
  }
}