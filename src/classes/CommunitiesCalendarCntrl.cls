/**
                                    Name             : CommunitiesCalendarCntrl
                                    Date             : 08 JUNE 2018
                                    Descripition     : That Class is used by "CommunitiesCalendar" vf page for display a calendar and allow
                                                       User to select a date in calendar and it will load depositions records that are exits on that date
                                                       as well as alllow them to modify this field values:
                                                        -          State
                                                        -          Event location
                                                        -          Reporter assigned (either their name from the attendee record or CR Email address)
                                                        -          Videographer/tech assigned (either their name from the attendee record or CR Email address)
                                                        -          VIP Status
                                                        -          Case (Deposition Group)
                                                        -          Expedite Level
                                                        -          Deposition Services
                                                        -          Source
                                                        -          Due Date to Client
                                                        -          Corporate Client
                                                        -          Special Instructions
                                                        -          Networking/Covering For
                                                        -          Deposition Time
                                                        -          Esimate Duration
*/     
public class CommunitiesCalendarCntrl{
    public List<Deposition__c>lstDepositions {get;set;}
    public string selectedDate{get;set;}
    Date dt;
    public string SelectedType{get;set;}
    public string selctedBrand{get;set;}
    Public User currentUser{get;set;}
    public CommunitiesCalendarCntrl(){
        currentUser = [select id,Name,Contact.Account.Name,ContactId From User WHERE id=:UserInfo.getUserId()];
        
        selectedDate = System.today().month()+'/'+System.today().day()+'/'+System.today().year();
        selectedType = ApexPages.currentPage().getParameters().get('SelectedType');
        if(selectedType==null || selectedType.trim().length()==0)
            selectedType='Show all Jobs';
        selctedBrand = ApexPages.currentPage().getParameters().get('firm');
        if(selctedBrand == NULL)
            selctedBrand = '';
        system.debug('$$selctedBrand '+selctedBrand );
        fetchDayDepositions();
        
    }
    
    public void fetchDayDepositions(){
        dt = Date.parse(selectedDate);
        lstDepositions = fetchDepositions(dt);
    }
    
    @RemoteAction
    public static string eventdata(String startDate,String endDate,String selectedType,String selctedBrand){
    
        User usr = [select Id,ContactId,Contact.AccountId From User WHERE Id=:Userinfo.getUserId()];
        
        CalEvent[] events = new CalEvent[]{};
        String query = 'select Deposition_Time__c, Deposition_Date__c,Deponent_Name__c '; 
        query += ' From  Deposition__c WHERE  Deposition_Date__c != NULL '; 
        query += ' AND Deposition_Status__c != \'Cancelled\'';
        Date dtStart;
        Date dtEnd;
        if(startDate == '') 
            query += ' AND Deposition_Date__c =THIS_MONTH';
        else{
            dtStart = date.parse(startDate );
            dtEnd = date.parse(endDate);
            query += ' AND Deposition_Date__c >=:dtStart AND Deposition_Date__c <=:dtEnd';
            
        }
        if(selctedBrand!= NULL && selctedBrand.trim().length()>0)
            query += ' AND Primary_Court_Reporting_Firm__r.Name=:selctedBrand ';
        if(selectedType!='Show all Jobs' && selectedType !='All_Account_Depositions')
            query += ' AND VIP_Level__c != NULL '; 
       
        if(usr.ContactId != NULL){
            
           String attendeeQuery = 'select Id,Deposition__c From Attendee__c WHERE'+
                                   ' Deposition__r.Deposition_Date__c  >=Last_Month AND Deposition__r.Deposition_Date__c <=Next_Month';
           if(selectedType =='All_Account_Depositions')
               attendeeQuery +=' AND Contact__r.AccountId=\''+usr.Contact.AccountId+'\'';
           else
               attendeeQuery +=' AND Contact__c =\'' +usr.ContactId +'\'';
            Set<Id>setDepositionIds = new Set<Id>();
            for(Attendee__c attendee : Database.Query(attendeeQuery )){
                setDepositionIds.add(attendee.Deposition__c ) ;
            }
            query += ' AND (OwnerId =\''+ usr.Id+'\'  OR ID IN:setDepositionIds) ';
        }
        
        system.debug('$$$'+query );
        for(Deposition__c  dep: Database.Query(query )){
            
            calEvent myEvent = new calEvent();
            myEvent.title = '';
            if(dep.Deposition_Time__c != NULL)
                myEvent.title = dep.Deposition_Time__c ;
            if(dep.Deponent_Name__c == NULL)
                dep.Deponent_Name__c = '';
            if(myEvent.title != '')
                myEvent.title += ' - ';
            myEvent.title +=dep.Deponent_Name__c;
            myEvent.startString = ''+dep.Deposition_Date__c;
            myEvent.startString = myEvent.startString.split(' ')[0];
            events.add(myEvent);
        }

        string jsonEvents = JSON.serialize(events);
        jsonEvents = jsonEvents.replace('startString','start');
        return jsonEvents;
    }
    
