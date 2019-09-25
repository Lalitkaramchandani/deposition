public class RateSheetItemsDetailsCntrl{
    public string rateSheetRecordId{get;set;}
    public List<Rate_Sheet_Item__c>getRateSheetItems(){
        return [select id,Item__c,Item__r.name,Price__c,Units_of_Measure__c From Rate_Sheet_Item__c 
                WHERE Rate_Sheet__c=:rateSheetRecordId 
                ORDER By Default__c DESC NULLS Last,  Item__r.Name ASC];
    }
    
    public Firm__c getFrimRecord(){
         List<user>lstUsers = [select id,Default_CR_Firm__c From User WHERE Id=:UserInfo.getUserId()];
         if(lstUsers.size()>0){
           return DepositionHelper.fetchFirm(lstUsers[0].Default_CR_Firm__c );
           
         }
         return new Firm__c ();
    }
     
}