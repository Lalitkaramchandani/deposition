/**                                    
                                        Name             : TestUtility
                                        Date             : 3 DEC 2015
                                        Description      : Utility Class for all test classes
*/ 
@isTest
public Class TestUtility{
     // Create Account record
     public static Account createAccount(String name, String Industry) {
        Account account = new Account(Name = name,Industry = Industry);
        return account;
     }
     
     // Create Contact Record
     public static  Contact createContact(ID accountID,String lastName, String email) {
        Contact contact = new Contact(LastName = lastName,Email = email,CR_Status__c = 'A - Great');
        contact.AccountId = accountID;
        return contact;
     }
     
     // Create Deposition record
     public static Deposition__c createDeposition(Id accountId) {
        
        Deposition__c deposition = new Deposition__c(Expedite__c = '9 day turnaround',Deposition_Date__c = System.today(),
                                                CR_Email_Address__c='test@gmail.com',Vidyo_Room__c='1');
        return deposition;
     }
     
     // Create Depositin Location
     public static  Deposition_Location__c createDepositionLocation(String depositionId) {
        Deposition_Location__c location =  new Deposition_Location__c(Deposition__c = depositionId);
        location.Room__c = 'Hello';
        return location;
     }
     
     //Create attendee record
     public static Attendee__c createAttendee(Id contactId,Id depositionID) {
          Attendee__c attendee = new Attendee__c(Contact__c = contactId,Deposition__c = depositionID);
          return attendee;
     }
     
     // create State Rules record for a state
     public static State_Rules__c createStateRules(String state,String rule){
         State_Rules__c stateRules = new State_Rules__c(Rule__c=rule, Name=state);
         return stateRules ;
     }
     
     // Create Rate Sheet
     public static Rate_Sheet__c createRateSheet(String name, String Type){
         return new Rate_Sheet__c(name=name,Type__c=type);
     }     
     
     // Create Item Record
     public static Item__c createItem(String name){
         return new Item__c(Name=name);
     }
     
     // Create Rate Sheet Item record
     public static Rate_Sheet_Item__c createRateSheetItem(Id rateSheetId,Id itemId, decimal price, String defaultValue){
         return new Rate_Sheet_Item__c(Item__c=itemId, Rate_Sheet__c= rateSheetId,Price__c=price,Default__c=defaultValue);
     }
     
     // Create Deposition Group record
     public static Case__c createDepositionGroup(String name){
         return new Case__c(Name=name);
     }
     
     // Create Firm record
     public static Firm__c createFirm(String name){
         return new Firm__c(Name=name);
     }
    
    public static Case_Leads__c createCaseLead(){
        return new Case_Leads__c( unicourt_case_id__c= 'HFKCQLBTIBKEMKEVPFAW7CTMNVRCC0998', Case_Name__c = 'testCase',Case_Management_Conference__c = System.Today()+1 );
    }
    
    public static Docket_Activity__c createDocketActivity(String caseId){
        return new Docket_Activity__c(Case__c= caseId, Docket_Update__c= '#1 docket update test' );
    }
    
    public static Commission__c createCommission(){
        return new Commission__c(name='testCommission', Primary_Rep__c=Userinfo.getUserId() );
    }
    
    public static representation__c createRepresentation(Id caseLeadId){
        representation__c rep = new representation__c();
        rep.Case__c = caseLeadId;
        return rep;
    }
     public static User createCommunityUser(){
        Account accountNewInsert = new Account(name ='Community Account',Industry = 'Law Firm') ;
        insert accountNewInsert;
        
        List<Contact> LewContact = new List<Contact>();                               
        Contact con1 = new Contact(LastName ='testCon',ownerId=userinfo.getuserid(),AccountId = accountNewInsert.Id,email='test1211@tgd.com');
        
        insert con1; 
        
        Contact contactNewInsert = new Contact(LastName ='testCon',ownerId=userinfo.getuserid(),AccountId = accountNewInsert.Id,email='test1211@tgd.com');
        
        insert contactNewInsert;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Customer Community Login User(Custom)'];
        
        User usr= new User(
            Alias = 'standt',
            Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8',
            LastName='Testing',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId = p.Id,
            contactId=contactNewInsert.id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standarduser@testorg.com',
            isActive = true
        );
        insert usr;
        return usr;
     }
}