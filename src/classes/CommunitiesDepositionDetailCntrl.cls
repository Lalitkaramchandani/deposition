/**************************************************
                Name        : CommunitiesDepositionDetailCntrl 
                Author      : Rajendra Rathore
                Purpose     : That class is used by CommunitiesDepositionDetail VF page for do following things:
                                A.) List All Transcripts files for Deposition
                                B.) List All Exhibits files for Deposition
                                C.) List All Videosfiles for Deposition
                                E.) Allow user to upload new files as well as allow them to specify File Type for newly upload files.
                Created Date: 25 JUNE 2016
                
                Modification History:
*****************************************************/
global class CommunitiesDepositionDetailCntrl {
    public Deposition__c webdeposition{get;set;}
    public String depDate{get;set;}
    public List<AWS_S3_Object__c>lstTranscripts{get;set;}
    public List<AWS_S3_Object__c>lstExhibits{get;set;}
    public List<AWS_S3_Object__c>lstVideos{get;set;}
    public User usr {get;set;}
    public List<AWS_S3_Object__c>lstFiles{get;set;}
    public Upload_Files__c uploadBatch{get;set;}
    public Integer latestUploadNo{get;set;}
    public String accessCodeToken{get;set;}
    public Integer selectedFileIndex{get;set;}
    public String selectedFileType{get;set;}
    public Boolean readonly{get;set;}
    
    public CommunitiesDepositionDetailCntrl(ApexPages.StandardController controller) {
        usr = [select id,ContactId,Contact.Account.Industry,Contact.Account.COD_Warning__c From User WHERE id=:Userinfo.getUserId()];
        lstFiles = new List<AWS_S3_Object__c>();
        webdeposition = (Deposition__c)controller.getRecord();
        List<Deposition__c>lstDeps = [select id,Name,Event_Type__c,Deponent_Name__c,Deposition_Status__c
                                 ,Deposition_Date__c,Deposition_Time__c,Time_Zone__c,Event_Location__c,
                                 Deposition_Services__c,Estimated_Duration__c,Case_Name__c
                                  From Deposition__c WHERE ID=:webdeposition.id];
        if(lstDeps.size()>0){
            webdeposition  = lstDeps[0];
            depDate = '';
            if(webdeposition.Deposition_Date__c!= NULL){
                String month= String.valueOf(webdeposition.Deposition_Date__c.Month());
                String day = String.valueOf(webdeposition.Deposition_Date__c.Day());
                if(Integer.valueOf(month)<10)
                    month = '0'+month;
                if(Integer.valueOf(day)<10)
                    day  = '0'+day;    
                depDate = month+'/'+day+'/'+webdeposition.Deposition_Date__c.Year();
                
                DateTime restricttion = System.now().addDays(2);
                readonly = false;
                if(webdeposition.Deposition_Date__c ==null || webdeposition.Deposition_Date__c<= restricttion){
                    readonly = true;
                }
                if(!readonly){
                    List<Attendee__c> att = [SELECT Id,Role__c FROM Attendee__c 
                                             WHERE Deposition__c =:webdeposition.Id and Contact__c=:usr.ContactId];
                    if(!att.isEmpty()){
                        readonly = (att[0].Role__c =='Court Reporter' || att[0].Role__c =='Videographer/Technician');
                    }
                }
            }
            if(readonly == null){
                readonly = !(usr.Contact.Account.Industry =='Court Reporting' || usr.Contact.Account.Industry =='Videography');
            }
        }
        loadFiles();
        
    }
    
    public void init(){
       if(Test.isRunningTest()==false)
           accessCodeToken = GoogleDriveAuthenticationCntrl.getAccessToken();
        /*List<Upload_Files__c>lstUploadFiles = [select Id,Latest_Upload_Number__c FROM Upload_Files__c WHERE Deposition__c=:webdeposition.id AND CreatedById=:Userinfo.getUserId()
                                              ORDER BY CREATEDDATE DESC];
        if(lstUploadFiles.size()>0)
            uploadBatch = lstUploadFiles[0];
        else{*/
            uploadBatch= new Upload_Files__c(Deposition__c=webdeposition.id,Contact__c=usr.ContactId,IP_Address__c=ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP'));
            insert uploadBatch;
        /*}*/
        if(uploadBatch.Latest_Upload_Number__c >0)
            latestUploadNo = Integer.valueOf(uploadBatch.Latest_Upload_Number__c+1);
        else
            latestUploadNo =1;
    }
    public void fetchUserFiles(){
      
      for(AWS_S3_Object__c s3Obj : [select id,File_Name__c,File_Type__c From AWS_S3_Object__c
                                    WHERE Deposition__c=:webdeposition.id 
                                    AND CreatedById=:UserInfo.getUserId() AND Upload_Files__c=:uploadBatch.id
                                    AND Upload_No__c=:latestUploadNo AND ID NOT IN: lstFiles]){
          lstFiles.add(s3Obj);
          
      }
      
    }
    
    @RemoteAction
    global static String createAwsS3Object(String fileName,String fileId, String uploadBatchId,String depostionId,String contentType,
                                              Integer fileSize,Integer uploadNumber ) {
            return UploadFilesController.createAwsS3Object(fileName,'',fileId,uploadBatchId,depostionId,contentType,fileSize,uploadNumber  );
            
    }
    
    public void updateFileType(){
      try{
          AWS_S3_Object__c fileObj = lstFiles[selectedFileIndex];
          fileObj.File_Type__c = selectedFileType;
          update fileObj;
       }catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getMessage()));
      }
    }
    public void saveFiles(){
         try{
             if(lstFiles.size()>0 ){
                 update lstFiles;
                 loadFiles();
                 ApexPages.addMessage(new  ApexPages.Message(ApexPages.Severity.ERROR,'File Information Successfully Saved.')); 
             }
         }catch(Exception e){
             ApexPages.addMessage(new  ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage())); 
         }
    }
    public void loadFiles(){
        lstTranscripts = new List<AWS_S3_Object__c>();
        lstExhibits = new List<AWS_S3_Object__c>();
        lstVideos = new List<AWS_S3_Object__c>();
        Set<id>setFilesIds = new Set<Id>();
        for(File_Access__c fileAccess : [select File__c FROM File_Access__c WHERE Attendee__r.Contact__c =: usr.ContactId]){
            setFilesIds.add(fileAccess.File__c);
        }
        List<Attendee__c>lstAttendees = [select id FROM Attendee__c where Contact__c=:usr.ContactId AND Deposition__c=:webdeposition.id
                                             AND Role__c IN('Court Reporter','Interpreter','Videographer/Technician') ];
        if(lstAttendees.size()>0){
            for(AWS_S3_Object__c file : [select id,File_Id__c,File_Name__c,File_Type__c  From AWS_S3_Object__c WHERE Deposition__c=:webdeposition.id
                                    AND File_Type__c IN('Transcript','Exhibit','Video','','Deposition Notice')
                                    AND ( CreatedById=:UserInfo.getUserId() OR ID IN : setFilesIds OR File_Type__c='Deposition Notice')
                                     ]){
                if(file.File_Type__c =='Transcript' ||file.File_Type__c =='Deposition Notice' ||  ((file.File_Type__c == NULL || file.File_Type__c=='') && webdeposition.Deposition_Date__c!= NULL && webdeposition.Deposition_Date__c<System.Today() ) )
                   lstTranscripts.add(file);
                else if(file.File_Type__c =='Exhibit')
                    lstExhibits.add(file);
                else
                    lstVideos.add(file);
            }
        }else{
            for(AWS_S3_Object__c file : [select id,File_Id__c,File_Name__c,File_Type__c  From AWS_S3_Object__c WHERE Deposition__c=:webdeposition.id
                                    AND File_Type__c IN('Transcript','Exhibit','Video','')
                                    AND ( CreatedById=:UserInfo.getUserId() OR ID IN : setFilesIds)
                                     ]){
                if(file.File_Type__c =='Transcript' || ((file.File_Type__c == NULL || file.File_Type__c=='') && webdeposition.Deposition_Date__c!= NULL && webdeposition.Deposition_Date__c<System.Today() ) )
                   lstTranscripts.add(file);
                else if(file.File_Type__c =='Exhibit')
                    lstExhibits.add(file);
                else
                    lstVideos.add(file);
            }
        }
          
        
    }
    public void saveDeposition() {
       try{
           webdeposition.Deposition_Date__c = date.parse(depDate);
           update webdeposition;
           saveFiles();
           ApexPages.addMessage(new  ApexPages.Message(ApexPages.Severity.ERROR,'Deposition information successfully saved.'));
       }catch(Exception ex) {
           ApexPages.addMessage(new  ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
       }
   }
}