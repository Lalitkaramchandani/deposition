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
        updateLawFirm();
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
    
    
    
}