/**
                                    Name             : TestDepositionAssignmentCntrl
                                    Date             : 11 Jan 2016
                                    Descripition     : Test Class for DepositionAssignmentCntrl class.
*/                                   
@isTest
private class TestDepositionAssignmentCntrl{

    @isTest
    private static void Test_DepositionAssignmentCntrl() {
        /*Account account = TestUtility.createAccount('Test Account','Court Reporting');
        insert account;
        
        Deposition__c deposition = TestUtility.createDeposition(account.id);
        deposition.Event_Location__c= 'His Prison Cell Folsom, CA 94123';
        deposition.Corporate_Client_Source__c = 'Allstate';
        deposition.Deposition_Date__c = sytem.today();
        insert deposition;
        */
        TestUtils tUtils = new TestUtils();
        Account account = tUtils.insertAccount();
        Deposition__c deposition = tUtils.createDeposition();
        Contact contact = tUtils.insertContact(account.ID);
        Firm__c firm = new Firm__c(Name='NextGen Reporting');
        insert firm;
        deposition.Deposition_Date__c = System.today()+1;
        deposition.Primary_Court_Reporting_Firm__c =firm.id;
        update deposition;
        DepositionAssignmentCntrl cntrl = new DepositionAssignmentCntrl();
        
        for(DepositionAssignmentCntrl.DepositionModel depModel : cntrl.lstTomorrowDepositions){
            depModel.reporter.Court_Reporter__c  = depModel.videographer.Videographer__c = contact.id;
        }
        cntrl.saveDepositions();
        
        Test.StartTest();
           cntrl = new DepositionAssignmentCntrl(); 
        Test.StopTest();
    }


}