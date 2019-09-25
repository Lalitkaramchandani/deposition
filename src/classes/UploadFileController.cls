public without sharing class UploadFileController {
    
    public Upload_File__c uploadFile {get;set;}
    private Transient Document pvt_document;
    public Boolean isSuccess {get;set;}
    
    public Document getUploadDocument() {
      if(pvt_document== null) {
        this.pvt_document= new Document();
      }
      return pvt_document;
    
    }
    
    public UploadFileController(){
      this.uploadFile = new Upload_File__c();
      this.pvt_document = new Document();
      isSuccess = false;
      
      if(!String.isBlank(ApexPages.currentPage().getParameters().get('id'))) {
      	this.uploadFile.Deposition_Number__c = ApexPages.currentPage().getParameters().get('id').trim();
      }
      if(!String.isBlank(ApexPages.currentPage().getParameters().get('email'))) {
        this.uploadFile.Email__c = ApexPages.currentPage().getParameters().get('email').trim();
      }
    }
    
    public void validateFile(){
      if(String.isBlank(this.uploadFile.Deposition_Number__c)){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Fatal,'Please enter a deposition Number'));
      }
      if(String.isBlank(this.uploadFile.Email__c)){
       ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Fatal,'Please enter your email'));
      }
     if(this.getUploadDocument().Body == null) {
       ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Fatal,'Please select a file'));
     }
    }
    
    public Deposition__c validateNumber(){
    	System.debug('****Upload File=>****' + uploadFile.Deposition_Number__c);
       List<Deposition__c> lstDeposition = [SELECT Id FROM Deposition__c WHERE Name =:uploadFile.Deposition_Number__c];
      if(lstDeposition.size() == 0) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Fatal,'Deposition Number is invalid.Please check and retry'));
        return null;
      }
      
      List<Attendee__c> lstAttendee = [SELECT Id,Email__c FROM Attendee__c WHERE Deposition__c = :lstDeposition[0].Id
                                       AND Email__c = :this.uploadFile.Email__c];
      if(lstAttendee.size() == 0) {
      	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Fatal,'You are not authorized to upload files to the deposition'));
        return null;
      } 
      return lstDeposition[0];                                
    }
    
  public PageReference SaveFile(){
  	isSuccess = false;
  	
    validateFile();
    if(ApexPages.hasMessages()) return null;
    Deposition__c deposition = validateNumber();
    if(ApexPages.hasMessages()) return null;
    
    try {
        
        Attachment attachment = new Attachment(Name = getUploadDocument().Name,ParentId = deposition.ID);
        attachment.Body = getUploadDocument().Body;
        attachment.Description = 'Uploaded By ' + this.uploadFile.Email__c + ' at ' + System.now();
        insert attachment;
        
        uploadFile.Deposition__c = deposition.Id;
        uploadFile.File_Name__c = attachment.Name;
        uploadFile.Attachment_ID__c = attachment.Id;
        
        upsert uploadFile;
        uploadFile = new Upload_File__c();
        //document = new Document();
        isSuccess = true;
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'File has been uploaded'));
    }
    catch(DmlException ex){
      ApexPages.addMessages(ex);
    }
    return null;
  }
}