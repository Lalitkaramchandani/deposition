public class TrackCaseWebhookController {
 Map<String, Case_Leads__c> mapCaseLeads = new Map<String,Case_Leads__c >();
 Map<String, String> UnicourtIdDocketTokenMap = new Map<String, String>();
 List<string> unicourtCaseIdList = new List<String>();
public void init(){
    
    try{
        String json = ApexPages.currentpage().getParameters().get('data');
       /* Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = new String[] { 'recipient email'};
            message.subject = 'Track Cases Webhook Call';
        message.plainTextBody = 'This is the message body.\n\n'+json;
        Messaging.SingleEmailMessage[] messages = 
            new List<Messaging.SingleEmailMessage> {message};
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages); */
        
        TrackCaseAPIResParse parseObj   = TrackCaseAPIResParse.parse(json);
        
        for(TrackCaseAPIResParse.Result result : parseObj.result){
            for(TrackCaseAPIResParse.Folder folder : result.folder){
                for(String caseId : folder.case_ids){
                    calloutCaseAndProcess(caseId);
                }
            }
        }
        system.debug('mapCaseLeads::'+mapCaseLeads);
        
        if(mapCaseLeads.size() > 0){
            upsert mapCaseLeads.values() Unicourt_Case_ID__c;
            notifyUsers(unicourtCaseIdList);
        }
        if(!Test.isRunningTest() && UnicourtIdDocketTokenMap != null && UnicourtIdDocketTokenMap.size() > 0){
            //19.01.2019 - commented below code as it is covered in LeadGenCaseBatch
            //CaseLeadCommonRoutine.createDocketEntries(UnicourtIdDocketTokenMap); // update the Docket Entries from Unicourt
            LeadGenCaseBatch cntrl = new LeadGenCaseBatch(UnicourtIdDocketTokenMap.keyset());
            Database.executeBatch(cntrl,100);
        }
        
    }catch(Exception e){
        Webhook_Log__c log = new Webhook_Log__c ();
        log.Details__c = e.getMessage();
        insert log;
       
    }
    
}

private void calloutCaseAndProcess(String caseId){
    if(String.isNotBlank(caseId)){
       // String caseUniCourtId = caseId;
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint('https://api.unicourt.com/rest/v1/case/'+caseId +'/?token=2a8c48f7019a286dae3ddd7f43a96622a9ccc669');
        req.setTimeout(60*1000);
        
        Http h = new Http();
        String resp;
        HttpResponse res = h.send(req);
        
        resp = res.getBody();
        system.debug('resp:::'+resp);
        if(resp.indexOf('"case"') !=-1)
            resp = resp.substring(0,resp.indexOf('"case"')) + '"caseObj"' + resp.substring(resp.indexOf(':{"case_meta"'),resp.length()) ;
        
        CaseParser casePraserRes =  CaseParser.parse(resp );
        Case_Leads__c caseLead;
        if(casePraserRes.error==false){
            caseLead  = new Case_Leads__c ();
            unicourtCaseIdList.add(casePraserRes.data.caseobj.case_meta.case_id);
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
            caseLead.LastSFDCUpdatedfromUnicourt__c = System.today();
            mapCaseLeads.put(caseLead.Unicourt_Case_ID__c, caseLead);
            UnicourtIdDocketTokenMap.put(caseLead.Unicourt_Case_ID__c,caseLead.Docket_Entry_Token__c);
        }
    }else{
        return;
    }
} 
@future
public static void notifyUsers(List<String> uniCaseIdList){
    
    //EmailTemplate et = [select id, name,DeveloperName from EmailTemplate where DeveloperName = 'Case_Update_Notification' limit 1];
    
    Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
    for(Case_Leads__c clead : [select id,Case_Name__c, (select id, User__c, User__r.email, User__r.name  from Case_Followers__r) from Case_Leads__c where Unicourt_Case_ID__c in :uniCaseIdList]){
        //List<Id> followersIdList = new List<Id>();
        //List<String> followerEmailList = new List<String>();
        for(case_follower__c cf : clead.Case_Followers__r){
            system.debug('CFF::'+cf);
            if(cf.user__c != null){
                //followersIdList.add(cf.user__c);
                //followerEmailList.add(cf.User__r.email);
                String subjectString = 'Case Update - '+clead.Case_Name__c;
                String emailBody = 'Dear '+cf.User__r.name+',\n';
                emailBody = emailBody + 'The matter of "'+clead.Case_Name__c+'" was updated on '+System.now()+'.\n';
                emailBody = emailBody + 'Access the case here: '+System.Url.getSalesforceBaseUrl().toExternalForm()+'/'+clead.Id;
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.setTargetObjectId(cf.user__c);
                message.setSaveAsActivity(false);
                message.setSubject(subjectString);
                message.setPlainTextBody(emailBody);
                //message.setTemplateId(et.Id);
                //message.setWhatIds(new String [] {clead.id});
                messages.add(message);
            }
        }
    }
    Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
} 
}