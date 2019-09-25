@isTest
private class TestSelectFirmExtn{
    
    static testMethod void test1() {
        insert TestUtility.createFirm('NextGen Reporting');
        SelectFirmExtn extn = new SelectFirmExtn(new ApexPages.StandardController(new Account()));
        extn.updateAccountDueAmountsFromInvoice();
        extn.accnt = null;
        extn.updateAccountDueAmountsFromInvoice();
    }
    
}