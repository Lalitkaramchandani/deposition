/**
                    Name            :  TestBatchUpdateGoogleDriveFolderId
                    Date            :  4 FEB 2017
                    Descriptiion    :  Test Class for BatchUpdateGoogleDriveFolderId
*/
@isTest
private class TestBatchUpdateGoogleDriveFolderId{
  
  @isTest
  private static void Test_DepositionBeforeTrigger(){
    insert TestUtils.createSignature();
    TestUtils tUtils = new TestUtils();
    Deposition__c deposition = tUtils.createDeposition();
    Id batchJobId = Database.executeBatch(new BatchUpdateGoogleDriveFolderId (), 10);
  }
  
}