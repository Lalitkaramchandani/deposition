/**************************************************
                Name        : GrantingFileAccessToUsersExtn 
                Author      : Rajendra Rathore
                Purpose     : GrantingFileAccessToUsersExtn  apex class are used by GrantingFileAccessToUsers VF page for sharing 
                              files with Attendee Contacts, so they can see files in community
                Created Date: 6 March 2016
                
                Modification History:
*****************************************************/
public class GrantingFileAccessToUsersExtn {
    public List<S3FileModel>lstFiles{get;set;}
    public List<AttendeeWrapper> AttendeesWithoutCommunity {get;set;}
    public Integer selectedDepFileIndex{get;set;}
    public String depId = '';
    public SelectOption[] selectedUsers{ get; set; }
    public SelectOption[] allUser{ get; set; }
    public String NotificationMessage{get;set;}
    public string folderId = '';
    public string searchText='';
    public Boolean NotifyRecipients{get;set;}
    Set<String>setFileIds = new Set<String>();
    Integer i=1;
    List<GoogleFilesParser.cls_items>lstClsItems = new List<GoogleFilesParser.cls_items>();
    String nextPageToken ='';
    String fileId='';
    public GrantingFileAccessToUsersExtn(ApexPages.StandardController controller) {
        depId = controller.getId();
        folderId = ApexPages.currentPage().getParameters().get('folderId');
        fileId = ApexPages.currentPage().getParameters().get('fileId');
        NotifyRecipients = true;
        NotificationMessage = '';
       
    }
    
      
    public class AttendeeWrapper{
        public String urlToCreateUser{get;set;}
        public Attendee__c attendee{get;set;}
        
        public AttendeeWrapper(String url, Attendee__c att){
            urlToCreateUser = url;
            attendee = att;
        }
    }
    
    public PageReference goBack(){
        if(fileId!= '' && fileId != NULL)
            return new PageReference('/'+fileId );
        return new PageReference('/'+depId );
    }
    public void init(){
        
        selectedUsers= new List<SelectOption>();
        allUser= new List<SelectOption>();
        if(fileId != NULL & fileId != ''){
            
            List<AWS_S3_Object__c >lstSFFiles = [select Id,Name,File_Name__c,CreatedBy.Name,File_Type__c,Deposition__c,Folder_Path__c,File_Size__c,Content_Type__c 
                                              from AWS_S3_Object__c   WHERE Id=:fileId];
            lstFiles = new List<S3FileModel>();
            if(lstSFFiles.size()>0){
                S3FileModel s3FileModel = new S3FileModel(lstSFFiles[0],true);
                s3FileModel.FileSize = lstSFFiles[0].File_Size__c;
                s3FileModel.OwnerName = lstSFFiles[0].CreatedBy.Name;
                lstFiles.add(s3FileModel);
            }
            loadAttendees();
        }else {
            List<Deposition__c>lstDepositions = [select id,Name From Deposition__c WHERE Id=:depId ];
            if(lstDepositions.size()>0){
                
                String folderName = lstDepositions[0].Name +'/';
                
                HttpRequest req = new HttpRequest();
                //\''+folderId +'\'+in+parents and 
                //req.setEndpoint('https://www.googleapis.com/drive/v2/files?q=fullText%20contains%20%27PTHJTU%27');
                if(folderId !='')
                    req.setEndpoint('https://www.googleapis.com/drive/v2/files?q=\''+folderId +'\'+in+parents+AND+trashed%3Dfalse');
                
                req.setMethod('GET');
                req.setHeader('Authorization', 'Bearer '+GoogleDriveAuthenticationCntrl.getAccessToken());
                
                Http http = new Http();
                HTTPResponse res = http.send(req);
                system.debug('$$folderI='+folderId);
                system.debug('$$folderI='+res.getBody());
                
                GoogleFilesParser googleFiles = GoogleFilesParser.parse(res.getBody());
                system.debug(res.getBody());
                
                lstFiles = new List<S3FileModel>();
                map<String,AWS_S3_Object__c > mapAWS_S3Objects = loadS3Files(new Set<String>());
                if(googleFiles.items!= NULL && googleFiles.items.size()>0){
                    for(GoogleFilesParser.cls_items fileObj : googleFiles.items){
                        String fileName =fileObj.title;
                        String uploadedBy= Userinfo.getName();
                        AWS_S3_Object__c S3Obj = new AWS_S3_Object__c(File_Name__c=fileName,File_Id__c=fileObj.id);
                        if(mapAWS_S3Objects.containsKey(fileObj.id)){
                           S3Obj.id = mapAWS_S3Objects.get(fileObj.id).id;
                           S3Obj.File_Type__c = mapAWS_S3Objects.get(fileObj.id).File_Type__c;
                           S3Obj.Note__c= mapAWS_S3Objects.get(fileObj.id).Note__c;
                           uploadedBy = mapAWS_S3Objects.get(fileObj.id).CreatedBy.Name;
                        }
                        S3Obj.Deposition__c = depId ;
                        S3Obj.Folder_Path__c = folderName;
                        if(fileObj.FileSize != NULL)
                            S3Obj.File_Size__c = Double.valueOf(fileObj.FileSize);
                        S3FileModel s3FileModel = new S3FileModel(S3Obj ,false);
                        s3FileModel.FileSize = S3Obj.File_Size__c;
                        s3FileModel.UploadedDate= fileObj.createdDate ;
                        s3FileModel.modifiedDate = fileObj.modifiedDate;
                        s3FileModel.lastModifiedBy= fileObj.lastModifyingUserName;
                        s3FileModel.fileType = fileObj.iconLink;
                        s3FileModel.OwnerName = uploadedBy;
                        lstFiles.add(s3FileModel);
                    }
                } 
                loadAttendees();
            }
        }
    }
    
