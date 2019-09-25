/**
                        Name             : RateSheetCloneExtn
                        Date             : 05/11/2015
                        Description      : That class is used by RateSheetClone VF page for clone
                                            Rate sheet record as well as their child rate sheet item records
*/                                             
public class RateSheetCloneExtn {
    //added an instance varaible for the standard controller
    private ApexPages.StandardController controller {get; set;}
     // add the instance for the variables being passed by id on the url
    public  Rate_Sheet__c rateSheet {get;set;}
    // set the id of the record that is created -- ONLY USED BY THE TEST CLASS
    public ID newRecordId {get;set;}

    // initialize the controller
    public RateSheetCloneExtn(ApexPages.StandardController sc) {

        //initialize the stanrdard controller
        this.controller = sc;
        // load the current record
        List<Rate_Sheet__c>lstRateSheets = [select Id, Name,Notes__c,Commission_Rate__c,Type__c
                                             from Rate_Sheet__c where id = :sc.getId()];
        if(lstRateSheets.size()>0){
            rateSheet =lstRateSheets[0].clone(false);
            rateSheet.OwnerId= UserInfo.getUserId();
        }
    }

    // method called from the VF's action attribute to clone the po
    public PageReference cloneWithItems() {

         // setup the save point for rollback
         Savepoint sp = Database.setSavepoint();
         try {
             if(!Test.isRunningTest()){
                upsert rateSheet;
            }
            // set the id of the new rate sheet created for testing
            newRecordId = rateSheet.id;

             // copy over the line items
             List<Rate_Sheet_Item__c> lstRateSheetItems = new List<Rate_Sheet_Item__c>();
             for (Rate_Sheet_Item__c item : [Select id,name,Item__c,Notes__c,Invoice_Text__c,
                                            Price__c,Units_of_Measure__c,Default__c,State__c
                                            From Rate_Sheet_Item__c 
                                            WHERE   Rate_sheet__c=:controller.getId() ]) {
                  Rate_Sheet_Item__c newRateSheetItem = item.clone(false);
                  newRateSheetItem.Rate_Sheet__c = rateSheet.id;
                  lstRateSheetItems.add(newRateSheetItem);
             }
             insert lstRateSheetItems;
         } catch (Exception e){
             // roll everything back in case of error
             system.debug('***** exception '+e);
            Database.rollback(sp);
            ApexPages.addMessages(e);
            return null;
         }

        return new PageReference('/'+rateSheet.id);
    }

}