/**************************************************
                Name        : GoogleDriveAuthenticationCntrl
                Author      : Rajendra Rathore
                Purpose     : That class is used for Google Drive authentication and get Files information from Google Drive
                Created Date: 25 March 2016
                
                Modification History:
*****************************************************/
global class GoogleDriveAuthenticationCntrl {
    public List<S3FileModel>lstFiles{get;set;}
    public String folderId{get;set;}
    public Integer selectedDepFileIndex{get;set;}
    String depId = '';
    ApexPages.StandardController controller ;
    String searchText='';
    public User usr{get;set;}
    
    public List<Deposition__c>lstDepositions{get;set;}
    public GoogleDriveAuthenticationCntrl() {
        this.controller  = new ApexPages.StandardController( new Deposition__c());
        folderId = '';
        init();
    }
    

    public GoogleDriveAuthenticationCntrl(ApexPages.StandardController controller) {
        this.controller  = controller ;
        init();
    }
    
    private void init(){
        usr = [select id,ContactId,Contact.Account.COD_Warning__c From User WHERE ID =:Userinfo.getUserId()];
        lstFiles = new List<S3FileModel>();
        if(ApexPages.currentPage()!=NULL){
            searchText = String.valueOf(ApexPages.currentPage().getParameters().get('searchText'));
            system.debug('$$$'+ApexPages.currentPage().getURL());
            if(searchText!=NULL && searchText.trim().length()>0)
                searchText = searchText.replaceAll(' ','%20');
        }
    }
    public void loadFilesInDataTable(){
        try{
            lstFiles = new List<S3FileModel>();
            
            GrantingFileAccessToUsersExtn  extn = new GrantingFileAccessToUsersExtn(controller );
            extn.folderId = folderId ;
            extn.searchText= searchText;
            if(folderId!=NULL && folderId!='')
                extn.init();
            else
                extn.callInitFullTextSearch();
            Set<String>setFileIds = new Set<String>();
            for(S3FileModel s3File : extn.lstFiles){
                if(s3File.awsS3Obj.Id == NULL){
                    s3File.isSelected=true;
                }
                setFileIds.add(s3File.awsS3Obj.File_Id__c);    
            }
            if(usr.ContactId == NULL )
                lstFiles = extn.lstFiles ;
            else if(setFileIds.size()>0){
                Set<String>setHaveAccessFileIds= new Set<String>();
                for(File_Access__c fileAccess : [select File__r.File_Id__c From File_Access__c 
                                                 WHERE File__r.File_Id__c IN: setFileIds
                                                 AND Attendee__r.Contact__c =:usr.ContactId]){
                    setHaveAccessFileIds.add(fileAccess.File__r.File_Id__c);
                } 
                  
                for(S3FileModel s3File : extn.lstFiles){
                    if(s3File.awsS3Obj.CreatedById == Userinfo.getUserId() || setHaveAccessFileIds.contains(s3File.awsS3Obj.File_Id__c))
                        lstFiles.add(s3File); 
                }                                
            }
            if(folderId!=NULL && folderId!='')
                extn.saveFiles();
            //lstFiles = extn.lstFiles ;
        }catch(Exception e){
            ApexPages.addMessage(new  ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage())); 
        }
        if(controller.getId() == NULL || controller.getId()!='')
            searchDepositions();
    }
    
    public void updateDepFileType(){
      try{
          AWS_S3_Object__c fileObj = lstFiles[selectedDepFileIndex].awsS3Obj;
          update fileObj;
       }catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getMessage()));
      }
    }
    public  void saveFiles(){
        try{
            
            List<AWS_S3_Object__c>lstFilesNeedUpdate = new List<AWS_S3_Object__c>();
            for(S3FileModel fileModel : lstFiles){
                lstFilesNeedUpdate.add(fileModel.awsS3Obj);
                system.debug(fileModel.awsS3Obj.File_Type__c);
            }
            if(lstFilesNeedUpdate.size()>0){
                update  lstFilesNeedUpdate;
                ApexPages.addMessage(new  ApexPages.Message(ApexPages.Severity.CONFIRM,'File Information Successfully Saved.'));
            }
             
        }catch(Exception e){
            ApexPages.addMessage(new  ApexPages.Message(ApexPages.Severity.Error,e.getMessage())); 
        }
        
    }
    private string key = Google_Drive_Configuration__c.getInstance().Client_Id__c;
    private string secret = Google_Drive_Configuration__c.getInstance().Client_Secret__c;
    private string refreshToken= Google_Drive_Configuration__c.getInstance().Refresh_Token__c;
    public String getAccessCode() {
       //Getting access token from google
        
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint('https://accounts.google.com/o/oauth2/token');
        req.setHeader('content-type', 'application/x-www-form-urlencoded');
        String messageBody = 'grant_type=refresh_token&refresh_token='+refreshToken+'&client_id='+key+'&client_secret='+secret;
        req.setHeader('Content-length', String.valueOf(messageBody.length()));
        req.setBody(messageBody);
        req.setTimeout(60*1000);

        Http h = new Http();
        String resp;
        HttpResponse res = h.send(req);
        resp = res.getBody();
        AccessToken token = new AccessToken();
        token = AccessToken.parse(resp);
        System.debug(' You can parse the response to get the access token ::: ' + resp);
        return token.access_token;
    }
    @RemoteAction
    global static String getAccessToken() {
           
           GoogleDriveAuthenticationCntrl cntrl = new GoogleDriveAuthenticationCntrl();
           return cntrl.getAccessCode();
    }
    @RemoteAction
    global static Boolean  haveAccessToFile(String fileId, String fileType, String depositionId) {
        User usr = [select ContactId From User WHERE ID=:UserInfo.getUserId()];
        List<File_Access__c>lstFileAccesses = [select id From File_Access__c WHERE Attendee__r.Contact__c=:usr.ContactId AND 
        File__c=:fileId];
        if(lstFileAccesses.size()>0 )
            return true;
        else if(fileType == 'Deposition Notice'){
            List<Attendee__c>lstAttendees = [select id FROM Attendee__c where Contact__c=:usr.ContactId AND Deposition__c=:depositionId
                                             AND Role__c IN('Court Reporter','Interpreter','Videographer/Technician')];
            if(lstAttendees.size()>0)
                return true;
        }
        return false;
    }
    @RemoteAction
    global static String  getFileInfo(String fileURL,String authorizationHeaderValue) {
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint(fileURL);
        req.setHeader('Authorization', authorizationHeaderValue);
        req.setHeader('content-type', 'application/json');
        
        
        req.setTimeout(60*1000);
        
        Http h = new Http();
        String resp;
        HttpResponse res = new HttpResponse();
        
            res = h.send(req);
        resp = res.getBody();
        system.debug('$$'+resp);
        return GogoleDriveFolderParser.parse(resp).downloadUrl;
    }
    public void searchDepositions(){
        lstDepositions = new List<Deposition__c>();
        String depSearchText = String.valueOf(ApexPages.currentPage().getParameters().get('searchText'))+'*';
        List<List<SObject>> searchList = [FIND :depSearchText IN ALL FIELDS RETURNING Deposition__c];
        Deposition__c [] Depositions= ((List<Deposition__c>)searchList[0]);
        if(Depositions.size()>0){
            Set<Id>setDepositionIds = new Set<Id>();
            for(Attendee__c attendee : [select Deposition__c From Attendee__c 
                                      WHERE 
                                      Deposition__c IN : Depositions
                                      AND (Deposition__r.OwnerId =:UserInfo.getUserId() OR Contact__c=:usr.ContactId)]){
                setDepositionIds.add(attendee.Deposition__c);
            }
            if(setDepositionIds.size()>0)
                lstDepositions = [select Id,Name,Case_Name__c,Deponent_Name__c,Deposition_Date__c,Hiring_Attorney__c
                                 ,Deposition_Services__c
                                 From Deposition__c WHERE ID =:setDepositionIds];
        }

    }
    
    public PageReference requestFileAccess(){
         String fileId = ApexPages.currentPage().getParameters().get('id');
         usr = [select id,ContactId,Contact.AccountId,Contact.Email From User WHERE ID =:Userinfo.getUserId()];
         if(usr.ContactId != NULL){
             List<File_Access__c>lstNeedFileAccess = new List<File_Access__c>();
             
             List<Id>setDepIds = new List<Id>();
             for(File_Access__c fileAccess :  [select File__c,attendee__r.Deposition__c FROM File_Access__c WHERE 
                                               Attendee__r.Contact__r.AccountId=:usr.Contact.AccountId
                                               AND File__c=:fileId ]){
                 setDepIds.add(fileAccess.attendee__r.Deposition__c);    
             }
             if(setDepIds.size()>0){
                 List<Attendee__c>lstAttendees = [select id From Attendee__c WHERE 
                                                  Deposition__c=:setDepIds AND Contact__c=:usr.ContactId
                                                  LIMIT 1];
                 try{
                     if(lstAttendees.size()==0){
                         lstAttendees.add(new Attendee__c(Deposition__c=setDepIds[0],Role__c='Attorney',Contact__c=usr.ContactId,Email__c=usr.Contact.Email));
                         insert lstAttendees;
                     }
                     lstNeedFileAccess.add(new File_Access__c (Attendee__c=lstAttendees[0].id,File__c=fileId ));
                     insert lstNeedFileAccess;
                     
                     return new PageReference ('/CommunitiesSecureDownload?id='+fileId );
                 }catch(Exception e){
                      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()));
                 }
             }else{
                 FirmInfoCntrl  cntrl = new  FirmInfoCntrl();
                 Firm__c firm = cntrl.getFirm();
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'None of the other people at your company have access to this file. Please <a href="mailto:'+ firm.Production_Email_Address__c +'" style="color:white;">contact us</a> if you have additional questions.'));
             }
         }
         return null;
        
    }
    @RemoteAction
    global static String  updateFileDownloadLog(String fileId) {
        List<AWS_S3_Object__c>lstFiles = [select Id,Download_log__c FROM AWS_S3_Object__c WHERE ID=:fileId];
        if(lstFiles.size()>0){
            if(lstFiles[0].Download_Log__c == NULL)
                lstFiles[0].Download_Log__c = '';
            lstFiles[0].Download_Log__c +='\n '+Userinfo.getName() + ' downloaded file at '+system.now().format('MMM dd, yyyy hh:mm:ss a') ;
            update lstFiles;
        }
        return '';
    }
    
}