    public void callInitFullTextSearch(){
        i=1;
        lstFiles = new List<S3FileModel>();
        nextPageToken ='';
        
        Set<String>setFolderIds = new Set<String>();
        String qry = 'select Attendee__r.Deposition__r.GOOGLE_DRIVE_FOLDER_ID__C From File_Access__c WHERE'+
                     ' Attendee__r.Deposition__r.GOOGLE_DRIVE_FOLDER_ID__C != NULL ';
        User usr = [select id,ContactId From User WHERE Id=:Userinfo.getUserId()];
        if(usr.ContactId != NULL)
            qry += ' AND Attendee__r.Contact__c=\''+usr.ContactId +'\'';
        
        for(File_Access__c fileAccess: Database.Query(qry)){
            setFolderIds.add(fileAccess.Attendee__r.Deposition__r.GOOGLE_DRIVE_FOLDER_ID__C );
        }
        initFullTextSearch(setFolderIds);
        map<String,AWS_S3_Object__c > mapAWS_S3Objects = loadS3Files(setFileIds);
        for(GoogleFilesParser.cls_items fileObj : lstClsItems){
            String fileName =fileObj.name;
            AWS_S3_Object__c S3Obj = new AWS_S3_Object__c(File_Name__c=fileName,File_Id__c=fileObj.id);
            if(mapAWS_S3Objects.containsKey(fileObj.id)){
               S3Obj = mapAWS_S3Objects.get(fileObj.id);
            }
            //if(fileObj.FileSize !=NULL)
            //    S3Obj.File_Size__c = Double.valueOf(fileObj.FileSize);
            S3FileModel s3FileModel = new S3FileModel(S3Obj ,false);
            //s3FileModel.FileSize = S3Obj.File_Size__c;
            //s3FileModel.UploadedDate= fileObj.createdDate ;
            //s3FileModel.modifiedDate = fileObj.modifiedDate;
            //s3FileModel.lastModifiedBy= fileObj.lastModifyingUserName;
            //s3FileModel.fileType = fileObj.iconLink;
            //if(fileObj.owners!=NULL && fileObj.owners.size()>0)
            //    s3FileModel.OwnerName = fileObj.owners[0].displayName;
            lstFiles.add(s3FileModel);
         }
         lstClsItems = new List<GoogleFilesParser.cls_items>();
         setFileIds = new Set<String>();
    }
    
