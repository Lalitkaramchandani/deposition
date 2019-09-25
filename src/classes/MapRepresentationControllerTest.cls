@isTest
public class MapRepresentationControllerTest {

    @isTest
    private static void testMapping(){
        Account acc = TestUtility.createAccount('TestAcc1', 'TstIndustry');
        insert acc;
        Contact con = TestUtility.createContact(acc.id, 'lname', 'email@test.com');
        insert con;
        Case_Leads__c cs = TestUtility.createCaseLead();
        insert cs;
        Representation__c rep1 = TestUtility.createRepresentation(cs.id);
        rep1.Unicourt_Attorney_First_Name__c = 'FName';
        rep1.Unicourt_Attorney_Last_Name__c = 'Lname';
        rep1.Law_Firm_Text__c = 'lfirmTest';
        rep1.Unicourt_Client_Name__c = 'client1';
        Representation__c rep2 = TestUtility.createRepresentation(cs.id);
        rep2.Unicourt_Attorney_First_Name__c = 'FName';
        rep2.Unicourt_Attorney_Last_Name__c = 'Lname';
        rep2.Law_Firm_Text__c = 'lfirmTest';
        rep2.Unicourt_Client_Name__c = 'client1';
        List<Representation__c> repList = new List<Representation__c>{rep1, rep2};
        insert repList;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(rep1);
        MapRepresentationController controller = new MapRepresentationController(sc);
        PageReference pr = Page.MapRepresentation;
        Test.setCurrentPage(pr);
        pr.getParameters().put('Id',String.valueOf(rep1.Id));
        Test.startTest();
        controller.rep.Client__c = acc.id;
        controller.rep.Law_Firm__c = acc.id;
        controller.rep.Attorney__c = con.id;
        controller.updateAllReps();
		Representation__c rep2AfterUpdate = [select id,Client__c,Law_Firm__c,Attorney__c from Representation__c where id = :rep2.Id];
        System.assertEquals(acc.Id, rep2AfterUpdate.Client__c);
        System.assertEquals(acc.Id, rep2AfterUpdate.Law_Firm__c);
        System.assertEquals(con.Id, rep2AfterUpdate.Attorney__c);
        test.stopTest();
        
        
    }
}