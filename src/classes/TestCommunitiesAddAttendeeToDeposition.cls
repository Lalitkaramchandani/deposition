/**************************************************
                Name        : TestCommunitiesAddAttendeeToDeposition
                Author      : Rajendra Rathore
                Purpose     : Test class for CommunitiesAddAttendeeToDepositionCntrl Apex class
                Created Date: 20 NOV 2016
                
                Modification History:
*****************************************************/
@isTest
public  class TestCommunitiesAddAttendeeToDeposition{
  @isTest
  private static void Test_AddAttendeeToDeposition(){
       Deposition__c  depo=TestUtility.createDeposition(null);
       depo.Case_Name__c = 'Test Case';
       insert depo;
       system.runAs(TestUtility.createCommunityUser()){
           Cookie cookie = new Cookie('firmCookie', 'NextGen Reporting', null, -1, false);
           ApexPages.currentPage().setCookies(new Cookie[]{cookie});
           ApexPages.StandardController SCont = new ApexPages.StandardController(depo);
           ApexPages.currentPage().getParameters().put('id', depo.Case_Name__c);
           PortalExtn ext = new PortalExtn (SCont);
           ext.saveDeposition();
           CommunitiesAddAttendeeToDepositionCntrl cntrl = new CommunitiesAddAttendeeToDepositionCntrl ();
           cntrl.searchDepositions();
           cntrl.lstDepositions = new List<Deposition__c>();
           cntrl.lstDepositions.add(depo);
           cntrl.addToMyAccount();
           for(Deposition__c dep : cntrl.lstDepositions){
               //dep.IsDeleted = true;
           }
           cntrl.addToMyAccount();
       }
  }
}