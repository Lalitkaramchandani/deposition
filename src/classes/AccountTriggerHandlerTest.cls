@isTest
public class AccountTriggerHandlerTest {
@isTest
    private static void testMethod1(){
        String AccName = 'TestName XYX';
        Account acc = new Account();
        acc.AKA__c = AccName;
        acc.AKA_Law_Firm__c = AccName;
        acc.name = 'AccTestName';
       
        insert acc;
        acc.AKA__c = AccName+';'+AccName+';'+AccName;
        acc.AKA_Law_Firm__c = AccName+';'+AccName+';'+AccName;
        acc.Assign_Requested_Owner__c = true;
        acc.Requested_Owner__c = UserInfo.getUserId();
        update acc;
        Account acc1 = [select id,AKA_Law_Firm__c,AKA__c from Account where id = :acc.Id];
       // system.assertEquals(AccName, acc1.AKA_Law_Firm__c);
       // system.assertEquals(AccName, acc1.AKA__c);
    }
}