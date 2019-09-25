global without sharing class UploadFilesController {

    public Upload_Files__c uploadFiles{get;set;}
    public Boolean isSuccess {get;set;}
    Private String selectedBucket = '';
    Private String bucketToUploadObject = '';
    //Boolean isUploadPage = false;
    Boolean isUploadPageWithoutTemplate = false;
    public Integer selectedFileIndex{get;set;}
    public List<AWS_S3_Object__c>lstAWSS3Objects{get;set;}
    Set<String>setAlreadyLoadedAWSObjectIds = new Set<String>();
    public Firm__c firm{get;set;}
    public Boolean isPortalForCourtReporterAndVideographer{get;set;}
    String firmName = '';
    public String selectedFileType{get;set;}
    public UploadFilesController(){
       Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=edge');
       firmName = ApexPages.currentPage().getParameters().get('firm');
       if(!String.isBlank(ApexPages.currentPage().getParameters().get('id'))) {
           List<Deposition__c> lstDeposition = [SELECT Id,Firm_Name__c FROM Deposition__c WHERE Name =:ApexPages.currentPage().getParameters().get('id')];
           if( lstDeposition.size()>0 && lstDeposition[0].Firm_Name__c != NULL && lstDeposition[0].Firm_Name__c != '') {
              firmName = lstDeposition[0].Firm_Name__c;
           }
       }
  
       loadFirm();  
    }
    

    public void loadFirm(){
       //firmName = ApexPages.currentPage().getParameters().get('firm');
       if(firmName == NULL || firmName.trim().length()==0)
           firmName  = 'NextGen Reporting' ;
       firm = DepositionHelper.fetchFirm(firmName );
       system.debug('$$'+firm);
    }
    public PageReference  initForUploadPageWithoutTemplate(){
        
        isUploadPageWithoutTemplate = true;
        return initForUploadPage();
    }
    
    public void dragDropUploadInit(){
        //loadFirm();
         
        isPortalForCourtReporterAndVideographer = false;
        String strPortalForCourtReporterAndVideographer = ApexPages.currentPage().getParameters().get('isPortalForCourtReporterAndVideographer');
        if(strPortalForCourtReporterAndVideographer != NULL && strPortalForCourtReporterAndVideographer  == 'true'){
            isPortalForCourtReporterAndVideographer = true;
            firmName = ApexPages.currentPage().getParameters().get('firm');
            loadFirm();
        }
        Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=edge');
        uploadFiles = [select id,Name,Contact__c,Contact__r.Name, Contact_Name__c,Deposition__c,Deposition_Number__c,Email__c,IP_Address__c,Notes__c,Phone_Number__c
                      ,Deposition__r.Event_Type_Lowercase__c,Deposition__r.Firm_Name__c
                      From Upload_Files__c WHERE Id=:ApexPages.currentPage().getParameters().get('id').trim()];
        //uploadBatchId = ApexPages.currentPage().getParameters().get('uploadBatchId').trim();
        lstAWSS3Objects = new List<AWS_S3_Object__c>();
        setAlreadyLoadedAWSObjectIds = new Set<String>();
        
    }
    public PageReference initForUploadPage(){
        //isUploadPage  =true;
        return init();
    }
    public PageReference init(){
          
          
          this.uploadFiles = new Upload_Files__c(IP_Address__c=ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP'));
          
          isSuccess = false;
          
          if(!String.isBlank(ApexPages.currentPage().getParameters().get('id'))) {
            this.uploadFiles.Deposition_Number__c = ApexPages.currentPage().getParameters().get('id').trim();
          }
          if(!String.isBlank(ApexPages.currentPage().getParameters().get('email'))) {
            this.uploadFiles.Email__c = ApexPages.currentPage().getParameters().get('email').trim();
          }
          return null;
    }
   
    
     
    
    
    public Deposition__c fetchDespositonNumber(){
      List<Deposition__c> lstDeposition = [SELECT Id,Event_Type_Lowercase__c FROM Deposition__c WHERE Name =:uploadFiles.Deposition_Number__c];
      if( lstDeposition.size() == 0) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Fatal,'Deposition Number is invalid.Please check and retry'));
        return null;
      }
      
      /**List<Attendee__c> lstAttendee = [SELECT Id,Email__c,Role__c FROM Attendee__c WHERE Deposition__c = :lstDeposition[0].Id
                                       AND Email__c = :this.uploadFiles.Email__c];
      
      if(isUploadPage == false && lstAttendee.size() == 0) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Fatal,'The email address you provided does not match anyone that we have on this ' + lstDeposition[0].Event_Type_Lowercase__c+ '. Feel free to use our main upload page http://nextgenreporting.com/upload/.'));
        return null;
      }*/
      
      
      if(lstDeposition.size() == 0) {
        return null;
      }
      return lstDeposition[0];                                
    }
    public Contact fetchContact(){
     
     
      List<Contact> lstContacts = [SELECT Id,AccountId,Account.Industry FROM Contact 
      WHERE Email = :this.uploadFiles.Email__c AND Email != NULL];
      
      if(lstContacts.size() == 0) {
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Fatal,'You are not authorized to upload files to the deposition because we don\'t find any contact with that email adress!!!'));
        return null;
      }
      return lstContacts[0];                                
    }
    
  public PageReference SaveFiles(){
    isSuccess = false;
    
    Boolean isErr = false;
    /*if(isUploadPage == false && String.isBlank(this.uploadFiles.Email__c)){
       ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Fatal,'Please enter your email'));
       return null;
    }*/
    
    Deposition__c deposition = uploadFiles.Deposition_Number__c != NULL && uploadFiles.Deposition_Number__c.trim().length()>0 ? fetchDespositonNumber() : null;
    
    if(deposition  == null && uploadFiles.Deposition_Number__c != NULL && uploadFiles.Deposition_Number__c.trim().length()>0){
        return null;
    }
    Contact cont = fetchContact();
    
    Savepoint sp = Database.setSavepoint();
    try {
        
        String  depositionNumber = '';
        if(uploadFiles.Deposition_Number__c == null || uploadFiles.Deposition_Number__c.trim().length()==0){
            depositionNumber = firm.Google_Drive_Folder_Name__c;
        }else{
            depositionNumber = uploadFiles.Deposition_Number__c;
        }

        bucketToUploadObject = depositionNumber;
        
        if(deposition != NULL)
            uploadFiles.Deposition__c = deposition.Id;
            
        if(cont  != NULL ){
            uploadFiles.Contact__c= cont.Id;
        }
        
        
        upsert uploadFiles;
        Pagereference Pg ;
        if(isUploadPageWithoutTemplate ==false)
            Pg = Page.DragDropUpload;
        else
            Pg = Page.DragDropUploadWithoutTemplate;
        Pg.getParameters().put('id',uploadFiles.id);
        Pg.getParameters().put('folderName',bucketToUploadObject);
        pg.getParameters().put('firm',firmName);
        //Pg.getParameters().put('firm',firmName);
        //return null;
        return pg;

    }
    catch(exception ex){
       Database.rollback(sp);  
       ApexPages.addMessages(ex);
    }
    return null;
  }
  
  
  
  
  private Boolean sendEmail(Upload_Files__c uploadFiles, Contact con,Boolean isInvoceFileAttached,Boolean isVideoFileAttached ){
      /** An email will be sent to schedule@nextgenreporting.com and the email address provided by the uploader with the following info:
        a.  Email address
        b.  Job number (If there is no job number provided, note that as well.)
        c.  Notes
        d.  File name(s) and sizes of any files
        e.  Date/time of upload
      */
      
      List<EmailTemplate>lstEmailTemplate = [select id From EmailTemplate WHERE DeveloperName='Upload_Files_Notification' ];
       List<OrgwideEmailAddress>lstOrgwideaddress = [select id,displayname,Address from orgwideEmailAddress 
                                                    WHERE displayName='NextGen Production']; 
      if(lstEmailTemplate.size()>0){
          List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
          Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
          
          List<String>additionalList = new List<String>();
          //mail.setToAddresses(additionalList);
          
          if(uploadFiles.Contact__c != null){
              mail.setTemplateId(lstEmailTemplate[0].id);
              mail.setTargetObjectId(uploadFiles.Contact__c);
              mail.setWhatId(uploadFiles.id);  
          }else{
              Messaging.SingleEmailMessage mailForHtmlBody = getHtmlBodyFromEmail(lstEmailTemplate[0].id,uploadFiles.id);
              String mailHtmlBody = mailForHtmlBody.getHTMLBody();
              String mailSubject = mailForHtmlBody.getSubject();
              mail.setHtmlBody(mailHtmlBody );
              mail.setSubject(mailSubject );
              if(uploadFiles.Email__c != NULL && uploadFiles.Email__c.trim().length()>0)
                  additionalList.add(uploadFiles.Email__c);
          }
          if(lstOrgwideaddress.size()>0)
              mail.setOrgWideEmailAddressId(lstOrgwideaddress[0].id);
          Upload_Email_Notification__c  setting = Upload_Email_Notification__c.getOrgDefaults();
          /*if(setting != NULL){
              if(setting.Email_For_All_File_Type__c != NULL)
                  additionalList.add(setting.Email_For_All_File_Type__c);
              
              
              /**If an upload is received from someone whose Account:Industry type is Court Reporting, 
                 and any of the files are marked as an invoice, send an email to accounting@nextgenreporting.com
                  with all of the information they provided on the page as well as a link to download the file from Salesforce.
              */    
              /**if(isInvoceFileAttached && setting.Email_For_Invoice__c != NULL){
                  additionalList.add(setting.Email_For_Invoice__c );
              }
              /** any time an upload is tagged as a video, please email it to
                 video@nextgenreporting.com
              */
              /**if(isVideoFileAttached && setting.Email_For_Video__c!= NULL){
                  additionalList.add(setting.Email_For_Video__c);  
              }*//*
                  
          }*/
          if(additionalList.size()>0)
             mail.setToAddresses(additionalList);
          
          mailList.add(mail);
          Messaging.sendEmail(mailList);
      }
      
      return true;
  }
  
  private Messaging.SingleEmailMessage getHtmlBodyFromEmail(Id templateId,String whatId){
      Savepoint sp = Database.setSavepoint();
      
      List<Contact>lstDummyContact = [select id From Contact WHERE Email='jprimuth@nextgenreporting.com' AND Email != NULL];
      Contact cont  = new Contact();
      if(lstDummyContact.size()>0){
          cont = lstDummyContact[0];
      }else{
          cont.LastName ='Do Not Delete';
          cont.Email = 'jprimuth@nextgenreporting.com';
          insert cont;
      }
      
      
      Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
      mail.setTemplateId(templateId);
      mail.setWhatId(whatId);   
      mail.setTargetObjectId(cont.id);        
      Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
      Database.rollback(sp);
      return mail;
  }
  
  @RemoteAction
  global static String fetchFileNameWithVersionRemote(String fileName,String folderName ) {
        List<AWS_S3_Object__c>lstExistingAWSS3Objects = [select id,File_Name__c,Version_Number__c 
                                                        From AWS_S3_Object__c WHERE
                                                        Folder_Path__c =:  folderName +'/' AND File_Name__c = :fileName
                                                        AND Version_Number__c != NULL
                                                        Order by Version_Number__c DESC LIMIT 1];
        Integer versionCounter = 0;
        if(lstExistingAWSS3Objects.size()>0){
            versionCounter  = Integer.valueOf(lstExistingAWSS3Objects[0].Version_Number__c);
            versionCounter++;
        }    
        List<String>splittedFileName = fileName.split('\\.');
        String fileNameForAWS = '';
        if(versionCounter > 0){
            fileNameForAWS = splittedFileName[0]+'V'+versionCounter  + '.'+ splittedFileName[1];
        }else{
            fileNameForAWS = fileName;
        }
        return fileNameForAWS ;
  }
  
  @RemoteAction
  global static String createAwsS3Object2() {
        return 'true';
        
  }
  
  @RemoteAction
  global static String createAwsS3Object(String fileName,String folderName,String fileId, String uploadBatchId,String depostionId,String contentType,
                                          Integer fileSize,Integer uploadNumber ) {
        try{
            
            AWS_S3_Object__c AWS3Obj = new AWS_S3_Object__c(File_Name__c=fileName,Folder_Path__c= folderName+'/', File_Id__c=fileId );
            AWS3Obj.Upload_Files__c = uploadBatchId;
            AWS3Obj.Content_Type__c= contentType;
            AWS3Obj.File_Size__c  = fileSize ;
            AWS3Obj.Upload_No__c = uploadNumber ;
             if(depostionId != NULL && depostionId.trim().length()>0)
                AWS3Obj.Deposition__c  = depostionId;
            AWS3Obj.Access__c = 'Private'; 
            insert AWS3Obj;
            return AWS3Obj.id;
        }catch(Exception ex){
            return ex.getMessage();
           
        }
        
  }
  @RemoteAction
  global static String createAwsS3ObjectAmazon(String fileName,String folderName,String bucketName, String uploadBatchId,String depostionId,String contentType,
                                          Integer fileSize,Integer uploadNumber ) {
        try{
            
            AWS_S3_Object__c AWS3Obj = new AWS_S3_Object__c(File_Name__c=fileName,Folder_Path__c= folderName+'/');
            AWS3Obj.Upload_Files__c = uploadBatchId;
            AWS3Obj.Content_Type__c= contentType;
            AWS3Obj.File_Size__c  = fileSize ;
            AWS3Obj.Upload_No__c = uploadNumber ;
            AWS3Obj.Bucket_Name__c = bucketName ;
            if(depostionId != NULL && depostionId.trim().length()>0)
                AWS3Obj.Deposition__c  = depostionId;
            AWS3Obj.Access__c = 'Private'; 
            insert AWS3Obj;
            return AWS3Obj.id;
        }catch(Exception ex){
            return ex.getMessage();
           
        }
        
  }
  public void fetchAWSS3Objects(){
      
      for(AWS_S3_Object__c s3Obj : [select id,File_Name__c,File_Type__c From AWS_S3_Object__c
                                    WHERE Upload_Files__c =:uploadFiles.id AND ID not in : setAlreadyLoadedAWSObjectIds]){
          lstAWSS3Objects.add(s3Obj);
          setAlreadyLoadedAWSObjectIds.add(s3Obj.id);
      }
  }
  
  
  public void updateFileType(){
      try{
          AWS_S3_Object__c fileObj = lstAWSS3Objects[selectedFileIndex];
          fileObj.File_Type__c = selectedFileType;
          update fileObj;
       }catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getMessage()));
      }
  }
  public PageReference saveAndSendEmail(){
      Savepoint sp = Database.setSavepoint();
      try{
          List<Contact>lstContacts = [select id,Account.Industry  From Contact WHERE Id =: uploadFiles.Contact__c];
          List<Deposition__c> lstDeposition = [SELECT Id,Event_Type_Lowercase__c,Transcript_Status__c FROM Deposition__c WHERE Name =:uploadFiles.Deposition_Number__c];
          List<Attendee__c> lstAttendee = new List<Attendee__c>();
          if(lstDeposition.size()>0){
              if(isPortalForCourtReporterAndVideographer ==false ){
                  lstAttendee  = [SELECT Id,Email__c,Role__c,Contact__r.Account.Industry FROM Attendee__c WHERE Deposition__c = :uploadFiles.Deposition__c
                                       AND Email__c = :this.uploadFiles.Email__c LIMIT 1];
              }else{
                  lstAttendee  = [SELECT Id,Email__c,Role__c,Contact__r.Account.Industry FROM Attendee__c WHERE Deposition__c = :uploadFiles.Deposition__c
                                       AND contact__c = :this.uploadFiles.Contact__c LIMIT 1];
              }
          } 
          boolean isInvoceFileAttached  = false;
          Boolean isVideoFileAttached  = false;
          Boolean isTranscriptFileAttached = false;
          Boolean isVideoAttached = false;
          for(AWS_S3_Object__c  AWSS3Obj :  lstAWSS3Objects){
    
                if(AWSS3Obj.File_Type__c == NULL)
                    AWSS3Obj.File_Type__c = ''; 
                if( AWSS3Obj.File_Type__c == 'Video'){
                    isVideoFileAttached  = true;  
                    isVideoAttached = true;
                }
                
                if( AWSS3Obj.File_Type__c == 'Transcript')
                    isTranscriptFileAttached  = true;
                if(lstContacts.size()>0  && lstContacts[0].Account.Industry == 'Court Reporting'  ){
                    
                    
                    if( AWSS3Obj.File_Type__c == 'Invoice')
                        isInvoceFileAttached = true;
                      
                    
                    if(lstDeposition.size()>0){
                        /**  If an upload is received from someone whose Account:Industry type is Court Reporting, 
                            and any of the files are marked as a transcript, change the Transcript status field to “In Process.” 
                        
                        if( AWSS3Obj.File_Type__c == 'Transcript'){
                            lstDeposition[0].Transcript_Status__c = 'In production';
                        }*/
                        
                        /**  If an upload is received from someone whose Account:Industry type is Court Reporting,
                            and any of the files are marked as an exhibit, change the Exhibit status field to “In Process.”
                        */
                        if(AWSS3Obj.File_Type__c == 'Exhibit'){
                            lstDeposition[0].Exhibit_Status__c = 'In Process';
                        }
                        
                        
                   }
                }
                
            }
            if(lstAWSS3Objects.size()>0 ){
                //update lstAWSS3Objects;
                if(lstDeposition.size()>0){
                    if(isVideoAttached ){
                        lstDeposition[0].Video_Status__c= 'In Production';
                    }
                    if(isTranscriptFileAttached ){
                        lstDeposition[0].Transcript_Status__c= 'In Production';
                    }
                    if(lstAttendee.size()>0 ){
                       
                       
                        
                        if(isInvoceFileAttached){
                            /** When an invoice is uploaded by an attendee whose role is Videographer/Technician, 
                               check the new deposition checkbox named " Invoice Status – Video".
                            */
                            if(lstAttendee[0].Role__c == 'Videographer/Technician')
                                lstDeposition[0].Invoice_Status_Video__c = true;
                            
                            /**
                               When an invoice is uploaded by an attendee whose role is Court Reporter,checked
                               the new deposition checkbox named "Invoice Status – Reporter"
                            */
                            if( lstAttendee[0].Role__c == 'Court Reporter')
                                lstDeposition[0].Invoice_Status_Reporter__c= true;
                        }
                    }
                    update lstDeposition;
                }
                if(lstContacts.size() == 0)
                    lstContacts.add(new Contact());
                    
                if(isInvoceFileAttached && this.uploadFiles.Email__c != NULL && uploadFiles.Deposition__c != NULL ){
                     
                     if(lstAttendee.size()>0){
                         lstAttendee[0].Invoice_Status__c = 'Received';
                         update lstAttendee[0];
                     }
                }
                if(isPortalForCourtReporterAndVideographer == false){
                 sendEmail(uploadFiles,lstContacts[0],isInvoceFileAttached,isVideoFileAttached ); 
                }
                if(uploadFiles.Contact__c != NULL){
                    //createTaskForContact(uploadFiles.Contact__c ,uploadFiles.Deposition__c,'File Uploaded','Upload');
                    if(isPortalForCourtReporterAndVideographer == false)
                        createTaskForContact(uploadFiles.Contact__c ,uploadFiles.Deposition__c,'File Uploaded','Upload');
                    else
                        createTaskForContact(uploadFiles.Contact__c ,uploadFiles.Deposition__c,'Deposition information updated by '+ uploadFiles.Contact_Name__c,'Upload'); 
                    
                }
                Pagereference Pg ;
                if(isPortalForCourtReporterAndVideographer == false){
                    if(isUploadPageWithoutTemplate )
                        Pg = Page.UploadFilesWithoutTemplateThanks;
                    else
                        Pg = Page.UploadFilesThanks;
                    Pg.getParameters().put('id',uploadFiles.id);
                }else{
                    Pg = Page.PortalReportersAndvideographersThanks;
                }
                pg.getParameters().put('firm',firmName);
                return pg;
            }
            return null;
      }catch(Exception ex){
            Database.rollback(sp);  
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getMessage()));
            return null;
      }
        
  }
  
  private void createTaskForContact(String whoId,String whatId,String subject,string type){
      Task tsk = new Task();
      tsk.Subject = subject;
      tsk.WhoId = whoId;
      tsk.Status =  'Completed';
      tsk.Type = type;
      tsk.WhatId = whatId;
      tsk.ActivityDate = System.today();
      insert tsk;
  }
  
  @RemoteAction
  global static String getAccessToken() {
       GoogleDriveAuthenticationCntrl cntrl = new GoogleDriveAuthenticationCntrl();
       return cntrl.getAccessCode();
  }
}