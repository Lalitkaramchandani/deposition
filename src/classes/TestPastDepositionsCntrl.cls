/**************************************************
                Name        : TestPastDepositionsCntrl
                Author      : Rajendra Rathore
                Purpose     : Test class for PastDepositionsCntrl Apex class
                Created Date: 12 JUNE  2016
                
                Modification History:
*****************************************************/
@isTest
public  class TestPastDepositionsCntrl{
  @isTest
  private static void Test_PastDepositionsCntrl(){
      
      Deposition__c dep = TestUtility.createDeposition(null);
      dep.Deposition_Date__c= Date.valueOf(System.now().addDays(-5));
      insert dep;
      User usr  = TestUtility.createCommunityUser();
      system.runAs(usr  ){
          Attendee__c attendee = TestUtility.createAttendee(usr.ContactId,dep.id);
          insert attendee;
          PastDepositionsCntrl  cntrl = new PastDepositionsCntrl();
          cntrl.selectedCaseNameChar = 'Other';
          cntrl.fetchDepositions();
          cntrl.selectedCaseNameChar = 'A';
          cntrl.getDepositions();
      }
     
      
  }
}