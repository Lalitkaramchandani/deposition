@isTest
private class TestConfirmDepositionController{
    
    @isTest
    private static void Test_ConfirmDeposition(){
        
        TestUtils tUtils = new TestUtils();
        Deposition__c deposition = tUtils.createDeposition();
        
        ConfirmDepositionController cntrl = new ConfirmDepositionController();
        cntrl.updateDeposition();
        
        
        ApexPages.currentPage().getParameters().put('type','test3');
        cntrl.updateDeposition();
        String name = [SELECT Name from Deposition__c WHERE ID = :deposition.Id].Name;
        
        
        Account account = tUtils.insertAccount();
        Contact contact = tUtils.insertContact(account.ID);
        tUtils.insertAttendee(contact.Id, deposition.ID);
        
        
        
        ApexPages.currentPage().getParameters().put('id',deposition.ID );
        ApexPages.currentPage().getParameters().put('code','434343423');
        ApexPages.currentPage().getParameters().put('type','V');
        cntrl = new ConfirmDepositionController();
        cntrl.updateDeposition();
        
        ApexPages.currentPage().getParameters().put('code',deposition.ID);
        
        cntrl.updateDeposition();
        ApexPages.currentPage().getParameters().put('type','C');
        cntrl.updateDeposition();
        ApexPages.currentPage().getParameters().put('type','R');
        cntrl.updateDeposition();
    }
    
    private static testMethod void testConfirm() {
        TestFactory tFact = new TestFactory();
        List<Deposition__c> depositions = tFact.depositions;
        
        Test.startTest();
        ApexPages.currentPage().getParameters().put('code',depositions[0].Id);
        ConfirmDepositionController control = new ConfirmDepositionController();
        control.validateDespositionAndAttendees(depositions[0].Name, depositions[0].Id);
        Test.stopTest();
    }
    
}