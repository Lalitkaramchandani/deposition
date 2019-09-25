/**
        Name            :    TwilioIntegration
        Description     :    Class to integrate Twilio API and Send SMS using custom Setting
        Date            :    11 Jan 2019
        Developer       :
*/
public class TwilioIntegration{

    //Required parameters
    private static final String VERSION = '3.2.0';
    private static final String endpoint = 'https://api.twilio.com';
    private static final String DEFAULT_VERSION = '2010-04-01';
    
    private static Twilio_Configuration__c twilioConfig;
    
    //Method to Send SMS accepts two parameters "To phone number" and "SMS body" as string
    @Future(callout=true)
    public static void sendSMS( String toPhoneNumber, String msgBody ){
    
        if( String.isNotEmpty( toPhoneNumber ) && String.isNotEmpty( msgBody ) ){
            
            toPhoneNumber = parsePhoneNumer(toPhoneNumber);
            twilioConfig = getTwilioConfiguration();
            
            if( twilioConfig != NULL && String.isNotEmpty( twilioConfig.Account_SID__c ) &&
                String.isNotEmpty( twilioConfig.Auth_Token__c ) && String.isNotEmpty( twilioConfig.From_Phone_Number__c ) ){
                
                //Call Twilio API
                callTwilioAPI( toPhoneNumber, msgBody);
            }
        }
        
        //return NULL;
    }
    
    //Make Rest Callout to Twilio API
    private Static MessageResponse callTwilioAPI( String toPhoneNumber, String msgBody ){
    
        //variable to hold the response
        String responseBody = '';
        MessageResponse smsRes = new MessageResponse();
        
        //Endpoint URL
        String path = endpoint + '/' + DEFAULT_VERSION + '/Accounts/' + twilioConfig.Account_SID__c + '/Messages.json';
        URL uri = new URL(path);
        
        //Create request body
        String entity = '';
        entity += (entity=='' ? '' : '&')+ 'To' + '=' + EncodingUtil.urlEncode( toPhoneNumber, 'UTF-8');
        entity += (entity=='' ? '' : '&')+ 'Body' + '=' + EncodingUtil.urlEncode( msgBody, 'UTF-8');
        entity += (entity=='' ? '' : '&')+ 'From' + '=' + EncodingUtil.urlEncode( twilioConfig.From_Phone_Number__c, 'UTF-8');
        
        //Initiallize http request
        Http h = new Http();
        HttpRequest request = new HttpRequest();
        
        //Append parameters to the request
        request.setHeader('X-Twilio-Client', 'salesforce-' + VERSION);
        request.setHeader('User-Agent', 'twilio-salesforce/' + VERSION);
        request.setHeader('Accept', 'application/json');
        request.setHeader('Accept-Charset', 'utf-8');
        request.setHeader('Authorization', 'Basic '+EncodingUtil.base64Encode(Blob.valueOf(twilioConfig.Account_SID__c + ':' + twilioConfig.Auth_Token__c)));
        request.setEndpoint(uri.toExternalForm());
        request.setMethod('POST');
        request.setBody(entity);
        
        //Check for is test running 
        if( !Test.isRunningTest() ) {              
            //Send request
            HttpResponse res = h.send(request);
            responseBody = res.getBody(); 
            System.debug(responseBody);
        } else {
            responseBody =  '{"sid":"SMba4ab2fafa3d709004359818f50a67eb","date_created":"Thu, 12 Dec 2013 15:13:06 +0000","date_updated":"Thu, 12 Dec 2013 15:13:06 +0000","date_sent":null,"account_sid":"ACfdd0fcec687020b86d09fa8451c4b614","to":"+919820242561","from":"+13047132065","body":"Hello there!","status":"queued","direction":"outbound-api","api_version":"2010-04-01","price":-0.01,"price_unit":"USD","uri":"/2010-04-01/Accounts/ACfdd0fcec687020b86d09fa8451c4b614/SMS/Messages/SMba4ab2fafa3d709004359818f50a67eb.json","num_segments":"1"}';
            
        }
        
        smsRes = (MessageResponse)JSON.deserialize(responseBody, MessageResponse.class);
        //Return response
        return smsRes;
    }
    
    //Get Twilio Account configuration
    private static Twilio_Configuration__c getTwilioConfiguration(){
        List<Twilio_Configuration__c> config = [SELECT Id, Account_Name__c, Account_SID__c, Auth_Token__c, From_Phone_Number__c, 
                Test_Account_SID__c, Test_Auth_Token__c FROM Twilio_Configuration__c 
                WHERE Name ='jason.primuth@lexitaslegal.com' ];
        if(!config.isEmpty()){
            return config[0];
        }
        if(Test.isRunningTest()){
            return TestFactory.twilios[0];
        }
        return null;
    }
    
    static String parsePhoneNumer(String toNumber){
        return toNumber.replaceAll('-','').replaceAll('-','').replaceAll(' ','').replaceAll('\\(','').replaceAll('\\)','');
    }
    
    //Wrapper class for response
    public class MessageResponse {
        public String status;
        public String message;
    }
}