/*****************************************************************
*Created on : July 23rd, 2012
*Purpose : Compute rollup summary for contact records that are passed in
******************************************************************/
public class ContactRollUp {
  
  private static Set<ID> setDepositionContact = new Set<ID>();
  
  public static void setRelatedContacts(List<Deposition__c> lstDeposition) {
    ContactRollup contactRollup = new ContactRollup();
    setDepositionContact = contactRollup.getContactRelatedToDeposition(lstDeposition);
  }
  
  public static void computeSummaryForDeletedDeposition() {
  	 ContactRollup contactRollup = new ContactRollup();
  	 contactRollup.computeCountAndMaxDate(setDepositionContact);
  }
  
  
  /*********************************************************************************************************/
  public Set<Id> getContactRelatedToDeposition(List<Deposition__c> lstDeposition) {
  	Set<ID> setContact = new Set<Id>();
    for(Attendee__c attendee : [SELECT Contact__c FROM Attendee__c 
                               WHERE Deposition__c IN :lstDeposition AND Contact__c != null]) {
      setContact.add(attendee.Contact__c);
    } 
    return setContact;
  }
  
  //================================================================================//
  //Find the related records for deposition and do computation
  //================================================================================//
  public void computeSummaryForDeposition(List<Deposition__c> lstDeposition) {
    Set<ID> setContact = getContactRelatedToDeposition(lstDeposition);
    computeCountAndMaxDate(setContact); 
  }
  
  //=====================================================================//
  //compute roll up summary for count and Deposition Date
  //=====================================================================//
  public void computeCountAndMaxDate(Set<ID> setContactID) {
  	List<Contact> lstContact = new List<Contact>();
  	
    for(AggregateResult result : [SELECT Contact__c contactID,Max(Deposition_Date__c) maxDate,
                                  Count(Name) contactCount
                                  FROM Attendee__c WHERE Contact__c IN :setContactID
                                  GROUP BY Contact__c]) {
      
      Id contactID = Id.valueOf(String.valueOf(result.get('contactID'))) ; 
      Contact contact = new Contact(Id = contactID);
      contact.Attendee_Count__c = Integer.valueOf(result.get('contactCount'));
      contact.Recent_Attendee_Date__c = Date.valueOf(result.get('maxDate'));
      
      lstContact.add(contact);
    } 
    update lstContact;
  }
  
  //=======================================================================//
  //Test the roll up method
  //=======================================================================//
  @isTest
  private static void Test_computeCountAndMaxDate() {
    TestUtils util = new TestUtils();
    Account account = util.insertAccount();
    Contact contact = util.insertContact(account.ID);
    Deposition__c deposition = util.insertDeposition(account.ID);
    Attendee__c attendee = util.insertAttendee(contact.Id, deposition.ID);
    
    ContactRollup rollup = new ContactRollup();
    Set<ID> setContactId = new Set<Id>{contact.Id};
    rollup.computeCountAndMaxDate(setContactID); 
    
    contact = [SELECT Attendee_Count__c,Recent_Attendee_Date__c FROM Contact WHERE Id = :contact.ID];
    System.assertNotEquals(contact.Attendee_Count__c,0);
    
    attendee.Contact__c = null;
    update attendee;
    delete attendee;
    undelete attendee;
    
    deposition.Deposition_Date__c = System.today().addDays(1);
    update deposition;
    
    delete deposition;
    undelete deposition;
  }
}