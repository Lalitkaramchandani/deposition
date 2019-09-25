/**
*                                    Name             : CaseHelper
*                                    Date             : 06/02/2015
*                                    Description      : Helper Class for Case__c object Triggers
*/
public class CaseHelper{
    /** Whenever case VIP Level field value is updated then update deposition VIP Level to Case__c.Vip_Level__C*/
    public static void updateDepostionInfoFromCase(map<Id,Case__c>mapCases, map<Id,Case__c>oldMap){
        
        set<Id>setCaseIds = new Set<Id>();
        for(Case__c cse: mapCases.values()){
            if(cse.VIP_Level__c != oldmap.get(cse.id).VIP_Level__c || cse.Billing_Notes__c!= oldmap.get(cse.id).Billing_Notes__c
             || cse.Production_Notes__c != oldmap.get(cse.id).Production_Notes__c || cse.Video_Notes__c!= oldmap.get(cse.id).Video_Notes__c
             || cse.Name != oldmap.get(cse.id).Name || cse.Description__c!= oldmap.get(cse.Id).Description__c)
                setCaseIds.add(cse.id);
        }
        if(setCaseIds.size()>0){
            List<Deposition__c>lstNeedUpdateDespostions = new List<Deposition__c>();
            for(Deposition__c depostion : [select id,Deposition_Group__c,VIP_Level__c,Case_Billing_Notes__c,
                                          Case_Video_Notes__c,Case_Name_Text__c,Case_Production_Notes__c,Description__c
                                          From Deposition__c 
                                          WHERE Deposition_Group__c IN :setCaseIds]){
                Boolean needUpdate = false;
                if(depostion.VIP_Level__c != mapCases.get(depostion.Deposition_Group__c).VIP_Level__c ){
                    depostion.VIP_Level__c = mapCases.get(depostion.Deposition_Group__c).VIP_Level__c;
                    needUpdate = true;
                }
                if(depostion.Case_Billing_Notes__c != mapCases.get(depostion.Deposition_Group__c).Billing_Notes__c){
                    depostion.Case_Billing_Notes__c= mapCases.get(depostion.Deposition_Group__c).Billing_Notes__c;
                    needUpdate = true;
                }
                if(depostion.Case_Production_Notes__c!= mapCases.get(depostion.Deposition_Group__c).Production_Notes__c ){
                    depostion.Case_Production_Notes__c= mapCases.get(depostion.Deposition_Group__c).Production_Notes__c ;
                    needUpdate = true;
                }
                if(depostion.Case_Video_Notes__c!= mapCases.get(depostion.Deposition_Group__c).Video_Notes__c){
                    depostion.Case_Video_Notes__c= mapCases.get(depostion.Deposition_Group__c).Video_Notes__c;
                    needUpdate = true;
                }
                if(depostion.Description__c!= mapCases.get(depostion.Deposition_Group__c).Description__c){
                    depostion.Description__c= mapCases.get(depostion.Deposition_Group__c).Description__c;
                    needUpdate = true;
                }
                if(depostion.Case_Name_Text__c!= mapCases.get(depostion.Deposition_Group__c).Name){
                     String newCaseName = '';
                    if(mapCases.get(depostion.Deposition_Group__c).Name.trim().length()>100)
                        newCaseName  = mapCases.get(depostion.Deposition_Group__c).Name.trim().left(100);
                    else
                        newCaseName  = mapCases.get(depostion.Deposition_Group__c).Name.trim();
                    if(newCaseName  != depostion.Case_Name_Text__c){
                        depostion.Case_Name_Text__c = newCaseName;
                        needUpdate = true;
                    }
                    
                    
                }
                if(needUpdate )
                    lstNeedUpdateDespostions.add(depostion);
            }
            if(lstNeedUpdateDespostions.size()>0)
                update lstNeedUpdateDespostions;
        }
    }
    
    /** Whenever case VIP Level field value is updated then update deposition VIP Level to Case__c.Vip_Level__C*/
    public static void logCaseFieldHistory(map<Id,Case__c>mapCases, map<Id,Case__c>oldMap){
        List<Task>lstTasks = new List<Task>();
        
        for(Case__c cse: mapCases.values()){
            String taskDescription = '';
            String taskSubject = 'Update to ';
            if(cse.Billing_Notes__c!= oldmap.get(cse.id).Billing_Notes__c){
                taskDescription +='The Billing Notes has been changed from \n'+ oldmap.get(cse.id).Billing_Notes__c+' to \n'+ cse.Billing_Notes__c+'.\n';
                taskSubject += 'Billing Notes, ';
            }
            if(cse.Default_Case_Caption__c != oldmap.get(cse.id).Default_Case_Caption__c ){
                taskDescription +='The Case Caption has been changed from \n'+ oldmap.get(cse.id).Default_Case_Caption__c +' to \n'+ cse.Default_Case_Caption__c +'.\n';
                taskSubject += 'Case Caption, ';
            }
            if(cse.Description__c!= oldmap.get(cse.id).Description__c){
                taskDescription +='The Description has been changed from \n'+ oldmap.get(cse.id).Description__c+' to \n'+ cse.Description__c+'.\n';
                taskSubject += 'Description, ';
            }
            if(cse.Production_Notes__c!= oldmap.get(cse.id).Production_Notes__c){
                taskDescription +='The Production Notes has been changed from \n'+ oldmap.get(cse.id).Production_Notes__c+' to \n'+ cse.Production_Notes__c+'.\n';
                taskSubject += 'Production Notes, ';
            }
            if(cse.Video_Notes__c!= oldmap.get(cse.id).Video_Notes__c){
                taskDescription +='The Video Notes has been changed from \n'+ oldmap.get(cse.id).Video_Notes__c+' to \n'+ cse.Video_Notes__c+'.\n';
                taskSubject += 'Video Notes, ';
            }
            if(cse.Reporter_Instructions__c!= oldmap.get(cse.id).Reporter_Instructions__c){
                taskDescription +='The Reporter Instructions has been changed from \n'+ oldmap.get(cse.id).Reporter_Instructions__c+' to \n'+ cse.Reporter_Instructions__c+'.\n';
                taskSubject += 'Reporter Instructions, ';
            }
            if(taskDescription != ''){
                taskSubject = taskSubject.removeend(', ');
                Task tsk = new Task(Status='Completed',WhatId=cse.Id,ActivityDate=System.today(),Subject=taskSubject );
                tsk.Description = taskDescription;
                lstTasks.add(tsk);
            }
            
        }
        if(lstTasks.size()>0)
            insert lstTasks;
    }
}