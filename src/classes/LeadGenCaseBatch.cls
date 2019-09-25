global class LeadGenCaseBatch implements Database.Batchable<sObject>,   Database.AllowsCallouts{ 
    global Set<String>setCasesIds= new Set<String>();
    global LeadGenCaseBatch (Set<String>setCasesIds){
        system.debug('setCasesIds::'+setCasesIds);
        this.setCasesIds = setCasesIds;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('Select id,Unicourt_Case_ID__c FROM Case_Leads__c WHERE Unicourt_Case_ID__c IN:setCasesIds');
    }
    global void execute(Database.BatchableContext info, List<Case_Leads__c> scope){
        system.debug('scope::: '+scope);
        List<Case_Leads__c> lstCases= new List<Case_Leads__c>();
        List<Representation__c>lstRepresentations = new List<Representation__c>();
        Set<String>setAttorneyName = new Set<String>();
        Set<String>setPartiesName = new Set<String>();
        List<CaseParser>lstCasesParser = new List<CaseParser>();
        Map<String,Case_Leads__c>mapCaseLeads= new Map<String,Case_Leads__c>();
        Map<String, String> UnicourtSFDCIdMap = new Map<String,String>();
        
        map<String,Set<String>>mapAttorneyIdWithPartyName = new Map<String,Set<String>>();
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
                    if(String.isNotBlank(casePraserRes.data.docket_entries_token))
                        UnicourtSFDCIdMap.put(caseLead.Unicourt_Case_ID__c, casePraserRes.data.docket_entries_token);
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
                                        if(mapAttorneyIdWithPartyName.containsKey(attorney_association.attorney_id)){
                                            mapAttorneyIdWithPartyName.get(attorney_association.attorney_id).add(party.fullname);
                                        }else{
                                            mapAttorneyIdWithPartyName.put(attorney_association.attorney_id, new Set<String>());
                                            mapAttorneyIdWithPartyName.get(attorney_association.attorney_id).add(party.fullname);
                                        }
                                        
                                        System.debug('att id partyname :::'+attorney_association.attorney_id+' '+party.fullname);
                                    }
                                }
                            }
                        }
                       system.debug('mapAttorneyIdWithPartyName.size():::'+mapAttorneyIdWithPartyName.size());
                    }
                    
                    if(setAttorneyName.size()>0|| setPartiesName.size()>0)
                        lstCasesParser.add(casePraserRes);
                    caseLead.Docket_Entry_Token__c = casePraserRes.data.docket_entries_token;
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
                system.debug('setAttorneyName:::'+setAttorneyName);
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
            List<Representation__c> ListadditionalRepForOneContMultiParty = new List<Representation__c>();
            for(CaseParser casePraserRes:lstCasesParser){
                Set<String>setAlreaedyAddedClientNames = new set<String>();
                system.debug('attorney list size:::'+casePraserRes.data.caseObj.attorneys.size());
                for(CaseParser.cls_attorneys attorney : casePraserRes.data.caseObj.attorneys){
					
                    system.debug('attorney exist::'+mapAttorneys.containsKey(attorney.firstname+' '+attorney.lastname));
					system.debug('New attorney:::'+mapNewContacts.containsKey(attorney.firstname+' '+attorney.lastname));
                    if( (attorney.firstname != NULL || attorney.lastname != NULL) && mapAttorneys.containsKey(attorney.firstname+' '+attorney.lastname)){
                        Representation__c rep = new Representation__c();
                        system.debug('attoney nameL::::'+attorney.firstname+'  '+attorney.lastname);
						system.debug('casePraserRes.data.caseobj.case_meta.case_id::'+casePraserRes.data.caseobj.case_meta.case_id);
						system.debug('mapCaseLeads====='+mapCaseLeads);
						rep.Case__c = mapCaseLeads.get(casePraserRes.data.caseobj.case_meta.case_id).id;
                        //Representation = new Representation__c(Case__c=mapCaseLeads.get(casePraserRes.data.caseobj.case_meta.case_id).id);
                        if(mapAttorneys.get(attorney.firstname+' '+attorney.lastname).size() == 1 ){
                            rep.Attorney__c=mapAttorneys.get(attorney.firstname+' '+attorney.lastname)[0].id;
                        }else{
                            rep.Unicourt_Attorney_First_Name__c = attorney.firstname;
                            rep.Unicourt_Attorney_Last_Name__c = attorney.lastname;
                        }
                        rep.Unicourt_Id__c = casePraserRes.data.caseobj.case_meta.case_id+'-'+attorney.attorney_id;
                        rep.Law_Firm_Text__c = attorney.firm;
                        if(rep.Law_Firm_Text__c == null || rep.Law_Firm_Text__c =='null')
                            rep.Law_Firm_Text__c = '';
                        system.debug('attorney.attorney_id:::'+attorney.attorney_id +' '+mapAttorneyIdWithPartyName.get(attorney.attorney_id));
                        if(mapAttorneyIdWithPartyName.containsKey(attorney.attorney_id) && rep.Unicourt_Id__c != null){
                            integer partyNo = 0;
                            for(String partyFullName : mapAttorneyIdWithPartyName.get(attorney.attorney_id)){
                                Representation__c rep1 = rep.clone(false, true, false, false);
                                partyNo++;
                                rep1.Unicourt_Id__c = rep1.Unicourt_Id__c+ '-p'+partyNo;
                                if(mapParties.containsKey(partyFullName)){
                                    system.debug('attorney party map found---');
                                    if(mapParties.get(partyFullName).size() == 1){
                                        rep1.Client__c= mapParties.get(partyFullName)[0].id;
                                    }else{
                                        rep1.Unicourt_Client_Name__c = partyFullName;
                                    }
                                    
                                    setAlreaedyAddedClientNames.add(partyFullName);
                                }
                                else if(mapNewAccounts.containsKey(partyFullName)){
                                    system.debug('attorney party map found---');
                                    rep1.Unicourt_Client_Name__c = partyFullName;
                                    setAlreaedyAddedClientNames.add(partyFullName);
                                }
                                lstRepresentations.add(rep1);
                            }
                        }else if(rep.Unicourt_Id__c != null){
                            lstRepresentations.add(rep);
                        }
                         
                    }
                    else if( (attorney.firstname != NULL || attorney.lastname != NULL) && mapNewContacts.containsKey(attorney.firstname+' '+attorney.lastname)){
                        Representation__c rep = new Representation__c();
                        rep.Unicourt_Attorney_First_Name__c = mapNewContacts.get(attorney.firstname+' '+attorney.lastname).FirstName;
						rep.Unicourt_Attorney_Last_Name__c = mapNewContacts.get(attorney.firstname+' '+attorney.lastname).LastName;
						rep.Case__c=mapCaseLeads.get(casePraserRes.data.caseobj.case_meta.case_id).id;
                        rep.Unicourt_Id__c = casePraserRes.data.caseobj.case_meta.case_id+'-'+attorney.attorney_id;
                        rep.Law_Firm_Text__c = attorney.firm;
                        if(rep.Law_Firm_Text__c == null || rep.Law_Firm_Text__c =='null')
                            rep.Law_Firm_Text__c = '';
                        system.debug('attorney id :::'+attorney.attorney_id+' unicourt id==='+rep.Unicourt_Id__c);
                        system.debug('contains att party map::'+mapAttorneyIdWithPartyName.containsKey(attorney.attorney_id));
                        //system.debug('parties exist:: '+mapParties.containsKey(mapAttorneyIdWithPartyName.get(attorney.attorney_id)));
                        ///// start here - If Attorney is associated with some Party
                        if(mapAttorneyIdWithPartyName.containsKey(attorney.attorney_id) && rep.Unicourt_Id__c != null){
                            integer partyNo = 0;
                            for(String partyFullName : mapAttorneyIdWithPartyName.get(attorney.attorney_id)){
                                Representation__c rep1 = rep.clone(false, true,false,false);
                                partyNo++;
                                rep1.Unicourt_Id__c = rep1.Unicourt_Id__c+ '-p'+partyNo;
                                if(mapParties.containsKey(partyFullName)){
                                    if(mapParties.get(partyFullName).size() == 1){
                                        rep1.Client__c= mapParties.get(partyFullName)[0].id;
                                    }else{
                                        rep1.Unicourt_Client_Name__c = partyFullName;
                                    }
                                    setAlreaedyAddedClientNames.add(partyFullName);
                                }
                                else if(mapNewAccounts.containsKey(partyFullName)){
                                    rep1.Unicourt_Client_Name__c = partyFullName;
                                    setAlreaedyAddedClientNames.add(partyFullName);
                                }
                                lstRepresentations.add(rep1);
                            }
                        }else if(rep.Unicourt_Id__c != null){
                            lstRepresentations.add(rep);
                        }
                        ///// end here
                    }
                    
                       // lstRepresentations.add(rep);
                }
				system.debug('lstRepresentations size'+lstRepresentations.size());
                system.debug('setAlreaedyAddedClientNames::::  '+setAlreaedyAddedClientNames);
				
                for(CaseParser.cls_parties party : casePraserRes.data.caseObj.parties){
                    system.debug('setAlreaedyAddedClientNames.contains(party.fullname)==false:: '+setAlreaedyAddedClientNames.contains(party.fullname));
                    system.debug('party namee------'+party.fullname+' already added :::: '+setAlreaedyAddedClientNames.contains(party.fullname));
                    Representation__c Representation = new Representation__c();
                    if(party.fullname != NULL && mapParties.containsKey(party.fullname) && !setAlreaedyAddedClientNames.contains(party.fullname)){
                        system.debug('Party not already added:::;'+party.fullname);
                        Representation.Case__c = mapCaseLeads.get(casePraserRes.data.caseobj.case_meta.case_id).id;
                        if(mapParties.get(party.fullname).size() == 1){
                            Representation.Client__c=mapParties.get(party.fullname)[0].id;
                        }else{
                            Representation.Unicourt_Client_Name__c = party.fullname;
                        }
                        if(party.party_types.size()>0)
                            Representation.Representation_Type__c = party.party_types[0].representation_type;
                        Representation.Unicourt_Id__c = casePraserRes.data.caseobj.case_meta.case_id+'-'+party.party_id;
                        //lstRepresentations.add(Representation);
                    }
                    else if(party.fullname != null && mapNewAccounts.containsKey(party.fullname) && !setAlreaedyAddedClientNames.contains(party.fullname)){
						system.debug('party not added already::: '+party.fullname);
                        Representation.Unicourt_Client_Name__c = mapNewAccounts.get(party.fullname).name;
						Representation.Case__c = mapCaseLeads.get(casePraserRes.data.caseobj.case_meta.case_id).id;
                        if(party.party_types.size()>0)
                            Representation.Representation_Type__c = party.party_types[0].representation_type;
                        Representation.Unicourt_Id__c = casePraserRes.data.caseobj.case_meta.case_id+'-'+party.party_id;
                       // lstRepresentations.add(Representation);
                    }
                    if(Representation.Unicourt_Id__c != null)
                        lstRepresentations.add(Representation);
                }
            }
			
            if(!Test.isRunningTest() && UnicourtSFDCIdMap != null && UnicourtSFDCIdMap.size() > 0){
                CaseLeadCommonRoutine.createDocketEntries(UnicourtSFDCIdMap);
            }
            system.debug('total repss::: '+lstRepresentations.size());
            if(lstRepresentations.size()>0){
                upsert lstRepresentations Unicourt_Id__c ;
            }
            
        }
    }     
    global void finish(Database.BatchableContext info){     
    } 
}