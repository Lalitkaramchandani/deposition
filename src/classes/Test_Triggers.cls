@isTest
private class Test_Triggers {
  
  @isTest
  private static void Test_PromoEmailTrigger() {
    TestUtils utils = new TestUtils();
    Account account = utils.insertAccount();
    Contact contact = utils.insertContact(account.Id);
    
    Active_Trigger__c activeTrigger = Active_Trigger__c.getInstance();
    if(activeTrigger == null) {
      activeTrigger = new Active_Trigger__c();
    }
    activeTrigger.Promo_Email__c = true;
    upsert activeTrigger;
    
    Promo_Email__c promoEmail = new Promo_Email__c(Contact__c = contact.Id);
    insert promoEmail;
  }
  
  @isTest
  private static void Test_AttendeeTrigger() {
    TestUtils utils = new TestUtils();
    Account account = utils.insertAccount();
    Contact contact = utils.insertContact(account.Id);
    
    Deposition__c deposition = utils.insertDeposition(account.ID);
    deposition.Generate_Change_Log__c = true;
    deposition.Billing_Notes__c = 'Changd';
    
    update deposition;
    
    Deposition_Location__c depositionLocation = utils.createDepositionLocation(deposition);
    Attendee__c attendee = utils.insertAttendee(contact.Id, deposition.ID);
    
  }
  
  @isTest
  private static void Test_TaskTrigger() {
    Account account = new Account(Name = 'ssssss');
    insert account;
  
    Contact contact = new Contact(LastName = 'SSSS');
    insert contact;
    
    Task task = new task(Subject = 'sss',ActivityDate = System.today());
    task.WhoId = contact.Id;
    insert task;
  }
}