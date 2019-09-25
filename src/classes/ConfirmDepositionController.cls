public without sharing class ConfirmDepositionController {
    public Boolean isSucess{get;set;}
    private Boolean hasMissingParameterMsgAdded = false;
    public Deposition__c deposition{get;set;}
    public ConfirmDepositionController (){
        isSucess = false;
        
        String depId = ApexPages.currentpage().getParameters().get('code');
        if(depId != NULL && depId != '')
            this.deposition = loadDeposition(depId );
        else
            this.deposition = new Deposition__c();
        String selectedFirm = deposition.Primary_Court_Reporting_Firm__r.Name;
        system.debug('$$$'+selectedFirm );
        
        Cookie Cookie= new Cookie('firmCookie', null,null,0,false);
        ApexPages.currentPage().setCookies(new Cookie[]{Cookie});
        Cookie= new Cookie('firmCookie', selectedFirm,null,-1,false);
        ApexPages.currentPage().setCookies(new Cookie[]{Cookie});
    }
    //======================================================================//
    //Load deposition
    //======================================================================//
    private Deposition__c loadDeposition(String depId ) {
        List<Deposition__c>lstDeps =  [SELECT Id,Firm_Name__c, Event_Type_Lowercase__c,Deposition_Date__c ,Deposition_Time__c ,Time_Zone__c,
                                       Event_Location__c, Deposition_Services__c,Client_Notes__c,Hiring_Attorney__c,Hiring_Firm__c,
                                       Primary_Court_Reporting_Firm__r.Name,Primary_Court_Reporting_Firm__r.Phone__c
            FROM Deposition__c WHERE Id = : depId Limit 1
        ];
        if(lstDeps.size()>0)
            return lstDeps [0];
            
        return new Deposition__c();
    }
    public PageReference updateDeposition(){
        String depostionId = '';
        String code ='';
        String type ='';
        Boolean isErr = false;
        if(!String.isBlank(ApexPages.currentPage().getParameters().get('code'))) {
            depostionId = ApexPages.currentPage().getParameters().get('code').trim();
        }else{
            if(!hasMissingParameterMsgAdded)
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Fatal, Label.Msg_on_Missing_Parameter));
            hasMissingParameterMsgAdded = true;
            isErr = true;
        }
        
        /*if(!String.isBlank(ApexPages.currentPage().getParameters().get('code'))) {
            code = ApexPages.currentPage().getParameters().get('code').trim();
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Fatal,'Code parameter missing in url!!!'));
            isErr = true;
        }*/
        
        if(!String.isBlank(ApexPages.currentPage().getParameters().get('type'))) {
            type= ApexPages.currentPage().getParameters().get('type').trim();
            if(type != 'R'  && type !='C' && type != 'V' && hasMissingParameterMsgAdded == false){
               // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Fatal,'Invalid Type parameter value!!!'));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Fatal,Label.Msg_on_Missing_Parameter));
                hasMissingParameterMsgAdded = true;
                isErr = true;
            }
                
        }else{
            if(!hasMissingParameterMsgAdded)
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Fatal,Label.Msg_on_Missing_Parameter));
            hasMissingParameterMsgAdded = true;
            isErr = true;
        } 
        
        if(isErr)
            return null;
            
        
        if(deposition == null){
            deposition  = new Deposition__c();
            return null;
        }else{
            try{
                if(type == 'R' )
                    deposition.Confirm_Reporter__c = 'Confirmed';
                else if(type == 'C' )
                    deposition.Confirm_Client__c = 'Confirmed';
                else if(type == 'V' )
                    deposition.Confirm_Video_Tech__c= 'Confirmed';
                update deposition;
                isSucess = true;
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'We have successfully confirmed Deposition.'));
            }Catch(Exception e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Fatal,e.getMessage()));
            }
        }
        return null;
    }
   
   
    
    public Deposition__c validateDespositionAndAttendees(String depositionID,String code){
      List<Deposition__c> lstDeposition = [SELECT Id,Event_Type_Lowercase__c,Deposition_Date__c,Deposition_Time__c,Time_Zone__c
                                           ,Hiring_Attorney__c,Hiring_Firm__c,Deposition_Services__c,
                                           Client_Notes__c,Event_Location__c,Deponent_Name__c,Case_Name__c,Location_contact__c 
                                           FROM Deposition__c WHERE Name =:depositionID AND Id=:code];
      if(lstDeposition.size() == 0 && hasMissingParameterMsgAdded == false) {
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Fatal,'Deposition Number OR Code is invalid.Please check and retry'));
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Fatal,Label.Msg_on_Missing_Parameter));
          hasMissingParameterMsgAdded = true;
          return null;
      }
      
      /*List<Attendee__c> lstAttendee = [SELECT Id,Email__c FROM Attendee__c WHERE Deposition__c = :lstDeposition[0].Id
                                       AND Email__c = :email];
      if(lstAttendee.size() == 0) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Fatal,'You are not authorized to confirm the deposition'));
        return null;
      } */
      return lstDeposition[0];                                
    }
    
  
}