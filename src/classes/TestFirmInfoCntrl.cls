/**************************************************
                Name        : TestFirmInfoCntrl
                Author      : Rajendra Rathore
                Purpose     : Test class for FirmInfoCntrl Apex class
                Created Date: 11 JULY 2016
                
                Modification History:
*****************************************************/
@isTest
public  class TestFirmInfoCntrl{
  @isTest
  private static void Test_FirmInfoCntrl(){
       insert TestUtility.createFirm('NextGen Reporting');
       Cookie Cookie= new Cookie('firmCookie', 'NextGen Reporting',null,-1,false);
       ApexPages.currentPage().setCookies(new Cookie[]{Cookie});
       FirmInfoCntrl cntrl = new FirmInfoCntrl();
       cntrl.getFirm();
  }
}