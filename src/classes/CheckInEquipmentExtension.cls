public with sharing class CheckInEquipmentExtension {
  Equipment__c equipment;
  
  public CheckInEquipmentExtension(ApexPages.StandardController controller) {
    this.equipment = (Equipment__c)controller.getRecord();
  }
  
  public Boolean getHasMessages() {
    return ApexPages.hasMessages();
  }
  
  
  public PageReference clearContact() {
    try {
      this.equipment.Contact__c = null;
      this.equipment.Deposition_Location__c = null;
      this.equipment.Status__c = 'In Our Office';
      
      update this.equipment;
    }
    catch(DmlException ex) {
      ApexPages.addMessages(ex);
      return null;
    }
    return new PageReference('/' + this.equipment.Id);
  }
  
  @isTest
  private static void Test_Equipment() {
    Equipment__c equipment = new Equipment__c();
    ApexPages.StandardController sController = new ApexPages.StandardController(equipment);
    
    CheckInEquipmentExtension ext = new CheckInEquipmentExtension(sController);
    ext.clearContact();
  }

}