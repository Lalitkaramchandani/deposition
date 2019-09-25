/**
                                    Name             : TestCommunitiesCalendarCntrl
                                    Date             : 05 Jan 2016
                                    Descripition     : Test Class for CommunitiesCalendarCntrl class.
*/                                   
@isTest
private class TestCommunitiesCalendarCntrl{

    @isTest
    private static void Test_CommunitiesCalendarCntrl() {
       
        TestUtils tUtils = new TestUtils();
        Deposition__c deposition = tUtils.createDeposition();
        deposition.Deposition_Date__c = System.today();
        
        Test.StartTest();
            CommunitiesCalendarCntrl cntrl = new CommunitiesCalendarCntrl();
            String dt = system.today().month()+'/'+system.today().day()+ '/'+system.today().year();
            for(Deposition__c  dep :cntrl.lstDepositions ){
                
                dep.Primary_CR_Firm__c = 'Nextgen Reporting';
            }
               
            cntrl.saveDepositions();
            CommunitiesCalendarCntrl.eventdata('','','Show all Jobs','');
            
            CommunitiesCalendarCntrl.eventdata(dt,dt,'test','NextGen Reporting');
            
       Test.StopTest();
    }


}