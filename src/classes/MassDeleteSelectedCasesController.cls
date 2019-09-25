public class MassDeleteSelectedCasesController {
	PageReference originalPage;
    List<case_leads__c> cases;
    public MassDeleteSelectedCasesController(ApexPages.StandardSetController setController){
        cases = setController.getSelected();
        system.debug('Casess:: '+cases);
        originalPage = setController.cancel();
        
    }
    
    public PageReference redirectBack(){
        
        system.debug('cases::: '+cases);
        List<Id> caseIds = new List<Id>();
        for(case_leads__c c : cases){
            caseIds.add(c.Id);
        }
        // add Unicourt case ids to metadata before deleting case.
        List<Blocked_Unicourt_Case__c> blockedCases = new List<Blocked_Unicourt_Case__c>();
        for(case_leads__c c : [select id,Unicourt_Case_ID__c from case_leads__c where id in :caseIds]){
            if(String.isNotBlank(c.Unicourt_Case_ID__c)){
                Blocked_Unicourt_Case__c buc = new Blocked_Unicourt_Case__c(Unicourt_Case_Id__c=c.Unicourt_Case_ID__c);
                blockedCases.add(buc);
            }
        }
        if(blockedCases.size() > 0)
            insert blockedCases;
        if(cases.size() > 0)
            delete cases;
        
        originalPage.setRedirect(true);
        return originalPage;
        /*
        Schema.DescribeSObjectResult result = Case_Leads__c.SObjectType.getDescribe();
        
        PageReference pg = new PageReference('/'+result.getKeyPrefix());
        pg.setRedirect(true);
        return pg; */
    }
}