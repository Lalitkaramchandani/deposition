public class DocketActivitiesInlineExtension {

    public List<Docket_Activity__c> docketActivities{get;set;}  
    public Id caseId{get;set;}
    public DocketActivitiesInlineExtension(ApexPages.StandardController ctrlr){
        caseId = ctrlr.getId();
        docketActivities = [select id,name,Docket_Entry_Date__c, Case__c,Docket_Update__c, LastModifiedDate
                                          from Docket_Activity__c where case__c = :caseId];
    }

}