@isTest
private class TestCaseAfterTrigger{
  
  @isTest
  private static void Test_CaseAfterTrigger(){
   
    TestUtils tUtils = new TestUtils();
    Deposition__c deposition = tUtils.createDeposition();
    
    Account account = tUtils.insertAccount();
    Contact contact = tUtils.insertContact(account.ID);
    account.VIP_Level__c = 'VIP 1';
    update account;
    contact.VIP_Level__c = 'VIP 2';
    update contact;
    
    Case__c cse = new Case__c(Name='Test Case');
    insert cse;
    deposition.Deposition_Group__c  = cse.id;
    update deposition;
    
    cse.VIP_Level__c = 'VIP 2';
    cse.Billing_Notes__c= 'Test Billing Notes';
    cse.Production_Notes__c = 'Test Production Notes';
    cse.Video_Notes__c= 'Test Video Notes';
    cse.Description__c= 'Test Description';
    cse.Name ='Test Case New';
    update cse;
  }

}