public class GroupSelectedCasesController {
    PageReference originalPage;
    public String parentGroupName{get;set;}
    public Boolean groupingSuccessful{get;set;}
    public String message{get;set;}
    public String parentCaseId {get;set;}
    public List<case_leads__c> parentCases{get;set;}
    List<case_leads__c> cases;
    public GroupSelectedCasesController(ApexPages.StandardSetController setController){
        cases = setController.getSelected();
        parentCases = new List<case_leads__c>();
        system.debug('Casess:: '+cases);
        originalPage = setController.cancel();
        
    }
    
    public void findParentCases(){
        String nameString = '%'+parentGroupName+'%';
        parentCases = [select name, case_number__c from case_leads__c where name like :nameString];
      /*  if(parentCases.size() == 1){
            parentCaseId = parentCases[0].id;
            groupSelectedCaseLeads();
        }else */
        if(parentCases.size() > 0){
            message = 'Please select one from below list:';
        }else if(parentCases.size() < 1){
            message = 'No match found with this Name';
        }
        
    }
    
    public void groupSelectedCaseLeads(){
        
        system.debug('cases::: '+cases);
        system.debug('parentCaseId:::'+parentCaseId);
        List<Id> caseIds = new List<Id>();
        for(case_leads__c c : cases){
            c.Parent_Case__c = parentCaseId;
        }
        update cases;
        groupingSuccessful = true;
        message = 'Grouping done successfully.';
       
        
    }
    
    public pageReference gotoParent(){
         PageReference pg = new PageReference('/'+parentCaseId);
         pg.setRedirect(true);
         return pg;
    }
}