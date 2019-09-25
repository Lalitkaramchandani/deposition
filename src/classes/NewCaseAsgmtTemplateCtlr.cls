/*
* Class Name  :  NewCaseAsgmtTemplateCtlr
* Author      :  Jitendra Kumar	   
* Purpose	  :  To get the Representations, related to case lead in right order.
*/

global class NewCaseAsgmtTemplateCtlr {
    
    global string caseleadId;
    global List<representation__c> repList;
    global Map<String, List<Representation__c>> commission_repList_Map{get;set;}
    
    global Set<String> commissionList{get;set;}
   
    global void setcaseleadId(String caseid){
        if(String.isBlank(caseleadId) && String.isNotBlank(caseid)){
            caseleadId = caseid;
            system.debug('caseleadid::'+caseid);
            List<Representation__c> RepsWithNoCommission = new List<Representation__c>();
            commission_repList_Map = new Map<String, List<Representation__c>>();
            for(Representation__c rep : [select id, Client__c,Client__r.name, Unicourt_Client_Name__c, Commission__r.name, Law_Firm__c,Law_Firm__r.name,Law_Firm_Text__c, Attorney__r.name, Unicourt_Attorney_First_Name__c, Unicourt_Attorney_Last_Name__c, Full_Attorney_Email__c from Representation__c where Case__c = :caseid order by Client__r.name, Unicourt_Client_Name__c, Law_Firm__r.name,Law_Firm_Text__c, Attorney__r.name,Unicourt_Attorney_First_Name__c]){
                String commission = rep.Commission__r.name != null ? rep.Commission__r.name : 'No Commission';
                if(commission.equals('No Commission')){
                    RepsWithNoCommission.add(rep);
                }
                else if(commission_repList_Map.keyset().contains(commission)){
                    commission_repList_Map.get(commission).add(rep);
                }else{
                    commission_repList_Map.put(commission, new List<Representation__c>());
                    commission_repList_Map.get(commission).add(rep);
                }
            }
            commission_repList_Map.put('No Commission',RepsWithNoCommission);
            commissionList = commission_repList_Map.keySet();
            system.debug('rep size::'+commission_repList_Map.get('No Commission').size());
            system.debug('commissionList::'+commissionList);
        }
    }
    
    global string getcaseleadId(){
        return caseleadId;
    }
}