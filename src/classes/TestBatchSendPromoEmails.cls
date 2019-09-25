/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestBatchSendPromoEmails {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        
         Account account = new Account(Name='Test Account');
         insert account;
    Contact contact = new Contact(lastname='Test Contact',accountid=account.id,Email='test@gmail.com');
    insert contact;
    Active_Trigger__c setting = new Active_Trigger__c(Promo_Email__c=true);
    insert setting;
    
    Promo_Email__c promoEmail = new Promo_Email__c(Contact__c = contact.Id);
    insert promoEmail;
        
         Test.startTest();
         
            
            Date todayDate = system.today();
            String query='Select   p.End_Date__c, p.Date__c,contact__r.email,Days_After_Created_Date__c ,Created_Date1__c From Promo_Email__c p  where p.End_Date__c!=null and End_Date__c>:todayDate and (p.Days_After_Created_Date__c= 30 or p.Days_After_Created_Date__c=60 or p.Days_After_Created_Date__c = 90 or p.Days_After_Created_Date__c=120)';
       
                BatchSendPromoEmails brd=new BatchSendPromoEmails();
                 brd.query=query;
                
               Database.executebatch(brd);
        Test.stopTest();
    }
}