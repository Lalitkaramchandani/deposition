@isTest
public class ContactTriggerHandlerTest {
	@isTest
    private static void testMethod1(){
        String testAttName = 'TestName XYX';
        Contact con = new contact();
        con.AKA_Attorney__c = testAttName;
        con.FirstName = 'ConName';
        con.LastName = 'LastName';
        insert con;
        con.AKA_Attorney__c = testAttName+';'+testAttName+';'+testAttName;
        con.Assign_Requested_Owner__c = true;
        con.Requested_Owner__c = UserInfo.getUserId();
        update con;
        Contact con1 = [select id,AKA_Attorney__c from contact where id = :con.Id];
        //system.assertEquals(testAttName, con1.AKA_Attorney__c);
    }
}