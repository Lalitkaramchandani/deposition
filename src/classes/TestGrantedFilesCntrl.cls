/**************************************************
                Name        : TestGrantedFilesCntrl
                Author      : Rajendra Rathore
                Purpose     : Test class for GrantedFilesCntrl Apex class
                Created Date: 11 JUNE 2017
                
                Modification History:
*****************************************************/
@isTest
public  class TestGrantedFilesCntrl{
  @isTest
  private static void Test_GrantedFiles(){
      GrantedFilesCntrl cntrl = new GrantedFilesCntrl();
      cntrl.getAccessFiles();
  }
  
}