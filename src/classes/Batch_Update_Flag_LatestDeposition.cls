global with sharing class Batch_Update_Flag_LatestDeposition implements Database.Stateful,Database.Batchable<sObject> {

global String query; 

        global Database.QueryLocator start(Database.BatchableContext BC)
            {
              return Database.getQueryLocator(query);  
            }
            global void execute(Database.BatchableContext BC,  List<Contact> lstContact)  
            { 
            	
               Map<Id,Attendee__c> AttndMap = new Map<Id,Attendee__c>();
               Map<Id,List<Attendee__c>> AttndMapNot = new Map<Id,List<Attendee__c>>();
               list<Attendee__c>lstUpdateAttnd = new List<Attendee__c>();
               list<Attendee__c>lstUpdateAttNot=new List<Attendee__c>();
               Set<Id> noUpdateIds=new Set<Id>();
               for(Contact con:[Select Id,(Select id,LatestDepositionFlag__c from Deposition_Roles__r order by Deposition_Date__c desc limit 1)from Contact where ID IN:lstContact])
               {
                	if(con.Deposition_Roles__r.size()>0){                  
                   		AttndMap.put(con.id,con.Deposition_Roles__r);
                    }    
                }
                
               for(String S :   AttndMap.keyset()){
	                Attendee__c atd = AttndMap.get(s);
	                noUpdateIds.add(atd.id);
	                atd.LatestDepositionFlag__c = true;
	                lstUpdateAttnd.add(atd);
               }
	            if( lstUpdateAttnd.size()>0){
	            	update lstUpdateAttnd;
            	}     
            	
               for(Contact con:[Select Id,(Select id,LatestDepositionFlag__c from Deposition_Roles__r where id not in:noUpdateIds)from Contact where ID IN:lstContact])
               {
                	if(con.Deposition_Roles__r.size()>0){                  
                   		AttndMapNot.put(con.id,con.Deposition_Roles__r);
                    }    
                }  
               
               
               for(String S :   AttndMapNot.keyset()){
	                List<Attendee__c> atd = AttndMapNot.get(s);
	                for(Attendee__c aRec:atd){
	                	aRec.LatestDepositionFlag__c = false;
	                	lstUpdateAttNot.add(aRec);
	                }
               }
	            if( lstUpdateAttnd.size()>0){
	            	update lstUpdateAttNot;
            	}     
            }
            
             global void finish(Database.BatchableContext BC)
            {
                
            }  
}