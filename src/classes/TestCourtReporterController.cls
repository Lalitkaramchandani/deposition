@isTest
public class TestCourtReporterController {
    @isTest
    private static void Test_CourtReportController() {
        TestUtils utils = new TestUtils();
        Account account = utils.insertAccount();
        Deposition__c deposition = utils.insertDeposition(account.ID);
        
        Contact contact = utils.insertContact(account.Id);
        
        ApexPages.Standardcontroller sController = new ApexPages.StandardController(deposition);
        ApexPages.currentPage().getParameters().put('ctcId','1');
        CourtReporterController courtReportController = new CourtReporterController(sController);
        courtReportController.selectedType = 'Court Reporter';
        courtReportController.keywordSearch = 'aa';
        courtReportController.showOtherAccount = true;
        courtReportController.Search();
        courtReportController.getTypeOptions();
        courtReportController.SendEmail();
        courtReportController.keywordSearch = '';
        courtReportController.Search();
        
        
        
        courtReportController.SendEmail();
        courtReportController.getEmailTemplateId();
        //courtReportController.dispatchEmail(null,null);
    }
}