/**************************************************
                Name        : TwilioRestResource
                Author      : Lalit karamchandani
                Purpose     : Webhook for twilio post request callback
                Created Date: 02 May 2019
                
                
*****************************************************/
@RestResource(urlMapping='/twilio/*')
global with sharing class TwilioRestResource {

    // https://dev-nextgentest.cs11.force.com/services/apexrest/twilio
    
    //https://demo.twilio.com/welcome/sms/reply/
    @HttpPost
    global static void handleTwilio() {
        
        RestRequest req = RestContext.request;
        Map<String, String> params;
        if(!Test.isRunningTest())
            params = req.params;
        else{
            params= getMockParams(); 
        }
        // if(params!=NULL){
        processMessageForNotification(params);
        // }
    }
    
    public static void processMessageForNotification(Map<String, String> params){
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.toAddresses = new String[] { 'lalitkaramchandani27@gmail.com', 'jason.primuth@lexitaslegal.com'};
            String nextTwoLine='<br/><br/>';
        String nextLine='<br/>';
        String htmlText='Hi team,'+nextTwoLine;
        
        htmlText+='Got a message from a customer, here are the details as following:'+nextTwoLine;
        htmlText+='A message comes from the number <b>'+ params.get('From') + '</b> with Following message'+nextLine;
        htmlText+='<p style="padding-left: 1.8em">'+params.get('Body')+'</p>'+nextLine;
        htmlText+='Kindly Contact them regarding the message for more details'+nextTwoLine;
        htmlText+= 'Thanks!'+nextLine+'Team Deposition Support!';
        
        email.optOutPolicy = 'FILTER';
        email.subject = 'Message received';
        email.htmlBody = htmlText;
        
        Messaging.SingleEmailMessage[] messages = 
            new List<Messaging.SingleEmailMessage> {email};
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        if (results[0].success) {
            System.debug('The email was sent successfully.');
        } else {
            System.debug('The email failed to send: '
                         + results[0].errors[0].message);
        }
    }
    
    public static Map<String, String> getMockParams(){
        return new Map<String, String>{
            'ApiVersion'=>'2010-04-01',
            'SmsSid'=>'SMf8afcd3aa0d8f4335dc590e8b7ec898a',
            'SmsMessageSid'=>'SMf8afcd3aa0d8f4335dc590e8b7ec898a',
            'MessageSid'=>'SMf8afcd3aa0d8f4335dc590e8b7ec898a',
            'AccountSid'=>'AC35d15f806bff855c79eabd016e03107e',
            
            'NumSegments'=>'1',
            'SmsStatus'=>'received',
            
            'FromCountry'=>'US',
            'FromState'=>'CA',
            'FromCity'=>'SEAL BEACH',
            'FromZip'=>'90815',
            
            'ToCountry'=>'US',
            'ToState'=>'',
            'ToCity'=>'',
            'ToZip'=>'',
            
            'Body'=>'Thank you for confirming the deposition on 4/27/2019 at 8 AM Eastern. The deposition will occur at 123 Main St. St. Pete, FL 45678. Once you arrive at the deposition, please click this link to check in: http://dev-nextgen.cs11.force.com/OnSiteConfirmation?depositionId=a06Z000000I923lIAB&contactId=003Z000000xAGpmIAG',
            'NumMedia'=>'0',
            'From'=>'+15623143087',
            'To'=>'+18779595275'
        };
    }
// TWilio request params
/*
    new Map<String, String>{
        'ApiVersion'=>'2010-04-01',
        'SmsSid'=>'SMf8afcd3aa0d8f4335dc590e8b7ec898a',
        'SmsMessageSid'=>'SMf8afcd3aa0d8f4335dc590e8b7ec898a',
        'MessageSid'=>'SMf8afcd3aa0d8f4335dc590e8b7ec898a',
        'AccountSid'=>'AC35d15f806bff855c79eabd016e03107e',
        
        'NumSegments'=>'1',
        'SmsStatus'=>'received',
        
        'FromCountry'=>'US',
        'FromState'=>'CA',
        'FromCity'=>'SEAL BEACH',
        'FromZip'=>'90815',
        
        'ToCountry'=>'US',
        'ToState'=>'',
        'ToCity'=>'',
        'ToZip'=>'',
        
        'Body'=>'Thank you for confirming the deposition on 4/27/2019 at 8 AM Eastern. The deposition will occur at 123 Main St. St. Pete, FL 45678. Once you arrive at the deposition, please click this link to check in: http://dev-nextgen.cs11.force.com/OnSiteConfirmation?depositionId=a06Z000000I923lIAB&contactId=003Z000000xAGpmIAG',
        'NumMedia'=>'0',
        'From'=>'+15623143087',
        'To'=>'+18779595275'
    }
*/
}