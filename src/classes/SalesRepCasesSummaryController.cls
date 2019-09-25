public class SalesRepCasesSummaryController {
    Public List<Deposition__c> clientList{get;set;}
    Public List<Case_Leads__c> prospectList{get;set;}
    Public List<Case_Follower__c> followedCaseList{get;set;}
    Public String rId{get;set;}
    String currentUserId;
    
    public SalesRepCasesSummaryController(){
        currentUserId = Userinfo.getUserId();
        clientList = [select id,Name, Case_Lead__r.Case_Name__c, Deposition_Date__c, Deposition_Status__c from Deposition__c 
                      where Deposition_Date__c > TODAY and 
                      (Commission__r.Primary_Rep__c = :currentUserId or Commission__r.Secondary_Rep__c = :currentUserId or Commission__r.Tertiary_Rep__c = :currentUserId ) order by Deposition_Date__c asc];
        prospectList = [select id,Name, Case_Management_Conference__c, Case_Name__c from Case_Leads__c where Case_Management_Conference__c > TODAY and ownerId = :currentUserId order by Case_Management_Conference__c asc];
        followedCaseList = [select id, Case_Lead__c,Case_Lead__r.Case_Name__c  from Case_Follower__c where User__c = :currentUserId];
    }
    
    public PageReference showDetail() {
        String baseURL = System.Url.getSalesforceBaseUrl().toExternalForm();
        pagereference ref = new pagereference(baseURL+'/'+rId);
                                              ref.setredirect(true);
                                              return ref;
                                              }
                                              
                                              }