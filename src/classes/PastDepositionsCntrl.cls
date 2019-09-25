/**************************************************
                Name        : PastDepositionsCntrl 
                Author      : Rajendra Rathore
                Purpose     : That class is used by PastDepositions VF component for showing past depositions for community User.
                Created Date: 16 April 2016
                
                Modification History:
*****************************************************/
public class PastDepositionsCntrl {
    public Transient  List<Deposition__c>lstDepositions {get;set;}
    public string selectedCaseNameChar{get;set;}
    string whereClause ='';
    public User currentUser{get;set;}
    public Firm__c firm{get;set;}
    public PastDepositionsCntrl(){
        List<String> alphabet = new List<String>
        {   'a','b','c','d','e','f','g','h','i','j','k','l','m',
            'n','o','p','q','r','s','t','u','v','w','x','y','z'
        };
        
        List<String> comparisons = new List<String>();
        for ( String letter : alphabet )
        {
            comparisons.add( '( NOT Deposition__r.Hiring_Attorney__c  LIKE \'' + letter + '%\')' );
        }
        
        whereClause = String.join( comparisons, ' AND ' );
        selectedCaseNameChar = 'All';
        currentUser = [select id,ContactId,Contact.AccountId,Contact.Account.Industry From User Where Id=:Userinfo.getUserId()];
        //fetchDepositions();
        FirmInfoCntrl cntrl = new FirmInfoCntrl();
        firm = cntrl.getFirm();
    }
    public void fetchDepositions(){
        //fetchDepositions();
    }
    /*public List<Deposition__c>getDepositions(){
        Date todayDate = System.today();
        
        String attendeeQuery = 'SELECT Id, Deposition__c From Attendee__c WHERE Deposition__r.Deposition_Date__c <:todayDate';
        String query =  'SELECT Id, Name, Deposition_Date__c, Case_Name__c, Hiring_Attorney__c';
        query+=', Deposition_Services__c, Deponent_Name__c, Cancelled_Date__c, Deposition_Status__c ';
        query+='  From Deposition__c WHERE Deposition_Date__c <:todayDate';
        if(selectedCaseNameChar != 'All' && selectedCaseNameChar != 'Other'){
            query+=' AND Deponent_Name__c like \''+ selectedCaseNameChar +'%\'';
            attendeeQuery += ' AND Deposition__r.Deponent_Name__c like \''+ selectedCaseNameChar +'%\'';
        }else if(selectedCaseNameChar == 'Other'){
            query+=' AND ' +whereClause  ;
        }
        if(currentUser.ContactId != NULL)
            attendeeQuery +=' AND Contact__c =\'' +currentUser.ContactId+'\'';
        else
            attendeeQuery +=' AND Deposition__r.OwnerId=\'' +currentUser.Id+'\'';
            
        String caseId = Apexpages.currentPage().getParameters().get('caseId');
        if(caseId != '' &&caseId != NULL  && caseId.trim().length()>0)
            attendeeQuery +=' AND Deposition__r.Deposition_Group__c =\'' +caseId+'\'';
        Set<Id>setDepositionIds = new Set<Id>();
        System.debug('>query'+query);
        System.debug('>query'+attendeeQuery);
        for(Attendee__c attendee : Database.Query(attendeeQuery )){
            setDepositionIds.add(attendee.Deposition__c ) ;
        }
        List<Deposition__c>lstDepositions = new List<Deposition__c>();
        if(setDepositionIds.size()>0){
            query+=' AND ID IN:setDepositionIds' ;
            query+=' ORDER By Deposition_Date__c DESC LIMIT 800';
            lstDepositions = Database.Query(query);
        }else
            lstDepositions = new list<Deposition__c>(); 
        getPastDepositions();
        return lstDepositions ;
    }*/
    
    public List<DepositionData> getPastDepositions(){
        Date todayDate = System.today();
        List<DepositionData> pasDep = new List<DepositionData>();
        String attendeeQuery ='';// 'SELECT Id, Deposition__c From Attendee__c WHERE Deposition__r.Deposition_Date__c <:todayDate';
        
        String query =  'SELECT Deposition__r.Id, Deposition__r.Name, Deposition__r.Deposition_Date__c, Deposition__r.Case_Name__c, Deposition__r.Hiring_Attorney__c';
        query+=', Deposition__r.Deposition_Services__c, Deposition__r.Deponent_Name__c, Deposition__r.Cancelled_Date__c, Deposition__r.Deposition_Status__c ';
        query+='  From Attendee__c WHERE Deposition__r.Deposition_Date__c <:todayDate';
        String invFilter ='';
        if(selectedCaseNameChar != 'All' && selectedCaseNameChar != 'Other'){
            query+=' AND Deposition__r.Deponent_Name__c like \''+ String.escapeSingleQuotes(selectedCaseNameChar) +'%\'';
            // attendeeQuery += ' AND Deposition__r.Deponent_Name__c like \''+ selectedCaseNameChar +'%\'';
        }else if(selectedCaseNameChar == 'Other'){
            query+=' AND ' +whereClause  ;
        }
        if(currentUser.ContactId != NULL){
            attendeeQuery +=' AND Contact__c =\'' +currentUser.ContactId+'\'';
            invFilter +=' AND Contact__c =\'' +currentUser.ContactId+'\'';
        }else{
            attendeeQuery +=' AND Deposition__r.OwnerId=\'' +currentUser.Id+'\'';
            invFilter +=' AND OwnerId=\'' +currentUser.Id+'\'';
        }
        String caseId = Apexpages.currentPage().getParameters().get('caseId');
        if(caseId != '' &&caseId != NULL  && caseId.trim().length()>0)
            attendeeQuery +=' AND Deposition__r.Deposition_Group__c =\'' +caseId+'\'';
        Set<Id>setDepositionIds = new Set<Id>();
        attendeeQuery = query + attendeeQuery;
        System.debug(attendeeQuery);
        Map<Id, DepositionData> sMap = new Map<Id, DepositionData>();
        for(List<Attendee__c> attendees : Database.Query(attendeeQuery )){
            for(Attendee__c attendee : attendees){
                if(!sMap.containsKey(attendee.Deposition__r.Id)){
                    DepositionData d = new DepositionData(attendee.Deposition__r);
                    sMap.put(attendee.Deposition__r.Id, d);
                }
            }
        }
        if(!sMap.isEmpty()){
            Set<Id> ids = sMap.keySet();
            String invQuery = 'SELECT Id,Name, Deposition__c FROM Invoice__c '
                            +' WHERE Deposition__c in :ids AND Status__c=\'Valid\''
                            + invFilter
                            +' ORDER BY CreatedDate';
            for(List<Invoice__c> invoices : Database.query(invQuery)){
                for(Invoice__c invoice : invoices){
                    if(sMap.containsKey(invoice.Deposition__c)){
                        DepositionData d = sMap.get(invoice.Deposition__c);
                        d.invoices.add(invoice);
                    }
                }
            }
        }
        return sMap.values();
    }
    public class DepositionData{
        public Deposition__c dep{get;set;}
        public List<Invoice__c> invoices{get;set;}
        public DepositionData(Deposition__c dep){
            this.dep = dep;
            invoices = new List<Invoice__c>();
        }
    }
}