/**************************************************
                Name        : RepresentationTrigger 
                Purpose     : Representation object trigger
                Created Date: 17 APRIL 2018
                
                Modification History:
*****************************************************/
trigger RepresentationTrigger on Representation__c (before insert, before update) {
    new RepresentationHandler().run();
}