/*
* Name : LeadGenWebhookCntrl
* Test Class: LeadGenWebhookCntrlTest
*/
public class LeadGenWebhookCntrl {
    Map<String,String> SavedSearchIdNameMap = new Map<String, string>();
    String json;
    public void init(){
        //Set<String>setCasesIds= new Set<String>();
        List<String> prohibitedStatusList = new List<String>{'Other Disposed','Terminated','Arbitration'};
            //Savepoint sp = Database.setSavepoint(); // cannot make callout after DML
            try{
                json = ApexPages.currentpage().getParameters().get('data').trim();
                integer len = json.length();
                system.debug('original string ::: '+ json);
                system.debug('Json string length :::: '+len);
                integer maxLen;
                if(Test.isRunningTest()){
                    maxLen = 1000;
                }else{
                    maxLen = 125000;
                }
                
                //String json = [select id,Details__c From Webhook_Log__c WHERE Id='a0t29000000IVRU' ].Details__c;
                if(json!= NULL && len > 0){
                    List<String> listJSON = new List<String>();
                    if(len > maxLen){
                        integer offsetIndex, startOfNewObj, remainingCharlen;
                        String header, jsonString, leftOverObjectString; 
                        String endString = ']}'; 
                        header = json.substringBefore('{"case": {');
                        system.debug('header string :: - '+header);
                        jsonString = json.substring(0, maxLen);
                         system.debug('jsonString 0 string :: - '+jsonString);
                        startOfNewObj = json.indexOf('{"case": {', maxLen);
                        leftOverObjectString = json.substring(maxLen, startOfNewObj-2 );
                        system.debug('leftOverObjectString 0 string :: - '+leftOverObjectString);
                        // header string not added as already included for first time.
                        listJSON.add(jsonString+leftOverObjectString+endString);
                        offsetIndex = startOfNewObj;
                        remainingCharlen = len-1 - offsetIndex;
                        While(remainingCharlen > maxLen){
                            jsonString = json.substring(offsetIndex, offsetIndex+maxLen);
                            system.debug('jsonString string :: - '+jsonString);
                            offsetIndex = offsetIndex+maxLen;
                            startOfNewObj = json.indexOf('{"case": {', offsetIndex);
                            System.debug('startOfNewObj:: '+startOfNewObj);
                            if(startOfNewObj == -1){
                                system.debug('json.length()::- '+json.length());
                                leftOverObjectString = json.substring(offsetIndex, json.length());
                                offsetIndex = len;
                            }else{
                                leftOverObjectString = json.substring(offsetIndex, startOfNewObj-2)+endString;
                                offsetIndex = startOfNewObj;
                            }
                            system.debug('leftOverObjectString string :: - '+leftOverObjectString);
                            remainingCharlen = len - offsetIndex;
                            listJSON.add(header+jsonString+leftOverObjectString);
                            system.debug('complete string ::: '+header+jsonString+leftOverObjectString);
                            

                        }
                        if(len > offsetIndex){
                            String lastString = header + json.substring(offsetIndex, len);
                            system.debug('last String ::::  '+lastString);
                            listJSON.add(lastString);
                        }

                    }else{
                        listJSON.add(json);
                    }
                    List<Unicourt_Case_Lead_JSON__c> tempCases = new List<Unicourt_Case_Lead_JSON__c>();
                    for(String jString : listJSON){
                        Unicourt_Case_Lead_JSON__c tCase = new Unicourt_Case_Lead_JSON__c();
                        tCase.JSON_String__c = jString;
                        tempCases.add(tCase);
                    }
                    if(tempCases.size() > 0){
                        insert tempCases;
                    }
                   
                }

                // execute batch to process JSON and create Case Lead
                ParseUnicourtJSONandCreateCasesBatch job = new ParseUnicourtJSONandCreateCasesBatch();
                // In test class it's high because must be processed in single chunk only.Else throw error
                Integer batchsize = test.isRunningTest() ? 5 :2; 
                
                Database.executeBatch(job, batchsize);
                
            }catch(Exception e){
                Webhook_Log__c log = new Webhook_Log__c ();
                log.Details__c = 'Stack Trace::- '+e.getStackTraceString() +' Message:- '+ e.getMessage();
                //Database.RollBack(sp);
                insert log;
                
            }
        
    }
    
}