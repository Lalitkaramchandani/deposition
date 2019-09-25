/*
 * Name: CaseLeadCommonRoutine
 * Author: Jitendra Kumar
 * Date: 25/12/2018
 * Purpose: Provide commonly used methods. 
 * Test Classes : CaseLeadsStartPageControllerTest; ContactAndAccountsMatchWebhookCntrlTest;TestLeadGenCaseBatch
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
            for(Docket_Activity__c doc : cl.Docket_Activities__r){
                oldDocketEntries.add(doc);
            }
           // oldDocketEntries.addAll(cl.Docket_Activities__r);
            UnicourtSFDCIdMap.put(cl.Unicourt_Case_ID__c, cl.Id);
        }
        // callout to fetch new docket entries
        String DocketLastKey;
        for(String unicourtId : caseIdDocketTokenMap.keyset() ){
            do{
                HttpRequest req = new HttpRequest();
                req.setMethod('GET');
                if(String.isNotBlank(DocketLastKey)){
                    req.setEndpoint('https://api.unicourt.com/rest/v1/case/'+unicourtId+'/docketEntries/?token=2a8c48f7019a286dae3ddd7f43a96622a9ccc669&docket_entries_token='+caseIdDocketTokenMap.get(unicourtId)+'&sort=DESC&last_key='+DocketLastKey);
                }else{
                    req.setEndpoint('https://api.unicourt.com/rest/v1/case/'+unicourtId+'/docketEntries/?token=2a8c48f7019a286dae3ddd7f43a96622a9ccc669&docket_entries_token='+caseIdDocketTokenMap.get(unicourtId)+'&sort=DESC');
                }
                
                req.setTimeout(60*1000);
                
                Http h = new Http();
                String resp;
                HttpResponse res = h.send(req);
                resp = res.getBody();
                resp = resp.replace('"date\"', '"entryDate\"');
                system.debug('resp::'+resp);
                DocketEntryParser parser = DocketEntryParser.parse(resp);
                If(parser != null && parser.Data != null)
                    DocketLastKey = parser.Data.last_key;
                if(!parser.error && parser != null){
                    
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
                system.debug('DocketLastKey::'+DocketLastKey);
            }while(String.isNotBlank(DocketLastKey));
        }
        if(oldDocketEntries.size() > 0)
            delete oldDocketEntries;
        if(newDocketEntries.size() > 0)
            insert newDocketEntries;
        
    }

     /*
     * Method: fetchAllCaseParties
     * Author: Jitendra
     * Date: 31/08/2019
     * Param 1: CaseID -- Unicourt Case Id
     * Param 2: PartiesToken -- Parties Token received from CASE API response

     */
    public static List<CaseParser.cls_parties> fetchAllCaseParties(String UnicourtCaseId, String PartiesToken){
        PartyJSONParser partyParser;
        List<CaseParser.cls_parties> partylist = new List<CaseParser.cls_parties>();
        Integer pageNumber = 0;
        do{
            pageNumber++;
            HttpRequest req = new HttpRequest();
            req.setMethod('GET');
            req.setEndpoint('https://api.unicourt.com/rest/v1/case/'+UnicourtCaseId+'/parties/?token=2a8c48f7019a286dae3ddd7f43a96622a9ccc669&parties_token='+PartiesToken+'&page_number='+pageNumber+'');
            req.setTimeout(60*1000);
            Http h = new Http();
            String resp;
            HttpResponse res = h.send(req);
            resp = res.getBody();
            system.debug('resp::'+resp);
            partyParser = PartyJSONParser.parse(resp);
            if(partyParser != null && partyParser.data != null && partyParser.data.parties != null && partyParser.data.parties.size() > 0){
                for(PartyJSONParser.Parties party : partyParser.data.parties){
                    CaseParser.cls_parties clsParty = new CaseParser.cls_parties();
                    clsParty.party_id = party.party_id;
                    clsParty.firstname = party.firstname;
                    clsParty.lastname = party.lastname;
                    clsParty.middlename = party.middlename;
                    clsParty.fullname = party.fullname;
                    clsParty.entity_type = party.entity_type;
                    clsParty.prefix = party.prefix;
                    clsParty.suffix = party.suffix;
                    clsParty.party_types = getCls_Party_Types(party.party_types);
                    system.debug('clsParty.party_types size ++ '+clsParty.party_types.size());
                    List<CaseParser.cls_entities> clsEntities = new List<CaseParser.cls_entities>();
                    for(PartyJSONParser.Entities ent : party.entities){
                        if(!ent.emails.isEmpty()){
                            CaseParser.cls_entities cls_ent = new CaseParser.cls_entities();
                           
                            cls_ent.emails = ent.emails;
                            clsEntities.add(cls_ent);
                        }
                        
                    }
                    if(!clsEntities.isEmpty())
                        clsParty.entities = clsEntities;

                    partylist.add(clsParty);

                }

            }
            system.debug('more Parties ? '+partyParser.data.more_parties);
            system.debug('req. page no -- '+partyParser.data.requested_page_number);
        }While(partyParser != null && partyParser.data != null && partyParser.data.more_parties != null && partyParser.data.more_parties);
        
        return partylist;
    }

    private static List<CaseParser.cls_attorney_association> getCls_attorney_associationList(List<PartyJSONParser.Attorney_association> AAList){
        List<CaseParser.cls_attorney_association> clsAAList = new List<CaseParser.cls_attorney_association>();
        for(PartyJSONParser.Attorney_association AA : AAList){
            CaseParser.cls_attorney_association clsAA = new CaseParser.cls_attorney_association();
            clsAA.attorney_type = AA.attorney_type;
            clsAA.active = AA.active;
            clsAA.attorney_id = AA.attorney_id;
            clsAAList.add(clsAA);
        }
        return clsAAList;

    }

    private static List<CaseParser.cls_party_types> getCls_Party_Types(List<PartyJSONParser.Party_types> partyTypeList){
        List<CaseParser.cls_party_types> clsPTlist = new List<CaseParser.cls_party_types>();
        for(PartyJSONParser.Party_types PT : partyTypeList){
            CaseParser.cls_party_types clsPT = new CaseParser.cls_party_types();
            clsPT.active = PT.active;
            clsPT.party_type = PT.party_type;
            clsPT.representation_type = PT.representation_type;
            clsPT.attorney_association = getCls_attorney_associationList(PT.attorney_association);
            clsPTlist.add(clsPT);

        }
        return clsPTlist;
    }

    /*
     * Method: fetchAllCaseAttorneys
     * Author: Jitendra
     * Date: 31/08/2019
     * Param 1: CaseID -- Unicourt Case Id
     * Param 2: AttorneysToken -- AttorneysToken received from CASE API response

     */
    public static List<CaseParser.cls_attorneys> fetchAllCaseAttorneys(String UnicourtCaseId, String AttorneysToken){
        AttorneyJSONParser attorneyParser;
        List<CaseParser.cls_attorneys> attorneyList = new List<CaseParser.cls_attorneys>();
        Integer pageNumber = 0;
        do{
            pageNumber++;
            HttpRequest req = new HttpRequest();
            req.setMethod('GET');
            req.setEndpoint('https://api.unicourt.com/rest/v1/case/'+UnicourtCaseId+'/attorneys/?token=2a8c48f7019a286dae3ddd7f43a96622a9ccc669&attorneys_token='+AttorneysToken+'&page_number='+pageNumber+'');
            req.setTimeout(60*1000);
            Http h = new Http();
            String resp;
            HttpResponse res = h.send(req);
            resp = res.getBody();
            system.debug('resp::'+resp);
            attorneyParser = AttorneyJSONParser.parse(resp);
            if(attorneyParser != null && attorneyParser.data != null && attorneyParser.data.attorneys != null && attorneyParser.data.attorneys.size() > 0){
                for(AttorneyJSONParser.Attorneys attorney : attorneyParser.data.attorneys){
                    CaseParser.cls_attorneys att = new CaseParser.cls_attorneys();
                    att.attorney_id = attorney.attorney_id;
                    att.firm = attorney.firm;
                    att.firstname = attorney.firstname;
                    att.lastname = attorney.lastname;
                    att.fullname = attorney.fullname;
                    att.middlename = attorney.middlename;
                    List<CaseParser.cls_entities> clsEntities = new List<CaseParser.cls_entities>();
                    for(AttorneyJSONParser.Entities ent : attorney.entities){
                        CaseParser.cls_entities cls_ent = new CaseParser.cls_entities();
                        if(!ent.emails.isEmpty()){
                            cls_ent.emails = ent.emails;
                        }
                        if(!ent.potentials.isEmpty()){
                            List<CaseParser.cls_potentials> ptList = new List<CaseParser.cls_potentials>();
                            for(AttorneyJSONParser.Potentials pot : ent.potentials){
                                CaseParser.cls_potentials cls_pot = new Caseparser.cls_potentials();
                                cls_pot.address = pot.address;
                                cls_pot.city = pot.city;
                                cls_pot.state = pot.state;
                                cls_pot.zipcode = pot.zipcode;
                                cls_pot.court_verified = pot.court_verified;
                                cls_pot.attorney_potential_id = pot.attorney_potential_id;
                                ptList.add(cls_pot);
                            }
                            if(!ptList.isEmpty()){
                                cls_ent.potentials = ptList;
                            }
                            
                        }
                        if (cls_ent != null) {
                            clsEntities.add(cls_ent);
                        }
                        
                    }
                    if(!clsEntities.isEmpty())
                        att.entities = clsEntities;

                    attorneyList.add(att);

                }

            }
            system.debug('more attorneys ? '+attorneyParser.data.more_attorneys);
            system.debug('req. page no -- '+attorneyParser.data.requested_page_number);
            system.debug('req. page no -- '+attorneyParser);
        }While(attorneyParser != null && attorneyParser.data != null && attorneyParser.data.more_attorneys != null && attorneyParser.data.more_attorneys);
        
        return attorneyList;
        
    }

     
    public static Date ParseDateString(String dateString){
        return ParseDateString(dateString, '', '');
    }
    
    public static Date ParseDateString(String dateString, String separator, String format){
        Date dateValue;
        if(String.isBlank(separator)){
            separator = '-';
        }
        system.debug('DateString---'+dateString+ ' separator:: '+separator+' format::- '+format);
        List<String> ListDateComp = dateString.split(separator);

        if(format.equals('ddmmyyyy')){
           dateValue = Date.newInstance(Integer.valueOf(ListDateComp[2]), Integer.valueOf(ListDateComp[1]), Integer.valueOf(ListDateComp[0])); 
        }else{
           dateValue = Date.newInstance(Integer.valueOf(ListDateComp[0]), Integer.valueOf(ListDateComp[1]), Integer.valueOf(ListDateComp[2])); 
        }
        
        return dateValue;
    }
    
   
}