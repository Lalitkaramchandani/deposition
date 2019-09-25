/**************************************************
                Name        : TestPastDepositionsCntrl
                Author      : Rajendra Rathore
                Purpose     : Test class for PastDepositionsCntrl Apex class
                Created Date: 12 JUNE  2016
                
                Modification History:
*****************************************************/
@isTest
public  class TestPastDepositionsCntrl{
    @isTest
    private static void Test_PastDepositionsCntrl(){
        TestFactory tFact = new TestFactory();
        List<Invoice__c> invoices = tFact.invoices;
        System.runAs(tFact.communtiyUser){
            PastDepositionsCntrl  cntrl = new PastDepositionsCntrl();
            cntrl.getPastDepositions();
            cntrl.selectedCaseNameChar = 'Other';
            cntrl.fetchDepositions();
            cntrl.selectedCaseNameChar = 'A';
            cntrl.getPastDepositions();
        }
    }
}