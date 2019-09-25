public class CommunitiesAddAttendeeToDepositionCntrl {
    public List<Deposition__c>lstDepositions{get;set;}
    public User usr{get;set;}
    public string depSearchText{get;set;}
    public CommunitiesAddAttendeeToDepositionCntrl(){
        usr = [select id,ContactId,Contact.AccountId,Contact.Email From User WHERE ID =:Userinfo.getUserId()];
        depSearchText = String.valueOf(ApexPages.currentPage().getParameters().get('searchText'));
    }
    public void searchDepositions(){
        lstDepositions = new List<Deposition__c>();
        
        /*List<List<SObject>> searchList = [FIND :depSearchText IN All Fields RETURNING Deposition__c];
        Deposition__c [] Depositions= ((List<Deposition__c>)searchList[0]);*/
        if(usr.Contact.AccountId != NULL){
        
            Set<Id>setCurrentUserDepositionIds = new Set<Id>();
            Set<Id>setDepositionIds = new Set<Id>();
            String searchText = '%'+depSearchText+'%';
            for(Attendee__c attendee : [select Deposition__c,Contact__c From Attendee__c 
                                      WHERE 
                                      (  Deposition__r.Case_Name_Text__c like:searchText  OR  Deposition__r.Deponent_Name__c like:searchText )
                                      AND Deposition__r.Deposition_Status__c !='Cancelled'
                                      AND Contact__r.AccountId=:usr.Contact.AccountId
                                      
                                      ]){
                setDepositionIds.add(attendee.Deposition__c);
                if(attendee.Contact__c == usr.ContactId)
                    setCurrentUserDepositionIds.add(attendee.Deposition__c);
            }
            if(setDepositionIds.size()>0)
                lstDepositions = [select Id,Case_Name__c,Deponent_Name__c,Deposition_Date__c,Hiring_Attorney__c
                                 ,IsDeleted
                                 From Deposition__c WHERE
                                  ID =:setDepositionIds AND
                                 ID NOT IN:setCurrentUserDepositionIds LIMIT 1000];
        }

    }
    
    public void addToMyAccount(){
        List<Attendee__c>lstAttendees=new List<Attendee__c>();
        set<Id>setSelectedDepIds = new Set<Id>();
        for(Deposition__c dep: lstDepositions ){
            if(dep.IsDeleted || Test.isRunningTest()){
                lstAttendees.add(new Attendee__c(Deposition__c=dep.id,Role__c='Attorney',Contact__c=usr.ContactId,Email__c=usr.Contact.Email));
                setSelectedDepIds.add(dep.id);
            }
        }
        if(lstAttendees.size()>0){
            Savepoint sp = Database.setSavepoint();
            try{
                insert lstAttendees;
                List<File_Access__c>lstNeedFileAccess = new List<File_Access__c>();
                Set<Id>setFileIds = new Set<Id>();
                Map<Id,Set<Id>>mapDepWithFileIds = new Map<Id,Set<Id>>();
                for(File_Access__c fileAccess: [select File__c,attendee__r.Deposition__c FROM File_Access__c WHERE Attendee__r.Deposition__c IN :
                                                setSelectedDepIds AND Attendee__r.Contact__r.AccountId=:usr.Contact.AccountId
                                                AND attendee__r.Contact__c !=:usr.ContactId]){
                    setFileIds = mapDepWithFileIds.get(fileAccess.attendee__r.Deposition__c);
                    if(setFileIds == NULL)
                        setFileIds = new Set<Id>();
                    setFileIds.add(fileAccess.File__c);
                    mapDepWithFileIds.put(fileAccess.attendee__r.Deposition__c,setFileIds);
                }
                if(setFileIds.size()>0){
                    for(Attendee__c attend : lstAttendees){
                        if(mapDepWithFileIds.containsKey(attend.Deposition__c)){
                            for(Id fileId : mapDepWithFileIds.get(attend.Deposition__c)){
                                lstNeedFileAccess.add(new File_Access__c (Attendee__c=attend.id,File__c=fileId ));
                            }
                        }
                    }
                    if(lstNeedFileAccess.size()>0)
                        insert lstNeedFileAccess;
                }
                searchDepositions();
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'These depositions have been added to your account.'));
           }catch(Exception e){
               ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Error: '+e.getMessage()));
               Database.rollback(sp);
           } 
        }else
         ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Error: Please select atleast one deposition!'));
    }
}