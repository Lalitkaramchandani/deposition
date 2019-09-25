/**
 * @author Karthik Bhat K.
 * @date 2019-08-19
 * @see https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_scheduler.htm
 * @description Runs a scheduled job daily to fetch case information from UniCourt for cases that have been filed exactly before 62 days from today.
 * ScheduleGetUniCourtCaseTest contains unit test 
 */
global class ScheduleGetUniCourtCase implements Schedulable {
    
    global Set<String> setUniCourtCaseIds = new Set<String>();
    
    // Seconds: 0
    // Minutes: 0
    // Hours: 7
    // Day_of_month: *
    // Month: *
    // Day_of_week: ?
    // Optional_year: 
    // Runs every day at 7 A.M.
    public static String CRON_EXP = '0 0 7 * * ?';
    
    public Integer numberOfDaysToNegate = 62;
    
    /**
     * @author Karthik Bhat K.
     * @date 2018-08-19
     * @description Negates number of days specified from Today and sends back the date obtained
     * @param Int numberOfDaysToNegate
     * @return date
     */
    public date getUniCourtCaseFilingDateToFetch(Integer numberOfDaysToNegate) {
        Integer noOfDaysToNegate = 0 - numberOfDaysToNegate;
        Date d = system.today().addDays(noOfDaysToNegate);
        return d;
    }
    
    /**
     * @author Karthik Bhat K.
     * @date 2018-08-19
     * @description Find unicourt case ids of all those cases which were filed exactly 62 days before from today.
     * @param Date unicourtCaseFilingDate
     * @return Integer numberOfUniCourtCaseIds
     */
    public Integer setUniCourtCaseIdsForFilingDate() {
		// Sandbox has only one case for the below specified date. To reduce get/case API calls to 1, uncomment below line and use it.
		// Date unicourtCaseFilingDateTest = Date.newInstance(2018, 12, 10);
        // List<Case_Leads__c> caseLeads = [SELECT Unicourt_Case_ID__c FROM Case_Leads__c WHERE Filing_Date__c=:unicourtCaseFilingDateTest AND Unicourt_Case_ID__c!=NULL];
        Date unicourtCaseFilingDate = this.getUniCourtCaseFilingDateToFetch(this.numberOfDaysToNegate);
        List<Case_Leads__c> caseLeads = [SELECT Unicourt_Case_ID__c FROM Case_Leads__c WHERE Filing_Date__c=:unicourtCaseFilingDate AND Unicourt_Case_ID__c!=NULL];
        for (Case_Leads__c caseLead : caseLeads) {
            this.setUniCourtCaseIds.add(caseLead.Unicourt_Case_ID__c);
        }

        return this.setUniCourtCaseIds.size();
    }

    /**
     * @see https://help.salesforce.com/articleView?id=code_schedule_batch_apex.htm&type=5
     * @author Karthik Bhat K.
     * @date 2018-08-19
     * @description Executes the scheduledJob
     */
    global void execute(SchedulableContext schedulableContext) {
		this.setUniCourtCaseIdsForFilingDate();

        System.debug('Executing leadGenCaseBatch!');
        LeadGenCaseBatch leadGenCaseBatch = new LeadGenCaseBatch(this.setUniCourtCaseIds);
        Database.executeBatch(leadGenCaseBatch, 50);
    }
}