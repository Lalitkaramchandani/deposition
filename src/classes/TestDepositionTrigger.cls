/**
                    Name            :  TestDepositionTrigger
                    Date            :  26/07/2015
                    Descriptiion    : Test Class for  Deposition after insert, after update,before insert, beefore triggers
*/
@isTest
private class TestDepositionTrigger{
  
  @isTest
  private static void Test_DepositionBeforeTrigger(){
    insert TestUtils.createSignature();
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
    
  }
  @isTest
  private static void Test_eDefaultAttendeeFromDepositionGroup(){
    TestUtils tUtils = new TestUtils();
    Account account = tUtils.insertAccount();
    Contact contact = tUtils.insertContact(account.ID);
    
    Case__c cse = new Case__c(Name='Test Case');
    insert cse;
    contact.Deposition_Group__c  = cse.id;
    update contact;
    Deposition__c deposition = TestUtility.createDeposition(null);
    deposition.Deposition_Group__c  = cse.id;
    insert deposition;
    
  }  
    
  @isTest
  private static void Test_DepositionAfterTrigger(){
    Case__c cse = new Case__c(Name='Test Case');
    insert cse;
    
    
    insert TestUtils.createSignature();
    TestUtils tUtils = new TestUtils();
    Account account = tUtils.insertAccount();
    Deposition__c deposition = TestUtils.insertDepositionWithDepostionGroup(account.id,cse.id,1);
    Deposition.CR_Email_Address__c= 'test@gmail.com';
    deposition.Deposition_Group__c  = cse.id;
    update deposition;
    
    DepositionHelper.isDepositiononAdjacentDaysWithDifferentCrEmailCalled  = false;
    Deposition__c  deposition2 = TestUtils.insertDepositionWithDepostionGroup(account.id,cse.id,3);
    deposition2.Deposition_Date__c = system.today().addDays(1);
    deposition2.Deposition_Group__c  = cse.id;
    DepositionHelper.isDepositiononAdjacentDaysWithDifferentCrEmailCalled  = false;
    update deposition2;
    
    delete deposition2;
    
  }
  @isTest
  private static void Test_logFieldChanges(){
    TestUtils tUtils = new TestUtils();
    Deposition__c deposition = tUtils.createDeposition();
    
    deposition.Billing_Notes__c       ='Test Billing Notes';
    deposition.Post_event_Notes__c    ='Test Post Event Notes';
    deposition.Case_Name__c           ='Test Case Name';
    deposition.Notes__c               ='Test  Notes';
    deposition.Reporter_Instructions__c='Test Reporter Instructions';
    deposition.Special_Instructions_text__c='Test Special Instructions';
    update deposition;
  }
}