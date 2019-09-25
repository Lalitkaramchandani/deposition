/*
* Name   	:   ContactAndAccountsMatchWebhookCntrl
* Author  	:   Jitendra
* TestClass :   ContactAndAccountsMatchWebhookCntrlTest
*/
public class ContactAndAccountsMatchWebhookCntrl {
	 String json;
     public void init(){
       try{
        json = ApexPages.currentpage().getParameters().get('data');
        
       AccConMatchParser parser = AccConMatchParser.parse(json);
       system.debug('parser.csv_file_link::: '+parser.csv_file_link);
       HttpRequest req = new HttpRequest();
            req.setMethod('GET');
            req.setEndpoint(parser.csv_file_link);
            //req.setEndpoint('https://s3.amazonaws.com/codaxtr.misc/codaxtr-central/production/nextgen/client_data/2019-04-22/UC_Lexitas_Account_Federal_Match_20190214_to_20190221.csv');
            req.setTimeout(60*1000);
            
            Http h = new Http();
            String resp;
            HttpResponse res = h.send(req);
            resp = res.getBody();
			system.debug('resp::'+resp);
			integer maxLen;
			if(Test.isRunningTest()){
				maxLen = 400;
			}else{
				maxLen = 125000;
			}
			
			integer len = resp.length();
			List<Unicourt_Case_Lead_JSON__c> csvRecList = new List<Unicourt_Case_Lead_JSON__c>();
			integer remainingChar = len;
			integer offSet = maxLen;
			integer startOfRow = resp.indexOf('\n') + 1;
			String headers = resp.substring(0, resp.indexOf('\n'))+'\n';
			while(remainingChar > maxLen){
				offset = resp.indexOf('\n', offset);
				String tempCSV = resp.substring(startOfRow, offset);
				Unicourt_Case_Lead_JSON__c csv = new Unicourt_Case_Lead_JSON__c();
				csv.type__c = 'CSV';
				csv.JSON_String__c = headers + tempCSV;
				csvRecList.add(csv);
				startOfRow = offset+1;
				remainingChar = len - offset-1;
				offset = offset+maxLen;

			}
			if(remainingChar > 0){
				Unicourt_Case_Lead_JSON__c csv = new Unicourt_Case_Lead_JSON__c();
				csv.type__c = 'CSV';
				csv.JSON_String__c = headers + resp.substring(startOfRow, len-1);
				csvRecList.add(csv);
			}
			insert csvRecList;
			Webhook_Log__c log = new Webhook_Log__c ();
	        log.Details__c = json ;
	        log.Type__c ='Contact & Accounts match';
	        insert log;
			ParseUnicourtJSONandCreateCasesBatch pjcBatch = new ParseUnicourtJSONandCreateCasesBatch('CSV');
			Integer batchsize = Test.isRunningTest() ? 50 : 1;
			Database.executeBatch(pjcBatch, batchsize);
		}catch(Exception e){
			Webhook_Log__c log1 = new Webhook_Log__c ();
	        log1.Details__c = json ;
	        log1.Type__c ='Contact & Accounts match';
	       
            Webhook_Log__c log = new Webhook_Log__c ();
            log.Details__c = e.getMessage() +' ; Stack Trace - '+e.getStackTraceString();
            system.debug('exception ::: '+log.Details__c);
            List<Webhook_Log__c> loglist = new List<Webhook_Log__c>();
            loglist.add(log);
            loglist.add(log1);

            //Database.RollBack(sp);
            insert loglist;
        }
    }
        
}