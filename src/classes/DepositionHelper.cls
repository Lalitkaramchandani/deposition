/**
*                                    Name             : DepositionHelper
*                                    Date             : 06/02/2015
*                                    Description      : Helper Class for Deposition__c object Triggers
*/
public class DepositionHelper{
    public static Boolean isDepositiononAdjacentDaysWithDifferentCrEmailCalled = false;
    
    
    public static void blockDelete(List<Deposition__c>lstDeps){
        String profileId=userinfo.getProfileId();   
        List<Profile>lstProfiles = [Select Id,Name from Profile where Id=:profileId];
        
            
        if(lstProfiles.size()>0 &&  lstProfiles[0].Name =='New Platform'){
            for (Deposition__c preventDelete: lstDeps)
    
            {
                  preventDelete.addError('You don\'t have permission for delete Deposition. Please contact System Administrator.');
            }
    
    
        }
    }
    
    /** Create a folder in Google Drive and popuplate Folder Id in Deposition record
     */
    @future(Callout=true) 
    public static void populateGoogleDriveFolderId(String depositionsJson){
        List<Deposition__c> lstDeposition = (List<Deposition__c>)JSON.deserialize(depositionsJson, List<Deposition__c>.class);
        set<String>setStateNames = new Set<String>();
        List<Deposition__c>lstDepositionNeedUpdate = new List<Deposition__c>();
        String accessToken = '';
        if(Test.isRunningTest())
            accessToken = 'Testing';    
        else 
            accessToken =GoogleDriveAuthenticationCntrl.getAccessToken();

        for(Deposition__c dep : lstDeposition){
            try{
                HttpRequest req = new HttpRequest();
                req.setMethod('POST');
                req.setEndpoint('https://www.googleapis.com/drive/v2/files');
                req.setHeader('Authorization', 'Bearer '+accessToken);
                req.setHeader('content-type', 'application/json');
                
                String messageBody = '{'+
                  '"title": "' +dep.Name+'",'+
                  '"parents": [],'+
                  '"mimeType": "application/vnd.google-apps.folder"'+
                '}';
                req.setBody(messageBody);
                req.setTimeout(60*1000);
                
                Http h = new Http();
                String resp;
                HttpResponse res = new HttpResponse();
                if(Test.isRunningTest()){
                    String json=        '{'+
                    ' "id": "",'+
                    '}';
                    res.SetBody(json);
                }else
                    res = h.send(req);
                resp = res.getBody();
                lstDepositionNeedUpdate.add(new Deposition__c(Id=dep.id,Google_Drive_Folder_Id__c=GogoleDriveFolderParser.parse(resp).id));
            }Catch(Exception e ){
                System.debug('Error in Google Drive Create Folder'+e.getMessage());
            }
        }
        
        if(lstDepositionNeedUpdate.size()>0){
            update lstDepositionNeedUpdate;                                              
        }
    }
    
    
    /** Whenever Deposition Created or Updated then populate State Rule lookup value account state field
     */
    public static void populateStateRule(List<Deposition__c> lstDeposition,map<Id,Deposition__c>oldMap,Boolean isUpdate){
        set<String>setStateNames = new Set<String>();
        List<Deposition__c>lstDepositionNeedUpdate = new List<Deposition__c>();
        for(Deposition__c dep : lstDeposition){
            if(dep.State__c != NULL && (isUpdate == false || dep.State__c != oldmap.get(dep.id).State__c )){
                setStateNames.add(dep.State__c); 
                lstDepositionNeedUpdate.add(dep);
            }
            
        }
        
        if(setStateNames.size()>0){
            Map<String,Id>mapStateNameWithStateRuleId = new Map<String,Id>();
            for(State_Rules__c rule : [select id,Name From State_Rules__c WHERE Name IN:setStateNames]){
                mapStateNameWithStateRuleId.put(rule.Name.toLowerCase(),rule.id);
            }
            for(Deposition__c dep : lstDepositionNeedUpdate){
                if(mapStateNameWithStateRuleId.containsKey(dep.State__c.toLowercase()))
                    dep.State_Rule__c = mapStateNameWithStateRuleId.get(dep.State__c.toLowercase());
                
            }                                            
        }
    }
    
