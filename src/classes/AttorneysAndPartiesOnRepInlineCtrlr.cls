public class AttorneysAndPartiesOnRepInlineCtrlr {
    Public Representation__c representation{get;set;}
    Public List<Account> partyList{get;set;}
    Public String selectedPartyId{get;set;}
    Public List<Contact> attorneyList{get;set;}
    Public String selectedAttorneyId{get;set;}
    Public AttorneysAndPartiesOnRepInlineCtrlr(ApexPages.StandardController ctrlr){
        String repId = ctrlr.getId();
        representation = [select id,Unicourt_Attorney_First_Name__c,Unicourt_Attorney_Last_Name__c,Unicourt_Client_Name__c from representation__c where id = :repId];
        system.debug('attorny name:: '+representation.Unicourt_Attorney_First_Name__c+'-'+representation.Unicourt_Attorney_Last_Name__c);
        system.debug('party name:: '+representation.Unicourt_Client_Name__c);
        init();
    }
    
    public void init(){
        //populate party list
        partyList = [select id,name,phone,industry from Account where name = :representation.Unicourt_Client_Name__c];
        system.debug('pList::'+partyList);
        
        //populate attorney list
        String aName = representation.Unicourt_Attorney_First_Name__c+' '+representation.Unicourt_Attorney_Last_Name__c;
        attorneyList = [select id,name, account.name, email, phone from Contact where name = :aName];
        system.debug('aList::'+attorneyList);
    }
    // populate Representation Attorney lookup with the selected Contact
    Public void selectAttorney(){
        representation.Attorney__c = selectedAttorneyId;
        update representation;
    }
    
    // populate Representation Client lookup with the selected Account
    Public void selectParty(){
        representation.Client__c = selectedPartyId;
        update representation;
    }

}