    public void initFullTextSearch(Set<String>setFolderIds){
        
        if(setFolderIds.size()>0){
            HttpRequest req = new HttpRequest();
            String endPointURL= 'https://www.googleapis.com/drive/v3/files?q=fullText%20contains%20%27'+searchText +'%27+AND+trashed%3Dfalse';
            String folderFilters = 'AND(';
            Boolean addORFlag = false;
            for(String googleFolderId :setFolderIds){
                if(addORFlag )
                    folderFilters +='%20OR%20';
                folderFilters += '\''+ googleFolderId + '\'+in+parents';
                addORFlag =true;
            }
            folderFilters += ')&pageSize=1000';
            endPointURL = endPointURL+folderFilters ;
            if(nextPageToken != NULL && nextPageToken != '')
                endPointURL+='&pageToken='+nextPageToken;
            req.setEndpoint(endPointURL);
            req.setMethod('GET');
            req.setHeader('Authorization', 'Bearer '+GoogleDriveAuthenticationCntrl.getAccessToken());
            
            Http http = new Http();
            HTTPResponse res = http.send(req);
            system.debug('$$folderI='+req.getEndPoint());
            system.debug('$$folderI='+res.getBody());
            
            GoogleFilesParser googleFiles = GoogleFilesParser.parse(res.getBody());
            system.debug(res.getBody());
            
            if(googleFiles.files!= NULL && googleFiles.files.size()>0){
                
                for(GoogleFilesParser.cls_items fileObj : googleFiles.files){
                    setFileIds.add(fileObj.id);
                }
                lstClsItems.addAll(googleFiles.files);
                
            }
            
            if(googleFiles.nextPageToken != NULL && googleFiles.nextPageToken != '' && i<5){
                nextPageToken = googleFiles.nextPageToken;
                i++;
                initFullTextSearch(setFolderIds);
            }
            
       } 
     
    }
    
