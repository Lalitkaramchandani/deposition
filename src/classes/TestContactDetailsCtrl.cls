/**
                        Name         : TestContactDetailsCtrl
                        Date         : 30 May 2019
                        Description  : Test class for ContactDetailsCtrl
*/
@isTest
public class TestContactDetailsCtrl {
    static void executeTestCase() {
    TestUtils tUtils = new TestUtils();
    Account accnt = tUtils.insertAccount();
    Contact cont = tUtils.insertContact(accnt.id);
    cont.email='test123@gmail.com';
    update cont;
        Test.setCurrentPageReference(new PageReference('Page.affinity'));
        System.currentPageReference().getParameters().put('id',cont.id );
        System.currentPageReference().getParameters().put('email',cont.email );
        
        ContactDetailsController rmCon = new ContactDetailsController();
        rmCon.save();
        
        Test.setCurrentPageReference(new PageReference('Page.affinity'));
        System.currentPageReference().getParameters().put('id',cont.id );
        System.currentPageReference().getParameters().put('email','rattest@gmail.com' );
        System.currentPageReference().getParameters().put('updated','1' );
        
        ContactDetailsController rmCon1 = new ContactDetailsController();
        
        
    }
     static testMethod void test_Controller() {
        executeTestCase();
    }
}