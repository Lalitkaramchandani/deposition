public class PortalReportersAndvideographersCntrl{
    public Deposition__c deposition {get;set;}
    public Boolean isErr{get;set;}
    String depositionId  = '';
    String contactId = '';
    String type = '';
    Upload_Files__c uploadFiles = new Upload_Files__c();
    public string arrivalTime{get;set;}
    public string departureTime{get;set;}
    public Attendee__c attendee {get;set;}
    public PortalReportersAndvideographersCntrl(ApexPages.StandardController sc){
        attendee = new Attendee__c ();
        depositionId = sc.getId();
        contactId= ApexPages.currentPage().getParameters().get('contactId');
        type = ApexPages.currentPage().getParameters().get('type');
        isErr = false;
        deposition = new Deposition__c();
        arrivalTime = '';
        
    }
    
    public  void validatePageParameters(){
        
        if(depositionId == NULL || depositionId.trim().length()==0){
            addMessage('Id parameter is missing in url.');
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Id parameter is missing in url.'));
        }else{
            List<Deposition__c>lstDepositions = [select id,Name,Deposition_Date__c,Deposition_Time__c,Transcript_Due_From_Reporter_Computed__c
                                                ,Special_Instructions_text__c,Page_Count__c,Exhibit_page_count__c,
                                                Reporter_EOD_Check_In__c,Firm_Name__c
                                                 From Deposition__c WHERE Id =:depositionId ];
                          
            if(lstDepositions.size()>0){
                deposition = lstDepositions[0];
            }
        }
        String contactName = '';
        String contactEmail ='';
        //if(contactId == NULL || contactId.trim().length()==0){
        //    addMessage('ContactId parameter is missing in url.');
        //}else
        
        //if(contactId != NULL && contactId.trim().length()>0){
            /**List<Contact>lstContacts = [select Name,Email From Contact WHERE ID=:contactId ];
            if(lstContacts.size()>0){
                contactName  =lstContacts[0].Name;
                if(lstContacts[0].email != NULL)    contactEmail  = lstContacts[0].email;
            }
            */
            
            List<Attendee__c>lstAttendee = new List<Attendee__c>();
            
            if(contactId != NULL && contactId.trim().length()>0){
                lstAttendee  = [select id,Contact__r.Name,Contact__r.Email,Arrival_Time__c,Departure_Time__c
                               ,Mileage__c,Parking_Expenses__c,Recap_Notes__c,Timestamp_of_Recap__c
                                From Attendee__c 
                                WHERE Contact__c =:contactId AND Deposition__c=:depositionId];
            }else{
                type = type==NULL ? '':type;
                String role = type.equalsIgnoreCase('v')? 'Videographer/Technician' : 'Court Reporter';
                lstAttendee  = [select id,Contact__r.Name,Contact__r.Email,Arrival_Time__c,Departure_Time__c
                               ,Mileage__c,Parking_Expenses__c,Recap_Notes__c,Timestamp_of_Recap__c
                                From Attendee__c 
                                WHERE Role__c =:role  AND Deposition__c=:depositionId];
            }
            
            
            if(lstAttendee.size()>0){
                attendee = lstAttendee[0];
                contactName  =attendee.Contact__r.Name;
                if(attendee.Contact__r.Email!= NULL)    contactEmail  = attendee.Contact__r.Email;
                if(attendee.Arrival_Time__c != NULL)
                    arrivalTime =  attendee.Arrival_Time__c.format('hh:mm a','PST');
                
                if(attendee.Departure_Time__c!= NULL)
                    departureTime=  attendee.Departure_Time__c.format('hh:mm a','PST');
            }else{
                addMessage('Attendee Not found for Deposition.');
            }
        /*}else{
            addMessage('ContactId parameter is missing in url.');
        }*/
        if(type == NULL || type.trim().length()==0){
            addMessage('Type  parameter is missing in url.');
        }else if(type != 'r' && type != 'v'){
            addMessage('Invalid type value. Type is either v for videographer/technician or r for reporter allowed.');
        }
        if(isErr == false){
            this.uploadFiles = new Upload_Files__c(
            Deposition_Number__c= deposition.Name,Email__c=contactEmail  , Contact_Name__c= contactName ,
             IP_Address__c=ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP'),Deposition__c =depositionId );
            if(contactId != NULL && contactId.trim().length()>0)
                this.uploadFiles.Contact__c=contactId;
        }
    }
    
    public PageReference saveDeposition(){
        try{
            if(type=='r' && attendee.Recap_Notes__c!= NULL && attendee.Recap_Notes__c!= '')
                deposition.Reporter_EOD_Check_In__c = true;
            if(deposition.Deposition_Date__c != NULL){
                Integer day = deposition.Deposition_Date__c.day();
                Integer month = deposition.Deposition_Date__c.month();
                Integer year = deposition.Deposition_Date__c.year();
                String depDate = month+'/'+day+'/'+year +' ';
                if(arrivalTime!= '' && arrivalTime!=NULL){
                    arrivalTime = arrivalTime.toLowerCase().replace('a.m.','am').replace('p.m.','pm');
                    attendee.Arrival_Time__c = Datetime.parse(depDate +arrivalTime);
                }else 
                    attendee.Arrival_Time__c = NULL;
                if(departureTime!= '' && departureTime!=NULL){
                    departureTime= departureTime.toLowerCase().replace('a.m.','am').replace('p.m.','pm');
                    attendee.Departure_Time__c= Datetime.parse(depDate +departureTime );
                }else 
                    attendee.Departure_Time__c= NULL; 
                
                attendee.Timestamp_of_Recap__c = System.now();
                update attendee;
            }
            update deposition;
            upsert uploadFiles ;
            PageReference pg = new PageReference('/apex/DragDropUpload?isPortalForCourtReporterAndVideographer=true&id='+uploadFiles.id+'&firm='+ EncodingUtil.urlEncode(deposition.Firm_Name__c,'UTF-8')+'&folderName='+deposition.Name);
            return pg;
        }catch(Exception e){
            addMessage(e.getMessage());
            isErr  = false;
        }
        return null;
    }
    private void addMessage(String msg){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,msg));
        isErr = true;
    }
}