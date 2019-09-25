global class BatchUpdateGoogleDriveFolderId implements Database.batchable<Sobject>, Database.AllowsCallouts{ 
   
   global String qryStr = 'select Id,Name,GOOGLE_DRIVE_FOLDER_ID__C From Deposition__c';
   global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(qryStr );
   }

    
   global void execute(Database.BatchableContext info, List<Sobject> scope){
       List<Deposition__c> DepositionsToUpdate = new List<Deposition__c>();
       String accessToken = '';
       if(Test.isRunningTest())
            accessToken = 'Testing';    
       else 
            accessToken =GoogleDriveAuthenticationCntrl.getAccessToken();
            
       for(Sobject depSobj : scope){ 
           Deposition__c dep = (Deposition__c)depSobj ;
           String searchText=dep.Name;
           HttpRequest req = new HttpRequest();
           String endPointURL= 'https://www.googleapis.com/drive/v3/files?q=name%3D%27'+searchText +'%27%20AND%20mimeType=%27application/vnd.google-apps.folder%27';
           req.setEndpoint(endPointURL);
           req.setMethod('GET');
           req.setHeader('Authorization', 'Bearer '+accessToken);
            
           Http http = new Http();
           HTTPResponse res = new HttpResponse();
           if(Test.isRunningTest()){
                String json='{'+
                         '"kind": "drive#fileList",'+
                         '"files": []'+
                        '}';
                res.SetBody(json);
            }else
                res = http.send(req);
           
           
           String resBody = res.getBody();
           system.debug('$$folder response='+resBody );
           GoogleFilesParser googleFiles = GoogleFilesParser.parse(resBody);
           if(googleFiles.files!= NULL && googleFiles.files.size()>0){
               dep.GOOGLE_DRIVE_FOLDER_ID__C  = googleFiles.files[0].id;
               DepositionsToUpdate.add(dep);
           }else{
                req = new HttpRequest();
                req.setMethod('POST');
                req.setEndpoint('https://www.googleapis.com/drive/v2/files');
                req.setHeader('Authorization', 'Bearer '+accessToken);
                req.setHeader('content-type', 'application/json');
                
                String messageBody = '{'+
                  '"title": "' +dep.Name+'",'+
                  '"parents": [],'+
                  '"mimeType": "application/vnd.google-apps.folder"'+
                '}';
                req.setBody(messageBody);
                req.setTimeout(60*1000);
                
                http= new Http();
                String resp;
                res = new HttpResponse();
                if(Test.isRunningTest()){
                    String json=        '{'+
                    ' "id": "0B3EaxhqyEcP2WGZGX0tfQ0xvMW8"'+
                    '}';
                    res.SetBody(json);
                }else
                    res = http.send(req);
                resp = res.getBody();
                dep.GOOGLE_DRIVE_FOLDER_ID__C  = GogoleDriveFolderParser.parse(resp).id;
                DepositionsToUpdate.add(dep);
           }
           
       } 
       if(DepositionsToUpdate.size()>0)
           update DepositionsToUpdate; 
   }     
   global void finish(Database.BatchableContext info){     
   } 
}