     // Class to hold calendar event data
    public class CalEvent {
        public String title {get;set;}
        public String startString {get;set;}
    }
    private List<Deposition__c> fetchDepositions(Date dt){
        String query =  'select id,Name,Deposition_Date__c,State__c,Event_Location__c,CR_Email_Address__c,';
        query+=' Videographer_Email_Address__c,VIP_Level__c,Expedite__c,Deposition_Services__c,';
        query+=' Source__c,Corporate_Client_Source__c,';
        query+=' Primary_CR_Firm__c,Primary_Court_Reporting_Firm__c,Firm_Name__c,';
        query+='  Case_Name__c,Hiring_Firm__c,Deposition_Time__c,Estimated_Duration__c,Time_Zone__c,Deponent_Name__c';
        query+='  From Deposition__c WHERE Deposition_Date__c =:dt ';
        query+=' AND Deposition_Status__c != \'Cancelled\'  ';
        if(selectedType!='Show all Jobs' && selectedType !='All_Account_Depositions')
            query += ' AND VIP_Level__c != NULL ';
        if(selctedBrand!= NULL && selctedBrand.trim().length()>0)
            query += ' AND Primary_Court_Reporting_Firm__r.Name=:selctedBrand ';   
        
        if(currentUser.ContactId != NULL){
            
            String attendeeQuery = 'select Id,Deposition__c From Attendee__c WHERE'+
                                   ' Deposition__r.Deposition_Date__c =:dt';
           if(selectedType =='All_Account_Depositions')
               attendeeQuery +=' AND Contact__r.AccountId=\''+currentUser.Contact.AccountId+'\'';
           else
               attendeeQuery +=' AND Contact__c =\'' +currentUser.ContactId +'\'';
            Set<Id>setDepositionIds = new Set<Id>();
            for(Attendee__c attendee : Database.Query(attendeeQuery )){
                setDepositionIds.add(attendee.Deposition__c ) ;
            }
            query += ' AND (OwnerId =\''+ currentUser.Id+'\'  OR ID IN:setDepositionIds) ';
        }
        system.debug('$$'+query);
        
        query+=' ORDER By Name';
        return Database.Query(query);
    }
    public void saveDepositions(){
        try{
            List<Deposition__c>lstDepositionsNeedUpdate = new List<Deposition__c>();
            Map<Id,Deposition__c>mapDepositions = new Map<Id,Deposition__c>(fetchDepositions(dt));
            for(Deposition__c dep : lstDepositions ){
                Deposition__c oldDep = mapDepositions.get(dep.id);
                if(oldDep.State__c != dep.State__c || oldDep.Event_Location__c != dep.Event_Location__c || oldDep.CR_Email_Address__c != dep.CR_Email_Address__c|| 
                    oldDep.Videographer_Email_Address__c != dep.Videographer_Email_Address__c || oldDep.VIP_Level__c!= dep.VIP_Level__c|| 
                    oldDep.Expedite__c!= dep.Expedite__c|| 
                    oldDep.Deposition_Services__c!= dep.Deposition_Services__c|| oldDep.Source__c!= dep.Source__c|| 
                    oldDep.Corporate_Client_Source__c!= dep.Corporate_Client_Source__c|| 
                    oldDep.Primary_Court_Reporting_Firm__c != dep.Primary_Court_Reporting_Firm__c
                    || oldDep.Case_Name__c != dep.Case_Name__c
                    || oldDep.Hiring_Firm__c != dep.Hiring_Firm__c ||
                    oldDep.Primary_CR_Firm__c!= dep.Primary_CR_Firm__c||
                    oldDep.Deposition_Time__c!= dep.Deposition_Time__c||
                    oldDep.Estimated_Duration__c!= dep.Estimated_Duration__c
                    ){
                    lstDepositionsNeedUpdate.add(dep);    
                } 
            }
            if(lstDepositionsNeedUpdate.size()>0)
                update lstDepositionsNeedUpdate ;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Changes successfully saved.'));
        }Catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Fatal,e.getMessage()));
        }
    }
    
}