    public String getCreateUserURL(Attendee__c attendee){
        String url = URL.getSalesforceBaseUrl().toExternalForm() +'/';
        url = url + '005/e?ut=c&retURL=%2F'+attendee.Contact__c+'&cntc='+attendee.Contact__c;
        url = url + '&name_firstName='+attendee.contact__r.firstname+'&name_lastName='+attendee.contact__r.lastname;
        url = url + '&Addressstreet='+attendee.contact__r.MailingStreet+'&Addresscity='+attendee.contact__r.MailingCity+'&Addressstate='+attendee.contact__r.MailingState+'&Addresszip='+attendee.contact__r.MailingPostalCode+'&Addresscountry='+attendee.contact__r.MailingCountry;
        url = url + '&Email='+attendee.contact__r.Email+'&Username='+attendee.contact__r.Email+'&Alias='+attendee.contact__r.lastname+'&CommunityNickname='+attendee.contact__r.lastname+''+attendee.contact__r.firstname;
        
        return url;
    }
    private void loadAttendees(){
        List<ID> attendeeContactIdList = new List<ID>();
        List<Attendee__c> allAttendees = new List<Attendee__c>();
        AttendeesWithoutCommunity = new List<AttendeeWrapper>();
        List<String> ContactIDsHavingCommunity = new List<String>();
        for(Attendee__c attendee : [select id,role__c, Contact__c,contact__r.name,contact__r.Email,contact__r.MailingStreet,contact__r.MailingCity, contact__r.MailingCountry, contact__r.MailingState, contact__r.MailingPostalCode,contact__r.firstname,contact__r.lastname,contact__r.Account.Industry 
                                   ,Contact__r.Account.Name
                                   FROM Attendee__c  
                                   WHERE Deposition__c=:depId
                                   AND Contact__c!=NULL   ]){
            attendeeContactIdList.add(attendee.Contact__c);
            system.debug('Attendee Contact ID :: '+attendee.Contact__c);
            allAttendees.add(attendee);  
            String labelValue = attendee.contact__r.name;
            if(attendee.Contact__r.Account.Name != NULL && attendee.Contact__r.Account.Name !='')      
                labelValue += ', '+ attendee.Contact__r.Account.Name;
                                     
            if(attendee.contact__r.Account.Industry == 'Corporation' || attendee.contact__r.Account.Industry == 'Law Firm')
                selectedUsers.add(new SelectOption(attendee.id, labelValue ));
            else
                allUser.add(new SelectOption(attendee.id, labelValue ));
        }
        
        for(User u : [select id, ContactId from user 
                      where ContactId in :attendeeContactIdList and Profile.Name = 'Customer Community Login User(Custom)']){
                        ContactIDsHavingCommunity.add(u.ContactId);  
                      }
        system.debug('ContactIDsHavingCommunity:::'+ContactIDsHavingCommunity);
        //populate Attendees list that don't have Community Account
        for(Attendee__c att : allAttendees){
            if(!ContactIDsHavingCommunity.contains(att.Contact__c)){
               AttendeeWrapper attWrap = new AttendeeWrapper(getCreateUserURL(att), att);
               AttendeesWithoutCommunity.add(attWrap);
            }          
        }
    }
    private map<String,AWS_S3_Object__c >loadS3Files(Set<String>setFileIds){
        map<String,AWS_S3_Object__c > mapAWS_S3Objects = new map<String,AWS_S3_Object__c >();
        String qry = 'select Id,File_Id__c,File_Name__c,Upload_Files__c,File_Type__c,File_Size__c,Note__c,Notes__c, Content_Type__c,';
        qry +='CreatedById,CreatedDate,Deposition__c,Deposition__r.Deposition_Date__c,Deposition__r.Case_Name__c,Deposition__r.Event_Location__c,';
        qry +='Deposition__r.Deponent_Name__c,Deposition__r.Deposition_Time__c,Deposition__r.Time_Zone__c,CreatedBy.Name From AWS_S3_Object__c ';
        qry += ' WHERE File_Id__c != NULL';
        if(depId != NULL && depId!='')
            qry += ' AND Deposition__c=:depId ';
        else{
            qry += ' AND File_Id__c=:setFileIds';
        }
        
        for(AWS_S3_Object__c s3File : Database.query(qry)){
                                             
            mapAWS_S3Objects.put(s3File.File_Id__c,s3File ); 
        }
        return mapAWS_S3Objects;
    }
    
