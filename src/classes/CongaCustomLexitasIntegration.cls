/**
        Name            :    Conga Integration
        Description     :    Class to integrate CONGA API and Send Emial using conga
        Date            :    11 may 2019
        Developer       :    Lalit karamchandani // lalitkaramchandani27@gmail.com //skype lalit.karamchandani93
*/
public class CongaCustomLexitasIntegration{

   
    public static String congaSendMailBackgroundMode(String idz,String contactId, String sTemplateId, String sEmailTemplateId, String subject, String filename,String fromaddress, String AttParentID,String sQueryId, String pvz) {
                    
        String sessId = UserInfo.getSessionId();
        String servUrl = Url.getSalesforceBaseUrl().toExternalForm() + '/services/Soap/u/37.0/' + UserInfo.getOrganizationId();
        system.debug('*** sessId ' + sessId);
        system.debug('*** servUrl ' + servUrl);
        String url2 = 'https://composer.congamerge.com/composer8/index.html' +
            '?sessionId=' + sessId +
            '&serverUrl=' + EncodingUtil.urlEncode(servUrl, 'UTF-8');
    
        if (String.isNotBlank(idz)) {
            url2 += '&id=' + idz;
        }
        if(String.isNotBlank(contactId)){
            url2 += '&EmailToId=' + contactId;
        
        }
        if (String.isNotBlank(sTemplateId)) {
            url2 += '&TemplateId=' + sTemplateId;
        }
        if (String.isNotBlank(subject)) {
            subject=EncodingUtil.urlEncode(subject, 'UTF-8');
            url2 += '&EmailSubject=' + subject;
        }
        
        if (String.isNotBlank(sEmailTemplateId)) {
            url2 += '&EmailTemplateId=' + sEmailTemplateId;
        }
        if (String.isNotBlank(fromaddress)) {// must check first Organization-Wide Email Address profile is assigned.
            url2 += '&EmailFromID=' + fromaddress;
        }
        if (String.isNotBlank(sQueryId) && String.isNotBlank(pvz)) {
            url2 += '&QueryId=' + sQueryId + '?pv0=' + pvz;
        }
        if (String.isNotBlank(filename)) {
            filename=EncodingUtil.urlEncode(filename, 'UTF-8');
            //filename = filename.replace(' ', '%20');
            system.debug('*** filename ' + filename);
            url2 += '&OFN=' + filename;
        }
    
        url2 += '&SC0=1&SC1=Attachments';
        if (String.isNotBlank(AttParentID)) {
            url2 += '&AttachmentParentID=' + AttParentID;
        }
        url2 +='&defaultPDF=1' +
        '&DS7=12' +
        '&APIMODE=12';
    
    
        System.debug('***URL ' + url2);
    
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url2);
        req.setMethod('GET');
        req.setTimeout(60000);
        // Send the request, and return a response
        HttpResponse res = http.send(req);
    
        System.debug('*** $$$ ' + res);
        System.debug('*** $$$ getStatus ' + res.getStatus());
        System.debug('*** $$$ getBody ' + res.getBody());
    
        return res.getStatus() + ' => ' + res.getBody();


    }
    public static String sendMailToCourtReporter(string depositionId,string attendeeId,string contactId){
        if(string.isNotBlank(depositionId) && string.isNotBlank(attendeeId) && string.isNotBlank(contactId)){
            String SfEmailTemplateID = Label.SalesforceEmailTemplateID;
            String rr='';
            if(string.isNotBlank(SfEmailTemplateID)){
                rr =congaSendMailBackgroundMode(depositionId,contactId,'a1z2K0000011Rtw',SfEmailTemplateID,'','Transcript','',contactId,'a1r2K000007ObAX',attendeeId);
                system.debug('###rr '+rr);
             }
            return rr;
                
        }else{
            return null;
        }
        
    }  
}