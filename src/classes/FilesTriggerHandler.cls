/**************************************************
                Name        : FilesTriggerHandler
                Purpose     : Files object Trigger handler
                Created Date: 19 FEB 2017
                
                Modification History:
*****************************************************/

public class FilesTriggerHandler extends TriggerHandler {

    public FilesTriggerHandler() {}

    /* context overrides */
    protected override  void afterUpdate() {
        updateDepositonInformation();
        Map<Id,AWS_S3_Object__c>oldMap = (Map<id,AWS_S3_Object__c>)trigger.oldmap;
        List<AWS_S3_Object__c>lstFiles = new List<AWS_S3_Object__c>();
        for(AWS_S3_Object__c file: (List<AWS_S3_Object__c>)trigger.new){
            if( file.File_Id__c != '' && file.File_Id__c != NULL && (file.File_name__c !=oldmap.get(file.id).File_Name__c
            || file.Deposition__c!=oldmap.get(file.id).Deposition__c) ){
                lstFiles.add(file);
            }
        }
        if(lstFiles.size()>0){
            if(System.isBatch() || System.isFuture())
                callUpdateFileOnGoogleDrive(Json.serialize(lstFiles));
            else
                futureCallUpdateFileOnGoogleDrive(Json.serialize(lstFiles));
        }
    }
    protected override  void afterdelete() {
        set<String>setFileIds = new Set<String>();
        
        for(AWS_S3_Object__c file: (List<AWS_S3_Object__c>)trigger.old){
            if( file.File_Id__c != '' && file.File_Id__c != NULL){
                setFileIds.add(file.File_Id__c );
            }
        }
        if(setFileIds.size()>0){
            if(System.isBatch() || System.isFuture())
                callDeleteFileFromGoogleDrive(setFileIds);
            else
                futureCallDeleteFileFromGoogleDrive(setFileIds);
        }
        
    }
    

    /* private methods */
    
    private static void updateDepositonInformation() {
        set<Id>setDepIds = new Set<Id>();
        Map<Id,AWS_S3_Object__c>oldMap = (Map<Id,AWS_S3_Object__c>)trigger.oldmap;
        for(AWS_S3_Object__c file: (List<AWS_S3_Object__c>)trigger.new){
            if( file.File_Type__c =='Invoice' && file.File_Type__c!= oldmap.get(file.id).File_Type__c){
                setDepIds.add(file.Deposition__c);
            }
        }
        if(setDepIds.size()>0){
            User Usr = [select id,ContactId From User WHERE Id=:Userinfo.getUserId()];
            if(usr.Contactid != NULL){
                List<Attendee__c>lstAttendees = [select Id,Role__c,Invoice_Status__c From Attendee__c WHERE Deposition__c IN:setDepIds
                                                 AND Contact__c=:usr.ContactId AND Role__c IN ('Videographer/Technician','Court Reporter') ];
                if(lstAttendees.size()>0){
                    List<Deposition__c>lstDepNeedUpdate = new List<Deposition__c>();
                    map<Id,Attendee__c>mapAttendeesNeedUpdate = new Map<Id,Attendee__c>();
                    for(Id depId : setDepIds){
                        Boolean updateDep = false;
                        Deposition__c dep = new Deposition__c(Id= depId);
                        for(Attendee__c attendee : lstAttendees){
                            if(attendee.Role__c=='Court Reporter'){
                                dep.Invoice_Status_Reporter__c = true;
                                updateDep=true;
                            }else if(attendee.Role__c=='Videographer/Technician'){
                                dep.Invoice_Status_Video__c= true;
                                updateDep=true;
                            }
                            if(attendee.Invoice_Status__c !='Received'){
                                attendee.Invoice_Status__c = 'Received';
                                mapAttendeesNeedUpdate.put(attendee.id,attendee);
                            }
                            
                        }
                        if(updateDep)
                           lstDepNeedUpdate.add(dep); 
                        if(mapAttendeesNeedUpdate.size()>0)
                            update mapAttendeesNeedUpdate.values();
                    }
                    
                    if(lstDepNeedUpdate.size()>0)
                        update lstDepNeedUpdate;
                }
            }
        }
        
    }
    
