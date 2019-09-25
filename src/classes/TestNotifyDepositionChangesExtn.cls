@isTest
private class TestNotifyDepositionChangesExtn{
  
  @isTest
  private static void Test_NotifyDepositionChangesExtn (){
      TestUtils tUtils = new TestUtils();
      Deposition__c deposition = tUtils.createDeposition();
      Account account = tUtils.insertAccount();
      Contact contact = tUtils.insertContact(account.ID);
      
      NotifyDepositionChangesExtn  extn= new NotifyDepositionChangesExtn (new ApexPages.StandardController(deposition ));
      extn.sendEmailForClientConfirm();
      
      Attendee__c attendee = tUtils.insertAttendee(contact.Id, deposition.ID);
      attendee.Role__c='Scheduler';
      update attendee;
      
      ApexPages.currentPage().getParameters().put('Confirmed','true') ;
      extn= new NotifyDepositionChangesExtn (new ApexPages.StandardController(deposition ));
      extn.sendEmailForClientConfirm();
      extn.sendEmailForCancelled();
      
      
      attendee.Role__c='Court Reporter';
      update attendee;
      
      Test.startTest();
          extn= new NotifyDepositionChangesExtn (new ApexPages.StandardController(deposition ));
          extn.sendEmailForClientConfirm();
          extn.sendEmailForCancelled();
          
          attendee.Role__c='Videographer/Technician';
          update attendee;
          
          extn= new NotifyDepositionChangesExtn (new ApexPages.StandardController(deposition ));
          extn.sendEmailForClientConfirm();
          extn.sendEmailForCancelled();
          
          attendee.Role__c='Attorney';
          update attendee;
          
          extn= new NotifyDepositionChangesExtn (new ApexPages.StandardController(deposition ));
          extn.sendEmailForClientConfirm();
          extn.sendEmailForCancelled();
      
      Test.stopTest();
  }
}