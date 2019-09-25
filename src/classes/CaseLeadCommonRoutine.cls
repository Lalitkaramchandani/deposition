/*
 * Name: CaseLeadCommonRoutine
 * Author: Jitendra Kumar
 * Date: 25/12/2018
 * Purpose: Provide commonly used methods. 
 */
public class CaseLeadCommonRoutine {
    
    /*
     * Method: createDocketEntries
     * Author: Jitendra
     * Date: 25/12/2018
     * Param 1: Map<String, String> -- Unicourt Case Id, Docket Entry Token map
     */
    public static void createDocketEntries(Map<String, String> caseIdDocketTokenMap){
        List<Docket_Activity__c> oldDocketEntries = new List<Docket_Activity__c>();
        List<Docket_Activity__c> newDocketEntries = new List<Docket_Activity__c>();
        Map<String, String> UnicourtSFDCIdMap = new Map<String, String>();
        for(case_leads__c cl : [select id, Docket_Entry_Token__c, Unicourt_Case_ID__c, (select id from Docket_Activities__r) from Case_Leads__c where unicourt_case_id__c in :caseIdDocketTokenMap.keyset()]){
            oldDocketEntries.addAll(cl.Docket_Activities__r);
            UnicourtSFDCIdMap.put(cl.Unicourt_Case_ID__c, cl.Id);
        }
        // callout to fetch new docket entries
        for(String unicourtId : caseIdDocketTokenMap.keyset() ){
            HttpRequest req = new HttpRequest();
            req.setMethod('GET');
            req.setEndpoint('https://api.unicourt.com/rest/v1/case/'+unicourtId+'/docketEntries/?token=2a8c48f7019a286dae3ddd7f43a96622a9ccc669&docket_entries_token='+caseIdDocketTokenMap.get(unicourtId)+'&sort=DESC');
            req.setTimeout(60*1000);
            
            Http h = new Http();
            String resp;
            HttpResponse res = h.send(req);
            resp = res.getBody();
            resp = resp.replace('"date\"', '"entryDate\"');
			system.debug('resp::'+resp);
            DocketEntryParser parser = DocketEntryParser.parse(resp);
            if(!parser.error){
                for(DocketEntryParser.Docket_entries entry : parser.data.docket_entries){
                    Docket_Activity__c activity = new Docket_Activity__c();
                    activity.Case__c = UnicourtSFDCIdMap.get(unicourtId);
                    activity.Docket_Update__c = entry.text;
                    activity.Order__c = entry.order;
                    activity.Docket_Entry_Date__c = ParseDateString(entry.entryDate);
                    List<String> dateComp = entry.updated.split(' ');
                    activity.Unicourt_Updated_Date__c = ParseDateString(dateComp[0]);
                    newDocketEntries.add(activity);
                }
            }
        }
        if(oldDocketEntries.size() > 0)
            delete oldDocketEntries;
        if(newDocketEntries.size() > 0)
            insert newDocketEntries;
        
    }
    
    public static Date ParseDateString(String dateString){
        List<String> ListDateComp = dateString.split('-');
        Date dateValue = Date.newInstance(Integer.valueOf(ListDateComp[0]), Integer.valueOf(ListDateComp[1]), Integer.valueOf(ListDateComp[2]));
        return dateValue;
    }
}