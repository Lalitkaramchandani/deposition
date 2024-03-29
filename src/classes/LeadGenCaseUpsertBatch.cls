global class LeadGenCaseUpsertBatch     implements Database.Batchable<sObject>,   Database.AllowsCallouts{ 
    global Set<String>setCasesIds= new Set<String>();
    global LeadGenCaseUpsertBatch(Set<String>setCasesIds){
        system.debug('setCasesIds::'+setCasesIds);
        this.setCasesIds = setCasesIds;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('Select id,Unicourt_Case_ID__c FROM Case_Leads__c WHERE Unicourt_Case_ID__c  IN:setCasesIds');
    }
    global void execute(Database.BatchableContext info, List<Case_Leads__c> scope){
        system.debug('scope::: '+scope);
        List<Case_Leads__c> lstCases= new List<Case_Leads__c>();
        List<Representation__c>lstRepresentations = new List<Representation__c>();
        Set<String>setAttorneyName = new Set<String>();
        Set<String>setPartiesName = new Set<String>();
        List<CaseParser>lstCasesParser = new List<CaseParser>();
        Map<String,Case_Leads__c>mapCaseLeads= new Map<String,Case_Leads__c>();
        map<String,String>mapAttorneyIdWithPartyName = new Map<String,String>();
        for(Case_Leads__c caseLead : scope){ 
            HttpRequest req = new HttpRequest();
            req.setMethod('GET');
            req.setEndpoint('https://api.unicourt.com/rest/v1/case/'+caseLead.Unicourt_Case_ID__c +'/?token=2a8c48f7019a286dae3ddd7f43a96622a9ccc669');
            req.setTimeout(60*1000);
            
            Http h = new Http();
            String resp;
            HttpResponse res = h.send(req);
            resp = res.getBody();
            system.debug('resp::'+resp);
            //resp = resp.substring(0,resp.indexOf('{"case"')) + '{"caseObj"' + resp.substring(resp.indexOf(':{"case_meta"'),resp.length()) ;
            if(resp.indexOf('"case"') != -1){
                resp = resp.substring(0,resp.indexOf('"case"')) + '"caseObj"' + resp.substring(resp.indexOf(':{"case_meta"'),resp.length()) ;
                system.debug('resp::'+resp);
                //List<String>respArray = resp.split('{"case"');
                //resp = respArray[0]+ '{"caseObj"' + respArray[0];
                CaseParser casePraserRes =  CaseParser.parse(resp);
                if(casePraserRes.error==false){
                    for(CaseParser.cls_attorneys attorney : casePraserRes.data.caseObj.attorneys){
                        if(attorney.firstname != NULL || attorney.lastname != NULL)
                            setAttorneyName.add(attorney.firstname+' '+attorney.lastname);
                    }
                    for(CaseParser.cls_parties  party : casePraserRes.data.caseObj.parties){
                        if(party.fullname != NULL){
                            setPartiesName.add(party.fullname);
                            if(party.party_types!= NULL ){
                                for(CaseParser.cls_party_types partyType: party.party_types){
                                    for(CaseParser.cls_attorney_association attorney_association: partyType.attorney_association){
                                        mapAttorneyIdWithPartyName.put(attorney_association.attorney_id,party.fullname);
                                    }
                                }
                            }
                        }
                    }
                    
                    if(setAttorneyName.size()>0|| setPartiesName.size()>0)
                        lstCasesParser.add(casePraserRes);
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
                    mapCaseLeads.put(caseLead.Unicourt_Case_ID__c,caseLead);
                }
           }
        } 
        if(lstCasesParser.size()>0){
            Map<String,List<Contact>>mapAttorneys = new Map<String,List<Contact>>();  
            Map<String,List<Account>>mapParties = new Map<String,List<Account>>();
            if(setAttorneyName.size()>0){
                /* for(contact cont : [Select Id,Unicourt_Attorney_Id__c From Contact WHERE Unicourt_Attorney_Id__c IN : setAttorneyId]){
mapAttorneys.put(cont.Unicourt_Attorney_Id__c,cont);
} */
                for(contact cont : [Select Id,Unicourt_Attorney_Id__c,name From Contact WHERE name IN : setAttorneyName]){
                    if(mapAttorneys.containsKey(cont.Name)){
                        mapAttorneys.get(cont.Name).add(cont);
                    }else{
                        mapAttorneys.put(cont.name,new List<Contact>());
                        mapAttorneys.get(cont.Name).add(cont);
                    }
                    
                }
            }
            
            if(setPartiesName.size()>0){
                
                for(Account accnt : [Select Id,Unicourt_Party_ID__c, name From Account WHERE name IN : setPartiesName]){
                    if(mapParties.containsKey(accnt.Name)){
                        mapParties.get(accnt.Name).add(accnt);
                    }else{
                        mapParties.put(accnt.name,new list<Account>());
                        mapParties.get(accnt.name).add(accnt);
                    }
                    
                }
            }
            Map<String,Contact>mapNewContacts = new Map<String,Contact>();
            Map<String,Account>mapNewAccounts = new Map<String,Account>();
            for(CaseParser casePraserRes:lstCasesParser){
                
                for(CaseParser.cls_attorneys attorney : casePraserRes.data.caseObj.attorneys){
                    if( (attorney.firstname != NULL || attorney.lastname != NULL) && mapAttorneys.containsKey(attorney.firstname+' '+attorney.lastname)==false){
                        Contact cont = new Contact(FirstName=attorney.firstname,LastName=attorney.lastname);
                        if(cont.LastName== NULL || cont.LastName =='')
                            cont.LastName = cont.FirstName;
                        if(cont.FirstName != NULL && cont.FirstName.length() >40)
                            cont.firstName= cont.FirstName.left(40);
                        if(cont.LastName != NULL && cont.LastName.length() >40)
                            cont.LastName= cont.LastName.left(40);    
                        cont.Unicourt_Attorney_Id__c = attorney.attorney_id;
                        if(cont.LastName != NULL )
                            mapNewContacts.put( attorney.firstname+' '+attorney.lastname,cont);
                    }
                    
                } 
                
                for(CaseParser.cls_parties  party : casePraserRes.data.caseObj.parties){
                    if(party.fullname != NULL && mapParties.containsKey(party.fullname)==false){
                        Account accnt = new Account(Name=party.fullname,Unicourt_Party_ID__c= party.party_id);
                        mapNewAccounts.put(party.fullname,accnt);
                    }
                    
                } 
            } 
            // Commented as we no more create new attorneys and new parties automatically.
            if(mapNewContacts.size()>0)
                //  upsert mapNewContacts.values() Unicourt_Attorney_Id__c ;
                if(mapNewAccounts.size()>0)
                //  upsert mapNewAccounts.values() Unicourt_Party_ID__c;
                for(Contact cont : mapNewContacts.values()){
                    // mapAttorneys.put(cont.Unicourt_Attorney_Id__c,cont);
                }
            for(Account accnt : mapNewAccounts.values()){
                // mapParties.put(accnt.Unicourt_Party_ID__c,accnt);
            }
            
            for(CaseParser casePraserRes:lstCasesParser){
                Set<String>setAlreaedyAddedClientNames = new set<String>();
                
                for(CaseParser.cls_attorneys attorney : casePraserRes.data.caseObj.attorneys){
                    if( (attorney.firstname != NULL || attorney.lastname != NULL) && mapAttorneys.containsKey(attorney.firstname+' '+attorney.lastname)){
                        Representation__c Representation = new Representation__c(Case__c=mapCaseLeads.get(casePraserRes.data.caseobj.case_meta.case_id).id);
                        if(mapAttorneys.get(attorney.firstname+' '+attorney.lastname).size() == 1 ){
                            Representation.Attorney__c=mapAttorneys.get(attorney.firstname+' '+attorney.lastname)[0].id;
                        }else{
                            Representation.Unicourt_Attorney_First_Name__c = attorney.firstname;
                            Representation.Unicourt_Attorney_Last_Name__c = attorney.lastname;
                        }
                        Representation.Unicourt_Id__c = casePraserRes.data.caseobj.case_meta.case_id+'-'+attorney.attorney_id;
                        
                        
                        if(mapAttorneyIdWithPartyName.containsKey(attorney.attorney_id) && mapParties.containsKey(mapAttorneyIdWithPartyName.get(attorney.attorney_id))){
                            if(mapParties.get(mapAttorneyIdWithPartyName.get(attorney.attorney_id)).size() == 1){
                                Representation.Client__c= mapParties.get(mapAttorneyIdWithPartyName.get(attorney.attorney_id))[0].id;
                            }else{
                                Representation.Unicourt_Client_Name__c = mapAttorneyIdWithPartyName.get(attorney.attorney_id);
                            }
                            
                            setAlreaedyAddedClientNames.add(mapAttorneyIdWithPartyName.get(attorney.attorney_id));
                        }
                        Representation.Law_Firm_Text__c = attorney.firm;
                        if(Representation.Law_Firm_Text__c == null || Representation.Law_Firm_Text__c =='null')
                            Representation.Law_Firm_Text__c = '';
                        lstRepresentations.add(Representation);
                    }
                    if( (attorney.firstname != NULL || attorney.lastname != NULL) && mapNewContacts.containsKey(attorney.firstname+' '+attorney.lastname)){
                        Representation__c Representation = new Representation__c(Unicourt_Attorney_First_Name__c=mapNewContacts.get(attorney.firstname+' '+attorney.lastname).FirstName, 
                                                                                 Unicourt_Attorney_Last_Name__c=mapNewContacts.get(attorney.firstname+' '+attorney.lastname).LastName,
                                                                                 Case__c=mapCaseLeads.get(casePraserRes.data.caseobj.case_meta.case_id).id);
                        Representation.Unicourt_Id__c = casePraserRes.data.caseobj.case_meta.case_id+'-'+attorney.attorney_id;
                        
                        if(mapAttorneyIdWithPartyName.containsKey(attorney.attorney_id) && mapParties.containsKey(mapAttorneyIdWithPartyName.get(attorney.attorney_id))){
                            if(mapParties.get(mapAttorneyIdWithPartyName.get(attorney.attorney_id)).size() == 1){
                                Representation.Client__c= mapParties.get(mapAttorneyIdWithPartyName.get(attorney.attorney_id))[0].id;
                            }else{
                                Representation.Unicourt_Client_Name__c = mapAttorneyIdWithPartyName.get(attorney.attorney_id);
                            }
                            setAlreaedyAddedClientNames.add(mapAttorneyIdWithPartyName.get(attorney.attorney_id));
                        }
                        
                        Representation.Law_Firm_Text__c = attorney.firm;
                        if(Representation.Law_Firm_Text__c == null || Representation.Law_Firm_Text__c =='null')
                            Representation.Law_Firm_Text__c = '';
                        lstRepresentations.add(Representation);
                    }
                }
                for(CaseParser.cls_parties party : casePraserRes.data.caseObj.parties){
                    if(party.fullname != NULL && mapParties.containsKey(party.fullname) && setAlreaedyAddedClientNames.contains(party.fullname)==false){
                        Representation__c Representation = new Representation__c(Case__c=mapCaseLeads.get(casePraserRes.data.caseobj.case_meta.case_id).id);
                        if(mapParties.get(party.fullname).size() == 1){
                            Representation.Client__c=mapParties.get(party.fullname)[0].id;
                        }else{
                            Representation.Unicourt_Client_Name__c = party.fullname;
                        }
                        if(party.party_types.size()>0)
                            Representation.Representation_Type__c = party.party_types[0].representation_type;
                        Representation.Unicourt_Id__c = casePraserRes.data.caseobj.case_meta.case_id+'-'+party.party_id;
                        lstRepresentations.add(Representation);
                    }
                    
                    if(party.fullname != null && mapNewAccounts.containsKey(party.fullname) && setAlreaedyAddedClientNames.contains(party.fullname)==false){
                        Representation__c Representation = new Representation__c(Unicourt_Client_Name__c=mapNewAccounts.get(party.fullname).name,Case__c=mapCaseLeads.get(casePraserRes.data.caseobj.case_meta.case_id).id);
                        if(party.party_types.size()>0)
                            Representation.Representation_Type__c = party.party_types[0].representation_type;
                        Representation.Unicourt_Id__c = casePraserRes.data.caseobj.case_meta.case_id+'-'+party.party_id;
                        lstRepresentations.add(Representation);
                    }
                }
            }
            if(lstRepresentations.size()>0)
                upsert lstRepresentations Unicourt_Id__c ;
        }
        if(mapCaseLeads.size()>0)
           update mapCaseLeads.values();
    }     
    global void finish(Database.BatchableContext info){     
    } 
}