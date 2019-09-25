global class BatchDeleteGoogleDriveFolderId implements Database.batchable<Sobject>, Database.AllowsCallouts{ 
   
   global String qryStr = 'select Id,Name,GOOGLE_DRIVE_FOLDER_ID__C From Deposition__c WHERE GOOGLE_DRIVE_FOLDER_ID__C   != NULL';
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
           String searchText='2017-439181';
           HttpRequest req = new HttpRequest();
           String endPointURL= 'https://www.googleapis.com/drive/v3/files/'+dep.GOOGLE_DRIVE_FOLDER_ID__C;
           req.setEndpoint(endPointURL);
           req.setMethod('DELETE');
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
           
       } 
       
   }     
   global void finish(Database.BatchableContext info){     
   } 
}