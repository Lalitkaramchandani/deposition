@isTest
private class TestSendConfirmationEmailCtlr {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        Set<String> depIds=new Set<String>();
        TestFactory tFact = new TestFactory();
        List<Deposition__c> depositions = tFact.depositions;
        List<Attendee__c> attendees = tFact.attendees;
        System.debug([SELECT id,name from Firm__c]);
        Deposition__c dep = [select Primary_Court_Reporting_Firm__r.Name, name,Event_Type__c,Deposition_Status__c,Deposition_Time__c,Deposition_Date__c,Time_Zone__c,Event_Location__c
                            ,(select id,Name,Contact__c,Contact__r.Name,Contact__r.Email,Role__c,Deposition__r.Confirm_Reporter__c,
                            Deposition__r.Confirm_Client__c,Deposition__r.Confirm_Video_Tech__c,IsDeleted,Primary_Attorney__c 
                            From Deposition_Roles__r WHERE Role__c IN ('Scheduler','Court Reporter','Videographer/Technician') AND Contact__r.Email!= NULL)
                            from Deposition__c where Id=:depositions[1].Id
                            LIMIT 1];
        System.debug(dep);
        System.debug(dep.Primary_Court_Reporting_Firm__r);
        System.debug(depositions[1].Primary_Court_Reporting_Firm__c);
        System.debug([SELECT id,name from Firm__c where id=:depositions[1].Primary_Court_Reporting_Firm__c]);
        
        SendConfirmationEmailCtlr cntrl = new SendConfirmationEmailCtlr();
        cntrl.dummydeposition=depositions[1];
        cntrl.selectedFirm = dep.Primary_Court_Reporting_Firm__r.Name;
        cntrl.actionmethod();
        cntrl.lstDepositionsModel.add(new SendConfirmationEmailCtlr.DepositionModel(dep));
        cntrl.sendEmail();
        cntrl.cancel();
        Test.startTest();
        
    }
}