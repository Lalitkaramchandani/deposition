/**************************************************
                Name        : TestRequestContactOwnershipExtn
                Author      : Rajendra Rathore
                Purpose     : Test class for RequestContactOwnershipExtn Apex class
                Created Date: 11 NOV 2017
                
                Modification History:
*****************************************************/
@isTest
public  class TestRequestContactOwnershipExtn{
  @isTest
  private static void Test_RequestContactOwnershipExtn(){
      Contact cont = new Contact(LastName='Test');
      insert cont;
      RequestContactOwnershipExtn extn = new RequestContactOwnershipExtn(new ApexPages.StandardController(cont));
      extn.requestOwnerShip();
  }
  
}