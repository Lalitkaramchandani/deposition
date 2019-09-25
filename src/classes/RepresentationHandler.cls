/**************************************************
                Name        : RepresentationHandler
                Purpose     : Representation Trigger handler
                Created Date: 17 APRIL 2018
                
                Modification History:
*****************************************************/

public class RepresentationHandler extends TriggerHandler {

    public RepresentationHandler() {}

    /* context overrides */
    protected override  void beforeUpdate() {
        updateLawFirm();
    }
    
    protected override  void beforeInsert() {
        beforeInsertRoutine();
        updateLawFirm();
    }
	
    protected override  void afterUpdate() {
       afterUpdateRoutine();
    }

    /* private methods */
    
    /* Update User Firm Email and Firm Phone From according to User Default CR Firm
    */
    private static void updateLawFirm() {
       
        for(Representation__c  representation: (List<Representation__c>)trigger.new){
            if(representation.Law_Firm__c == null){
                representation.Law_Firm__c = representation.Law_Firm_Id__c;
            }
            
        }
        
    }
    
    /* Perform routine tasks to be done on after update of representation
    */
    private static void afterUpdateRoutine() {
      
       // Map<ID, String> accIdAKA_map = new Map<Id, String>();
       // Map<ID, String> accIdAKALawFirm_map = new Map<Id, String>();
       // For Contacts
       // Map<ID, String> accIdAKAAttorney_map = new Map<Id, String>();

       Map<Id, Representation__c> repOldMap = (Map<Id, Representation__c>)trigger.oldMap; 
       /*
        for(Representation__c  representation: (List<Representation__c>)trigger.new){
            if(representation.Client__c != null && representation.Unicourt_Client_Name__c != null
               && repOldMap != null && repOldMap.get(representation.Id).Client__c == null){
                   if(accIdAKA_map.containsKey(representation.Client__c)){
                       String akaList = accIdAKA_map.get(representation.Client__c)+';'+representation.Unicourt_Client_Name__c;
                       system.debug('akaList:::'+akaList);
                       accIdAKA_map.put(representation.Client__c,akaList);
                   }else{
                       accIdAKA_map.put(representation.Client__c,representation.Unicourt_Client_Name__c);
                   }
               }
               // Check Law Firm mapping and populate map
               if(representation.Law_Firm__c != null && representation.Law_Firm_Text__c != null
               && repOldMap != null && repOldMap.get(representation.Id).Law_Firm__c == null){
                   if(accIdAKALawFirm_map.containsKey(representation.Law_Firm__c)){
                       String akaLawFirmList = accIdAKALawFirm_map.get(representation.Law_Firm__c)+';'+representation.Law_Firm_Text__c;
                       system.debug('akaLawFirmList:::'+akaLawFirmList);
                       accIdAKALawFirm_map.put(representation.Law_Firm__c,akaLawFirmList);
                   }else{
                       accIdAKALawFirm_map.put(representation.Law_Firm__c,representation.Law_Firm_Text__c);
                   }
               }
            
            // Check Attornet mapping and populate map
             String fullname = null;
            if(String.isNotBlank(representation.Unicourt_Attorney_First_Name__c) && String.isNotBlank(representation.Unicourt_Attorney_Last_Name__c))
              fullname = representation.Unicourt_Attorney_First_Name__c + ' ' + representation.Unicourt_Attorney_Last_Name__c;
            
             if(representation.Attorney__c != null && fullname != null
               && repOldMap != null && repOldMap.get(representation.Id).Attorney__c == null){
                   if(accIdAKAAttorney_map.containsKey(representation.Attorney__c)){
                       String akaAttorneyList = accIdAKAAttorney_map.get(representation.Attorney__c)+';'+fullname;
                       system.debug('akaAttorneyList:::'+akaAttorneyList);
                       accIdAKAAttorney_map.put(representation.Attorney__c,akaAttorneyList);
                   }else{
                       accIdAKAAttorney_map.put(representation.Attorney__c,fullname);
                   }
               }
        }
        List<Account> accToUpdateList = new List<account>();
        for(Account acc : [select id, aka__c,AKA_Law_Firm__c from account where id in :accIdAKA_map.keyset() or id in :accIdAKALawFirm_map.keyset()]){
            if(String.isNotBlank(accIdAKA_map.get(acc.id))){
                acc.AKA__c = acc.AKA__c != null ? acc.AKA__c + ';'+accIdAKA_map.get(acc.id) : accIdAKA_map.get(acc.id);
            }
            if(String.isNotBlank(accIdAKALawFirm_map.get(acc.id))){
                acc.AKA_Law_Firm__c = acc.AKA_Law_Firm__c != null ? acc.AKA_Law_Firm__c + ';'+accIdAKALawFirm_map.get(acc.id) : accIdAKALawFirm_map.get(acc.id);
            }
            accToUpdateList.add(acc);
        }
        if(accToUpdateList.size() > 0)
         update accToUpdateList;
        
        //Update Contact List
        List<Contact> contactToUpdateList = new List<Contact>();
        for(Contact cont : [select id, AKA_Attorney__c from contact where id in :accIdAKAAttorney_map.keyset()]){
            if(String.isNotBlank(accIdAKAAttorney_map.get(cont.id))){
                cont.AKA_Attorney__c = cont.AKA_Attorney__c != null ? cont.AKA_Attorney__c + ';'+accIdAKAAttorney_map.get(cont.id) : accIdAKAAttorney_map.get(cont.id);
            }
            
            contactToUpdateList.add(cont);
        }
        if(contactToUpdateList.size() > 0)
         update contactToUpdateList;
        */
    }

    
    /* Perform routine tasks to be done on after update of representation
    */
    private static void beforeInsertRoutine() { 
        /*
        Set<String> AccNamesToSearch = new Set<String>();
        Set<String> ClientAccNamesToSearch = new Set<String>();
        Set<String> LawFirmAccNamesToSearch = new Set<String>();
        
        Set<String> ConNamesToSearch = new Set<String>();
        Set<String> AttorneyConNamesToSearch = new Set<String>();
        
        for(Representation__c  representation: (List<Representation__c>)trigger.new){
            if(representation.Client__c == null && representation.Unicourt_Client_Name__c != null){
                String searchValue = representation.Unicourt_Client_Name__c;
                AccNamesToSearch.add(searchValue.toUpperCase());
                ClientAccNamesToSearch.add(searchValue.toUpperCase());
               }
            if(representation.Law_Firm__c == null && representation.Law_Firm_Text__c != null){
                String searchValue = representation.Law_Firm_Text__c;
                AccNamesToSearch.add(searchValue.toUpperCase());
                LawFirmAccNamesToSearch.add(searchValue.toUpperCase());
               }
            
            //Contacts
            String fullname = null;
            if(String.isNotBlank(representation.Unicourt_Attorney_First_Name__c) && String.isNotBlank(representation.Unicourt_Attorney_Last_Name__c) )
             fullname =  representation.Unicourt_Attorney_First_Name__c + ' ' +representation.Unicourt_Attorney_Last_Name__c;
            if(representation.Attorney__c == null && fullname != null){
                String searchValue = fullname;
                ConNamesToSearch.add(searchValue.toUpperCase());
                AttorneyConNamesToSearch.add(searchValue.toUpperCase());
            }
        }
        
        //Contacts
        String conQuery;
        Integer j = 0;
        for(String contactname : ConNamesToSearch){
            if(j == 0){
                conQuery = '("'+contactname+'")';
            }else{
                conQuery = conQuery + ' OR ("'+contactname+'")';
            }
            j++; 
        }
        // search all the unmatched attorney name in Contact name and AKA_Attorney__c
        if(String.isNotBlank(conQuery)){
        String contactQuery = 'Find :conQuery IN ALL FIELDS RETURNING Contact(id, AKA_Attorney__c,name)';
        system.debug('Query:: '+contactQuery);
        List<List<SObject>> contactList = search.query(contactQuery);
        Map<String, Id> SearchValueContactIDMap = new Map<String, Id>();
        
        for(Contact cont : (List<Contact>)contactList[0]){
          //Jitendra - commenting below code to match Contact with Name. It is being performed in LeadGenCaseBatch with additional criteria.
          /*  String ContactName;
            If(String.isNotBlank(cont.Name))
                ContactName = cont.Name.toUpperCase();
            
            if(AttorneyConNamesToSearch != null && String.isNotBlank(ContactName) && AttorneyConNamesToSearch.contains(ContactName)){
                SearchValueContactIDMap.put(ContactName, cont.Id);
            } */
            /*
            //populate map for contact Match
            If(String.isNotBlank(cont.AKA_Attorney__c)){
                for(String searchValue : cont.AKA_Attorney__c.split(';')){
                    searchValue = searchValue.toUpperCase();
                    // system.debug('searchValue::: '+searchValue);
                    // system.debug('AccNamesToSearch::: '+AccNamesToSearch);
                    if(AttorneyConNamesToSearch != null && AttorneyConNamesToSearch.contains(searchValue)){
                        SearchValueContactIDMap.put(searchValue, cont.Id);
                    }
                } 
            }
            
        }
        // map Representation Attorney with matching Contact
        for(Representation__c  representation: (List<Representation__c>)trigger.new){
            String fullname = representation.Unicourt_Attorney_First_Name__c + ' ' +representation.Unicourt_Attorney_Last_Name__c;
            if(representation.Attorney__c == null && fullname != null){
                String ContactNameText = fullname.toUpperCase();
                if(SearchValueContactIDMap != null && SearchValueContactIDMap.containsKey(ContactNameText))
                    representation.Attorney__c = SearchValueContactIDMap.get(ContactNameText);
               }

        }
        }
        
        String searchQuery;
        Integer i = 0;
        for(String accname : AccNamesToSearch){
            if(i == 0){
                searchQuery = '("'+accname+'")';
            }else{
                searchQuery = searchQuery + ' OR ("'+accname+'")';
            }
            i++; 
        }
        // search all the unmatched client name or Law Firm Names in Account name and AKA or AKA Law Firm field
        system.debug('searchQuery::: '+searchQuery);
        if(String.isNotBlank(searchQuery)){
            String Query = 'Find :searchQuery IN ALL FIELDS RETURNING Account(id, AKA__c,AKA_Law_Firm__c,name)';
            system.debug('Query:: '+Query);
            List<List<SObject>> resList = search.query(Query);
            Map<String, Id> SearchValueAccIDMap = new Map<String, Id>();
            Map<String, Id> SearchValueAccIDMapForLawFirm = new Map<String, Id>();
            for(Account acc : (List<Account>)resList[0]){
                String AccName;
                If(String.isNotBlank(acc.Name))
                    AccName = acc.Name.toUpperCase();
                //populate map for client Match
                if(ClientAccNamesToSearch != null && String.isNotBlank(AccName) && ClientAccNamesToSearch.contains(AccName)){
                    SearchValueAccIDMap.put(AccName, acc.Id);
                }
                If(String.isNotBlank(acc.aka__c)){
                    for(String searchValue : acc.aka__c.split(';')){
                        searchValue = searchValue.toUpperCase();
                        // system.debug('searchValue::: '+searchValue);
                        // system.debug('AccNamesToSearch::: '+AccNamesToSearch);
                        if(ClientAccNamesToSearch != null && ClientAccNamesToSearch.contains(searchValue)){
                            SearchValueAccIDMap.put(searchValue, acc.Id);
                        }
                    } 
                }
                //populate map for Law Firm match
                if(LawFirmAccNamesToSearch != null && String.isNotBlank(AccName) && LawFirmAccNamesToSearch.contains(AccName)){
                    SearchValueAccIDMapForLawFirm.put(AccName, acc.Id);
                }
                If(String.isNotBlank(acc.AKA_Law_Firm__c)){
                    for(String searchValue : acc.AKA_Law_Firm__c.split(';')){
                        searchValue = searchValue.toUpperCase();
                        // system.debug('searchValue::: '+searchValue);
                        // system.debug('AccNamesToSearch::: '+AccNamesToSearch);
                        if(LawFirmAccNamesToSearch != null && LawFirmAccNamesToSearch.contains(searchValue)){
                            SearchValueAccIDMapForLawFirm.put(searchValue, acc.Id);
                        }
                    } 
                }
            }
            // map Representation Client with matching Account
            for(Representation__c  representation: (List<Representation__c>)trigger.new){
                if(representation.Client__c == null && representation.Unicourt_Client_Name__c != null){
                    String ClientNameText = representation.Unicourt_Client_Name__c.toUpperCase();
                    if(SearchValueAccIDMap != null && SearchValueAccIDMap.containsKey(ClientNameText))
                        representation.Client__c = SearchValueAccIDMap.get(ClientNameText);
                }
                // populate Law Firm match
                if(representation.Law_Firm__c == null && representation.Law_Firm_Text__c != null){
                    String LawFirmText = representation.Law_Firm_Text__c.toUpperCase();
                    if(SearchValueAccIDMapForLawFirm != null && SearchValueAccIDMapForLawFirm.containsKey(LawFirmText))
                        representation.Law_Firm__c = SearchValueAccIDMapForLawFirm.get(LawFirmText);
                }
                
            }
        }
        
        */
        
        
     }
    
    
    
}