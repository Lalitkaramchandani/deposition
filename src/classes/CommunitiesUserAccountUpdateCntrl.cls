/**************************************************
                Name        : CommunitiesUserAccountUpdateCntrl
                Author      : Rajendra Rathore
                Purpose     : That class is used by CommunitiesUserAccountUpdate VF page for 
                              update Community user and contact information.
                Created Date: 24 JUNE 2016
                
                Modification History:
*****************************************************/
public class CommunitiesUserAccountUpdateCntrl {
    public User usr{get;set;}
    public Contact con{get;set;}
    public String errMsg{get;set;}
    public CommunitiesUserAccountUpdateCntrl(){
        usr = [select id,ContactId,FirstName,LastName,TimeZoneSidKey,Phone From User Where ID=:Userinfo.getUserId()];
        con = new Contact();
        if(usr.ContactId!= NULL){
            List<Contact>lstContacts = [select id,MailingStreet,MailingCity,MailingState,MailingPostalCode,MailingCountry,Standing_Orders__c From 
                                    Contact WHERE Id=:usr.contactId];
            if(lstContacts.size()>0)
                con = lstContacts[0];
        }
    }
    public void save(){
        errMsg  ='';
        try{
            update con;
            update usr;
            errMsg ='<span>Account information successfully updated.</span>';
        }catch(Exception e){
            errMsg ='<span>'+ e.getMessage() +'</span>';
        }
    }
}