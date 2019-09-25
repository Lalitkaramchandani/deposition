/**************************************************
                Name        : UpcomingDepositionsCntrl
                Author      : Rajendra Rathore
                Purpose     : That class is used by UpcomingDepositions VF component for showing upcomming depositions for community User
                Created Date: 16 April 2016
                
                Modification History:
*****************************************************/
public  class UpcomingDepositionsCntrl{
    public Transient  List<Deposition__c>lstDepositions {get;set;}
    public string selectedCaseNameChar{get;set;}
    string whereClause ='';
    User currentUser = New User();
    public Firm__c firm{get;set;}
    
    public UpcomingDepositionsCntrl(){
        List<String> alphabet = new List<String>
        {   'a','b','c','d','e','f','g','h','i','j','k','l','m',
            'n','o','p','q','r','s','t','u','v','w','x','y','z'
        };
        
        List<String> comparisons = new List<String>();
        for ( String letter : alphabet )
        {
            comparisons.add( '( NOT Hiring_Attorney__c  LIKE \'' + letter + '%\')' );
        }
        
        whereClause = String.join( comparisons, ' AND ' );
        selectedCaseNameChar = 'All';
        currentUser = [select id,ContactId From User Where Id=:Userinfo.getUserId()];
        //fetchDepositions();
        FirmInfoCntrl cntrl = new FirmInfoCntrl();
        firm = cntrl.getFirm();
    }
    
    public void fetchDepositions(){
    
    }
    public List<Deposition__c>getDepositions(){
        Date todayDate = System.today();
        
        String attendeeQuery = 'select Id,Deposition__c From Attendee__c WHERE (Deposition__r.Deposition_Date__c >=:todayDate OR Deposition__r.Deposition_Date__c =null)';
        
        String query =  'select id,Name,Deposition_Date__c,Case_Name__c,Hiring_Attorney__c';
        query+=',Deposition_Services__c,Deponent_Name__c,Cancelled_Date__c,Deposition_Status__c ';
        
        query+='  From Deposition__c WHERE (Deposition_Date__c >=:todayDate OR Deposition_Date__c =null)';
        query+= ' AND Deposition_Status__c !=\'Cancelled\'';
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
        system.debug('$$$'+selectedCaseNameChar );
        String caseId = Apexpages.currentPage().getParameters().get('caseId');
        if(caseId != '' &&caseId != NULL  && caseId.trim().length()>0)
            attendeeQuery +=' AND Deposition__r.Deposition_Group__c =\'' +caseId+'\'';
        Set<Id>setDepositionIds = new Set<Id>();
        for(Attendee__c attendee : Database.Query(attendeeQuery )){
            setDepositionIds.add(attendee.Deposition__c ) ;
        }
        List<Deposition__c>lstDepositions = new List<Deposition__c>();
        if(setDepositionIds.size()>0){
            query+=' AND ID IN:setDepositionIds' ;
            query+=' ORDER By Name,CreatedDate DESC LIMIT 800';
            lstDepositions= Database.Query(query);
        }else
            lstDepositions = new list<Deposition__c>(); 
        return lstDepositions ;
    }
}