    /** Whenever Deposition Created or Updated By Community User then copy their related Contact.Reports To>Email Field 
        IN Assistant_Or_Boss_Email__c field
     */
    public static void updateDepostionAdminORBossEmail(List<Deposition__c> lstDeposition,map<Id,Deposition__c>oldMap,Boolean isUpdate){
        set<Id>setOwnerIds = new Set<Id>();
        for(Deposition__c dep : lstDeposition){
            if(isUpdate == false || (dep.OwnerId!= oldmap.get(dep.id).OwnerId)){
                setOwnerIds.add(dep.OwnerId); 
            }
            
        }
        
        if(setOwnerIds.size()>0){
            Map<Id,User>mapOwner = new Map<Id,User>([select id,Assistant_Or_Boss_Email__c 
                                                          From User WHERE Id IN: setOwnerIds]);
            for(Deposition__c dep : lstDeposition){
                dep.Assistant_Or_Boss_Email__c = mapOwner.get(dep.Ownerid).Assistant_Or_Boss_Email__c ;
                
            }                                            
        }
    }
    public static void updateDepostionFirm(List<Deposition__c> lstDeposition, map<Id,Deposition__c>oldMap,Boolean isUpdate){
        List<Deposition__c >lstDepositonsNeedUpdate= new List<Deposition__c >();
        for(Deposition__c dep : lstDeposition){
           
            If(dep.Primary_Court_Reporting_Firm__c == NULL &&
               (isUpdate == false || dep.Primary_Court_Reporting_Firm__c != oldMap.get(dep.id).Primary_Court_Reporting_Firm__c  )){
                lstDepositonsNeedUpdate.add(dep);
            }
            
        }
        
        if(lstDepositonsNeedUpdate.size()>0){
            List<user>lstUser= [select id,Default_CR_Firm__c From User WHERE Id=:userinfo.getUserId() AND Default_CR_Firm__c  !=NULL];  
            String userFirmName= 'NextGen Reporting';
            if(lstUser.size()>0){
                userFirmName = lstUser[0].Default_CR_Firm__c;
            }       
            
            List<Firm__c>lstFirms = [select id From Firm__c WHERE Name=:userFirmName];
            if(lstFirms.size()>0){
                for(Deposition__c  dep : lstDepositonsNeedUpdate){
                    dep.Primary_Court_Reporting_Firm__c  = lstFirms[0].id;
                }
            }                               
        }
    }
    /** Whenever Deposition.Deposition_Group__c field changed Or new  Deposition in inserted then populate
        Deposition.VIP_Level__c = Case__C.VIP_Level__c 
     */
    public static void updateDepostionVIPLevel(List<Deposition__c> lstDeposition, map<Id,Deposition__c>oldMap,Boolean isUpdate){
        set<Id>setCaseIds = new Set<Id>();
        for(Deposition__c dep : lstDeposition){
            if(dep.Deposition_Group__c  != NULL ){
                If(isUpdate == false || (dep.Deposition_Group__c != oldmap.get(dep.id).Deposition_Group__c )){
                    setCaseIds.add(dep.Deposition_Group__c);
                }
            }
        }
        
        if(setCaseIds.size()>0){
            Map<Id,Case__c>mapCases = new Map<Id,Case__c>([select id,VIP_Level__c 
                                                          From Case__c WHERE Id in:setCaseIds ]);
            for(Deposition__c dep : lstDeposition){
                if(dep.Deposition_Group__c  != NULL && mapCases.containsKey(dep.Deposition_Group__c)){
                    dep.VIP_Level__c  = mapCases.get(dep.Deposition_Group__c).VIP_Level__c;
                }
            }                                            
        }
    }
    /** Whenever Deposition.Deposition_Group__c field changed Or new  Deposition in inserted then populate
        Deposition.VIP_Level__c = Case__C.VIP_Level__c 
     */
    public static void checkDepositiononAdjacentDaysWithDifferentCrEmail(map<Id,Deposition__c> mapDepositions, map<Id,Deposition__c>oldMap,Boolean isUpdate){
        if(DepositionHelper.isDepositiononAdjacentDaysWithDifferentCrEmailCalled == false){
            
            map<Id,Deposition__c >mapDepositionUpdated = new map<Id,Deposition__c >();
            for(Deposition__c dep : mapDepositions.values()){
                if(dep.Deposition_Date_With_CR_Email__c != NULL && dep.Deposition_Group__c != NULL ){
                    If(isUpdate == false || (oldmap.get(dep.id).Deposition_Group__c==NULL || dep.Deposition_Date__c!= oldmap.get(dep.id).Deposition_Date__c || dep.CR_Email_Address__c!= oldmap.get(dep.id).CR_Email_Address__c)){
                        mapDepositionUpdated.put(dep.id,dep);
                    }
                }
            }
            if(mapDepositionUpdated.size()>0){
                List<AggregateResult>lstAggregateResult = [select max(Deposition_Date__c) maxDate,min(Deposition_Date__c)minDate 
                                                          From Deposition__c WHERE Deposition_Date_With_CR_Email__c != ''
                                                           AND ID IN : mapDepositionUpdated.keyset()];
                                                          
                if(lstAggregateResult.size()>0){
                    Date maxDate ;
                    Date minDate;
                    for(AggregateResult result :lstAggregateResult){
                        maxDate = (Date)result.get('maxDate');
                        minDate= (Date)result.get('minDate');
                    }
                    if(maxDate  != NULL && minDate != NULL){
                        minDate = minDate.addDays(-1);
                        maxDate = maxDate.addDays(1);
                        map<String,List<Deposition__c>>mapDateWithDepoistions = new Map<String,List<Deposition__c>>();
                        for(Deposition__c dep : [select id,Deposition_Date_With_CR_Email__c,CR_Email_Address__c   From Deposition__c 
                                                WHERE Deposition_Date__c>=:minDate 
                                                AND Deposition_Date__c<=:maxDate AND Deposition_Group__c !=NULL
                                                AND ID NOT IN : mapDepositionUpdated.keyset() AND Deposition_Date_With_CR_Email__c  !=NULL]){
                            List<Deposition__c>lstDeps = mapDateWithDepoistions.get(dep.Deposition_Date_With_CR_Email__c.split('==Email==')[0]);
                            if(lstDeps == null )
                                lstDeps = new List<Deposition__c >();
                            lstDeps.add(dep );
                            mapDateWithDepoistions.put(dep.Deposition_Date_With_CR_Email__c.split('==Email==')[0],lstDeps);
                            
                        }
                        if(mapDateWithDepoistions.size()>0){
                            List<Deposition__c>lstDepositionNeedUpdate = new List<Deposition__c>(); 
                            Boolean isDepositionAdded= false;
                            for(Deposition__c dep : mapDepositionUpdated.values()){
                                 isDepositionAdded = false;
                                if(mapDateWithDepoistions.containsKey(dep.After_Deposition_Date_With_CR_Email__c.split('==Email==')[0])){
                                    for(Deposition__c  depRecord : mapDateWithDepoistions.get(dep.After_Deposition_Date_With_CR_Email__c.split('==Email==')[0])){
                                        if(dep.CR_Email_Address__c != depRecord.CR_Email_Address__c ){
                                            Deposition__c deposition = new Deposition__c(Id=dep.id,Different_Reporters_on_Adjacent_Days__c = true);
                                            lstDepositionNeedUpdate.add(deposition );  
                                            isDepositionAdded = true;
                                            break;  
                                        }
                                        
                                    }
                                }
                                if(isDepositionAdded == false && mapDateWithDepoistions.containsKey(dep.Prior_Deposition_Date_With_CR_Email__c.split('==Email==')[0])){
                                    for(Deposition__c  depRecord : mapDateWithDepoistions.get(dep.Prior_Deposition_Date_With_CR_Email__c.split('==Email==')[0])){
                                        if(dep.CR_Email_Address__c != depRecord.CR_Email_Address__c ){
                                            Deposition__c deposition = new Deposition__c(Id=dep.id,Different_Reporters_on_Adjacent_Days__c = true);
                                            lstDepositionNeedUpdate.add(deposition );  
                                            isDepositionAdded = true;
                                            break;  
                                        }
                                        
                                    }
                                }
                                 
                            }
                            if(lstDepositionNeedUpdate.size()>0){
                                DepositionHelper.isDepositiononAdjacentDaysWithDifferentCrEmailCalled = true;
                                update lstDepositionNeedUpdate;
                            }
                           
                        }
                    }
                }
            }
        }
    }
    
