@isTest
private class NewCaseAsgmtTemplateCtlrTest {
	@isTest
    private static void prepareRepListTest(){
        Account account = TestUtility.createAccount('Hendel & Collins, P.C.','Court Reporting');
        insert account;
        Contact contact = TestUtility.createContact(account.ID,'Philip L. Bednar', 'test@test.com');
        insert contact;
        Case_Leads__c case1 = new Case_Leads__c(Case_Name__c = 'testCase',Unicourt_Case_ID__c  ='EI6RCFI4E46S6EL6MIVFQ63AKVDAY1011');
        insert case1;
        Commission__c comm = new Commission__c(Name='TestCommission', Active__c=true);
        insert comm;
        Representation__c rep = new Representation__c(Case__c = case1.Id, Unicourt_Client_Name__c='Test Client', Law_Firm_Text__c='Test LAw Firm', attorney__c = contact.id);
        
        Representation__c rep1 = new Representation__c(Case__c = case1.Id, Unicourt_Client_Name__c='Test Client1', Law_Firm_Text__c='Test LAw Firm1', attorney__c = contact.id, Commission__c = comm.id);
        List<Representation__c> repList = new List<Representation__c>{rep, rep1};
        insert repList;
        
        NewCaseAsgmtTemplateCtlr con = new NewCaseAsgmtTemplateCtlr();
        con.setcaseleadId(case1.id);
    }
}