/**
                    Name            :  TestUpdateContactProfileExtn
                    Date            :  26/07/2015
                    Descriptiion    : Test Class for  UpdateContactProfileExtn class
*/
@isTest
private class TestUpdateContactProfileExtn{
  @isTest
  private static void Test_UpdateContactProfileExtn(){
    
    TestUtils tUtils = new TestUtils();
    Account accnt = tUtils.insertAccount();
    Contact cont = tUtils.insertContact(accnt.id);
    
    UpdateContactProfileExtn extn = new UpdateContactProfileExtn(new ApexPages.StandardController(new Contact()));
    extn.getLawSchools();
    extn.saveContact();
    
    extn = new UpdateContactProfileExtn(new ApexPages.StandardController(cont));
    extn.getLawSchools();
    extn.saveContact();
  }
}