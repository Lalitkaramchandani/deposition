/**
                    Name             : TestRateSheetCloneExtn
                    Date             : 08 Dec 2015
                    Descripition     : Test Class for RateSheetCloneExtn class.
*/                                   
@isTest
private class TestRateSheetCloneExtn {

    @isTest
    private static void TestRateSheetCloneExtn() {
        Rate_Sheet__c rateSheet = new Rate_Sheet__c(name='Allstate',Type__c='Reporter');
        insert rateSheet;
        Item__c itemrec=new Item__c(Type__c='Transcript');
        insert itemrec;
        
        Rate_Sheet_Item__c rateSheetItem=new Rate_Sheet_Item__c(Item__c=itemrec.id,Rate_Sheet__c=rateSheet.id);
        insert rateSheetItem;
        
        ApexPages.StandardController sc = new ApexPages.standardController(rateSheet);
        RateSheetCloneExtn eController = new RateSheetCloneExtn(sc);
        eController.cloneWithItems();
         
        
       
    }
       
}