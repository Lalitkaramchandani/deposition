public class updateCaseWebhookController {
    
    public void init(){
        //Map<String, CaseParser> mapCaseLeads = new Map<String,CaseParser >();
        try{
            String json = ApexPages.currentpage().getParameters().get('data');
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            UpdateAPIResParse parseObj	= UpdateAPIResParse.parse(json);
            if(parseObj.result.Status == 'has_update'){
                String caseUniCourtId = parseObj.result.case_id;
                HttpRequest req = new HttpRequest();
                req.setMethod('GET');
                req.setEndpoint('https://api.unicourt.com/rest/v1/case/'+caseUniCourtId +'/?token=2a8c48f7019a286dae3ddd7f43a96622a9ccc669');
                req.setTimeout(60*1000);
                
                Http h = new Http();
                String resp;
                HttpResponse res = h.send(req);
                resp = res.getBody();
                
                if(resp.indexOf('"case"') !=-1)
                    resp = resp.substring(0,resp.indexOf('"case"')) + '"caseObj"' + resp.substring(resp.indexOf(':{"case_meta"'),resp.length()) ;
                
                CaseParser casePraserRes =  CaseParser.parse(resp );
                Case_Leads__c caseLead;
                if(casePraserRes.error==false){
                    caseLead  = new Case_Leads__c ();
                    caseLead.Case_Name__c = casePraserRes.data.caseobj.case_meta.case_name;
                    caseLead.Case_Number__c = casePraserRes.data.caseobj.case_meta.case_number;
                    caseLead.Case_Status__c = casePraserRes.data.caseobj.case_meta.case_status;
                    caseLead.Case_Status_Category__c = casePraserRes.data.caseobj.case_meta.case_status_category;
                    caseLead.Case_Type__c = casePraserRes.data.caseobj.case_meta.case_type;
                    caseLead.Case_Type_Category__c = casePraserRes.data.caseobj.case_meta.case_type_category;
                    caseLead.Case_Type_Subcategory__c = casePraserRes.data.caseobj.case_meta.case_type_subcategory;
                    caseLead.County__c = casePraserRes.data.caseobj.case_meta.county;
                    caseLead.Courthouse__c = casePraserRes.data.caseobj.case_meta.courthouse;
                    caseLead.Filing_Date__c = Date.valueOf(casePraserRes.data.caseobj.case_meta.filing_date);
                    caseLead.Jurisdiction__c = casePraserRes.data.caseobj.case_meta.jurisdiction;
                    caseLead.Last_Updated__c = Date.valueOf(casePraserRes.data.caseobj.case_meta.last_updated_date);
                    caseLead.State__c = casePraserRes.data.caseobj.case_meta.state;
                    caseLead.Unicourt_Case_ID__c = casePraserRes.data.caseobj.case_meta.case_id;
                    caseLead.Docket_Entry_Token__c = casePraserRes.data.docket_entries_token;
                    caseLead.LastSFDCUpdatedfromUnicourt__c = system.today();
                    caseLead.Update_Request_Status__c = 'Updated';
                    
                    // mapCaseLeads.put(caseLead.Unicourt_Case_ID__c, caseLead);
                }
                
                if(caseLead !=null)
                    upsert caseLead Unicourt_Case_ID__c;
                if(!Test.isRunningTest() && caseLead != null && String.isNotBlank(caseLead.Unicourt_Case_ID__c)){
                    Map<String, String> caseIDTokenMap = new Map<String,String>();
                    caseIDTokenMap.put(caseLead.Unicourt_Case_ID__c, casePraserRes.data.docket_entries_token);
                    //CaseLeadCommonRoutine.createDocketEntries(caseIDTokenMap); // update the Docket Entries from Unicourt
                    LeadGenCaseBatch cntrl = new LeadGenCaseBatch(caseIDTokenMap.keyset());
                	Database.executeBatch(cntrl,100);
                }
            }
            
            if(parseObj.result.Status == 'has_no_update'){
                String caseUniCourtId = parseObj.result.case_id;
                Case_Leads__c clead  = new Case_Leads__c (Update_Request_Status__c = 'Had No Update', Unicourt_Case_ID__c = caseUniCourtId);
                upsert clead Unicourt_Case_ID__c;
            }
            
        }catch(Exception e){
            Webhook_Log__c log = new Webhook_Log__c ();
            log.Details__c = e.getMessage();
            insert log;
            
        }
        
    }
}