    public static Firm__c fetchFirm(String firmName){
        if(firmName == NULL || firmName=='' || firmName=='null')
            firmName  = 'NextGen Reporting';
        system.debug('$$'+firmName);
        List<Firm__c>lstFirms = [select id,Name,Web_Page_Footer_HTML__c,Web_Page_Header_HTML__c,Email_Footer_HTML__c,Email_Header_HTML__c,URL__c,
                                Scheduling_email_address__c,Community_Admin_Email__c,Google_Drive_Folder_Name__c From Firm__c WHERE Name like: firmName+'%'];
        if(lstFirms.size()>0)
            return lstFirms[0];
        else 
            return new Firm__c();
    }
    
    
     /** Case_Name_Text__C inherits the first 100 characters of the case name field(Long text area)
     */
    public static void updateCaseNameText(List<Deposition__c> lstDeposition){
        set<Id>setCaseIds = new Set<Id>();
        for(Deposition__c dep : lstDeposition){
            dep.Case_Name_Text__c = '';
            if(dep.Case_Name__c != NULL){
                if(dep.Case_Name__c.trim().length()>100)
                    dep.Case_Name_Text__c = dep.Case_Name__c.trim().left(100);
                else
                    dep.Case_Name_Text__c = dep.Case_Name__c.trim();
            }
        }  
    }
    public static void createDefaultAttendeeFromDepositionGroup(List<Deposition__c> lstDeposition, map<Id,Deposition__c>oldMap,Boolean isUpdate){
        set<Id>setDepGroupIds = new Set<Id>();
        for(Deposition__c dep : lstDeposition){
            if(dep.Deposition_Group__c != NULL && (isUpdate==false || oldmap.get(dep.id).Deposition_Group__c  != dep.Deposition_Group__c ))    
                setDepGroupIds.add(dep.Deposition_Group__c);
        }  
        if(setDepGroupIds.size()>0){
            List<Attendee__c>lstAttendees = new List<Attendee__c>();
            Map<Id,Case__c>mapDepositionGroups = new Map<Id,Case__c>([select id,(select id,Contact__c,Role__c FROM Deposition_Group_Contacts__r) FROM Case__c WHERE ID IN : setDepGroupIds]);
            for(Deposition__c dep : lstDeposition){
                if(dep.Deposition_Group__c != NULL && (isUpdate==false || oldmap.get(dep.id).Deposition_Group__c  != dep.Deposition_Group__c ) && mapDepositionGroups.get(dep.Deposition_Group__c).Deposition_Group_Contacts__r.size()>0){
                    Case__c cse= mapDepositionGroups.get(dep.Deposition_Group__c);
                    for(Deposition_Group_Contact__c depGroupContact: cse.Deposition_Group_Contacts__r){
                        lstAttendees.add(new Attendee__c(Deposition__c=dep.id,Contact__c=depGroupContact.Contact__c,Role__c=depGroupContact.Role__c));
                    }
                }
                    
            } 
            if(lstAttendees.size()>0)
                insert lstAttendees;
        }
    }
    
