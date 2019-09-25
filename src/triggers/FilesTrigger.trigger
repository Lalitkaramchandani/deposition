/**************************************************
                Name        : FilesTrigger
                Purpose     : Files object trigger
                Created Date: 19 FEB 2017
                
                Modification History:
*****************************************************/

trigger FilesTrigger on AWS_S3_Object__c( after update,after delete) {
 new FilesTriggerHandler().run();
}