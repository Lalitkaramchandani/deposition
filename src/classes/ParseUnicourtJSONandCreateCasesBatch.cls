/*
Name 		: 	ParseUnicourtJSONandCreateCasesBatch
Author 		:   Jitendra Kumar
Purpose		:   Fetch stored payload chunks of JSON and CSV from Unicourt_Case_Lead_JSON__c and Process to create Case record
Test Class  :   LeadGenWebhookCntrlTest; ContactAndAccountsMatchWebhookCntrlTest
*/
global class ParseUnicourtJSONandCreateCasesBatch implements Database.Batchable<sObject>, Database.stateful, Database.AllowsCallouts {
	
	String query;
	String responseType;
	Map<String,String> SavedSearchIdNameMap = new Map<String, string>();
	Set<String>setUnicourtCasesIds;
	

	
	global ParseUnicourtJSONandCreateCasesBatch(String resType) {
		responseType = resType;
		query = 'select id,name, JSON_String__c, Is_Processed__c from Unicourt_Case_Lead_JSON__c where Is_Processed__c = false and Type__c = :responseType';
		system.debug('query---- '+query);
		setUnicourtCasesIds = new Set<String>();
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<Unicourt_Case_Lead_JSON__c> scope) {
		//Set<String>setCasesIds= new Set<String>();
		// cannot use save point as callout fails after this.
		// Savepoint sp = Database.setSavepoint();
		 try{
		 	system.debug('responseType---'+responseType);
		 	
				if(responseType == 'CSV'){
					ParseCSVandCreateCase(scope);
				}
				else{
					ParseJSONandCreateCase(scope);
				}

			}catch(Exception e){
				// Database.RollBack(sp);
                Webhook_Log__c log = new Webhook_Log__c ();
                log.Details__c = e.getMessage() +' ; Stack Trace - '+e.getStackTraceString();
                system.debug('exception ::: '+log.Details__c);

                //Database.RollBack(sp);
                insert log;
            }

	}
	
	global void finish(Database.BatchableContext BC) {
		if(responseType == 'CSV'){
			LeadGenCaseUpsertBatch job = new LeadGenCaseUpsertBatch('Account/Contact Match Batch');
			Database.executeBatch(job,20);
		}
		else if(!Test.isRunningTest()){
		    LeadGenCaseBatch cntrl = new LeadGenCaseBatch(setUnicourtCasesIds);
		    Database.executeBatch(cntrl,50);
		}
	}

	private void ParseJSONandCreateCase(List<Unicourt_Case_Lead_JSON__c> scope){
		List<String> prohibitedStatusList = new List<String>{'Other Disposed','Terminated','Arbitration'};
		List<String> prohibitedCaseTypeList = new List<String>{'Commercial Eviction','Consumer Credit','Controlled Substance/Drug','Debt Collection','Declaratory Judgment ','Eminent Domain ','Expungement ','Foreclosure ','Franchise ','Government Benefit Recovery','Land','Marriage Dissolution/Divorce','Minor Compromise Claim','Other Family','Other Forfeiture','Other Prisoner','Other Tax','Residential Eviction','State Statute Constitutionality','Trust','Uninsured Motor Vehicle','Withdrawal','Writ Of Mandamus'};
		for(Unicourt_Case_Lead_JSON__c json : scope){
				Boolean isAllSuccess = true;
				json.Is_Processed__c = true;
				String jsonString = json.JSON_String__c;
				String jsonRecordName = json.name;
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
	                		// Check if OHND pattern
	                		Boolean isOHND = false;
	                		if(result.caseobj.case_number.length() > 8){
	                			String subS = result.caseobj.case_number.substring(4,8);
		                		system.debug('subS:::: '+subS);
		                		isOHND = subS.equalsIgnoreCase('-OP-');
	                		}
	                		
	                        if(!prohibitedStatusList.contains(result.caseobj.case_status) && !prohibitedCaseTypeList.contains(result.caseobj.case_type)
	                        	&& !(result.caseobj.courthouse.equalsIgnoreCase('Ohio Northern District') && isOHND )){
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
	                            caseObj.Related_JSON_OR_CSV__c = jsonRecordName;
	                           // setCasesIds.add(caseObj.Unicourt_Case_ID__c );
	                            mapCaseLeads.put(caseObj.Unicourt_Case_ID__c,caseObj);
	                            // attornerys
	                            
	                           
	                        }
	                    }
	                    Map<String, Case_Leads__c> existingCasesMap = new Map<String, Case_Leads__c>();
	                    for(Case_Leads__c cl : [SELECT Unicourt_Case_ID__c,Case_Status__c FROM Case_Leads__c WHERE Unicourt_Case_ID__c in :mapCaseLeads.keyset()]){
	                    	existingCasesMap.put(cl.Unicourt_Case_ID__c, cl);
	                    }
	                    List<Case_Leads__c> clListtoUpsert = new List<Case_Leads__c>();
	                   /* if(mapCaseLeads.size()>0){
	                        upsert mapCaseLeads.values() Unicourt_Case_ID__c;
	                       // setUnicourtCasesIds.addAll(mapCaseLeads.keyset());

	                      //  if(!Test.isRunningTest()){
	                           // LeadGenCaseBatch cntrl = new LeadGenCaseBatch(mapCaseLeads.keyset());
	                           //Database.executeBatch(cntrl,100);
	                      //  }
	                        
	                    } */
	                    List<String> freezedCaseStatus = new List<String>{'Related','Rejected'};
	                    // do not update existing cases with Related or Rejected status.
	                    for(String unicourtId : mapCaseLeads.keyset()){
	                    	if(!existingCasesMap.containsKey(unicourtId)){
	                    		setUnicourtCasesIds.add(unicourtId);
	                    		clListtoUpsert.add(mapCaseLeads.get(unicourtId));
	                    	}else if(!freezedCaseStatus.contains(existingCasesMap.get(unicourtId).Case_Status__c)){

	                    		clListtoUpsert.add(mapCaseLeads.get(unicourtId));
	                    	}
	                    }
	                    Database.UpsertResult[] results = Database.upsert(clListtoUpsert, Case_leads__c.Unicourt_Case_ID__c, false);
						Boolean noError = processUpsertResult(clListtoUpsert, results, 'Unicourt_Case_ID__c');
						if(!noError){
							isAllSuccess = false;
						}
						json.hadExceptions__c = isAllSuccess ? false : true;
	                   // upsert clListtoUpsert Unicourt_Case_ID__c;
				}
			}
			update scope;
	}

	private void ParseCSVandCreateCase(List<Unicourt_Case_Lead_JSON__c> scope){

		Map<String,String> UnicourtSFDCFieldMap = new Map<String,String>();
		Map<String,String> UnicourtSFDCREPFieldMap = new Map<String,String>();

		for(Unicourt_SFDC_field_Mapping__mdt mapping : [select id, label, SFDC_Field__c,RelatedTo__c from Unicourt_SFDC_field_Mapping__mdt]){
			Switch on mapping.RelatedTo__c {
				when 'Representation' {
					UnicourtSFDCREPFieldMap.put(mapping.label, mapping.SFDC_Field__c);
				}
				when 'Case' {
					UnicourtSFDCFieldMap.put(mapping.label, mapping.SFDC_Field__c);
				}
			}
			
		}
		Map<String, Case_Leads__c> caseMap = new Map<String, Case_Leads__c>();

		// SOQL and DML is inside the for loop because scope size is 1 only. 
		for(Unicourt_Case_Lead_JSON__c csv : scope){
			Boolean isAllSuccess = true;
			List<String> csvRecList = csv.JSON_String__c.split('\n');
			String csvRecordName = csv.name;
			system.debug('csvRecList size---- '+csvRecList.size());
			String columnListString = csvRecList[0];
			columnListString = columnListString.substring(1, columnListString.length()-2);
			List<String> columnList = columnListString.split('","');
			List<String> contactIdList = new List<String>();
			// Process all CSV records and create Case Records
			for(integer i=1; i < csvRecList.size(); i++){
				Case_Leads__c caseRec = new Case_Leads__c();
				caseRec.Related_JSON_OR_CSV__c = csvRecordName;
				caseRec.Source_Saved_Search__c = 'Account/Contact Match';
				String valueListString = csvRecList[i];
				valueListString = valueListString.substring(1, valueListString.length()-2);
				Integer colNumber = 0;
				for(String value : valueListString.split('","')){
					String colName = columnList[colNumber];
					//system.debug('colName---'+colName);
					if(colName.equals('Contact ID')){
						contactIdList.add(value);
					}
					if(UnicourtSFDCFieldMap.containsKey(colName)){
						if(String.isBlank(value)){
							system.debug(colName +' - Blank Value - '+value + ' s no. : '+i);
						}
						if(colName.equals('Filing Date')){
							Date dateValue = CaseLeadCommonRoutine.ParseDateString(value, '-','yyyymmdd');
							caseRec.put(UnicourtSFDCFieldMap.get(colName), dateValue);
						}else{
							caseRec.put(UnicourtSFDCFieldMap.get(colName), value);
						}
						
					}
					colNumber++;
				}
				if(String.isNotBlank(caseRec.Unicourt_Case_ID__c)){
					caseMap.put(caseRec.Unicourt_Case_ID__c, caseRec);
				}else{
					System.debug('Unicourt Case ID blank --- '+caseRec+ 'value String:::: '+valueListString);
				}

			}
			//upsert caseMap.values() Unicourt_Case_ID__c;
			List<Case_leads__c> recordsToUpsert = caseMap.values();
			Database.UpsertResult[] results = Database.upsert(recordsToUpsert, Case_leads__c.Unicourt_Case_ID__c, false);
			Boolean noError = processUpsertResult(recordsToUpsert, results, 'Unicourt_Case_ID__c');
			if(!noError){
				isAllSuccess = false;
			}
			// fetch all existing representation
			//16/07/2019 - Jitendra : commenting below code, No need to create representation as complete case detail will be fetched in CaseLeadUpsertBatch.
			/*
			Map<String, List<Representation__c>> caseIdRepListMap = new Map<String, List<Representation__c>>();
			for(Representation__c rep : [select id, Case__r.Unicourt_Case_ID__c, Attorney__c from representation__c where case__r.Unicourt_Case_ID__c in :caseMap.keyset()] ){
				if(caseIdRepListMap.containsKey(rep.Case__r.Unicourt_Case_ID__c)){
					caseIdRepListMap.get(rep.Case__r.Unicourt_Case_ID__c).add(rep);
				}else{
					caseIdRepListMap.put(rep.Case__r.Unicourt_Case_ID__c, new List<Representation__c>());
					caseIdRepListMap.get(rep.Case__r.Unicourt_Case_ID__c).add(rep);
				}
			}
		
			// Process all CSV records again to check and create Representation
			List<Representation__c> newRepList = new List<Representation__c>();
			for(integer i=1; i < csvRecList.size(); i++){
				String UnicourCaseID;
				Representation__c rep = new Representation__c();
				String valueListString = csvRecList[i];
				valueListString = valueListString.substring(1, valueListString.length()-2);
				Integer colNumber = 0;
				for(String value : valueListString.split('","')){
					String colName = columnList[colNumber];
					system.debug('colName---'+colName);
					if(colName.equals('Encrypted Case ID')){
						UnicourCaseID = value;
					}

					if(UnicourtSFDCREPFieldMap.containsKey(colName)){
						system.debug('rep colName match---'+UnicourtSFDCREPFieldMap.get(colName));
						rep.put(UnicourtSFDCREPFieldMap.get(colName), value);
					}
					colNumber++;
				}
				Boolean createRep = true;
				if(String.isNotBlank(rep.Attorney__c) && String.isNotBlank(UnicourCaseID) && caseIdRepListMap.containsKey(UnicourCaseID) ){
					for(Representation__c rep1 : caseIdRepListMap.get(UnicourCaseID) ){
						if(rep1.Attorney__c == rep.Attorney__c){
							createRep = false;
							break;
						}
					}
				}
				if(createRep && caseMap.containsKey(UnicourCaseID)){
					rep.Case__c = caseMap.get(UnicourCaseID).ID;
					newRepList.add(rep);
				}
			}
			Database.SaveResult[] saveResults = Database.insert(newRepList, false);
			Boolean noErrorOnSave = processSaveResult(newRepList, saveResults, 'Case__c');
			if(!noErrorOnSave){
				isAllSuccess = false;
			}
			*/
			//insert newRepList;
			csv.Is_Processed__c = true;
			csv.hadExceptions__c = isAllSuccess ? false : true;
    	}
    	

    	update scope;
	}

	 /*        
     * Method: processUpsertResult      
     * Author: Jitendra     
     * Date: 07/07/2019     
     * Purpose: process upsert results and create error log for any failed record.      
     */     
     public static Boolean processUpsertResult(List<sObject> recordList, List<Database.UpsertResult> upsertResults, string identifierField){       
        List<Webhook_Log__c> logList = new List<Webhook_Log__c>();  
        Boolean noError = true;    
       for(Integer index = 0, size = upsertResults.size(); index < size ; index++) {        
            if(!upsertResults[index].isSuccess()) { 
                noError = false;      
                String errorMessage;        
                if(String.isNotBlank(identifierField))      
                    errorMessage = identifierField +' : '+recordList[index].get(identifierField) +';  \n';      
                for(Database.Error err : upsertResults[index].getErrors()){       
                   errorMessage = errorMessage + 'Status Code: '+err.getStatusCode() + ' error msg: '+err.getMessage() +';  \n';        
                }       
                Webhook_Log__c log = new Webhook_Log__c ();     
                log.Details__c = errorMessage;      
                logList.add(log);       
                system.debug('exception ::: '+log.Details__c);      
            }           
        }       
        insert logList; 
        return noError;    
     }

    /*        
     * Method: processSaveResult      
     * Author: Jitendra     
     * Date: 07/07/2019     
     * Purpose: process save results and create error log for any failed record.      
     */     
     public static Boolean processSaveResult(List<sObject> recordList, List<Database.SaveResult> saveResults, string identifierField){       
        List<Webhook_Log__c> logList = new List<Webhook_Log__c>();
        Boolean noError = true;      
       for(Integer index = 0, size = saveResults.size(); index < size ; index++) {        
            if(!saveResults[index].isSuccess()) {    
                noError = false;   
                String errorMessage;        
                if(String.isNotBlank(identifierField))      
                    errorMessage = identifierField +' : '+recordList[index].get(identifierField) +';  \n';      
                for(Database.Error err : saveResults[index].getErrors()){       
                   errorMessage = errorMessage + 'Status Code: '+err.getStatusCode() + ' error msg: '+err.getMessage() +';  \n';        
                }       
                Webhook_Log__c log = new Webhook_Log__c ();     
                log.Details__c = errorMessage;      
                logList.add(log);       
                system.debug('exception ::: '+log.Details__c);      
            }           
        }       
        insert logList;
        return noError;     
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