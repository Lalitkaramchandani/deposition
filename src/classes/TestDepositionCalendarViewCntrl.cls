/**
                                    Name             : TestDepositionCalendarViewCntrl
                                    Date             : 05 Jan 2016
                                    Descripition     : Test Class for DepositionCalendarViewCntrl class.
*/                                   
@isTest
private class TestDepositionCalendarViewCntrl{

    @isTest
    private static void Test_DepositionCalendarViewCntrl() {
       
        TestUtils tUtils = new TestUtils();
        Deposition__c deposition = tUtils.createDeposition();
        deposition.Deposition_Date__c = System.today();
        
        Test.StartTest();
            DepositionCalendarViewCntrl  cntrl = new DepositionCalendarViewCntrl ();
            String dt = system.today().month()+'/'+system.today().day()+ '/'+system.today().year();
            for(Deposition__c  dep :cntrl.lstDepositions ){
                
                dep.Primary_CR_Firm__c = 'Nextgen Reportin';
            }
               
            cntrl.saveDepositions();
            DepositionCalendarViewCntrl.eventdata('','','Show all Jobs','');
            
            DepositionCalendarViewCntrl.eventdata(dt,dt,'test','NextGen Reporting');
            
       Test.StopTest();
    }


}