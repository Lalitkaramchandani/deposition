/**************************************************
                Name        : TestUserTrigger
                Author      : Rajendra Rathore
                Purpose     : Test class for User object trigger
                Created Date: 12 JULY 2016
                
                Modification History:
*****************************************************/
@isTest
public  class TestUserTrigger{
  @isTest
  private static void Test_UserTrigger(){
       insert TestUtility.createFirm('NextGen Reporting');
       TriggerHandler TriggerHandler = new TriggerHandler();
       TriggerHandler.setTriggerContext(null,true);
       TriggerHandler.afterInsert();
       TriggerHandler.afterUpdate();
       TriggerHandler.afterDelete();
       TriggerHandler.afterUndelete();
       TriggerHandler.beforedelete();
       TriggerHandler.beforeinsert();
       TriggerHandler.beforeupdate();
       TriggerHandler.run();
       User usr = TestUtility.createCommunityUser();
       system.runAs(usr){
           update usr;
       }
  }
}