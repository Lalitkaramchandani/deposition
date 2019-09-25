@isTest
private class TestLeadGenCaseBatch {
    
  @isTest
    private static void test_LeadGenCaseBatchs(){
        Account account = TestUtility.createAccount('Hendel & Collins, P.C.','Court Reporting');
        insert account;
        
        List<Contact> conList = new List<Contact>();
        Contact contact = TestUtility.createContact(account.ID,'Philip L. Bednar', 'test@test.com');
        conList.add(contact);
        Contact contact1 = new Contact(Firstname='Eileen', LastName = 'McAuliffe',Email = 'test@test.com',CR_Status__c = 'A - Great');
        conList.add(contact1);
        insert conList;
        Case_Leads__c case1 = new Case_Leads__c(Case_Name__c = 'testCase',Unicourt_Case_ID__c  ='EI6RCFI4E46S6EL6MIVFQ63AKVDAY1011');
        insert case1;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        database.executeBatch(new LeadGenCaseBatch(new set<String>{'EI6RCFI4E46S6EL6MIVFQ63AKVDAY1011'}),50);
    }
    @isTest
    private static void test_LeadGenCaseUpsertBatch(){
        Account account = TestUtility.createAccount('Hendel & Collins, P.C.','Court Reporting');
        insert account;
        
        List<Contact> conList = new List<Contact>();
        Contact contact = TestUtility.createContact(account.ID,'Philip L. Bednar', 'test@test.com');
        conList.add(contact);
        Contact contact1 = new Contact(Firstname='Eileen', LastName = 'McAuliffe',Email = 'test@test.com',CR_Status__c = 'A - Great');
        conList.add(contact1);
        insert conList;
        Case_Leads__c case1 = new Case_Leads__c(Case_Name__c = 'testCase',Unicourt_Case_ID__c  ='EI6RCFI4E46S6EL6MIVFQ63AKVDAY1011');
        insert case1;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        database.executeBatch(new LeadGenCaseUpsertBatch(new set<String>{'EI6RCFI4E46S6EL6MIVFQ63AKVDAY1011'}),50);
    }
   
}