public class CommissionTriggerHepler {
    
    public static void onAfterInsert(List<Commission__c> newCommissions){
        
    }
    
    public static void onAfterUpdate(List<Commission__c> newCommissions, Map<Id,Commission__c> oldMap ){
        updateCaseLeads(newCommissions,oldMap);
    }
    
    /*
* Purpose: when Primary, Secondary or Tertiary Rep changes, update their email id to Case Lead Fields.
* Author: Jitendra Kumar, 12-Jan-2019
*/
    private static void updateCaseLeads(List<Commission__c> newCommissions, Map<Id,Commission__c> oldMap){
        Set<ID> commissionIds = new Set<Id>();
        for(Commission__c comm : newCommissions){
            if(oldMap != null && (comm.Primary_Rep__c != oldMap.get(comm.Id).Primary_Rep__c || 
                                  comm.Secondary_Rep__c != oldMap.get(comm.Id).Secondary_Rep__c ||
                                  comm.Tertiary_Rep__c != oldMap.get(comm.Id).Tertiary_Rep__c)){
                                      commissionIds.add(comm.Id);
                                  }
        }
        List<Case_Leads__c> caseLeadList = new List<Case_Leads__c>();
        for(commission__c comm : [select id, Primary_Rep__r.email, Secondary_Rep__r.email, Tertiary_Rep__r.email, 
                                  (select id, Commission_Primary_Rep_Email__c, Commission_Secondary_Rep_Email__c, Commission_Tertiary_Rep_Email__c from Case_Leads__r) 
                                  from commission__c where id in :commissionIds]){
                                      if(comm.Case_Leads__r.size() > 0){
                                          for(Case_Leads__c cl : comm.Case_Leads__r){
                                              cl.Commission_Primary_Rep_Email__c = comm.Primary_Rep__r.email;
                                              cl.Commission_Secondary_Rep_Email__c = comm.Secondary_Rep__r.email;
                                              cl.Commission_Tertiary_Rep_Email__c = comm.Tertiary_Rep__r.email;
                                              caseLeadList.add(cl);
                                          }
                                      }           
                                  }
        update caseLeadList;
        
    }
    
}