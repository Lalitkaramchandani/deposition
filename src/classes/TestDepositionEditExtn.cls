@isTest
private class TestDepositionEditExtn{
  
  @isTest
  private static void Test_DepositionEditExtn(){
    
      TestUtils tUtils = new TestUtils();
      Deposition__c deposition = tUtils.createDeposition();
        
      DepositionEditExtn extn= new DepositionEditExtn(new ApexPages.StandardController(deposition ));
      extn.deposition.Deposition_Date__c = System.today().addDays(1);
      extn.deposition.Deposition_Time__c = extn.deposition.Case_Name__c = extn.deposition.Time_Zone__c = extn.deposition.Event_Location__c= 'test';
      extn.deposition.Event_Type__c =extn.deposition.Estimated_Duration__c =extn.deposition.Matter_Number__c =extn.deposition.Deponent_Name__c  ='Deposition';
      extn.deposition.Deponent_Name__c =extn.deposition.Hiring_Attorney__c =extn.deposition.Insurance_Claim_Info__c =extn.deposition.Claims_Professional__c = 'Test Name';
      extn.deposition.Client_Notes__c  = 'test note';
      extn.deposition.Expedite__c = 'Same day turnaround';
      extn.deposition.Deposition_Services__c = 'Expedite'; 
      extn.deposition.Deposition_Status__c ='In Production';
      extn.saveDeposition();
      
  }
}