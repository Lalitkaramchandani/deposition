/**************************************************
                Name        : TestFilesTrigger
                Author      : Rajendra Rathore
                Purpose     : Test class for FilesTrigger 
                Created Date: 21 FEB 2017
                
                Modification History:
*****************************************************/
@isTest
public  class TestFilesTrigger{
  @isTest
  private static void Test_S3FileModel(){
        Upload_Files__c upFiles = new Upload_Files__c();
        insert upFiles;
        
        AWS_S3_Object__c file= new AWS_S3_Object__c(Upload_Files__c= upFiles.id,File_Name__c='test.png',File_Id__c='TestId');
        insert file;
        file.File_Name__c='test1.png';
        update file;
        
        delete file;
  }
}