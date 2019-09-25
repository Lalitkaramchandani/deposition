/*
 * Name         : HighProfileCasesController
 * Author       : Jitendra, 25 Jan 2019
 * Test Class   : HighProfileCasesControllerTest
 */
public class HighProfileCasesController {
     public List<Case_leads__c> HPCaseList{get;set;}
     List<Case_leads__c>  HPCaseMasterList;
    public String selectedCommission{get;set;}
    public Boolean isReadOnly{get;set;}
    public List<SelectOption> commissionList;
    transient public Map<Id, String> caseFirmsMap= new Map<Id, String>();
    transient public Map<Id, String> casePartiesMap= new Map<Id, String>();
    public Map<String,String> commIDNameMap;

    List<String> filterStatusList = new List<String>{'Other Disposed','Terminated'};
    public HighProfileCasesController(){
        HPCaseList = new List<Case_leads__c>();
        isReadOnly = true;
        system.debug('isReadonly --- '+isReadOnly);
        HPCaseMasterList = new List<Case_leads__c>();
      //  caseFirmsMap = new Map<Id, String>();
     //   casePartiesMap = new Map<Id, String>();
        commIDNameMap = new Map<String,String>();
        for(Case_leads__c cl : [select id,name, Case_Type__c,Discovery_Deadline__c, Filing_Date__c, Commission__c,Commission__r.Name, Followup_Date__c, Notes__c, (select id, Law_Firm__r.name, Law_Firm_Text__c, Client__r.name, Unicourt_Client_Name__c  from Representation__r)   from Case_Leads__c where High_Profile_Case__c = true and Case_Status__c not in :filterStatusList LIMIT 1000]){
            List<String> partiesName = new List<String>();
            List<String> firmsName = new List<String>();
            if(String.isNotBlank(cl.Commission__c))
                commIDNameMap.put(cl.Commission__c,cl.Commission__r.Name);
            for(Representation__c rep : cl.Representation__r){
                if(String.isNotBlank(rep.Law_Firm__r.name) && !firmsName.contains(rep.Law_Firm__r.name))
                    firmsName.add(rep.Law_Firm__r.name);
                if(String.isNotBlank(rep.Law_Firm_Text__c) && !firmsName.contains(rep.Law_Firm_Text__c))
                    firmsName.add(rep.Law_Firm_Text__c);
                if(String.isNotBlank(rep.Client__r.name) && !partiesName.contains(rep.Client__r.name) )
                    partiesName.add(rep.Client__r.name);
                if(String.isNotBlank(rep.Unicourt_Client_Name__c) && !partiesName.contains(rep.Unicourt_Client_Name__c))
                    partiesName.add(rep.Unicourt_Client_Name__c);
            }
            
            Case_leads__c cloneCaseLead = new Case_leads__c (id=cl.id, Name=cl.Name,Case_Type__c = cl.Case_Type__c);
            cloneCaseLead.Filing_Date__c = cl.Filing_Date__c;
            cloneCaseLead.Commission__c= cl.Commission__c;
            cloneCaseLead.Followup_Date__c= cl.Followup_Date__c;
            cloneCaseLead.Notes__c= cl.Notes__c;
            cloneCaseLead.Discovery_Deadline__c = cl.Discovery_Deadline__c;
            HPCaseMasterList.add(cloneCaseLead );
            
           // if(!firmsName.isEmpty())
                caseFirmsMap.put(cl.Id, String.join(firmsName, ','));
           // if(!partiesName.isEmpty())
                casePartiesMap.put(cl.Id, String.join(partiesName, ','));
            
        }
        HPCaseList = HPCaseMasterList;
    }
    
