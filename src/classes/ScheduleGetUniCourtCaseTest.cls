@isTest
public class ScheduleGetUniCourtCaseTest {

    @isTest
    static void testGetUniCourtCaseFilingDateToFetch() {
        ScheduleGetUniCourtCase scheduleGetUniCourtCase = new ScheduleGetUniCourtCase();
        Date d = scheduleGetUniCourtCase.getUniCourtCaseFilingDateToFetch(scheduleGetUniCourtCase.numberOfDaysToNegate);
        Date today = System.today();
        Integer numberOfDaysToNegate = 0 - scheduleGetUniCourtCase.numberOfDaysToNegate;
        Date negatedDate = today.addDays(numberOfDaysToNegate);
        System.assertEquals(negatedDate, d);
    }
    
    @testSetup
    static void setup() {
        Date today = System.today();
        ScheduleGetUniCourtCase scheduleGetUniCourtCase = new ScheduleGetUniCourtCase();
        Integer numberOfDaysToNegate = 0 - scheduleGetUniCourtCase.numberOfDaysToNegate;
        Date filingDate = today.addDays(numberOfDaysToNegate);
        List<String> uniCourtCaseIds = new List<String>();
        uniCourtCaseIds.add('EE6BAFA3EY6C4ED5MEUVO7CVLBDAI1001');
        uniCourtCaseIds.add('E5BBMGRBFRBDIFUDM4XV3BTAMVFAW1016');
        
        // Creating a fresh dataSet so that the tests don't have to depend on the actual data from the database.
        for (Integer i = 0; i < uniCourtCaseIds.size(); i++) {
        	Case_Leads__c cLead = new Case_Leads__c();
        	cLead.Filing_Date__c = filingDate;
        	cLead.Unicourt_Case_ID__c = uniCourtCaseIds[i];
        	insert cLead;
        }
    }
    
    @isTest
    static void testSetUniCourtCaseIdsForFilingDate() {
        ScheduleGetUniCourtCase scheduleGetUniCourtCase = new ScheduleGetUniCourtCase();
        
        // Prep for expected results.
        Date today = System.today();
        Integer numberOfDaysToNegate = 0 - scheduleGetUniCourtCase.numberOfDaysToNegate;
        Date negatedDate = today.addDays(numberOfDaysToNegate);
        List<Case_Leads__c> caseLeads = [SELECT Unicourt_Case_ID__c FROM Case_Leads__c WHERE Filing_Date__c=:negatedDate];
        
        Set<String> unicourtCaseIds = new Set<String>();
        for (Case_Leads__c caseLead : caseLeads) {
            unicourtCaseIds.add(caseLead.Unicourt_Case_ID__c);
        }

        Integer sizeOfUniCourtCaseIds = scheduleGetUniCourtCase.setUniCourtCaseIdsForFilingDate();

        // Compare number of entries in database and returned by the function setUniCourtCaseIdsForFilingDate
        System.assertEquals(caseLeads.size(), sizeOfUniCourtCaseIds);
        
        // Compare the actual data in database and unicourt case ids set by the function setUniCourtCaseIdsForFilingDate
        System.assertEquals(unicourtCaseIds, scheduleGetUniCourtCase.setUniCourtCaseIds);
    }
}