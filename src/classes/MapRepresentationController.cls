public class MapRepresentationController {
    public Representation__c rep{get;set;}
    public MapRepresentationController(ApexPages.StandardController controller){
        String repID = controller.getId();
         system.debug('repID::: -- '+repID);
        rep = [select id,Unicourt_Attorney_First_Name__c,Unicourt_Attorney_Last_Name__c,Attorney__c,Unicourt_Client_Name__c,Client__c,Law_Firm_Text__c,Law_Firm__c  from representation__c where id = :repID];
        system.debug('rep::: -- '+rep);
    }
    
    public void updateAllReps(){
        try{
            system.debug('rep:::'+rep);
            List<Representation__c> allReps = [select id,Unicourt_Attorney_First_Name__c,Unicourt_Attorney_Last_Name__c,Attorney__c,Unicourt_Client_Name__c,Client__c,Law_Firm_Text__c,Law_Firm__c  
                                               from representation__c 
                                               where ((Unicourt_Attorney_First_Name__c != '' or Unicourt_Attorney_Last_Name__c != '') and Unicourt_Attorney_First_Name__c = :rep.Unicourt_Attorney_First_Name__c and Unicourt_Attorney_Last_Name__c =:rep.Unicourt_Attorney_Last_Name__c ) or (Unicourt_Client_Name__c = :rep.Unicourt_Client_Name__c and Unicourt_Client_Name__c != '') or (Law_Firm_Text__c = :rep.Law_Firm_Text__c and Law_Firm_Text__c != '')];
            system.debug('all reps :: - '+allReps.size());
            for(Representation__c repToUpdate : allReps){
                if(repToUpdate.Unicourt_Attorney_First_Name__c == rep.Unicourt_Attorney_First_Name__c 
                   && repToUpdate.Unicourt_Attorney_Last_Name__c == rep.Unicourt_Attorney_Last_Name__c && rep.Attorney__c != null && repToUpdate.Attorney__c == null){
                       repToUpdate.Attorney__c = rep.Attorney__c;
                       repToUpdate.IsAttorneyMappedManually__c = true;
                   }
                if(repToUpdate.Unicourt_Client_Name__c == rep.Unicourt_Client_Name__c && repToUpdate.Client__c == null
                   && rep.Client__c != null){
                       repToUpdate.Client__c = rep.Client__c;
                       repToUpdate.IsClientMappedManually__c = true;
                   }
                if(repToUpdate.Law_Firm_Text__c == rep.Law_Firm_Text__c && repToUpdate.Law_Firm__c == null
                   && rep.Law_Firm__c != null){
                       repToUpdate.Law_Firm__c = rep.Law_Firm__c;
                       repToUpdate.IsLawFirmMappedManually__c = true;
                   }
                
            }
            update allReps;
        }
        catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            system.debug('Exception:::- '+ex.getMessage()+' -- '+ex.getStackTraceString());
        }
    }
}