public class DepositionFilesCtrl {
    
    public String depositionId{get;set;}
    
    public List<AWS_S3_Object__c> awsFiles{
        get{
            if(awsFiles==null){
                awsFiles = [SELECT Id, File_Type__c, Deposition__c, Deposition__r.Primary_Court_Reporting_Firm__r.Name, 
                            File_Name__c,File_Size_KB__c 
                            FROM AWS_S3_Object__c 
                            WHERE Deposition__c=:depositionId
                            AND File_Type__c='Deposition Notice']; 
            }
            return awsFiles;
        }set;
    }
    
    public void getFileAccess(){
        if(depositionId != NULL && depositionId !=''){
            List<AWS_S3_Object__c>lstDepositionNoticeFiles = [select Id From AWS_S3_Object__c WHERE 
                                                             File_Type__c='Deposition Notice'
                                                             AND Deposition__c=:depositionId];
            if(lstDepositionNoticeFiles.size()>0){
                List<File_Access__c>lstFileAccesses = new List<File_Access__c>();
                for(AWS_S3_Object__c file: lstDepositionNoticeFiles ){
                    for(Attendee__c attendee : [select id from Attendee__c WHERE Deposition__c=:depositionId AND Role__c='Court Reporter']){
                        File_Access__c fileAccess = new File_Access__c(Attendee__c=attendee.id,File__c=file.id);
                        lstFileAccesses.add(fileAccess );
                    }
                }
                if(lstFileAccesses.size()>0)
                    insert lstFileAccesses;
            } 
        }
        
    }
}