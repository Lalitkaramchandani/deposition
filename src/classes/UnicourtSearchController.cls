/*
 * Name : UnicourtSearchController
 * Author: Jitendra
 * Test Class: UnicourtSearchControllerTest
 */
public class UnicourtSearchController {
    public String selectedSearchScope{get;set;}
    public Case_Leads__c caselead;
    public string searchValue{get;set;}
    public Integer pageSize{get;set;}
    public UnicourtSearchResultParser parser {get;set;}
    public Map<String, Boolean> Map_UnicourtCase_IsImportedFlag{get;set;}
    public Map<String, Case_Leads__c> AlreadyImportedCaseMap{get;set;}
    public UnicourtSearchResultParser.Case_Z selectedCase {get;set;}
    public String selectedCaseId{get;set;}
    public Map<String,UnicourtSearchResultParser.Case_Z> unicourtCaseMap{get;set;}
    public Boolean showSuccessMsg{get;set;}
    List<String> prohibitedStatusList = new List<String>{'Other Disposed','Terminated','Arbitration'};
    List<String> prohibitedCaseTypeList = new List<String>{'Commercial Eviction','Consumer Credit','Controlled Substance/Drug','Debt Collection','Declaratory Judgment ','Eminent Domain ','Expungement ','Foreclosure ','Franchise ','Government Benefit Recovery','Land','Marriage Dissolution/Divorce','Minor Compromise Claim','Other Family','Other Forfeiture','Other Prisoner','Other Tax','Residential Eviction','State Statute Constitutionality','Trust','Uninsured Motor Vehicle','Withdrawal','Writ Of Mandamus'};
    public UnicourtSearchController(){
        showSuccessMsg = false;
        pageSize = 5;
    }
    public void searchCasesInUnicourt(){
        Integer i = 0;
        unicourtCaseMap = new Map<String,UnicourtSearchResultParser.Case_Z>();
        Map_UnicourtCase_IsImportedFlag = new Map<String, Boolean>();
        AlreadyImportedCaseMap = new Map<String, Case_leads__c>();
        do{
            i++;
            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            string endPoint = 'https://api.unicourt.com/rest/v1/search/?token=2a8c48f7019a286dae3ddd7f43a96622a9ccc669';
            req.setEndpoint(endPoint);
            req.setTimeout(60*1000);
            String json = '{"query":[';
            json = json + '{"search_terms":["'+searchValue+'"],"attribute":"'+selectedSearchScope+'"}';
            json = json + '],"page":'+i+'}';
               // json = json+',"filters" : [{"filter_type":"case_status", "field": "name", "keys" : [1,2,3,4,6]},{"filter_type":"case_status", "field": "name", "keys" : [7,8,9,10,11]},{"filter_type":"case_status", "field": "name", "keys" : [12,13,14,15,16]}]}';
            system.debug('json::'+json);
            req.setBody(json);
            req.setHeader('Content-Type', 'application/json');
            Http h = new Http();
            String resp;
            HttpResponse res = h.send(req);
            resp = res.getBody();
            system.debug('resp:::'+resp);
            parser = UnicourtSearchResultParser.parse(resp);
            if(!parser.error){
                for(UnicourtSearchResultParser.Result result : parser.data.result){
                    if(!prohibitedStatusList.contains(result.case_Z.case_status_name) && !prohibitedCaseTypeList.contains(result.case_Z.case_type)){
                        unicourtCaseMap.put(result.case_Z.case_id, result.case_Z);
                        Map_UnicourtCase_IsImportedFlag.put(result.case_Z.case_id, false);
                        
                    }
                }
                
            }else{
                break;
            }
            if(i >=100)
                break;
        }while(!Test.isRunningTest());
        // check if case is already imported
        for(Case_leads__c cl : [select id, Unicourt_Case_ID__c from case_leads__c where Unicourt_Case_ID__c in :unicourtCaseMap.keySet()]){
            Map_UnicourtCase_IsImportedFlag.put(cl.Unicourt_Case_ID__c, true);
            AlreadyImportedCaseMap.put(cl.Unicourt_Case_ID__c, cl);
        }
        
    }
    
    public void upsertCase(){
        selectedCase = unicourtCaseMap.get(selectedCaseId);
        caselead = new Case_Leads__c(Unicourt_Case_ID__c = selectedCase.case_id);
        caselead.Case_Name__c = selectedCase.case_name;
        caselead.Case_Status__c = selectedCase.case_status_name;
        caselead.Case_Number__c = selectedCase.case_number;
        caselead.Case_Status_Category__c = selectedCase.case_status_category;
        caselead.Case_Type__c = selectedCase.case_type;
        caselead.Case_Type_Category__c = selectedCase.case_type_category;
        caselead.Courthouse__c = selectedCase.courthouse;
        caselead.Filing_Date__c = Date.valueof(selectedCase.filing_date);
        caselead.Jurisdiction__c = selectedCase.jurisdiction;
        caselead.Last_Updated__c = Date.valueOf(selectedCase.last_updated_date);
        caselead.State__c = selectedCase.state;
        caselead.Dockets__c = selectedCase.docket;
        caselead.LastSFDCUpdatedfromUnicourt__c = System.today();
        try{
            upsert caselead Unicourt_Case_ID__c;
            Map_UnicourtCase_IsImportedFlag.put(caselead.Unicourt_Case_ID__c, true);
            AlreadyImportedCaseMap.put(caselead.Unicourt_Case_ID__c, caselead);
            LeadGenCaseBatch batch = new LeadGenCaseBatch(new set<String>{selectedCase.case_id});
            if(!Test.isRunningTest())
                Database.executeBatch(batch);
            showSuccessMsg = true;
        }catch(Exception e){
            system.debug('e.getMessage():::'+e.getMessage());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
            system.debug('page messages:::'+ApexPages.getMessages());
        }
    }
    
    public void resetShowMsgFlag(){
        showSuccessMsg = false;
    }
    public PageReference redirectToImportedCase(){
        resetShowMsgFlag();
        PageReference pr = new PageReference('/'+caselead.Id);
        pr.setRedirect(true);
        return pr;
    }
    
}