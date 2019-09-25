/**************************************************
                Name        : UserTriggerHandler
                Purpose     : User Trigger handler
                Created Date: 12 JUNE 2016
                
                Modification History:
*****************************************************/

public class UserTriggerHandler extends TriggerHandler {

    public UserTriggerHandler() {}

    /* context overrides */
    protected override  void beforeUpdate() {
        updateUserFirmInfo();
    }
    
    protected override  void beforeInsert() {
        updateUserFirmInfo();
    }


    /* private methods */
    
    /* Update User Firm Email and Firm Phone From according to User Default CR Firm
    */
    private static void updateUserFirmInfo() {
        set<String>setFirms = new Set<String>();
        Map<Id,User>oldMap = (Map<Id,User>)trigger.oldmap;
        map<Id,User>mapUsers = new Map<Id,User>();
        List<Contact>lstContactsNeedUpdate = new List<Contact>();
        Set<Id>setContactIds = new Set<Id>();
        for(User user: (List<User>)trigger.new){
            if(user.Default_CR_Firm__c != NULL && (Trigger.IsInsert ||  (user.Default_CR_Firm__c!= oldmap.get(user.id).Default_CR_Firm__c))){
                setFirms.add(user.Default_CR_Firm__c );
                mapUsers.put(user.id,user);
                   
            }
            if(user.ContactId != NULL){
                setContactIds.add(user.ContactId);
                mapUsers.put(user.id,user);
            }
        }
        if(setFirms.size()>0 ||setContactIds.size()>0 ){
            Map<String,Firm__c>mapFirms = new Map<String,Firm__c>();
            Map<Id,Contact>mapContacts = new Map<Id,Contact>();
            if(setContactIds.size()>0){
                mapContacts = new Map<Id,Contact>([select Id,Default_CR_Firm__r.Name,Firm_Email__c,Firm_Phone__c FROM Contact
                                         WHERE ID IN : setContactIds AND Default_CR_Firm__c != NULL]);
            }
            for(Firm__c firm : [select Name,Phone__c,Scheduling_Email_Address__c From Firm__c 
                               WHERE Name IN:setFirms]){
                mapFirms.put(firm.Name,firm);
            }
            
            for(User usr : mapUsers.values()){
                if(mapFirms.containsKey(usr.Default_CR_Firm__c)){
                    Firm__c firm = mapFirms.get(usr.Default_CR_Firm__c);
                    usr.Firm_Email__c = firm.Scheduling_Email_Address__c ;
                    usr.Firm_Phone__c = firm.Phone__c;
                    
                    //if(lstContactsNeedUpdate.size()>0)
                    //    update lstContactsNeedUpdate;
                }
                if(usr.ContactId != NULL && mapContacts.containsKey(usr.ContactId) ){
                    /*Contact cont = new Contact(Id=usr.ContactId,Default_CR_Firm__c =usr.Default_CR_Firm__c ,
                    Firm_Email__c  = usr.Firm_Email__c ,Firm_Phone__c = usr.Firm_Phone__c );
                    lstContactsNeedUpdate.add(cont);*/
                    
                    Contact cont =mapContacts.get(usr.ContactId);
                    usr.Default_CR_Firm__c = cont.Default_CR_Firm__r.Name;
                    usr.Firm_Email__c = cont.Firm_Email__c ;
                    usr.Firm_Phone__c = cont.Firm_Phone__c ;
                }
            }
        }
        
    }
    
    
    
}