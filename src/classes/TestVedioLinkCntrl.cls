/**
                                Name             : TestVedioLinkCntrl
                                Date             : 10 MARCH 2016
                                Description      : Test Class for  VideoLinkExtn apex class
*/
@isTest
private class TestVedioLinkCntrl{
  
  @isTest
  private static void Test_VedioLinkCntrl(){
    VideoLinkExtn extn = new VideoLinkExtn( new ApexPages.StandardController(New Deposition__c()));
    ApexPages.CurrentPage().getParameters().put('contactid','003');
    extn = new VideoLinkExtn( new ApexPages.StandardController(New Deposition__c()));
  }
 
  
}