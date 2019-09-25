/**************************************************
                Name        : TestRequestAccountOwnershipExtn
                Author      : Rajendra Rathore
                Purpose     : Test class for RequestAccountOwnershipExtn Apex class
                Created Date: 11 NOV 2017
                
                Modification History:
*****************************************************/
@isTest
public  class TestRequestAccountOwnershipExtn{
  @isTest
  private static void Test_RequestAccountOwnershipExtn(){
      Account accnt= new Account(Name='Test');
      insert accnt;
      RequestAccountOwnershipExtn extn = new RequestAccountOwnershipExtn(new ApexPages.StandardController(accnt));
      extn.requestOwnerShip();
  }
  
}