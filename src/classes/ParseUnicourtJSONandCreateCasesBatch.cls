global class ParseUnicourtJSONandCreateCasesBatch implements Database.Batchable<sObject>, Database.stateful, Database.AllowsCallouts {
	
	String query;
	Map<String,String> SavedSearchIdNameMap = new Map<String, string>();
	Set<String>setUnicourtCasesIds;
	

	
	global ParseUnicourtJSONandCreateCasesBatch() {
		query = 'select id, JSON_String__c, Is_Processed__c from Unicourt_Case_Lead_JSON__c where Is_Processed__c = false';
		setUnicourtCasesIds = new Set<String>();
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<Unicourt_Case_Lead_JSON__c> scope) {
		//Set<String>setCasesIds= new Set<String>();
		List<String> prohibitedStatusList = new List<String>{'Other Disposed','Terminated','Arbitration'};
		try{
			for(Unicourt_Case_Lead_JSON__c json : scope){
				json.Is_Processed__c = true;
				String jsonString = json.JSON_String__c;
				if(jsonString!= NULL && jsonString.trim().length()>0){
					jsonString = jsonString.replaceAll('"case"','"caseObj"');
					// replace "case" with "caseObj" as String.replaceAll fails for bulk string
	                /*    While(json.indexOf('"case"') != -1){
	                        json = json.substring(0,json.indexOf('"case"')) + '"caseObj"' + json.substring(json.indexOf('"case"')+6,json.length()) ;
	                    }
	                    */
	                LeadGenCasesParser obj = LeadGenCasesParser.parse(jsonString);
	                Map<String,Case_Leads__c>mapCaseLeads= new Map<String,Case_Leads__c>();
	                Set<String>setAttorneyId = new Set<String>();
	                Set<String>setPartiesId = new Set<String>();
	                String savedSearchName;
	                //if(Test.isRunningTest()){
	               // 	savedSearchName = 'Test Search';
                	///}else{
                		savedSearchName = getSavedSearchName(obj.search_metadata.search_id);
                	//}
	                
	                for(LeadGenCasesParser.cls_results result : obj.results){
	                        if(!prohibitedStatusList.contains(result.caseobj.case_status)){
	                            Case_Leads__c caseObj  = new Case_Leads__c ();
	                            caseObj.Case_Name__c = result.caseobj.case_name;
	                            caseObj.Case_Number__c = result.caseobj.case_number;
	                            caseObj.Case_Status__c = result.caseobj.case_status;
	                            caseObj.Case_Status_Category__c = result.caseobj.case_status_category;
	                            caseObj.Case_Type__c = result.caseobj.case_type;
	                            caseObj.Case_Type_Category__c = result.caseobj.case_type_category;
	                            caseObj.Case_Type_Subcategory__c = result.caseobj.case_type_subcategory;
	                            caseObj.County__c = result.caseobj.county;
	                            caseObj.Courthouse__c = result.caseobj.courthouse;
	                            caseObj.Filing_Date__c = Date.valueOf(result.caseobj.filing_date);
	                            caseObj.Jurisdiction__c = result.caseobj.jurisdiction;
	                            caseObj.Last_Updated__c = Date.valueOf(result.caseobj.last_updated_date);
	                            caseObj.State__c = result.caseobj.state;
	                            caseObj.Unicourt_Case_ID__c = result.caseobj.case_id;
	                            caseObj.Source_Saved_Search__c = savedSearchName;
	                            caseObj.LastSFDCUpdatedfromUnicourt__c = System.today();
	                           // setCasesIds.add(caseObj.Unicourt_Case_ID__c );
	                            mapCaseLeads.put(caseObj.Unicourt_Case_ID__c,caseObj);
	                            // attornerys
	                            
	                           
	                        }
	                    } 
	                    if(mapCaseLeads.size()>0){
	                        upsert mapCaseLeads.values() Unicourt_Case_ID__c;
	                        setUnicourtCasesIds.addAll(mapCaseLeads.keyset());

	                      //  if(!Test.isRunningTest()){
	                           // LeadGenCaseBatch cntrl = new LeadGenCaseBatch(mapCaseLeads.keyset());
	                           //Database.executeBatch(cntrl,100);
	                      //  }
	                        
	                    }
				}
			}
			update scope;
			}catch(Exception e){
                Webhook_Log__c log = new Webhook_Log__c ();
                log.Details__c = e.getMessage() +' ; Stack Trace - '+e.getStackTraceString();
                system.debug('exception ::: '+log.Details__c);

                //Database.RollBack(sp);
                insert log;
                
            }

	}
	
	global void finish(Database.BatchableContext BC) {
		if(!Test.isRunningTest()){
		    LeadGenCaseBatch cntrl = new LeadGenCaseBatch(setUnicourtCasesIds);
		    Database.executeBatch(cntrl,50);
		}
	}
	
	public String getSavedSearchName(String searchId){
        if(SavedSearchIdNameMap.containsKey(searchId)){
            return SavedSearchIdNameMap.get(searchId);
        }
        try{
            HttpRequest req = new HttpRequest();
            req.setMethod('GET');
            req.setEndpoint('https://api.unicourt.com/rest/v1/account/savedSearches/'+searchId+'/?token=2a8c48f7019a286dae3ddd7f43a96622a9ccc669');
            req.setTimeout(60*1000);
            Http h = new Http();
            HttpResponse res = h.send(req);
            String resp = res.getBody();
            SavedSearchParser parser = SavedSearchParser.parse(resp);
            SavedSearchIdNameMap.put(parser.data.search_id, parser.data.search_name);
            return parser.data.search_name;
        }
        catch(Exception e){
            Webhook_Log__c log = new Webhook_Log__c ();
            log.Details__c = e.getMessage();
            //Database.RollBack(sp);
            insert log;
        }
        return null;
    }
}