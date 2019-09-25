/**************************************************
                Name        : TestCommunityLandingPageCntrl
                Author      : Rajendra Rathore
                Purpose     : Test class for CommunityLandingPageCntrl Apex class
                Created Date: 11 JULY 2016
                
                Modification History:
*****************************************************/
@isTest
public  class TestCommunityLandingPageCntrl{
  @isTest
  private static void Test_CommunityLandingPageCntrl (){
       
       system.runAs(TestUtility.createCommunityUser()){
           Apexpages.currentPage().getParameters().put('firm','NextGen Reporting');
           CommunityLandingPageCntrl cntrl  = new CommunityLandingPageCntrl();
           cntrl.setupCommunityFirm();
           cntrl.forwardToStartPage();
       }
  }
}