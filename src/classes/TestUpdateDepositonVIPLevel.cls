@isTest
private class TestUpdateDepositonVIPLevel{
  
  @isTest
  private static void Test_UpdateDepositonVIPLevel(){
   
    TestUtils tUtils = new TestUtils();
    Deposition__c deposition = tUtils.createDeposition();
    
    
    
    
    Account account = tUtils.insertAccount();
    Contact contact = tUtils.insertContact(account.ID);
    tUtils.insertAttendee(contact.Id, deposition.ID);
    
    account.VIP_Level__c = 'VIP 1';
    update account;
    contact.VIP_Level__c = 'VIP 2';
    update contact;
    
  }

}