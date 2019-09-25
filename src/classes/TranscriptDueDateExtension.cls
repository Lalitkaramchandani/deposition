public class TranscriptDueDateExtension {
   
    private Deposition__c deposition;
    public TranscriptDueDateExtension(ApexPages.StandardController controller) {
    	deposition = (Deposition__c)controller.getRecord();
      computeDate();
    }
    
    private void computeDate() {
      BusinessHours bh = [SELECT Id FROM BusinessHours WHERE IsDefault=true];
      // Create Datetime on May 28, 2008 at 1:06:08 AM in local timezone.
      Datetime startTime = Datetime.newInstanceGMT(System.today().year(),System.today().Month(), System.today().day());
      Date dt = deposition.Transcript_Due_From_Reporter_Computed__c;
      
      if(dt == null) return;
      
      Datetime endTime = Datetime.newInstanceGMT(dt.Year(), dt.Month(), dt.Day());
      
      Long diff = BusinessHours.diff(bh.id, startTime, endTime); //Milliseconds
      deposition.Days_Until_Transcript_Due_Computed__c = diff / (24l * 60 * 60 * 1000l);
    }
    
    @isTest
    private static void Test_TranscriptDueDateExtension() {
      TestUtils utils = new TestUtils();
      Deposition__c deposition = utils.createDeposition();
      
      deposition = [SELECT Transcript_Due_From_Reporter_Computed__c,Days_Until_Transcript_Due_Computed__c FROM 
                    Deposition__c Limit 1];
      
      ApexPages.StandardController sController = new ApexPages.StandardController(deposition);
      TranscriptDueDateExtension textension = new TranscriptDueDateExtension(scontroller);
    }

}