    /** Log Fields Updated changes in activity History for following fields:
            -          Billing Notes - Billing_Notes__c
            -          Post Event Notes - Post_event_Notes__c
            -          Case Name/Caption - Case_Name__c
            -          Pre-Event Notes - Notes__c
            -          Reporter Instructions - Reporter_Instructions__c
            -          Special Instructions - Special_Instructions__c
    **/
    public static void logFieldChanges(map<Id,Deposition__c> mapDepositions, map<Id,Deposition__c>oldMap){
        List<Task>lstTasks = new List<Task>();
        
        for(Deposition__c dep: mapDepositions.values()){
            String taskDescription = '';
            String taskSubject = 'Update to ';
            if(dep.Billing_Notes__c!= oldmap.get(dep.id).Billing_Notes__c){
                taskDescription +='The Billing Notes has been changed from \n'+ oldmap.get(dep.id).Billing_Notes__c+' to \n'+ dep.Billing_Notes__c+'.\n';
                taskSubject += 'Billing Notes, ';
            }
            if(dep.Post_event_Notes__c!= oldmap.get(dep.id).Post_event_Notes__c){
                taskDescription +='The Post Event Notes has been changed from \n'+ oldmap.get(dep.id).Post_event_Notes__c+' to \n'+ dep.Post_event_Notes__c+'.\n';
                taskSubject += 'Post Event Notes, ';
            }
            if(dep.Case_Name__c!= oldmap.get(dep.id).Case_Name__c){
                taskDescription +='The Case Name/Caption has been changed from \n'+ oldmap.get(dep.id).Case_Name__c+' to \n'+ dep.Case_Name__c+'.\n';
                taskSubject += 'Case Name/Caption, ';
            }
            if(dep.Notes__c!= oldmap.get(dep.id).Notes__c){
                taskDescription +='The Pre-Event Notes has been changed from \n'+ oldmap.get(dep.id).Notes__c+' to \n'+ dep.Notes__c+'.\n';
                taskSubject += 'Pre-Event Notes, ';
            }
            
            if(dep.Reporter_Instructions__c!= oldmap.get(dep.id).Reporter_Instructions__c){
                taskDescription +='The Reporter Instructions has been changed from \n'+ oldmap.get(dep.id).Reporter_Instructions__c+' to \n'+ dep.Reporter_Instructions__c+'.\n';
                taskSubject += 'Reporter Instructions, ';
            }
            if(dep.Special_Instructions_text__c!= oldmap.get(dep.id).Special_Instructions_text__c){
                taskDescription +='The Special Instructions has been changed from \n'+ oldmap.get(dep.id).Special_Instructions_text__c+' to \n'+ dep.Special_Instructions_text__c+'.\n';
                taskSubject += 'Special Instructions, ';
            }
            if(dep.Deposition_Services__c!= oldmap.get(dep.id).Deposition_Services__c){
                taskDescription +='The Deposition Services has been changed from \n'+ oldmap.get(dep.id).Deposition_Services__c+' to \n'+ dep.Deposition_Services__c+'.\n';
                taskSubject += 'Deposition Services, ';
            }
            
            if(taskDescription != ''){
                taskSubject = taskSubject.removeend(', ');
                Task tsk = new Task(Status='Completed',WhatId=dep.Id,ActivityDate=System.today(),Subject=taskSubject );
                tsk.Description = taskDescription;
                lstTasks.add(tsk);
            }
            
        }
        if(lstTasks.size()>0)
            insert lstTasks;       
       
    }
}