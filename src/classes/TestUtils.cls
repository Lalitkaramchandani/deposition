/*****************************************************************
*Created on : July 23rd, 2012
*Purpose : A testing utils class to generate records for testing 
******************************************************************/
public class TestUtils {
  
  public Contact insertContact(ID accountID) {
    Contact contact = new Contact(LastName = 'AAAAAA',Email = 'a@a.com',CR_Status__c = 'A - Great');
    contact.AccountId = accountId;
    insert contact;
    
    return contact;
  }
  
  public Account insertAccount() {
    Account account = new Account(Name = 'AAAAA',Industry = 'Court Reporting');
    insert account;
    
    return account;
  }
  
  public Deposition__c createDeposition() {
    Account account = insertAccount();
    Deposition__c deposition = insertDeposition(account.Id);
    
    return deposition;
  }
  
  public Deposition__c insertDeposition(Id accountId) {
    List<Deposition__c>lstDeposition = new List<Deposition__c >();
    List<Deposition__c>lstDeleteDepostions = [select id from Deposition__c];
    if(lstDeleteDepostions.size()>0)
        delete lstDeleteDepostions ;
    Deposition__c deposition = new Deposition__c(Expedite__c = '9 day turnaround',Deposition_Date__c = System.today(),
                                                 CR_Email_Address__c='test@gmail.com',Vidyo_Room__c='1');
    lstDeposition.add(deposition);
    
    Deposition__c deposition1 = new Deposition__c(Expedite__c = '9 day turnaround',Deposition_Date__c = Date.today().addDays(-1),
                                               CR_Email_Address__c='test2@gmail.com',Vidyo_Room__c='2');
    lstDeposition.add(deposition1 );
    insert lstDeposition;
    
    return deposition;
  }
  public Static Deposition__c insertDepositionWithDepostionGroup(Id accountId,Id caseId,Integer vidyoRoom) {
    List<Deposition__c>lstDeposition = new List<Deposition__c >();
    Deposition__c deposition = new Deposition__c(Deposition_Group__c=caseId,Expedite__c = '9 day turnaround',Deposition_Date__c = System.today(),
                                                CR_Email_Address__c='test@gmail.com',Vidyo_Room__c=vidyoRoom+'');
    Deposition__c deposition1 = new Deposition__c(Deposition_Group__c=caseId,Expedite__c = '9 day turnaround',Deposition_Date__c = System.today(),
                                                 CR_Email_Address__c='test@gmail.com',Vidyo_Room__c=vidyoRoom+1+'');
    lstDeposition.add(deposition);
    lstDeposition.add(deposition1);
    insert lstDeposition;
    
    return deposition;
  }
  
  public Deposition_Location__c createDepositionLocation(Deposition__c deposition) {
    Deposition_Location__c location =  new Deposition_Location__c(Deposition__c = deposition.Id);
    location.Room__c = 'Hello';
    
    insert location;
    
    return location;
  }
  
  public Attendee__c insertAttendee(Id contactId,Id depositionID) {
    Attendee__c attendee = new Attendee__c(Contact__c = contactId,Deposition__c = depositionID);
    insert attendee;
    
    Attendee__c attendee1 = new Attendee__c(Contact__c = contactId,Deposition__c = depositionID);
    insert attendee1;
    
    return attendee;
  }
  
  public Static Signature__c createSignature(){
      Signature__c signature = new Signature__c(Name='Test Signature',Active__c=true);
      return signature;
  }
}