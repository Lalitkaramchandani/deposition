/**************************************************
                Name        : S3FileModel
                Author      : Rajendra Rathore
                Purpose     : Model class for File
                Created Date: 30 March 2016
                
                Modification History:
*****************************************************/
public class S3FileModel{
    public AWS_S3_Object__c awsS3Obj{get;set;}
    public Boolean isSelected{get;set;}
    public Double FileSize{get;set;}
    public DateTime UploadedDate{get;set;}
    public DateTime modifiedDate{get;set;}
    public String lastModifiedBy{get;set;}
    public String fileType{get;set;}
    public String OwnerName{get;set;}
    public S3FileModel(AWS_S3_Object__c awsS3Obj , Boolean isSelected){
        this.awsS3Obj = awsS3Obj ;
        this.isSelected = isSelected;
    }
}