    public Map<Id,String> getCaseFirmsMap(){
       
       If(caseFirmsMap != null && caseFirmsMap.size() > 0){
            return caseFirmsMap;
       }
        caseFirmsMap = new Map<Id, String>();
        casePartiesMap = new Map<Id, String>();
        for(Case_leads__c cl : [select id,name, Case_Type__c, Filing_Date__c, Commission__c,Commission__r.Name, Followup_Date__c, Notes__c, (select id, Law_Firm__r.name, Law_Firm_Text__c, Client__r.name, Unicourt_Client_Name__c  from Representation__r)   from Case_Leads__c where High_Profile_Case__c = true and Case_Status__c not in :filterStatusList LIMIT 1000]){
            List<String> partiesName = new List<String>();
            List<String> firmsName = new List<String>();
           
            for(Representation__c rep : cl.Representation__r){
                if(String.isNotBlank(rep.Law_Firm__r.name) && !firmsName.contains(rep.Law_Firm__r.name))
                    firmsName.add(rep.Law_Firm__r.name);
                if(String.isNotBlank(rep.Law_Firm_Text__c) && !firmsName.contains(rep.Law_Firm_Text__c))
                    firmsName.add(rep.Law_Firm_Text__c);
                if(String.isNotBlank(rep.Client__r.name) && !partiesName.contains(rep.Client__r.name) )
                    partiesName.add(rep.Client__r.name);
                if(String.isNotBlank(rep.Unicourt_Client_Name__c) && !partiesName.contains(rep.Unicourt_Client_Name__c))
                    partiesName.add(rep.Unicourt_Client_Name__c);
            }
            
           // if(!firmsName.isEmpty())
                caseFirmsMap.put(cl.Id, String.join(firmsName, ','));
           // if(!partiesName.isEmpty())
                casePartiesMap.put(cl.Id, String.join(partiesName, ','));
        }
        return caseFirmsMap;
       
    }

    public Map<Id,String> getCasePartiesMap(){
        If(casePartiesMap != null && casePartiesMap.size() > 0){
            return casePartiesMap;
       }
        caseFirmsMap = new Map<Id, String>();
        casePartiesMap = new Map<Id, String>();
        for(Case_leads__c cl : [select id,name, Case_Type__c, Filing_Date__c, Commission__c,Commission__r.Name, Followup_Date__c, Notes__c, (select id, Law_Firm__r.name, Law_Firm_Text__c, Client__r.name, Unicourt_Client_Name__c  from Representation__r)   from Case_Leads__c where High_Profile_Case__c = true and Case_Status__c not in :filterStatusList LIMIT 1000]){
            List<String> partiesName = new List<String>();
            List<String> firmsName = new List<String>();
           
            for(Representation__c rep : cl.Representation__r){
                if(String.isNotBlank(rep.Law_Firm__r.name) && !firmsName.contains(rep.Law_Firm__r.name))
                    firmsName.add(rep.Law_Firm__r.name);
                if(String.isNotBlank(rep.Law_Firm_Text__c) && !firmsName.contains(rep.Law_Firm_Text__c))
                    firmsName.add(rep.Law_Firm_Text__c);
                if(String.isNotBlank(rep.Client__r.name) && !partiesName.contains(rep.Client__r.name) )
                    partiesName.add(rep.Client__r.name);
                if(String.isNotBlank(rep.Unicourt_Client_Name__c) && !partiesName.contains(rep.Unicourt_Client_Name__c))
                    partiesName.add(rep.Unicourt_Client_Name__c);
            }
            
           // if(!firmsName.isEmpty())
                caseFirmsMap.put(cl.Id, String.join(firmsName, ','));
           // if(!partiesName.isEmpty())
                casePartiesMap.put(cl.Id, String.join(partiesName, ','));
        }
        return casePartiesMap;
    }

    public List<SelectOption> getCommissionList(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','All'));
        for(String commId : commIDNameMap.keySet()){
            SelectOption option = new SelectOption(commId,commIDNameMap.get(commId));
            options.add(option);
        }
        
        return options;
    }
    public void save(){
        update HPCaseList;
    }
    
    public void filterListByCommission(){
        HPCaseList = new List<Case_leads__c>();
        if(String.isBlank(selectedCommission)){
            HPCaseList = HPCaseMasterList;
        }else{
            for(Case_leads__c cl : HPCaseMasterList ){
                system.debug(selectedCommission+' - '+cl.Commission__c);
                if(selectedCommission.equals(cl.Commission__c)){
                    HPCaseList.add(cl);
                }
            }
        }
    }

    public void toggleReadyOnlyMode(){
        system.debug('before toggle --- '+isReadOnly);
        if(isReadOnly){
            isReadOnly = false;
        }else{
            isReadOnly = true;
        }
        filterListByCommission();
        system.debug('after toggle --- '+isReadOnly);
    }
    
    
}