    public void updateDepFileType(){
      try{
          AWS_S3_Object__c fileObj = lstFiles[selectedDepFileIndex].awsS3Obj;
          update fileObj;
       }catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getMessage()));
      }
    }
    
    public void saveFiles(){
        List<AWS_S3_Object__c >lstS3ObjNeedUpdate = new List<AWS_S3_Object__c >();
        
        Boolean createUploadBatch  =false;
        for(S3FileModel s3File : lstFiles){
            if(s3File.isSelected){
                if(s3File.awsS3Obj.id == NULL)
                    createUploadBatch  = true;
                lstS3ObjNeedUpdate.add(s3File.awsS3Obj);
            }    
        }
        
        if(lstS3ObjNeedUpdate.size()>0){
           Savepoint sp = Database.setSavepoint();
           
           
           try{
               if(createUploadBatch){
                    Upload_Files__c uploadFile = fetchUploadBatch();
                    upsert uploadFile ;
                    for(AWS_S3_Object__c obj : lstS3ObjNeedUpdate){
                        if(obj.id ==NULL)
                            obj.Upload_Files__c = uploadFile.id;
                    }
                } 
                upsert lstS3ObjNeedUpdate;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Files successfully saved.'));
           }catch(Exception e){
               ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
               Database.rollback(sp);
           }
       }else{
           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select at least one File.'));
       }
    }
    public PageReference grantAccess(){
        String message = '';
        Set<String>setSelectedUserIds = new Set<String>();
        Set<String>setSelectedFilesIds = new Set<String>();
        for ( SelectOption so : selectedUsers) {
           setSelectedUserIds.add(so.getValue() );
        }
        
        Boolean createUploadBatch  =false;
        Integer countOfSelectedFiles = 0;
        List<AWS_S3_Object__c >lstS3ObjNeedUpdate = new List<AWS_S3_Object__c >();
        for(S3FileModel s3File : lstFiles){
            if(s3File.isSelected){
                countOfSelectedFiles++;
                if(s3File.awsS3Obj.id != NULL)
                    setSelectedFilesIds.add(s3File.awsS3Obj.id);
                else{
                    createUploadBatch  = true;
                    lstS3ObjNeedUpdate.add(s3File.awsS3Obj);
                }
            }
        }
        Boolean isErr = false;
        if(setSelectedUserIds.size()==0){
            isErr = true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select at least one user.'));
        }
        if(countOfSelectedFiles==0){
            isErr = true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select at least one File.'));
        }
        if(isErr==false){
           saveFiles(); 
           Savepoint sp = Database.setSavepoint();
           try{
                if(createUploadBatch){
                    Upload_Files__c uploadFile = fetchUploadBatch();
                    upsert uploadFile ;
                    for(AWS_S3_Object__c obj : lstS3ObjNeedUpdate){
                        if(obj.id==NULL)
                            obj.Upload_Files__c = uploadFile.id;
                    }
                    upsert lstS3ObjNeedUpdate;
                    for(AWS_S3_Object__c obj : lstS3ObjNeedUpdate){
                        setSelectedFilesIds.add(obj.id);
                    }
                } 
                List<File_Access__c>lstS3FilesAccess = [select Id From File_Access__c 
                                                        WHERE 
                                                        File__c IN :setSelectedFilesIds AND Attendee__c IN : setSelectedUserIds];
                if(lstS3FilesAccess.size()>0){
                    delete lstS3FilesAccess;
                    Database.emptyRecycleBin(lstS3FilesAccess);
                }
                lstS3FilesAccess  = new List<File_Access__c>();
                for(String fileId : setSelectedFilesIds){
                    for(String userId: setSelectedUserIds){
                        lstS3FilesAccess.add( new File_Access__c(Attendee__c=userId,File__c=fileId));
                    }
                }
                if(lstS3FilesAccess.size()>0)
                    insert lstS3FilesAccess;
                
                if(NotifyRecipients){
                    List<Messaging.SingleEmailMessage>lstEmails = new List<Messaging.SingleEmailMessage>();
                    List<EmailTemplate>lstEmailTemplate = [select id From EmailTemplate WHERE DeveloperName='Files_Granted_Email_Notification' ];
                    Deposition__c dep = new Deposition__c(Id=depId,File_Notification_Message__c=NotificationMessage);
                    update dep;
                    if(lstEmailTemplate.size()>0){
                        for(Attendee__c attend : [select Contact__c From Attendee__c WHERE Contact__r.Email != NULL AND ID IN:setSelectedUserIds]){
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            mail.setTemplateId(lstEmailTemplate[0].id);
                            mail.setWhatId(depId);  
                            mail.setSaveAsActivity(true);   
                            mail.setTargetObjectId(attend.Contact__c);        
                            lstEmails.add(mail);
                        }
                        Messaging.sendEmail(lstEmails);
                    }
                }
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'File Access successfully granted to users.'));
                return goBack();
           }catch(Exception e){
               ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
               Database.rollback(sp);
           }
        }
        return null;
    }
    
    public Upload_Files__c fetchUploadBatch(){
        List<Upload_Files__c>lstUploadFiles = [select Id FROM Upload_Files__c WHERE Deposition__c=:depId ORDER BY CREATEDDATE DESC];
        if(lstUploadFiles.size()>0)
            return lstUploadFiles[0];
        else
            return new Upload_Files__c(Deposition__c=depId);
    }
   
}