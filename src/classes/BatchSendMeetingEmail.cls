global with sharing class BatchSendMeetingEmail implements Database.Stateful,Database.Batchable<sObject>
{
 global string query;
 global Set<string> DepositionSet=new Set<string>();
 Date todayDate = date.today();
  global Database.QueryLocator start(Database.BatchableContext BC)   
  {
  
    return Database.getQueryLocator('Select name,id,notification_date__c,Deposition_Time__c,Deposition_Date__c,Account__c,Accounting_Email_Address__c,BIlled__c,Billing_Notes__c,Business_Days_Until_Transcript_is_Due__c,Cancelled_Date__c,Cancelled_Time__c,Case_Name__c,Change_Log__c,Claims_Professional__c,Client_Notes__c,Completed_By__c,Confirm__c,Confirm_Client__c,Confirm_Reporter__c,Confirm_Video_Tech__c,Court_Reporter_Count__c,OwnerId,GuestEmail__c,CR_Email_Address__c,Day_Of_The_Week__c,Day_Of_The_Week_Transcript_Due__c,Days_Until_Transcript_Due_Date__c,createddate from Deposition__c where notification_date__c =: todayDate and DAY_ONLY(createddate)=:todaydate' );  
  }
  
   global void execute(Database.BatchableContext BC,  List<Deposition__c> DepositionList){ 
   list<String>listOfAddresses=new list<String>();
   List<Deposition__c> depUpdateList=new List<Deposition__c>();
   EmailTemplate et = [select Id,Name,Subject,body from EmailTemplate where name =:'XX - Last Minute Booking Via Website'];
       if(et!=null)
       {
       system.debug('!!!!!!!!!!!depositionset!!!!!!!!!!!'+depositionlist);
           for(Deposition__c dep:DepositionList)
           {
                 listOfAddresses.add('jprimuth@nextgenreporting.com');
                 ID whatID = dep.id;
                 Contact cnt = [select id, Email from Contact where email != null limit 1];
                 List<Messaging.SingleEmailMessage> msgList= new List<Messaging.SingleEmailMessage>();
                 Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
                 msg.setTemplateId( et.id );
                 msg.setTargetObjectId(cnt.id);
                 msg.setWhatId(whatID);
                 
                 msg.setToAddresses(listOfAddresses);
                 msgList.add(msg);
                // Send the emails in a transaction, then roll it back
                Savepoint sp = Database.setSavepoint();
                 if (!Test.isRunningTest())
                    Messaging.sendEmail(msgList); // Dummy email send   
                 Database.rollback(sp); // Email will not send as it is rolled Back
                // Send Actual email
                OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'schedule@nextgenreporting.com'];

                 List<Messaging.SingleEmailMessage> msgListToBeSend = new List<Messaging.SingleEmailMessage>();
                 for (Messaging.SingleEmailMessage email : msgList) {
                     Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
                     emailToSend.setToAddresses(email.getToAddresses());
                     if ( owea.size() > 0 ) {
                      emailToSend.setOrgWideEmailAddressId(owea.get(0).Id);
                      }
                     emailToSend.setPlainTextBody(email.getPlainTextBody());
                     emailToSend.setHTMLBody(email.getHTMLBody());
                     emailToSend.setSubject(email.getSubject());
                     emailToSend.setSaveAsActivity(true);
                     msgListToBeSend .add(emailToSend);
                 }
                 if (!Test.isRunningTest())
                    Messaging.sendEmail(msgListToBeSend);
                    
               
                
           }
           
       }
   }
   
   global void finish(Database.BatchableContext info){
        
    }
    
}