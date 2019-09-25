/**
                                                Name             : DepositionAssignmentCntrl 
                                                Date             : 11 Jan 2015
                                                Descripotion     : This class is used by "DepositionAssignment" VF page.
                                                                 That page will enable us to assign reporters and videographers in bulk.
 
                                                                The user would go to a page which shows all of tomorrow’s jobs with the following columns:
                                                                -          Court Reporter (If there is an attendee whose role = court reporter, their name should
                                                                           be listed as a read only text field. If there is no court reporter assigned, there should be a lookup box 
                                                                           where the user can enter a court reporter. Ideally, it would have a filter field which would only show 
                                                                           contacts whose account = court reporting.)
                                                                
                                                                -          Videographer (If there is an attendee whose role = Videographer/Technician, their name should be listed as a 
                                                                           read only text field. If there is no Videographer/Technician assigned, there should be a lookup box where the 
                                                                           user can enter a court reporter. Ideally, it would have a filter field which would only show contacts whose 
                                                                           account industry = court reporting or Videography.)
                                                                
                                                                -          Case caption (Read only)
                                                                
                                                                -          Depo Start Time (Read only)
                                                                
                                                                -          Estimated Duration
                                                                
                                                                -          Hiring Firm (Read only)
                                                                
                                                                -          Hiring Attorney (Read only)
                                                                
                                                                -          Deposition Services (Read only)
                                                                -          Scheduler Name
*/
public class DepositionAssignmentCntrl {

    public List<DepositionModel>lstTomorrowDepositions{get;set;}
    
    public Deposition__c dep{get;set;}
    public List<SelectOption>lstFirms{get;set;}
    public string selectedFirm{get;set;}
    public DepositionAssignmentCntrl(){
        dep = new Deposition__c ();
        dep.Deposition_Date__c = System.Today()+1;
        fetchFirms();
        loadDepositions();
    }
    
    private void fetchFirms(){
        lstFirms = new List<SelectOption>();
        User usr = [select Default_CR_Firm__c FROM User WHERE Id =:UserInfo.getUserId() ];
        if(usr.Default_CR_Firm__c == NULL)
            usr.Default_CR_Firm__c = 'NextGen Reporting';
        for(Firm__c firm : [select id,Name From Firm__c LIMIT 100]){
            if( usr.Default_CR_Firm__c.equalsIgnoreCase(firm.Name))
                selectedFirm = firm.id;
            lstFirms.add(new SelectOption(firm.id,firm.Name));
        }
    }
    
    public void loadDepositions(){
        lstTomorrowDepositions = new List<DepositionModel>();
        
        for(Deposition__c dep : [select id,Name,Case_Name__c,Deposition_Time__c,Estimated_Duration__c,Hiring_Firm__c,
                                Hiring_Attorney__c,Deposition_Services__c,GuestName__c,
                                (select id,Contact__c,Role__c,Court_Reporter__c,Videographer__c
                                  From Deposition_Roles__r WHERE Role__c IN('Court Reporter','Videographer/Technician') )
                                From Deposition__c  WHERE  Deposition_Date__c != NULL 
                                AND Deposition_Status__c != 'Cancelled' AND Deposition_Date__c=:dep.Deposition_Date__c
                                 AND Primary_Court_Reporting_Firm__c=:selectedFirm ]){
                DepositionModel depModel = new DepositionModel();
                depModel.deposition = dep;
                depModel.reporter= new Attendee__c();
                depModel.videographer= new Attendee__c();
                for(Attendee__c attendee : dep.Deposition_Roles__r ){
                    if(attendee.Role__c =='Court Reporter')
                        depModel.reporter=  attendee;
                    else if(attendee.Role__c =='Videographer/Technician')
                        depModel.videographer= attendee;
                }
                
                lstTomorrowDepositions.add(depModel);
        }
    }
    
    public void saveDepositions(){
        Savepoint sp = Database.setSavepoint();
        try{
            List<Attendee__c>lstAttendeeNeedInsert = new List<Attendee__c>();
            for(DepositionModel depModel : lstTomorrowDepositions){
                // Reporter
                if(depModel.reporter.Court_Reporter__c != NULL){
                    depModel.reporter.Contact__c = depModel.reporter.Court_Reporter__c;
                    depModel.reporter.Court_Reporter__c = NULL;
                    depModel.reporter.Deposition__c = depModel.deposition.id;
                    depModel.reporter.Role__c= 'Court Reporter';
                    lstAttendeeNeedInsert.add(depModel.reporter);
                }
                
                //Videographer/Technician
                if(depModel.videographer.Videographer__c != NULL){
                    depModel.videographer.Contact__c = depModel.videographer.Videographer__c;
                    depModel.videographer.Videographer__c= NULL;
                    depModel.videographer.Deposition__c = depModel.deposition.id;
                    depModel.videographer.Role__c= 'Videographer/Technician';
                    lstAttendeeNeedInsert.add(depModel.videographer);
                }
            }
            if(lstAttendeeNeedInsert.size()>0){
                insert lstAttendeeNeedInsert;
                AttendeeHelper.sendEmailAlertToReporterAndVideographer(lstAttendeeNeedInsert);
            }
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Changes successfully saved.'));
            
        }Catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Fatal,e.getMessage()));
            Database.rollback(sp);
        }
    }
    public class DepositionModel{
        public Deposition__c deposition{get;set;}
        public Attendee__c reporter{get;set;}
        public Attendee__c videographer{get;set;}
    }
}