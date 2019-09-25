/**************************************************
                Name        : TestPortalExtn
                Author      : Rajendra Rathore
                Purpose     : Test class for PortalExtn Apex class
                Created Date: 10 JULY 2016
                
                Modification History:
*****************************************************/
@isTest
public  class TestPortalExtn{
  @isTest
  private static void Test_PortalExtn(){
       Deposition__c  depo=TestUtility.createDeposition(null);
       depo.Case_Name__c = 'Test Case';
       insert depo;
       PageReference pageRef = new PageReference('/apex/Portal');
       ApexPages.currentPage().getParameters().put('id', depo.id);
       Test.setCurrentPage(pageRef);
       
       system.runAs(TestUtility.createCommunityUser()){
           Cookie cookie = new Cookie('firmCookie', 'NextGen Reporting', null, -1, false);
           ApexPages.currentPage().setCookies(new Cookie[]{cookie});
           ApexPages.StandardController SCont = new ApexPages.StandardController(depo);
           
           PortalExtn ext = new PortalExtn (SCont);
           ext.depSearchText = depo.Case_Name__c;
           ext.searchDepositionsRecord();
           ext.saveDeposition();
           ext.confirmDeposition();
       }
  }
}