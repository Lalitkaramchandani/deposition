public class UploadFilesEmailsComponentCntrl{
      public String uploadFilesId{get;set;}
      
      public Upload_Files__c getUploadFiles(){
        Upload_Files__c uploadFiles= new Upload_Files__c();
        if(uploadFilesId != null && uploadFilesId.trim().length()>0){
            List<Upload_Files__c>lstUploadFiles = [select id,Name,Email__c,Deposition__r.Name,Contact__r.Email,Date_Time_Of_Upload__c,Notes__c,IP_Address__c
            From Upload_Files__c WHERE Id=:uploadFilesId];
            if(lstUploadFiles.size()>0)
                uploadFiles = lstUploadFiles[0];
        }
        return uploadFiles;
      }
      
      public List<AWS_S3_Object__c>getAWSS3Objects(){
          return [select id,Name,File_Name__c,File_Size_KB__c,File_Url__c,File_Type__c From AWS_S3_Object__c WHERE Upload_Files__c =:uploadFilesId ];
      }
      
      public String getLogoDocumentid(){
          List<Document>lstDocuments = [select id From Document WHERE Name='Next Gen Logo'];
          if(lstDocuments.size()>0)
              return lstDocuments[0].id;
          else
              return '';
      }
      
      
}