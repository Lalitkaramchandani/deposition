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
private class TestBatchSendMeetingEmail {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        Test.startTest();
         Account account = new Account(Name='Test Account');
         insert account;
    Contact contact = new Contact(lastname='Test Contact',email='test@test.com',accountid=account.id);
    insert contact;
        Email_Signature__c em=new Email_Signature__c(footer__c='Hello',Header1__c='Test',Header2__c='Test3',text4__c='Test4',text5__c='Test5');
        insert em;
        deposition__c dep=new deposition__c(GuestEmail__c='test@test.com',notification_date__c=system.today());
        insert dep;
        
            BatchSendMeetingEmail brd=new BatchSendMeetingEmail();
                 
               Database.executebatch(brd);
        Test.stopTest();
        }
        }