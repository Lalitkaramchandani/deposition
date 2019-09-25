public class CaseLeadsStartPageController {
    public Map<Id, Docket_Activity__c> CaseIddocketActivitiesMap{get;set;}
    public Map<Id, Integer> CaseVs30DayHistory{get;set;}
    public List<case_leads__c> myCaseList{get;set;}
    public Date caseUpdateSince{get;set;}
    Id currentUserId;
    List<String> followedCaseList;
    public CaseLeadsStartPageController(){
        
        caseUpdateSince = System.today().addDays(-30);
        
        followedCaseList = new List<String>();
        currentUserId = UserInfo.getUserId();
        for(Case_Follower__c cf : [select id, Case_Lead__c from Case_Follower__c where User__c = :currentUserId] ){
            followedCaseList.add(cf.Case_Lead__c);
        }
        myCaseList = [select id, LastModifiedDate, Case_Name__c,commission__c 
                      from Case_Leads__c 
                      where id in :followedCaseList or Commission__r.Primary_Rep__c = :currentUserId OR Commission__r.Secondary_Rep__c = :currentUserId OR Commission__r.Tertiary_Rep__c = :currentUserId 
                      order by lastmodifieddate desc];
        getCaseUpdates();
        
    }
    
    public void getCaseUpdates(){
        CaseIddocketActivitiesMap = new Map<Id, Docket_Activity__c>();
        CaseVs30DayHistory = new Map<Id, Integer>();
        Integer caseCount = 0;
        system.debug('caseUpdateSince:::'+caseUpdateSince);
        for(Docket_Activity__c docket :  [select id, Docket_Entry_Date__c, Case__c,Docket_Update__c, LastModifiedDate
                                          from Docket_Activity__c 
                                          where Docket_Entry_Date__c >= :caseUpdateSince And (case__c in :followedCaseList or Case__r.Commission__r.Primary_Rep__c = :currentUserId OR Case__r.Commission__r.Secondary_Rep__c = :currentUserId OR Case__r.Commission__r.Tertiary_Rep__c = :currentUserId)  
                                          order by Docket_Entry_Date__c desc, Order__c desc]){
                                              if(!CaseIddocketActivitiesMap.containsKey(docket.Case__c) && caseCount < 25){
                                                  CaseIddocketActivitiesMap.put(docket.Case__c, docket);
                                                  caseCount++;
                                              }
                                              if(CaseIddocketActivitiesMap.containsKey(docket.Case__c)){
                                                  if(CaseVs30DayHistory.containsKey(docket.Case__c)){
                                                      Integer count = CaseVs30DayHistory.get(docket.Case__c)+1;
                                                      CaseVs30DayHistory.put(docket.Case__c, count);
                                                  }else{
                                                      CaseVs30DayHistory.put(docket.Case__c, 1);
                                                  }
                                              }
                                          }
    }
    
}