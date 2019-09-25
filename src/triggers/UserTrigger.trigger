/**************************************************
                Name        : UserTrigger 
                Purpose     : User object trigger
                Created Date: 12 JUNE 2016
                
                Modification History:
*****************************************************/
trigger UserTrigger on User (before insert, before update) {
    new UserTriggerHandler().run();
}