    //Delete a file from Google Drive
    private static void deleteFileFromGoogleDrive(Set<String>setFileIds) {
        
            String accessToken = '';
            if(Test.isRunningTest())
                accessToken = 'Testing';    
            else 
                accessToken =GoogleDriveAuthenticationCntrl.getAccessToken();
    
            for(String fileId : setFileIds){
            
                try{
                    HttpRequest req = new HttpRequest();
                    req.setMethod('POST');
                    req.setEndpoint('https://www.googleapis.com/drive/v2/files/'+fileId+'/trash' );
                    req.setHeader('Authorization', 'Bearer '+accessToken);
                    req.setBody('');
                    req.setTimeout(60*1000);
                    
                    Http h = new Http();
                    String resp;
                    HttpResponse res = new HttpResponse();
                    if(Test.isRunningTest()==false)
                        res = h.send(req);
                    resp = res.getBody();
                    
                }Catch(Exception e ){
                    System.debug('Error in Google Drive delete File '+e.getMessage());
                }
            }
              
                    
       
    }
    
    private void callDeleteFileFromGoogleDrive(Set<String>setFileIds){
        deleteFileFromGoogleDrive(setFileIds);
        
    }
    @future(callout=true)
    private static void futureCallDeleteFileFromGoogleDrive(Set<String>setFileIds){
        deleteFileFromGoogleDrive(setFileIds);
    }
    
    //Delete a file from Google Drive
    private static void UpdateFileOnGoogleDrive(List<AWS_S3_object__c>lstFiles) {
        
            String accessToken = '';
            if(Test.isRunningTest())
                accessToken = 'Testing';    
            else 
                accessToken =GoogleDriveAuthenticationCntrl.getAccessToken();
    
            for(AWS_S3_Object__c file : lstFiles){
            
                try{
                    HttpRequest req = new HttpRequest();
                    
                    req.setEndpoint('https://www.googleapis.com/drive/v2/files/'+file.File_Id__c );
                    req.setHeader('Authorization', 'Bearer '+accessToken);
                    String fileBody = '{"title": "' +file.File_Name__c+ '"';
                    
                    if(file.Parent_Folder_Id__c != NULL && file.Parent_Folder_Id__c != '')
                        fileBody +=',"parents" : [{ "id": "'+file.Parent_Folder_Id__c +'" }]';
                        
                    fileBody +='}';
                    req.setBody(fileBody);
                    req.setHeader('Content-Type', 'application/json');
                    req.setHeader('X-HTTP-Method-Override','PATCH');
                    req.setMethod('POST');
                    req.setTimeout(60*1000);
                    
                    Http h = new Http();
                    String resp;
                    HttpResponse res = new HttpResponse();
                    if(Test.isRunningTest()==false)
                        res = h.send(req);
                    resp = res.getBody();
                    
                }Catch(Exception e ){
                    System.debug('Error in Google Drive delete File '+e.getMessage());
                }
            }
              
                    
       
    }
    
    private void callUpdateFileOnGoogleDrive(String jsonString){
        // Deserialize the list  from the JSON string.
         List<AWS_S3_Object__c> lstFiles=
          (List<AWS_S3_Object__c>)JSON.deserialize(jsonString, List<AWS_S3_Object__c>.class);
        UpdateFileOnGoogleDrive(lstFiles);
    }
    @future(callout=true)
    private static void futureCallUpdateFileOnGoogleDrive(string jsonString){
        // Deserialize the list  from the JSON string.
         List<AWS_S3_Object__c> lstFiles=
          (List<AWS_S3_Object__c>)JSON.deserialize(jsonString, List<AWS_S3_Object__c>.class);
        UpdateFileOnGoogleDrive(lstFiles);
    }
    
}