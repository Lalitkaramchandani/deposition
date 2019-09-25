/**************************************************
                Name        : TestCommunitiesUserAccountUpdateCntrl
                Author      : Rajendra Rathore
                Purpose     : Test class for CommunitiesUserAccountUpdateCntrl Apex class
                Created Date: 11 JULY 2016
                
                Modification History:
*****************************************************/
@isTest
public  class TestCommunitiesUserAccountUpdateCntrl{
  @isTest
  private static void Test_CommunitiesUserAccountUpdateCntrl(){
       CommunitiesUserAccountUpdateCntrl cntrl = new CommunitiesUserAccountUpdateCntrl();
       cntrl.save();
       system.runAs(TestUtility.createCommunityUser()){
           cntrl = new CommunitiesUserAccountUpdateCntrl();
           
       }
  }
}