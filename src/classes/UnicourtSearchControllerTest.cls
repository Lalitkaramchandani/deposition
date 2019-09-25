@isTest
private class UnicourtSearchControllerTest {
	
    @isTest
    private static void searchCasesInUnicourtTest(){
        PageReference pr = Page.UnicourtSearch;
        Test.setCurrentPage(pr);
        pr.getParameters().put('searchValue','Wallmart');
        pr.getParameters().put('selectedSearchScope','Attorney');
        UnicourtSearchController controller = new UnicourtSearchController();
        Test.setMock(HttpCalloutMock.class, new SearchAPICalloutMock());
        controller.searchCasesInUnicourt();
        // selectedCaseID value
        for(String caseid : controller.unicourtCaseMap.keySet()){
         controller.selectedCaseId =  caseid;
            break;
        }
        system.debug('controller.selectedCaseId:::'+controller.selectedCaseId);
        controller.upsertCase();
    }
    
}