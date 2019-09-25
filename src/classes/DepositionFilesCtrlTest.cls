@isTest
private class DepositionFilesCtrlTest {
    
    private static testMethod void testAccess() { 
        
        TestFactory tFact = new TestFactory();
        List<Invoice_Item__c> items = tFact.invoiceItems;
        List<Deposition__c> depositions = tFact.depositions;
        List<Contact> contacts = tFact.contacts;
        
        Upload_Files__c upFile = new Upload_Files__c (Contact__c=contacts[0].Id, Deposition__c  = depositions[0].Id);
        insert upFile;
        List<AWS_S3_Object__c> s3 = new List<AWS_S3_Object__c>();
        s3.add(new AWS_S3_Object__c(File_Type__c='Deposition Notice', Deposition__c= depositions[0].Id, 
                                    File_Name__c='test',Upload_Files__c=upFile.id ));
        insert s3;
        DepositionFilesCtrl control = new DepositionFilesCtrl();
        control.depositionId = depositions[0].Id;
        s3 = control.awsFiles;
        
        control.getFileAccess();
    }

}