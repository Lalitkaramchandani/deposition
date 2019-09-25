Global class ManageCaseFollowers {
    Webservice static string addFollower(String caseLeadId, String userId){
        List<Case_Follower__c> cfList = [select id from case_follower__c where user__c=:userId and case_lead__c = :caseLeadId limit 1];
        if(cfList.size() > 0){
            return 'You are already following this case';
        }
        
        insert new Case_Follower__c(user__c = userId, case_lead__c = caseLeadId);
        addCaseTracking(caseLeadId);
        return 'You are now following this case'; 
    }
    
    Webservice static string updateUnicourtCase(String caseLeadId){
        
        String calloutMsg = updateUnicourtCaseCallout(caseLeadId); 
        if(calloutMsg.equalsIgnoreCase('Case is requested for Update.')){
            setUpdateRequestStatus(caseLeadId);
        }
        return calloutMsg;
    }
    
    @future
    public static void setUpdateRequestStatus(String UnicourtCaseId){
        Case_Leads__c clead = new Case_Leads__c(Update_Request_Status__c='Queued for Update', Uni_UpdateRequestedOn__c = System.now(), Unicourt_Case_ID__c = UnicourtCaseId);
        upsert clead Unicourt_Case_ID__c;
    }
    public static void addCaseTracking(String caseLeadId){
        List<String> unicourtIdList = new List<String>();
        List<Case_Leads__c> caseList = [select Unicourt_Case_ID__c, BeingTracked__c from Case_Leads__c where id = :caseLeadId limit 1];
        if(caseList != null && caseList.size() > 0 && !caseList[0].BeingTracked__c){
            unicourtIdList.add(caseList[0].Unicourt_Case_ID__c);
            addCasesTracking(unicourtIdList);
        }
    }
    
    public static String updateUnicourtCaseCallout(String unicourtCaseId){
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        string endPoint = 'https://api.unicourt.com/rest/v1/updateCase/'+unicourtCaseId+'/?token=2a8c48f7019a286dae3ddd7f43a96622a9ccc669';
        req.setEndpoint(endPoint);
        req.setTimeout(60*1000);
        system.debug('unicourtCaseId:::'+unicourtCaseId);
        //req.setBody('case_ids='+stringCaseIds);
        //req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        Http h = new Http();
        String resp;
        HttpResponse res = h.send(req);
        resp = res.getBody();
        system.debug('response:: '+resp);
        if(res.getStatusCode() == 200){
            return 'Case is requested for Update.';
        }
        return 'Something went wrong please try after some time or contact Admin.';
    }
    
    @future(Callout = true)
    public static void addCasesTracking(List<String> unicourtCaseIds){
        String stringCaseIds = '';
        for(string csId: unicourtCaseIds){
            if(stringCaseIds !='')
                stringCaseIds +=',';
            stringCaseIds += csId;
        }
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        string endPoint = 'https://api.unicourt.com/rest/v1/trackCases/add/?token=2a8c48f7019a286dae3ddd7f43a96622a9ccc669';
        req.setEndpoint(endPoint);
        req.setTimeout(60*1000);
        system.debug('stringCaseIds:::'+stringCaseIds);
        req.setBody('case_ids='+stringCaseIds);
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        Http h = new Http();
        String resp;
        HttpResponse res = h.send(req);
        resp = res.getBody();
        system.debug('response:: '+resp);
    }
    
    @InvocableMethod
    public static void removeCaseTracking(List<String> caseIds){
        List<Case_Leads__c> lstCases= [select Id,Unicourt_Case_ID__c FROM Case_Leads__c WHERE ID  IN:caseIds ];
        List<Id> followersIdList = new List<Id>();
        List<Case_Follower__c> cfList = [select id,Case_Lead__r.Unicourt_Case_ID__c,User__c from case_follower__c where case_lead__c = :caseIds[0]];
        if(cfList.size()>0){
            /*for(Case_Follower__c follower : cfList){
                followersIdList.add(follower.User__c);
            }*/
            delete cfList;
            
            
        }
        List<String>unicourtCaseIds = new List<String>();
        
        if(lstCases.size()>0){
            for(Case_Leads__c caseLead : lstCases){
                unicourtCaseIds.add(caseLead.Unicourt_Case_ID__c);
            }
            removeCasesTrackingCallout(unicourtCaseIds);
        }
        notifyFollowersForCaseClose(caseIds);
        
    }
    
    @future(Callout = true)
    public static void removeCasesTrackingCallout(List<String> unicourtCaseIds){
        String stringCaseIds = '';
        for(string csId: unicourtCaseIds){
            if(stringCaseIds !='')
                stringCaseIds +=',';
            stringCaseIds += csId;
        }
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        string endPoint = 'https://api.unicourt.com/rest/v1/trackCases/remove/?token=2a8c48f7019a286dae3ddd7f43a96622a9ccc669';
        req.setEndpoint(endPoint);
        req.setTimeout(60*1000);
        system.debug('stringCaseIds:::'+stringCaseIds);
        req.setBody('case_ids='+stringCaseIds+'&folder_id=2');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        Http h = new Http();
        String resp;
        HttpResponse res = h.send(req);
        resp = res.getBody();
        system.debug('response:: '+resp);
    }
    
    public static void notifyFollowersForCaseClose(List<String> caseLeadIDs){
        
        //EmailTemplate et = [select id, name,DeveloperName from EmailTemplate where DeveloperName = 'Case_Closed_Notification' limit 1];
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
        for(Case_Leads__c clead : [select id,Case_Name__c,Case_Status__c, (select id, User__c, User__r.email, User__r.name  from Case_Followers__r) from Case_Leads__c where Id in :caseLeadIDs]){
            for(case_follower__c cf : clead.Case_Followers__r){
                system.debug('CFF::'+cf);
                if(cf.user__c != null){
                    String subjectString = 'Case Update - '+clead.Case_Name__c;
                    String emailBody = 'Dear '+cf.User__r.name+',\n';
                    emailBody = emailBody + 'The matter of "'+clead.Case_Name__c+'" is no longer active. The status of the case was changed to "'+clead.Case_Status__c+'" on '+System.now()+'.\n';
                    emailBody = emailBody + 'The case is still visible here: '+System.Url.getSalesforceBaseUrl().toExternalForm()+'/'+clead.Id;
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                    message.setTargetObjectId(cf.user__c);
                    message.setSubject(subjectString);
                    message.setPlainTextBody(emailBody);
                    messages.add(message);
                }
            }
        }
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);   
        
    } 
}