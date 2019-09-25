public class CaseLeadTriggerHelper {

    public static void onBeforeInsert(List<case_leads__c> newCaseLeads){
        
       
        Map<String, case_leads__c> UnicourtIdCaseLeadMap = new Map<String, case_leads__c>();
        
        for(case_leads__c cl : newCaseLeads){
            if(String.isNotBlank(cl.Unicourt_Case_ID__c)){
                UnicourtIdCaseLeadMap.put(cl.Unicourt_Case_ID__c, cl);
            }
        }
        // check if new unicourt case Ids are blocked
        system.debug('here validateUnicourtIds is called----');
        validateUnicourtIds(UnicourtIdCaseLeadMap);
        updateCommissionRepEmails(newCaseLeads,null);
    }
    
    public static void onBeforeUpdate(List<case_leads__c> newCaseLeads, Map<Id, case_leads__c> oldCaseLeadsMap){
        updateCommissionRepEmails(newCaseLeads,oldCaseLeadsMap);
    }
    
    /*
     * Method : validateUnicourtIds
     * @param1 : Map<String, case_leads__c>
     * purpose : Validate and add Error if Unicourt Case ID of the Case Lead is blocked.
     */
    private static void validateUnicourtIds(Map<String, case_leads__c> UnicourtIdCaseLeadMap){
        for(Blocked_Unicourt_Case__c blockedCase : [select id, Unicourt_Case_Id__c from Blocked_Unicourt_Case__c where Unicourt_Case_Id__c in :UnicourtIdCaseLeadMap.keyset()]){
			   if(UnicourtIdCaseLeadMap.keyset().contains(blockedCase.Unicourt_Case_Id__c))
                   UnicourtIdCaseLeadMap.get(blockedCase.Unicourt_Case_Id__c).addError('This Unicourt case is blocked.');
        }
    }
    
    private static void updateCommissionRepEmails(List<case_leads__c> newCaseLeads, Map<Id, case_leads__c> oldCaseLeadsMap){
        system.debug('updateCommissionRepEmails start--');
        List<id> commissionIds = new List<Id>();
        for(case_leads__c cl : newCaseLeads){
                system.debug('cl.Commission__c:::'+cl.Commission__c);
                if(cl.Commission__c != null){
                    commissionIds.add(cl.Commission__c);
                }else{
                    system.debug('commission null--');
                    cl.Commission_Primary_Rep_Email__c = null;
                    cl.Commission_Secondary_Rep_Email__c = null;
                    cl.Commission_Tertiary_Rep_Email__c = null;
                }
            
        }
        system.debug('commissionIds--'+commissionIds);
        Map<Id, Commission__c> commissionMap = new Map<Id, Commission__c>([select id, Primary_Rep__r.email, Secondary_Rep__r.email, Tertiary_Rep__r.email 
                                                                           from commission__c where id in :commissionIds]);
        for(case_leads__c cl : newCaseLeads){
            if(cl.Commission__c != null && commissionMap.keyset().contains(cl.Commission__c)){
                commission__c comm = commissionMap.get(cl.Commission__c);
                cl.Commission_Primary_Rep_Email__c = comm.Primary_Rep__r.email;
                cl.Commission_Secondary_Rep_Email__c = comm.Secondary_Rep__r.email;
                cl.Commission_Tertiary_Rep_Email__c = comm.Tertiary_Rep__r.email;
            }
        }
    }
    
    
    
    
}