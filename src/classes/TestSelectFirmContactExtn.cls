@isTest
private class TestSelectFirmContactExtn{
    
    static testMethod void test1() {
        insert TestUtility.createFirm('NextGen Reporting');
        SelectFirmContactExtn extn = new SelectFirmContactExtn(new ApexPages.StandardController(new Contact()));
        extn.updateContactDueAmountsFromInvoice();
        extn.cont= null;
        extn.updateContactDueAmountsFromInvoice();
    }
    
}