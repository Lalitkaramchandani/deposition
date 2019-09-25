/**************************************************
                Name        : TestCommunitiesDepositionDetailCntrl
                Author      : Rajendra Rathore
                Purpose     : Test class for CommunitiesDepositionDetailCntrl Apex class
                Created Date: 11 JULY 2016
                
                Modification History:
*****************************************************/
@isTest
public  class TestCommunitiesDepositionDetailCntrl{
    @isTest
    private static void Test_Community(){
        TestFactory tFact = new TestFactory();
        List<Deposition__c> depositions = tFact.depositions;
        List<Attendee__c> attendees = tFact.attendees;
        
        Deposition__c dep = depositions[0];
        System.runAs(tFact.communtiyUser){
            runTest(dep);
        }   
    }
    @isTest
    private static void Test_NonCommunity(){
        TestFactory tFact = new TestFactory();
        List<Deposition__c> depositions = tFact.depositions;
        List<Attendee__c> attendees = tFact.attendees;
        
        Deposition__c dep = depositions[0];
        runTest(dep);
    }
    static void runTest(Deposition__c dep){
        CommunitiesDepositionDetailCntrl cntrl = new CommunitiesDepositionDetailCntrl(new ApexPages.StandardController(dep));
        cntrl.init();
        cntrl.saveFiles();
        system.debug('$$'+CommunitiesDepositionDetailCntrl.createAwsS3Object('Test.jpg', 'test123', cntrl.uploadBatch.id,dep.id, 'test',
                                                                             100,1));
        CommunitiesDepositionDetailCntrl.createAwsS3Object('Test2.jpg', 'test1234', cntrl.uploadBatch.id,dep.id, 'test',
                                                           100,1);
        CommunitiesDepositionDetailCntrl.createAwsS3Object('Test3.jpg', 'test1236', cntrl.uploadBatch.id,dep.id, 'test',
                                                           100,1);                                    
        List<AWS_S3_Object__c>lstFiles = [select id From AWS_S3_Object__c  ];
        Integer i=0;
        for(AWS_S3_Object__c file : lstFiles){
            if(i==0)
                file.file_Type__c = 'Transcript';
            else if(i==1)
                file.file_Type__c = 'Exhibit';
            else 
                file.file_Type__c = 'Video';
            i++;
        }
        if(lstFiles.size()>0)
            update lstFiles;
        cntrl.fetchUserFiles();
        cntrl.loadFiles();
        cntrl.saveDeposition();
        cntrl.fetchUserFiles();
    }
}