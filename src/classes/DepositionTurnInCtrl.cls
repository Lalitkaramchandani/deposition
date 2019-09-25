/**************************************************
                Name        : DepositionTurnInCtrl
                Author      : Lalit karamchandani
                Purpose     : Deposition details                
                Created Date: 04 FEB 2019
                
                
*****************************************************/
global class DepositionTurnInCtrl {
    String depId = '';
    String attendeeId;
    ApexPages.StandardController controller ;
    String searchText='';
    Boolean isaddSearch;
    Boolean isLoaded;
    public Boolean isValidEntry{get;set;}
    private String rateSheetId;
    public Boolean isInvoiced{get;set;}
    public RateSheetTotal rtTotal{get;set;}
    public List<RateSheetItemData> rtItems{get;set;}
    public List<S3FileModel>lstFiles{get;set;}
    public List<S3FileModel>listFiles{get;set;}
    public String folderId{get;set;}
    public Integer selectedDepFileIndex{get;set;}
    public User usr{get;set;}
    public time depStartTime{get;set;}
    public time depEndTime{get;set;}
    public List<Deposition__c>lstDepositions{get;set;}
    public string stepname{get;set;}
    public string curUserRole{get;set;}
    public integer pageNo{get;set;}
    public integer removeIndex{get;set;}
    private string deposId;
    public Deposition__c depositionRec{get;set;}
    public Firm__c firm{get;set;}
    // public List<Attendee__c> attendeeRecs{get;set;}
    public Attendee__c curUserAttendee{get;set;}
    public boolean NoTranscript{get;set;}
    public List<AttendeeWrapper> attendeeWrapperList{get;set;}
    public Boolean prepareAttendee{get;set;}
    
    public Boolean isVideo{get;set;}
    public Boolean isExpert{get;set;}
    public Boolean isTechnical{get;set;}
    public Boolean readonly{get;set;}
    public Boolean isMediTechExpertVideo{get;set;}
    public Boolean showSurcharge{get;set;}
    
    public List<Rate_Sheet_Item__c> rtSheetItem{get;set;}
    
    public Map<String, List<RateSheetItemData>> rtItemsWithType{get;set;}
    public Map<String, Boolean> typeShowExpedite{get;set;}
    public Boolean isrtItemsWithType{
        get{
            return !rtItemsWithType.isEmpty();
        }set;
    }
    public Boolean isrtItemsPrimary{
        get{
            return rtItemsWithType.containsKey('Primary Transcript') && rtItemsWithType.get('Primary Transcript').size()>0;
        }set;
    }
    public Boolean isrtItemsOther{
        get{
            return rtItemsWithType.containsKey('Other Transcript') && rtItemsWithType.get('Other Transcript').size()>0;
        }set;
    }
    public Boolean isrtItemsReal{
        get{
            return rtItemsWithType.containsKey('Realtime Transcript') && rtItemsWithType.get('Realtime Transcript').size()>0;
        }set;
    }
    public Boolean isrtItemsRough{
        get{
            return rtItemsWithType.containsKey('Rough Draft Transcript') && rtItemsWithType.get('Rough Draft Transcript').size()>0;
        }set;
    }
    public Boolean isrtItemsTrad{
        get{
            return rtItemsWithType.containsKey('Traditional Video') && rtItemsWithType.get('Traditional Video').size()>0;
        }set;
    }
    public Boolean isrtItemsTrans{
        get{
            return rtItemsWithType.containsKey('Transcript') && rtItemsWithType.get('Transcript').size()>0;
        }set;
    }
    
    public Boolean showExpeditePrimary{
        get{
            return typeShowExpedite.containsKey('Primary Transcript') && typeShowExpedite.get('Primary Transcript');
        }set;
    }
    public Boolean showExpediteCopy{
        get{
            return typeShowExpedite.containsKey('Other Transcript') && typeShowExpedite.get('Other Transcript');
        }set;
    }
    
    
    
    public List<SelectOption> getDepositionExpedite(){
        return getOptionsFromPicklist(Deposition__c.Expedite__c.getDescribe().getPickListValues());
    }
    /**
     *  Method will return list of Select option from specify picklist
    **/
    private List<SelectOption> getOptionsFromPicklist(List<Schema.Picklistentry> picklistEntries){
        List<SelectOption> optionList = new List<SelectOption>();
        for(Schema.Picklistentry ple : picklistEntries) {
          optionList.add(new SelectOption(ple.getLabel(), ple.getValue()));
        }
        return optionList;
    }
    public List<AttendeeData> searchContacts{get;set;}
    public Boolean addNewAttendee{get;set;}
    public Boolean isSearchAttendee{get;set;}
    public Boolean isAlreadyMember{get;set;}
    public String partyAddedMsg{get;set;}
    public Contact newContact{get;set;}
    public Deposition__c conSearch{get;set;}
    public ContactInput conInput{get;set;}
    /* construct */
    
    public DepositionTurnInCtrl() {
        this.controller  = new ApexPages.StandardController( new Deposition__c());
        folderId = '';
        init();
        initialization();
        curUserRole = 'Attorney';
        // curUserRole = getCurretnUserRole();
    }
    public DepositionTurnInCtrl(ApexPages.StandardController controller) {
        this.controller  = controller ;
        init();
        initialization();
        curUserRole = 'Attorney';
        // curUserRole = getCurretnUserRole();
    }
    /*Post init*/
    public void postInit(){
        String query='SELECT Id, Contact__c, Primary_Attorney__c, Contact__r.Name, Contact__r.Account.Name,Recap_Notes__c,'
                    +' Notes__c, Deposition_Services__c,Expedite_Level__c, Shipping_Notes__c,Role__c, Contact__r.Email'
                    +' FROM Attendee__c WHERE Deposition__c=\''+deposId+'\' ';
        if(usr.ContactId!=NULL){
            query+=' AND Contact__c=\''+ usr.ContactId + '\'';
            List<Attendee__c> attendees = Database.query(query);
            if(attendees.isEmpty()){
                Attendee__c att = new Attendee__c(Deposition__c=deposId, Role__c='Attorney', Contact__c=usr.ContactId,Email__c=usr.Contact.Email);
                insert att;
                att.Contact__r = usr.Contact;
                curUserAttendee = att;
                //readonly = true;
            }else{
                curUserAttendee = attendees[0];
                curUserRole = curUserAttendee.Role__c;
                //readonly = curUserRole=='Attorney';
            }
            attendeeId = curUserAttendee.Id;
            isValidEntry = true;
        } else if(isValidEntry){
            query+=' AND Id=\''+ attendeeId + '\'';
            List<Attendee__c> attendees = Database.query(query);
            if(attendees.isEmpty()){
                isValidEntry = false;
            }else{
                curUserAttendee = attendees[0];
                curUserRole = curUserAttendee.Role__c;
            }
            //readonly = curUserRole=='Attorney';
        }
        /*if(readonly){
            DateTime restricttion = System.now().addDays(2);
            if(depositionRec.Deposition_Date__c ==null || depositionRec.Deposition_Date__c<= restricttion){
                readonly = true;
            }else{
                readonly = false;
            }
        }*/
    }
    public void initialization(){
        isValidEntry = false;
        NoTranscript = false;
        deposId = ApexPages.currentPage().getParameters().get('id');
        if(ApexPages.currentPage().getParameters().containsKey('attendeeId')){
            attendeeId = ApexPages.currentPage().getParameters().get('attendeeId');
        }else if(ApexPages.currentPage().getParameters().containsKey('attendeeid')){
            attendeeId = ApexPages.currentPage().getParameters().get('attendeeid');
        }
        isValidEntry = attendeeId!=null || attendeeId=='' || (attendeeId instanceof Id);
        attendeeWrapperList=new List<AttendeeWrapper>();
        prepareAttendee = true;
        rtSheetItem = new List<Rate_Sheet_Item__c>();
        readonly = false;
        if(String.isNotBlank(deposId)){
            depositionRec=getDeposition(deposId);
            firm = DepositionHelper.fetchFirm( 'Lexitas' );
            if(depositionRec.Primary_Court_Reporting_Firm__c!=null){
                firm = [SELECT Id, Name, Community_Header__c,Community_Footer__c, Web_Page_Footer_HTML__c , Web_Page_Header_HTML__c,
                        Scheduling_Email_Address__c, Phone__c
                        FROM Firm__c 
                        WHERE Id=: depositionRec.Primary_Court_Reporting_Firm__c  LIMIT 1];
                
                Cookie Cookie= new Cookie('firmCookie', null,null,0,false);
                ApexPages.currentPage().setCookies(new Cookie[]{Cookie});
                Cookie= new Cookie('firmCookie', firm.Name,null,-1,false);
                ApexPages.currentPage().setCookies(new Cookie[]{Cookie});
            }
        }
        rtItems = new List<RateSheetItemData>();
        rtItemsWithType = new Map<String, List<RateSheetItemData>>();
        typeShowExpedite = new Map<String, Boolean>();
        stepname='one';
        pageNo=1;
    }
    
    private void init(){
        isInvoiced = isLoaded = false;
        
        usr = [select id,ContactId,Contact.Account.COD_Warning__c, Contact.Email From User WHERE ID =:Userinfo.getUserId()];
        lstFiles = new List<S3FileModel>();
        listFiles = new List<S3FileModel>();
        if(ApexPages.currentPage()!=NULL){
            searchText = String.valueOf(ApexPages.currentPage().getParameters().get('searchText'));
            if(searchText!=NULL && searchText.trim().length()>0)
                searchText = searchText.replaceAll(' ','%20');
        }
    }
    
    
    private Deposition__c getDeposition(Id did){
        List<Deposition__c> depositions=new List<Deposition__c>();
        depositions=[Select id, Name,Firm_Name__c, Expedite__c ,Deponent_Name__c,Deposition_Services__c, Deposition_Date__c ,
                    Event_Type_Lowercase__c,Primary_Court_Reporting_Firm__c,
                    Transcript_page_count__c, Exhibit_page_count__c, Errata_Notes__c, Errata_Needed__c,Portal_Deposition_Services__c,
                    State_Rule__c, State_Rule__r.Read_and_Sign_Required__c, Start_Time__c, Stop_Time__c, Starts_Time__c,Ends_Time__c
                    from Deposition__c where id=:did];
        if(depositions!=null && depositions.size()>0){
            DateTime restricttion = System.now().addDays(2);

            if(depositions[0].Deposition_Date__c ==null || depositions[0].Deposition_Date__c<= restricttion){
                readonly = true;
            }

            preparePortalDepService(depositions);
            return depositions[0];
        }else{
            return null;
        }
    }
    void preparePortalDepService(List<Deposition__c> depositions) {
        Set<String> values = new Set<String>{'Expedite','Traditional Video','Realtime','Rough Draft','Interpreter','Synchronized Video'};
        for(Deposition__c dep: depositions){
            
            if(dep.Starts_Time__c!=null){
                depStartTime = Time.newInstance(dep.Starts_Time__c.hour(), dep.Starts_Time__c.minute(),0,0);
            }else if(dep.Start_Time__c!=null){
                depStartTime = Time.newInstance(dep.Start_Time__c.hour(), dep.Start_Time__c.minute(),0,0);
            }
            if(dep.Ends_Time__c!=null){
                depEndTime = Time.newInstance(dep.Ends_Time__c.hour(), dep.Ends_Time__c.minute(),0,0);
            }else if(dep.Stop_Time__c!=null){
                depEndTime = Time.newInstance(dep.Stop_Time__c.hour(), dep.Stop_Time__c.minute(),0,0);
            }
            
            
            System.debug(depStartTime);
            System.debug(depEndTime);
            String pSrvice = String.isEmpty(dep.Portal_Deposition_Services__c) ? '' : dep.Portal_Deposition_Services__c+';';
            List<String> pSrvices = pSrvice.split(';');
            if(String.isNotEmpty(dep.Deposition_Services__c)){
                for(String val: dep.Deposition_Services__c.split(';')){
                    val = val.trim();
                    if(values.contains(val) && !pSrvices.contains(val)){
                        pSrvice+=val+';';
                    }
                }
            }
            pSrvice = pSrvice.removeEnd(';');
            dep.Portal_Deposition_Services__c = pSrvice;
        }
    }
    private List<Attendee__c> getAttendees(Id did){
        List<Attendee__c> attendeeRecs=new List<Attendee__c>();
        attendeeRecs=[Select id, Contact__c, Primary_Attorney__c, Contact__r.Name, Contact__r.Account.Name,Recap_Notes__c,Notes__c, Deposition_Services__c,Expedite_Level__c, Shipping_Notes__c 
                        FROM Attendee__c 
                        WHERE Deposition__c =:did
                        AND Role__c not in ('Court Reporter','Videographer/Technician','Interpreter')];
        return attendeeRecs;
    }
    /*private String getCurretnUserRole(){
        String curRole = '';
        List<Attendee__c> attendees = [SELECT Id, Role__c FROM Attendee__c WHERE Contact__c =: usr.ContactId AND Deposition__c=:deposId];
        if(!attendees.isEmpty()){
            curRole = attendees[0].Role__c != NULL ? attendees[0].Role__c : '';
        }else{
            curRole = 'Attorney';
        }
        return curRole;
    }*/
    public void addAttendeesRow(){
        Attendee__c att = new Attendee__c(Role__c='Attorney');
        if(depositionRec.Id!=NULL){
            att.Deposition__c = depositionRec.Id;
        }
        att.Deposition_Services__c = depositionRec.Deposition_Services__c;
        if(String.isNotBlank(depositionRec.Expedite__c)){
            att.Expedite_Level__c = depositionRec.Expedite__c;
        }
        Boolean isSynVideo = depService.contains('Synchronized Video');
        attendeeWrapperList.add(new AttendeeWrapper(attendeeWrapperList.size(),att, depService, !NoTranscript));
    }
    public void removeAttendeesRow(){
        AttendeeWrapper attData = attendeeWrapperList.remove(removeIndex);
        integer i=0;
        for(AttendeeWrapper cm : attendeeWrapperList){
            cm.index = i++;
        }
        if(attData.atten.Id!=NULL){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'Attendee has been removed!'));
            // delete attData.atten;
        }
    }
    private void prepareDepositionServices(Boolean isCheck){
        if(String.isBlank(depositionRec.Deposition_Services__c)){
            depositionRec.Deposition_Services__c='';
        }
        depositionRec.Deposition_Services__c += (depositionRec.Deposition_Services__c!='' ? ';':'');
        /*if(isMediTechExpertVideo!=null){
            depositionRec.Deposition_Services__c=maintainValue(depositionRec.Deposition_Services__c, 'Medical/Technical/Expert/Video', isMediTechExpertVideo, isCheck);
            if(!isMediTechExpertVideo && isCheck){
                depositionRec.Deposition_Services__c=maintainValue(depositionRec.Deposition_Services__c, 'Traditional Video', isMediTechExpertVideo, isCheck);
            }
        }*/
        depositionRec.Deposition_Services__c=depositionRec.Deposition_Services__c.removeEnd(';');
    }
    
    /*
    private String maintainValue(String source, String val, Boolean isAdd, Boolean isCheck){
        Boolean isExist=false;
        if(source.startsWith(val) && source.endsWith(val) && source.length() == val.length()){
            if(!isCheck && !isAdd){
                source='';
            }
            isExist=true;
        }else if(source.startsWith(val+';') && source.endsWith(val+';') ){
            if(!isCheck && !isAdd){
                source='';
            }
            isExist=true;
        }else if(source.contains(';'+val+';')){
            if(!isCheck && !isAdd){
                source=source.replace(';'+val,'');
            }
            isExist=true;
        }else if(source.contains(';'+val) && source.endsWith(val)){
            if(!isCheck && !isAdd){
                source=source.removeEnd(';'+val);
            }
            isExist=true;
        }
        if(isCheck){
            switch on val{
                when 'Video'{
                    isVideo = isExist;
                }
                when 'Expert'{
                    isExpert = isExist;
                }
                when 'Medical/Technical/Expert/Video'{
                    isMediTechExpertVideo = isExist;
                }
                when 'Traditional Video'{
                    isMediTechExpertVideo = isExist;
                }
                when 'Technical'{
                    isTechnical = isExist;
                }
                when else{
                    
                }
            }
        }else if(!isExist && isAdd){
            source+=val+';';
        }
        return source;
    }
    */
    public PageReference onAddAdditional(){
        Savepoint sp =Database.setSavepoint();
        try{
            onSubmit();
            String fieldsCSV = prepareDepoField('Deposition__c');
            List<Deposition__c> curr = Database.query('SELECT '+fieldsCSV+' FROM Deposition__c WHERE Id=:deposId');
            if(!curr.isEmpty()){
                Deposition__c cloneDep = curr[0].clone(false, true, false, false);
                cloneDep.Transcript_page_count__c = '0';
                cloneDep.Exhibit_page_count__c  = '0';
                cloneDep.Starts_Time__c = null;
                cloneDep.Ends_Time__c = null;
                cloneDep.Google_Drive_Folder_Id__c = null;
                insert cloneDep;
                String attFieldsCSV = prepareDepoField('Attendee__c');
                
                List<Attendee__c> currAtt = Database.query('SELECT '+attFieldsCSV+' FROM Attendee__c WHERE Deposition__c=:deposId');
                List<Attendee__c> clonedAtt = new List<Attendee__c>();
                Integer attendeeIndex = 0;
                for(Attendee__c att : currAtt){
                    Attendee__c clAtt = att.clone(false, true, false, false);
                    clAtt.Deposition__c = cloneDep.Id;
                    if(attendeeId==att.Id){
                        attendeeIndex = clonedAtt.size();
                    }
                    clonedAtt.add(clAtt);
                }
                insert clonedAtt;
                return new PageReference('/DepositionTurnIn?id='+cloneDep.Id +'&attendeeid='+clonedAtt[attendeeIndex].Id);
            }
        }catch(Exception excp){
            Database.rollback(sp);
            ApexPages.addMessages(excp);
        }
        return null;
    }
    String prepareDepoField(String sName){
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(sName).getDescribe().fields.getMap();
        String fields = '';
        for(String key : fieldMap.keySet()){
            SObjectField field= fieldMap.get(key);
            DescribeFieldResult fRes = field.getDescribe();
            if(fRes.isAccessible() && fRes.isCreateable()){
                String fName = fRes.getLocalName();
                if(fName.toLowerCase()=='Deponent_Name__c'){
                    continue;
                }
                fields+=fName +',';
            }
        }
        fields = fields.removeEnd(',');
        fields = fields == '' ? 'Name' : fields;
        return fields;
    }
    public PageReference onSubmit(){
        // isInvoiced = true;
        // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Invoice create,you will receive an email soon or refer Order Id: '));
        // if(isInvoiced)
        // return null;
        Id conId;
        if(usr.ContactId != NULL){
           conId = usr.ContactId;
        } 
        if(conId == null && curUserAttendee != null){
            conId = curUserAttendee.Contact__c;
        }
        List<Deposition__c> depos = [SELECT Id, Event_Type_Lowercase__c FROM Deposition__c WHERE Id=:deposId];
        String eventType = '';
        if(!depos.isEmpty()){
            if(String.isNotEmpty(depos[0].Event_Type_Lowercase__c)){
                eventType = depos[0].Event_Type_Lowercase__c;
            }
        }
        List<Attendee__c> curUserAttendee =[ select id,Role__c, Deposition_Date__c,Contact__c, Deposition__c,Contact__r.AccountId, Deposition_Location__c, Deposition_Location__r.name,
                       Deposition__r.Deposition_Location__c,Deposition__r.Case_Name__c, Deposition__r.Deponent_Name__c,
                       Deposition__r.Billing_Notes__c, Deposition__r.Corporate_Client_Source__c, 
                       Deposition__r.Transcript_page_count__c,Standing_Orders_del__c, Deposition__r.Page_Count__c, 
                       Deposition__r.Exhibit_page_count__c, Deposition__r.Post_event_Notes__c, Contact__r.Account.Industry
                       ,Deposition__r.Event_Location__c,Primary_Attorney__c,Deposition__r.Deposition_Time__c ,Deposition__r.Expedite__c ,
                       Deposition__r.Deposition_Services__c,Deposition__r.Summary_of_Billable_Services__c,
                       Deposition__r.Insurance_Claim_Info__c,Deposition__r.Claims_Professional__c
                       ,Deposition__r.State__c,Deposition__r.Matter_Number__c,Expedite_Level__c,
                       Contact__r.Account.Financial_Notes__c, Contact__r.Financial_Notes__c
                       FROM Attendee__c 
                       WHERE Contact__c=: conId and Deposition__c =: deposId];
        
        savepoint sp = Database.setSavepoint();
        try{
            if(!curUserAttendee.isEmpty()){
                Attendee__c attendee = curUserAttendee[0];
                String invType = '';
                System.debug(attendee.Role__c);
                System.debug(curUserRole);
                Invoice__c newInvoice = new Invoice__c(Attendee__c = attendee.id, Contact__c = attendee.Contact__c,
                                            Account__c = attendee.Contact__r.AccountId,
                                              Deposition__c = attendee.Deposition__c,
                                              Claim_No_Text__c= attendee.Deposition__r.Insurance_Claim_Info__c,
                                              Claims_Professional_Text__c= attendee.Deposition__r.Claims_Professional__c,
                                              Matter_Number_Text__c= attendee.Deposition__r.Matter_Number__c,
                                               Deponent_Name__c=attendee.Deposition__r.Deponent_Name__c
                                               ,Ordering_Party__c=attendee.Primary_Attorney__c);
                newInvoice.Type__c = 'Other';
                switch on attendee.Role__c {
                    when 'Court Reporter'{
                       newInvoice.Type__c = 'Reporter';
                    }
                    when 'Videographer/Technician' {
                       newInvoice.Type__c = 'Video/Tech';
                    }
                    when 'Interpreter'{
                        newInvoice.Type__c = 'Interpreter';
                    }
                    when else{
                        // newInvoice.Type__c = 'Other';
                    }
                }
                
                List<Rate_Sheet__c> rateSheets=[select id,Name, Show_Quantity_Column__c, Show_Rate_Column__c, Show_Rows__c,Payment_Term_Days__c
                                     FROM Rate_Sheet__c WHERE id=: rateSheetId ];
                if(!rateSheets.isEmpty()){
                    //rateSheetName = rateSheet[0].Name;
                    newInvoice.Rate_Sheet__c = rateSheets[0].id;
                    newInvoice.Show_Quantity_Column__c=rateSheets[0].Show_Quantity_Column__c;
                    newInvoice.Show_Rate_Column__c=rateSheets[0].Show_Rate_Column__c;
                    newInvoice.Show_Rows__c =rateSheets[0].Show_Rows__c ;
                    newInvoice.Payment_Term_Days__c=rateSheets[0].Payment_Term_Days__c;
                }
                // to avoid sending emails
                InvoiceEmailNotificationQueueable.SEND_NOTIFICATION = false;
                insert newInvoice;
                attendee.Expedite_Level__c  = String.isNotBlank(attendee.Expedite_Level__c ) ? attendee.Expedite_Level__c  : '';
                List<Invoice_Item__c> invItems = new List<Invoice_Item__c>();
                Integer orderNo=1;
                for(String key: rtItemsWithType.keySet()){
                    for(RateSheetItemData rtItem: rtItemsWithType.get(key)){
                        // for(RateSheetItemData rtItem:rtItems){
                            if(rtItem.invoiceItem.Rate_Sheet_Item__c!=NULL && rtItem.invoiceItem.Item__c!=NULL
                                && rtItem.quantity != NULL && rtItem.quantity > 0){
                                
                                Invoice_Item__c invItem = rtItem.invoiceItem;
                                invItem.Quantity__c = key =='Traditional Video' ? rtItem.invoiceItem.Quantity__c: rtItem.quantity;
                                invItem.Invoice__c = newInvoice.Id;
                                invItem.Attendee__c=rtItem.AttendeeId;
                                invItem.Order__c = orderNo++;
                                invItems.add(invItem);
                            }
                        // }
                    }
                }
                insert invItems;
                isInvoiced = true;
                
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 
                    'Thank you for your help with this '+ eventType +'. We have emailed you a statement of payment for your services.'
                    ));
                sendEmail(newInvoice.Id, Userinfo.getUserId(), conId);
                // return new PageReference('/'+newInvoice.Id);
            }
            else{
                ApexPages.addMessage(new  ApexPages.Message(ApexPages.Severity.ERROR, 'Party Did not found!'));
            }
        }catch(Exception excp){
            Database.rollback(sp);
            
            ApexPages.addMessages(excp);
        }
        
        return null;
    }
    /*
    Integer getExpediteModification(String expedite){
        
        switch on expedite{
            when 'Same Day Turnaround'{
                return 110;
            }
            when 'Next Day Turnaround'{
                return 100;
            }
            when '2 Day Turnaround' {
                return 90;
            }
            
            when '3 Day Turnaround' {
                return 80;
            }
            
            when '4 Day Turnaround' {
                return 70;
            }
            
            when '5 Day Turnaround' {
                return 60;
            }
            
            when '6 Day Turnaround' {
                return 50;
            }
            
            when '7 Day Turnaround' {
                return 40;
            }
            
            when '8 Day Turnaround' {
                return 30;
            }
            
            when '9 Day Turnaround' {
                return 20;
            }
            when else {
                return 0;
            }
        }
    }
    */
    public PageReference onQuantityChange(){
        preprareTotal();
        return null;
    }
    void preprareTotal(){
        Integer itemc = 0;
        Decimal itemq = 0;
        Decimal itemt = 0;
        Decimal itemSelected = 0;
        for(String key : rtItemsWithType.keySet()){
            
            for(RateSheetItemData rtData : rtItemsWithType.get(key)){
                itemq+= rtData.quantity;
                Decimal price = (rtData.invoiceItem.Price__c!=NULL ? rtData.invoiceItem.Price__c : 0);
                Decimal modify =(rtData.invoiceItem.Modification__c!=NULL ? rtData.invoiceItem.Modification__c : 0);
                itemt+=  price * rtData.quantity * (100 +modify ) / 100;
                itemc++;
                if(rtData.quantity>0){
                    itemSelected++;
                }
            }
        }
        rtTotal = new RateSheetTotal(itemc, itemq, itemt);
        rtTotal.invoicedItemCount = itemSelected;
    }
    
    public PageReference nextStep(){
        pageNo++;
        if(pageNo==2){
            if(String.isEmpty(curUserRole)){
                pageNo++;
            }else {
                String curRole = curUserRole.toLowerCase();
                if(!(curRole =='Court Reporter' || curRole =='Videographer/Technician')){
                    pageNo++;
                }
            }
        }
        // pageNo+=3;
        //  curUserRole='Court Reporter';
        // curUserRole='Videographer/Technician';
        prepareSectionData(true);
        return NULL;
    }
    public PageReference previousStep(){
        pageNo--;
        
        if(pageNo==2){
            if(String.isEmpty(curUserRole)){
                pageNo--;
            }else {
                String curRole = curUserRole.toLowerCase();
                if(!(curRole =='Court Reporter' || curRole =='Videographer/Technician')){
                    pageNo--;
                }
            }
        }
        if(pageNo==1){
            update depositionRec;
            if(curUserAttendee!=NULL){
                update curUserAttendee;
            }
            PageReference pf = Page.DepositionTurnin;
            pf.getParameters().put('id',deposId);
            pf.getParameters().put('attendeeid',attendeeId);
            pf.setRedirect(true);
            return pf;
        }
        prepareSectionData(false);
        return NULL;
    }
    void prepareSectionData(Boolean isNext){
        
        if(pageNo==2){
            // System.debug('================='+depositionRec.Deposition_Services__c);
            // depositionRec.Deposition_Services__c = depositionRec.Deposition_Services__c== null ? '' : depositionRec.Deposition_Services__c;
            depositionRec.Portal_Deposition_Services__c = depositionRec.Portal_Deposition_Services__c == null ? '' : depositionRec.Portal_Deposition_Services__c;
            depositionRec.Deposition_Services__c = depositionRec.Portal_Deposition_Services__c;
            if(String.isNotBlank(depositionRec.Expedite__c) && depositionRec.Expedite__c!='none' ){
                if(!depositionRec.Deposition_Services__c.contains('Expedite')){
                    depositionRec.Deposition_Services__c+= String.isNotBlank(depositionRec.Deposition_Services__c) ? ';':'';
                    depositionRec.Deposition_Services__c+='Expedite';
                }
                system.debug('->>>>>'+depositionRec.Portal_Deposition_Services__c);
                if(!depositionRec.Portal_Deposition_Services__c.contains('Expedite')){
                    depositionRec.Portal_Deposition_Services__c+= String.isNotBlank(depositionRec.Portal_Deposition_Services__c) ? ';':'';
                    depositionRec.Portal_Deposition_Services__c+='Expedite';
                }
                system.debug('->>>>>'+depositionRec.Portal_Deposition_Services__c);
            }
            if(NoTranscript){
                depositionRec.Transcript_Status__c = 'No Transcript';
            }else{
                depositionRec.Transcript_Status__c = '';
            }
            loadFilesInDataTable();
            prepareDepositionServices(true);
            
            if(curUserRole=='Court Reporter'){
                prepareCourtReporterData();
            }
            DateTime dt;
            if(depositionRec.Deposition_Date__c != null){
                dt= DateTime.newInstance(depositionRec.Deposition_Date__c.year(), 
                            depositionRec.Deposition_Date__c.month(), 
                            depositionRec.Deposition_Date__c.day(),0,0,0);
            }
            if(depositionRec.Starts_Time__c!=null){
                depStartTime = Time.newInstance(depositionRec.Starts_Time__c.hour(), depositionRec.Starts_Time__c.minute(),0,0);
            }
            if(depositionRec.Ends_Time__c!=null){
                depEndTime = Time.newInstance(depositionRec.Ends_Time__c.hour(), depositionRec.Ends_Time__c.minute(),0,0);
            }
            depositionRec.Start_Time__c = depositionRec.Start_Time__c == null ? dt : depositionRec.Start_Time__c;
            depositionRec.Stop_Time__c = depositionRec.Stop_Time__c == null ? dt : depositionRec.Stop_Time__c;
            if(isNext && !readonly){
                update depositionRec;
                if(curUserAttendee!=null){
                    update curUserAttendee;
                }
            }
        }else if(pageNo==3){
            prepareDepositionServices(false);
            depositionRec.Starts_Time__c = depStartTime;
            depositionRec.Ends_Time__c = depEndTime;
            if(depositionRec.Start_Time__c>depositionRec.Stop_Time__c){
                ApexPages.addMessage(new  ApexPages.Message(ApexPages.Severity.Info, 'End time should be greater than Start time!'));
                pageNo--;
                return;
            }
            if((depositionRec.Transcript_page_count__c!=NULL && !depositionRec.Transcript_page_count__c.isNumeric() )
                || (depositionRec.Exhibit_page_count__c!=NULL && !depositionRec.Exhibit_page_count__c.isNumeric())){
                if(!depositionRec.Transcript_page_count__c.isNumeric()){
                    depositionRec.Transcript_page_count__c.addError('Invalid number!');
                }
                if( !depositionRec.Exhibit_page_count__c.isNumeric()){
                    depositionRec.Exhibit_page_count__c.addError('Invalid number!');
                }
                pageNo--;
                return;
            }
            if (String.isEmpty(depositionRec.Transcript_page_count__c)){
                depositionRec.Transcript_page_count__c = '0';
            }
            if(String.isEmpty(depositionRec.Exhibit_page_count__c)){
               depositionRec.Exhibit_page_count__c ='0'; 
            }
            Integer tCount = Integer.valueOf(depositionRec.Transcript_page_count__c);
            if(NoTranscript && tCount>0){
                ApexPages.addMessage(new  ApexPages.Message(ApexPages.Severity.ERROR, 'On the previous screen, you indicated that this deposition did not have a transcript. But on this screen, you entered a page count for the transcript.'));
                pageNo--;
                return;
            }
            calculatePageCount(false, false);
            if(prepareAttendee){
                attendeeWrapperList = new List<AttendeeWrapper>();
                List<Attendee__c> attendeeRecs=getAttendees(deposId);
                Boolean isSynVideo = depService.contains('Synchronized Video');
                for(Attendee__c attenRec :attendeeRecs){
                    AttendeeWrapper atData = new AttendeeWrapper(attendeeWrapperList.size(),attenRec, depService, !NoTranscript);
                    atData.atten.Deposition_Services__c=depositionRec.Deposition_Services__c;
                    atData.atten.Expedite_Level__c = String.isEmpty(atData.atten.Expedite_Level__c)
                                                        ? depositionRec.Expedite__c : atData.atten.Expedite_Level__c;
                    
                    if(curUserRole=='Videographer/Technician'){
                        atData.transcriptOrder = false;
                    }
                    
                    attendeeWrapperList.add(atData);
                }
                prepareAttendee = false;
            }
            if(isNext && !readonly){
                update depositionRec;
            }
        }else if(pageNo==4){
            Boolean isValid = true;
            isInvoiced = false;
            showSurcharge = false;
            Set<Id> attIds = new Set<Id>();
            List<Attendee__c> Attendees = new List<Attendee__c>();
            rtItemsWithType = new Map<String, List<RateSheetItemData>>();
            typeShowExpedite = new Map<String, Boolean>();
            Integer tranPgcount = 0;
            depositionRec.Deposition_Services__c = String.isBlank(depositionRec.Deposition_Services__c) ?'' : depositionRec.Deposition_Services__c;
            if(depositionRec.Transcript_page_count__c!=NULL && depositionRec.Transcript_page_count__c.isNumeric()){
                tranPgcount = Integer.valueOf(depositionRec.Transcript_page_count__c);
            }
            Boolean isExpedite = depositionRec.Deposition_Services__c.toLowerCase().contains('expedite');
            Integer realtimeCount = 0;
            Integer roughDraftCount = 0;
            for(Integer ind=attendeeWrapperList.size()-1; ind>-1; ind--){
                if(attendeeWrapperList[ind].atten.Contact__c == NULL){
                    attendeeWrapperList.remove(ind);
                    continue;
                }
                if(attendeeWrapperList[ind].realtimeOrder){
                    realtimeCount++;
                }
                if(attendeeWrapperList[ind].roughDraft){
                    roughDraftCount++;
                }
                String servies = '';
                if(!attendeeWrapperList[ind].expedite && String.isNotEmpty(attendeeWrapperList[ind].atten.Expedite_Level__c)){
                    attendeeWrapperList[ind].expedite = true;
                }
                
                servies+= attendeeWrapperList[ind].expedite ? 'Expedite;' : '';
                servies+= attendeeWrapperList[ind].videoOrder ? 'Traditional Video;' : '';
                servies+= attendeeWrapperList[ind].realtimeOrder ? 'Realtime;' : '';
                servies+= attendeeWrapperList[ind].roughDraft ? 'Rough Draft;' : '';
                servies+= attendeeWrapperList[ind].transcriptOrder ? 'Transcript;' : '';
                attendeeWrapperList[ind].atten.Deposition_Services__c = servies.removeEnd(';');
                
                if(attendeeWrapperList[ind].atten.Id!=NULL)
                    attIds.add(attendeeWrapperList[ind].atten.Id);
                
                if(curUserRole=='Court Reporter'){
                    if(attendeeWrapperList[ind].expedite && String.isEmpty(attendeeWrapperList[ind].atten.Expedite_Level__c)){
                    isValid = false;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                                            expeditedValidationError.replace('attendee', attendeeWrapperList[ind].atten.Contact__r.Name))); 
                }
                    String mapKey='';
                    String keyInd='';
                    if(attendeeWrapperList[ind].atten.Primary_Attorney__c){
                        mapKey = 'Primary Transcript';
                        keyInd='pt';
                        if(!rtItemsWithType.containsKey(mapKey)){
                            rtItemsWithType.put(mapKey, new List<RateSheetItemData>());
                            typeShowExpedite.put(mapKey, false);
                        }
                    }else{
                        mapKey = 'Other Transcript';
                        keyInd='ot';
                        if(!rtItemsWithType.containsKey(mapKey)){
                            rtItemsWithType.put(mapKey, new List<RateSheetItemData>());
                            typeShowExpedite.put(mapKey, false);
                        }
                    }
                    if(attendeeWrapperList[ind].transcriptOrder){
                        rtItemsWithType.get(mapKey).add(
                            new RateSheetItemData(new Invoice_Item__c(
                                    Quantity__c = tranPgcount,
                                    Price__c = 0, Invoice_Text__c = mapKey+' Page'), keyInd+rtItemsWithType.get(mapKey).size(),
                                    attendeeWrapperList[ind].atten, attendeeWrapperList[ind].expedite
                                ));
                        if(typeShowExpedite.containsKey(mapKey) && !typeShowExpedite.get(mapKey)
                            && attendeeWrapperList[ind].expedite){
                            typeShowExpedite.put(mapKey, true);
                        }
                    }
                }
                Attendees.add(attendeeWrapperList[ind].atten);
            }
            if(!isValid){
                pageNo--;
                return;
            }
            update depositionRec;
            if(curUserRole=='Court Reporter' && depositionRec.Deposition_Services__c.contains('Realtime')){
                if(realtimeCount>0){
                    rtItemsWithType.put('Realtime Transcript', new List<RateSheetItemData>());
                    rtItemsWithType.get('Realtime Transcript').add(
                        new RateSheetItemData(new Invoice_Item__c(
                            Quantity__c = tranPgcount*realtimeCount,
                            Price__c = 0, Invoice_Text__c = 'Realtime Transcript Page item'), 'rt1', 
                                              curUserAttendee, false
                                             ));
                    
                }
                if(roughDraftCount>0){
                    rtItemsWithType.put('Rough Draft Transcript', new List<RateSheetItemData>());
                    rtItemsWithType.get('Rough Draft Transcript').add(
                        new RateSheetItemData(new Invoice_Item__c(
                            Quantity__c = tranPgcount*roughDraftCount,
                            Price__c = 0, Invoice_Text__c = 'Rough Draft Transcript Page item'), 'rd1', 
                                              curUserAttendee, false
                                             ));
                    
                }
            }else if(curUserRole=='Videographer/Technician'
                    && depositionRec.Deposition_Services__c.contains('Traditional Video')){
                rtItemsWithType.put('Traditional Video', new List<RateSheetItemData>());
                rtItemsWithType.get('Traditional Video').add(
                    new RateSheetItemData(new Invoice_Item__c(
                            Quantity__c = calculateVideoHourWithTime(),
                            Price__c = 0, Invoice_Text__c = 'Traditional Video item'),
                            'tv'+rtItemsWithType.get('Traditional Video').size(),
                            curUserAttendee, false
                        ));
            }
            // deleting Attendees removed by users.
            List<Attendee__c> atts = [SELECT Id FROM Attendee__c 
                                        WHERE Deposition__c = :deposId AND Id not in :attIds
                                        AND Role__c not in ('Court Reporter','Videographer/Technician','Interpreter')];
            delete atts;
            upsert Attendees;
            // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Data saved!')); 
            try{
                prepareRateSheetItems(isExpedite);
                preprareTotal();
            }catch(Exception exp){
                System.debug(exp.getMessage());
                System.debug(exp.getstackTracestring());
            }
        }
    }
    @TestVisible
    String expeditedValidationError{
        get{
            return 'You have indicated that attendee has expedited their transcript but have not specified the expedite level. Please let us know how quickly they will need their transcript, e.g. 2-day, 3-day, etc.';
        }
    }
    public void prepareRateSheetItems(Boolean isExpedite){
        Id conId;
        if(usr.ContactId != NULL){
           conId = usr.ContactId;
        } 
        if(conId == null && curUserAttendee != null){
            conId = curUserAttendee.Contact__c;
        }
        List<Contact> contacts = [SELECT Id, Rate_Sheet__c FROM Contact WHERE Id=:conId];
        rateSheetId = NULL;
        if(!contacts.isEmpty()){
            rateSheetId = contacts[0].Rate_Sheet__c;
        }
        System.debug('--'+rateSheetId);
        if(rateSheetId == NULL){
            System.debug('--'+rateSheetId);
            Organization org = [SELECT Id, Name, IsSandbox FROM Organization LIMIT 1];
            if(org.IsSandbox){
                rateSheetId = Label.Portal_Deposition_Default_RateSheet_Id;
            }else{
                rateSheetId = 'a1mA00000072N73';
            }
        }
        List<Rate_Sheet__c> orgDefaultRateSheets = [SELECT Id, Name, Notes__c, Payment_Term_Days__c, 
                                                    Show_Quantity_Column__c, Show_Rate_Column__c, Show_Rows__c, 
                                                    Type__c, Show_After_Date_Surcharge__c, Alternative_Expedite__c
                                                    FROM Rate_Sheet__c WHERE Id=:rateSheetId];
        rateSheetId = null;
        if(!orgDefaultRateSheets.isEmpty()){
            rateSheetId = orgDefaultRateSheets[0].Id;
            for(Rate_Sheet_Item__c rtItem : [SELECT Id, Name, Type__c, Units_of_Measure__c, Item__c, 
                                                Price__c, Invoice_Text__c, Order_No__c, Default__c, Item_Description__c,
                                                Rate_Sheet__r.Alternative_Expedite__c
                                                FROM Rate_Sheet_Item__c
                                                WHERE Rate_Sheet__c =:rateSheetId AND Type__c!=NULL 
                                                ORDER By Type__c, Default__c]){
                Boolean isAdded = false;
                
                if(rtItem.Type__c=='Video' && rtItem.default__c=='Default Video'){
                    if(rtItemsWithType.containsKey('Traditional Video')){
                        List<RateSheetItemData> st = rtItemsWithType.get('Traditional Video');
                        // isAdded = !st.isEmpty();
                        for(Integer ind=0, len=st.size(); ind<len; ind++){
                            // st[ind] = new RateSheetItemData(rtItem, Integer.valueOf(st[ind].invoiceItem.Quantity__c),
                            //                     'tv'+ind, st[ind].attorneyName, st[ind].attendeeId);
                                st[ind] = new RateSheetItemData(rtItem, st[ind], 'tv'+ind );
                            st[ind].isQuantityEdit = false;
                        }
                    }
                }
                if(rtItem.Type__c == 'Transcript'){
                    if(rtItem.Default__c == 'Default Original'){
                        if(rtItemsWithType.containsKey('Primary Transcript')){
                            List<RateSheetItemData> st = rtItemsWithType.get('Primary Transcript');
                            // isAdded = !st.isEmpty();
                            for(Integer ind=0, len=st.size(); ind<len; ind++){
                                // st[ind] = new RateSheetItemData(rtItem, Integer.valueOf(st[ind].invoiceItem.Quantity__c),
                                //             'pt'+ind, st[ind].attorneyName, st[ind].attendeeId);
                                st[ind] = new RateSheetItemData(rtItem, st[ind], 'pt'+ind );
                                st[ind].isQuantityEdit = false;
                            }
                        }
                    }else if(rtItem.Default__c == 'Default Copy'){
                        
                        if(rtItemsWithType.containsKey('Other Transcript')){
                            List<RateSheetItemData> st = rtItemsWithType.get('Other Transcript');
                            // isAdded = !st.isEmpty();
                            for(Integer ind=0,len=st.size();ind<len;ind++){
                                // st[ind] = new RateSheetItemData(rtItem, Integer.valueOf(st[ind].invoiceItem.Quantity__c),
                                //             'ot'+ind, st[ind].attorneyName, st[ind].attendeeId);
                                st[ind] = new RateSheetItemData(rtItem, st[ind], 'ot'+ind );
                                st[ind].isQuantityEdit = false;
                            }
                        }
                    } 
                    else if(rtItem.Default__c == 'Default Rough Draft'){
                        
                        if(rtItemsWithType.containsKey('Rough Draft Transcript')){
                            List<RateSheetItemData> st = rtItemsWithType.get('Rough Draft Transcript');
                            // isAdded = !st.isEmpty();
                            for(Integer ind=0,len=st.size();ind<len;ind++){
                                
                                // st[ind] = new RateSheetItemData(rtItem, Integer.valueOf(st[ind].invoiceItem.Quantity__c),
                                //             'rt'+ind, st[ind].attorneyName, st[ind].attendeeId);
                                st[ind] = new RateSheetItemData(rtItem, st[ind], 'rd'+ind );
                                st[ind].isQuantityEdit = false;
                            }
                        }
                    }
                    else if(rtItem.Default__c == 'Default Realtime'){
                        
                        if(rtItemsWithType.containsKey('Realtime Transcript')){
                            List<RateSheetItemData> st = rtItemsWithType.get('Realtime Transcript');
                            // isAdded = !st.isEmpty();
                            for(Integer ind=0,len=st.size();ind<len;ind++){
                                
                                // st[ind] = new RateSheetItemData(rtItem, Integer.valueOf(st[ind].invoiceItem.Quantity__c),
                                //             'rt'+ind, st[ind].attorneyName, st[ind].attendeeId);
                                st[ind] = new RateSheetItemData(rtItem, st[ind], 'rt'+ind );
                                st[ind].isQuantityEdit = false;
                            }
                        }
                    }
                }
                if(!isAdded){
                    if(!rtItemsWithType.containsKey(rtItem.Type__c)){
                        rtItemsWithType.put(rtItem.Type__c, new List<RateSheetItemData>());
                    }
                    rtItemsWithType.get(rtItem.Type__c).add(
                        new RateSheetItemData(rtItem, 
                            rtItem.Type__c.replace(' ','')+rtItemsWithType.get(rtItem.Type__c).size(),
                            curUserAttendee, isExpedite
                            ));
                }
            }
        }
    }
    @TestVisible
    Decimal calculateVideoHour(){
        if(depositionRec.Start_Time__c!=NULL && depositionRec.Stop_Time__c!=NULL){
            Integer min1 = 60000;
            Integer hour1 = min1*60;
            Long diff = depositionRec.Stop_Time__c.getTime() - depositionRec.Start_Time__c.getTime();
            Long hour = diff/hour1;
            Long mins = (diff-(hour*hour1))/min1;
            return hour+((decimal)mins/60).setscale(2);
        }
        return 0;
    }
    @TestVisible
    Decimal calculateVideoHourWithTime(){
        if(depositionRec.Starts_Time__c!=NULL && depositionRec.Ends_Time__c!=NULL){
            Integer sec1 = 1;
            Integer min1 = 60;
            Integer hour1 = min1*60;
            Long starts = depositionRec.Starts_Time__c.hour()*hour1
                	+depositionRec.Starts_Time__c.minute()*min1
                	+depositionRec.Starts_Time__c.second()*sec1;
            Long ends = depositionRec.Ends_Time__c.hour()*hour1
                	+depositionRec.Ends_Time__c.minute()*min1
                	+depositionRec.Ends_Time__c.second()*sec1;
            Long diff = ends-starts;
            Long hour = diff/hour1;
            Long mins = (diff-(hour*hour1))/min1;
            System.debug(hour+(((decimal)mins)/60).setscale(2));
            return hour+(((decimal)mins)/60).setscale(2);
        }
        return 0;
    }
    void prepareCourtReporterData(){
        if(depositionRec.State_Rule__c != NULL && depositionRec.State_Rule__r.Read_and_Sign_Required__c){
            depositionRec.Errata_Needed__c = true;
        }
        calculatePageCount(true, false);
    }
    void calculatePageCount(Boolean updateCount, Boolean mustCount){
        Integer transcriptCnt = 0;
        Integer videoCnt = 0;
        Integer exhibitCnt = 0;
        
        for(S3FileModel lstFile : lstFiles){
            System.debug(lstFile.awsS3Obj.File_Type__c);
            if(lstFile.awsS3Obj.File_Type__c!=NULL){
                switch on lstFile.awsS3Obj.File_Type__c.toLowerCase(){
                    when 'video' {
                        videoCnt++;
                        depositionRec.Video_Status__c = 'Received';//'In Production';
                    }
                    when 'exhibit' {
                        exhibitCnt++;
                        depositionRec.Exhibit_Status__c = 'In Production';
                    }
                    when 'transcript' {
                        transcriptCnt++;
                        depositionRec.Transcript_Status__c = 'In Production';
                    }
                }
            }
        }
        if(updateCount || mustCount){
            if(mustCount 
                || String.isEmpty(depositionRec.Transcript_page_count__c)
                || (depositionRec.Transcript_page_count__c.isNumeric() && Integer.valueOf(depositionRec.Transcript_page_count__c)==0)){
               depositionRec.Transcript_page_count__c = transcriptCnt+'';
            }
            if(mustCount 
                || String.isEmpty(depositionRec.Exhibit_page_count__c)
                || (depositionRec.Exhibit_page_count__c.isNumeric() && Integer.valueOf(depositionRec.Exhibit_page_count__c)==0)){
                depositionRec.Exhibit_page_count__c = exhibitCnt+'';
            }
        }
    }
    public void setFirmName(){
        set<id> conIds=new set<id>();
        map<id,string> conWiseFirm=new map<id,string>();
        
            
            for(AttendeeWrapper attenRecWp :attendeeWrapperList){
                
                    conIds.add(attenRecWp.atten.Contact__c);
                
            
            }
            List<contact> cons=new List<contact>();
            cons=[select id,Account.Name from contact where id IN:conIds];
            for(contact cn :cons){
               conWiseFirm.put(cn.id,cn.Account.Name);
            }
            for(AttendeeWrapper attenRecWp :attendeeWrapperList){
                if(attenRecWp.index==removeIndex){
                    if(conWiseFirm.containsKey(attenRecWp.atten.Contact__c)){
                        attenRecWp.firmName=conWiseFirm.get(attenRecWp.atten.Contact__c);
                    }
                }
            }
            
        
    }
    public void loadFilesInDataTable(){
        try{
            lstFiles = new List<S3FileModel>();
            
            GrantingFileAccessToUsersExtn  extn = new GrantingFileAccessToUsersExtn(controller );
            extn.folderId = folderId ;
            extn.searchText= searchText;
            if(folderId!=NULL && folderId!=''){
                extn.init();
            }else
                extn.callInitFullTextSearch();
            
            Set<String>setFileIds = new Set<String>();
            Set<String> transcripts = new Set<String>{'txt'};
            Set<String> exhibits = new Set<String>{'pdf'};
            Set<String> videos = new Set<String>{'mpg','mpeg', 'mp4', 'avi', 'mov', 'webm'};
        
            Boolean iniitalSave = false;
            
            for(S3FileModel lstFile : extn.lstFiles){
                if(lstFile.awsS3Obj.Id == NULL){
                    lstFile.isSelected=true;
                }
                setFileIds.add(lstFile.awsS3Obj.File_Id__c);
                System.debug(lstFile.awsS3Obj);
                if(lstFile.awsS3Obj.File_Type__c == NULL){
                    if(lstFile.awsS3Obj.Content_Type__c != NULL){
                        if(lstFile.awsS3Obj.Content_Type__c.startsWithIgnoreCase('video')){
                            lstFile.awsS3Obj.File_Type__c = 'Video';
                            lstFile.isSelected = true;
                            iniitalSave = true;
                            continue;
                        }
                    }
                    Integer dotIndex = lstFile.awsS3Obj.File_Name__c.lastIndexOf('.');
                    if(dotIndex>-1){
                        String fileExtn = lstFile.awsS3Obj.File_Name__c.substring(dotIndex+1);
                        if(transcripts.contains(fileExtn)){
                            lstFile.awsS3Obj.File_Type__c = 'Transcript';
                            lstFile.isSelected = true;
                            iniitalSave = true;
                        }else if(exhibits.contains(fileExtn)){
                            lstFile.awsS3Obj.File_Type__c = 'Exhibit';
                            lstFile.isSelected = true;
                            iniitalSave = true;
                        }else if(videos.contains(fileExtn)){
                            lstFile.awsS3Obj.File_Type__c = 'Video';
                            lstFile.isSelected = true;
                            iniitalSave = true;
                        }
                    }
                }
            }
            lstFiles = extn.lstFiles ;
            calculatePageCount(true,false);
            
            /*// file access will add later
            if(usr.ContactId != NULL )
                lstFiles = new List<S3FileModel>();
            
            if(setFileIds.size()>0){
                Set<String>setHaveAccessFileIds= new Set<String>();
                for(File_Access__c fileAccess : [select File__r.File_Id__c From File_Access__c 
                                                 WHERE File__r.File_Id__c IN: setFileIds
                                                 AND Attendee__r.Contact__c =:usr.ContactId]){
                    setHaveAccessFileIds.add(fileAccess.File__r.File_Id__c);
                } 
                  
                for(S3FileModel s3File : extn.lstFiles){
                    if(s3File.awsS3Obj.CreatedById == Userinfo.getUserId() || setHaveAccessFileIds.contains(s3File.awsS3Obj.File_Id__c)){
                        lstFiles.add(s3File); 
                    }
                }                                
            }*/
            /*if(!lstFiles.isEmpty()){
                // Set<String> transcripts = new Set<String>{'txt'};
                // Set<String> exhibits = new Set<String>{'pdf'};
                // Set<String> videos = new Set<String>{'mpg','mpeg', 'mp4', 'avi', 'mov', 'webm'};
                // for(S3FileModel lstFile : lstFiles){
                //     if(lstFile.awsS3Obj.File_Type__c == NULL){
                //         if(lstFile.awsS3Obj.Content_Type__c != NULL){
                //             if(lstFile.awsS3Obj.Content_Type__c.startsWithIgnoreCase('video')){
                //                 lstFile.awsS3Obj.File_Type__c = 'Video';
                //                 lstFile.isSelected = true;
                //                 iniitalSave = true;
                //                 continue;
                //             }
                //         }
                //         Integer dotIndex = lstFile.awsS3Obj.File_Name__c.lastIndexOf('.');
                //         if(dotIndex>-1){
                //             String fileExtn = lstFile.awsS3Obj.File_Name__c.substring(dotIndex+1);
                //             if(transcripts.contains(fileExtn)){
                //                 lstFile.awsS3Obj.File_Type__c = 'Transcript';
                //                 lstFile.isSelected = true;
                //                 iniitalSave = true;
                //             }else if(exhibits.contains(fileExtn)){
                //                 lstFile.awsS3Obj.File_Type__c = 'Exhibit';
                //                 lstFile.isSelected = true;
                //                 iniitalSave = true;
                //             }else if(videos.contains(fileExtn)){
                //                 lstFile.awsS3Obj.File_Type__c = 'Video';
                //                 lstFile.isSelected = true;
                //                 iniitalSave = true;
                //             }
                //         }
                //     }
                // }
            }*/
            // if((folderId!=NULL && folderId!='' ) || iniitalSave )
            //     extn.saveFiles();
            if(iniitalSave)
                extn.saveFiles();
            //lstFiles = extn.lstFiles ;
        }catch(Exception e){
            ApexPages.addMessage(new  ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage())); 
        }
        if(controller.getId() == NULL || controller.getId()!='')
            searchDepositions();
    }
    public void loaduploaded(){
        GrantingFileAccessToUsersExtn  extn = new GrantingFileAccessToUsersExtn(controller );
        extn.folderId = folderId ;
        extn.searchText= searchText;
        if(folderId!=NULL && folderId!=''){
            extn.init();
        }
        if(extn.lstFiles==null || extn.lstFiles.isEmpty()){
            return;
        }
        /*
        for(S3FileModel lstFile : extn.lstFiles){
            //lstFile.isSelected = true;
        }
        */
        extn.selectedUsers = new List<SelectOption>();
        extn.selectedUsers.add(new SelectOption(UserInfo.getUserId(), UserInfo.getUserId() ));
        if(curUserAttendee!=null){
            extn.selectedUsers.add(new SelectOption(curUserAttendee.Id, curUserAttendee.Id));
        }
        extn.lstFiles[0].isSelected = true;
        extn.NotifyRecipients = false;
        extn.grantAccess();
        Set<String>setFileIds = new Set<String>();
        Set<String> transcripts = new Set<String>{'txt'};
        Set<String> exhibits = new Set<String>{'pdf'};
        Set<String> videos = new Set<String>{'mpg','mpeg', 'mp4', 'avi', 'mov', 'webm'};
    
        Boolean iniitalSave = false;
        
        for(S3FileModel lstFile : extn.lstFiles){
            if(lstFile.awsS3Obj.File_Type__c == NULL){
                if(lstFile.awsS3Obj.Content_Type__c != NULL){
                    if(lstFile.awsS3Obj.Content_Type__c.startsWithIgnoreCase('video')){
                        lstFile.awsS3Obj.File_Type__c = 'Video';
                        lstFile.isSelected = true;
                        iniitalSave = true;
                        continue;
                    }
                }
                Integer dotIndex = lstFile.awsS3Obj.File_Name__c.lastIndexOf('.');
                if(dotIndex>-1){
                    String fileExtn = lstFile.awsS3Obj.File_Name__c.substring(dotIndex+1);
                    if(transcripts.contains(fileExtn)){
                        lstFile.awsS3Obj.File_Type__c = 'Transcript';
                        lstFile.isSelected = true;
                        iniitalSave = true;
                    }else if(exhibits.contains(fileExtn)){
                        lstFile.awsS3Obj.File_Type__c = 'Exhibit';
                        lstFile.isSelected = true;
                        iniitalSave = true;
                    }else if(videos.contains(fileExtn)){
                        lstFile.awsS3Obj.File_Type__c = 'Video';
                        lstFile.isSelected = true;
                        iniitalSave = true;
                    }
                }
            }
        }
        if(isLoaded){
            listFiles.add(extn.lstFiles[0]);
        }
        isLoaded = true;
    }
    public void removeFile(){
        String fileId = ApexPages.currentPage().getParameters().get('removeFileId');
        String removeFileIndex = ApexPages.currentPage().getParameters().get('removeFileIndex');
        String screen = ApexPages.currentPage().getParameters().get('screen');
        if(String.isNotEmpty(fileId)){
            Integer index = Integer.valueOf(removeFileIndex);
            // List<File_Access__c> fileAccesses = [SELECT Id FROM File_Access__c WHERE File__c=:fileId];
            List<AWS_S3_Object__c> files = [SELECT Id FROM AWS_S3_Object__c WHERE Id=:fileId];
            if(!files.isEmpty()){
                delete files;
            }
            try{
                if(screen=='1'){
                    listFiles.remove(index);
                }else if(screen=='2'){
                    lstFiles.remove(index);
                }
            }catch(Exception excp){
                
            }
        }
    }
    public void updateDepFileType(){
        System.debug('fileObj>'+selectedDepFileIndex);
        try{
            AWS_S3_Object__c fileObj = listFiles[selectedDepFileIndex].awsS3Obj;
            System.debug(fileObj);
            update fileObj;
            calculatePageCount(true, true);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Files successfully saved.'));
        }catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getMessage()));
        }
    }
    public  void saveFiles(){
        try{
            
            List<AWS_S3_Object__c>lstFilesNeedUpdate = new List<AWS_S3_Object__c>();
            for(S3FileModel fileModel : lstFiles){
                lstFilesNeedUpdate.add(fileModel.awsS3Obj);
                system.debug(fileModel.awsS3Obj.File_Type__c);
            }
            if(lstFilesNeedUpdate.size()>0){
                update  lstFilesNeedUpdate;
                ApexPages.addMessage(new  ApexPages.Message(ApexPages.Severity.CONFIRM,'File Information Successfully Saved.'));
            }
             
        }catch(Exception e){
            ApexPages.addMessage(new  ApexPages.Message(ApexPages.Severity.Error,e.getMessage())); 
        }
        
    }
    private string key = Google_Drive_Configuration__c.getInstance().Client_Id__c;
    private string secret = Google_Drive_Configuration__c.getInstance().Client_Secret__c;
    private string refreshToken= Google_Drive_Configuration__c.getInstance().Refresh_Token__c;
    public String getAccessCode() {
       //Getting access token from google
        
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint('https://accounts.google.com/o/oauth2/token');
        req.setHeader('content-type', 'application/x-www-form-urlencoded');
        String messageBody = 'grant_type=refresh_token&refresh_token='+refreshToken+'&client_id='+key+'&client_secret='+secret;
        req.setHeader('Content-length', String.valueOf(messageBody.length()));
        req.setBody(messageBody);
        req.setTimeout(60*1000);

        Http h = new Http();
        String resp;
        AccessToken token = new AccessToken();
        if(!Test.isRunningTest()){
            HttpResponse res = h.send(req);
            resp = res.getBody();
            token = AccessToken.parse(resp);
        }
        System.debug(' You can parse the response to get the access token ::: ' + resp);
        return token.access_token;
    }
    @RemoteAction
    global static String getAccessToken() {
           
           DepositionTurnInCtrl cntrl = new DepositionTurnInCtrl();
           return cntrl.getAccessCode();
    }
    @RemoteAction
    global static Boolean  haveAccessToFile(String fileId, String fileType, String depositionId) {
        User usr = [select ContactId, Contact.Name From User WHERE ID=:UserInfo.getUserId()];
        List<File_Access__c>lstFileAccesses = [select id From File_Access__c WHERE Attendee__r.Contact__c=:usr.ContactId AND 
        File__c=:fileId];
        if(lstFileAccesses.size()>0 )
            return true;
        else if(fileType == 'Deposition Notice'){
            List<Attendee__c>lstAttendees = [select id FROM Attendee__c where Contact__c=:usr.ContactId AND Deposition__c=:depositionId
                                             AND Role__c IN('Court Reporter','Interpreter','Videographer/Technician')];
            if(lstAttendees.size()>0)
                return true;
        }
        return false;
    }
    @RemoteAction
    global static String  getFileInfo(String fileURL,String authorizationHeaderValue) {
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint(fileURL);
        req.setHeader('Authorization', authorizationHeaderValue);
        req.setHeader('content-type', 'application/json');
        
        
        req.setTimeout(60*1000);
        
        Http h = new Http();
        String resp;
        HttpResponse res = new HttpResponse();
        String fInfo = '';
        if(!Test.isRunningTest()){
            res = h.send(req);
            resp = res.getBody();
            fInfo = GogoleDriveFolderParser.parse(resp).downloadUrl;
        }
        return fInfo;
    }
    public void searchDepositions(){
        lstDepositions = new List<Deposition__c>();
        String depSearchText = String.valueOf(ApexPages.currentPage().getParameters().get('searchText'))+'*';
        List<List<SObject>> searchList = [FIND :depSearchText IN ALL FIELDS RETURNING Deposition__c];
        Deposition__c [] Depositions= ((List<Deposition__c>)searchList[0]);
        if(Depositions.size()>0){
            Set<Id>setDepositionIds = new Set<Id>();
            for(Attendee__c attendee : [select Deposition__c From Attendee__c 
                                      WHERE 
                                      Deposition__c IN : Depositions
                                      AND (Deposition__r.OwnerId =:UserInfo.getUserId() OR Contact__c=:usr.ContactId)]){
                setDepositionIds.add(attendee.Deposition__c);
            }
            if(setDepositionIds.size()>0)
                lstDepositions = [select Id,Name,Case_Name__c,Deponent_Name__c,Deposition_Date__c,Hiring_Attorney__c
                                 ,Deposition_Services__c
                                 From Deposition__c WHERE ID =:setDepositionIds];
        }

    }
    
    public PageReference requestFileAccess(){
         String fileId = ApexPages.currentPage().getParameters().get('id');
         usr = [select id,ContactId,Contact.AccountId,Contact.Email From User WHERE ID =:Userinfo.getUserId()];
         if(usr.ContactId != NULL){
             List<File_Access__c>lstNeedFileAccess = new List<File_Access__c>();
             
             List<Id>setDepIds = new List<Id>();
             for(File_Access__c fileAccess :  [select File__c,attendee__r.Deposition__c FROM File_Access__c WHERE 
                                               Attendee__r.Contact__r.AccountId=:usr.Contact.AccountId
                                               AND File__c=:fileId ]){
                 setDepIds.add(fileAccess.attendee__r.Deposition__c);    
             }
             if(setDepIds.size()>0){
                 List<Attendee__c>lstAttendees = [select id From Attendee__c WHERE 
                                                  Deposition__c=:setDepIds AND Contact__c=:usr.ContactId
                                                  LIMIT 1];
                 try{
                     if(lstAttendees.size()==0){
                         lstAttendees.add(new Attendee__c(Deposition__c=setDepIds[0],Role__c='Attorney',Contact__c=usr.ContactId,Email__c=usr.Contact.Email));
                         insert lstAttendees;
                     }
                     lstNeedFileAccess.add(new File_Access__c (Attendee__c=lstAttendees[0].id,File__c=fileId ));
                     insert lstNeedFileAccess;
                     
                     return new PageReference ('/CommunitiesSecureDownload?id='+fileId );
                 }catch(Exception e){
                      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()));
                 }
             }else{
                 FirmInfoCntrl  cntrl = new  FirmInfoCntrl();
                 Firm__c firm = cntrl.getFirm();
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'None of the other people at your company have access to this file. Please <a href="mailto:'+ firm.Production_Email_Address__c +'" style="color:white;">contact us</a> if you have additional questions.'));
             }
         }
         return null;
        
    }
    
    public class ContactInput{
        public String firstName{get;set;}
        public String lastName{get;set;}
        public String email{get;set;}
        public String phone{get;set;}
        public String mPhone{get;set;}
        public String AccountId{get;set;}
    }
    
    public class AttendeeWrapper{
        public Integer index{get;set;}
        public Attendee__c atten{get;set;}
        public String firmName{get;set;}
        
        public boolean transcriptOrder{get;set;}
        public boolean expedite{get;set;}
        public boolean videoOrder{get;set;}
        public boolean realtimeOrder{get;set;}
        public boolean roughDraft{get;set;}
        public boolean syncVideo{get;set;}
        public String selexpeditelevel{get;set;}
        
       /*
        public AttendeeWrapper(Integer index,Attendee__c atten){
            this(index, atten, '');
        }
        */
        public AttendeeWrapper(Integer index, Attendee__c atten, String depService, Boolean transcript){
            // String depService = String.isNotEmpty(atten.Deposition_Services__c) ? atten.Deposition_Services__c : '';
            this.index=index;
            this.atten=atten;
            transcriptOrder=transcript;
            
            expedite = depService.contains('Expedite') && transcript;
            videoOrder = depService.contains('Traditional Video');
            // roughDraft = depService.contains('Rough Draft');
            // realtimeOrder = depService.contains('Realtime');
            // realtimeOrder = realtimeOrder ? !depService.contains('Synchronized Video') : realtimeOrder;
            roughDraft = realtimeOrder = false;
            
            this.syncVideo = syncVideo;
            if(atten.Contact__c!=null){
                this.firmName=atten.Contact__r.Account.Name;
            }
            this.selexpeditelevel='';
            
        }
    }
    
    public class RateSheetItemData{
        public Invoice_Item__c invoiceItem{get;set;}
        public Integer quantity{get;set;}
        public Integer modification{get;set;}
        public String rtItemDescription{get;set;}
        public String key{get;set;}
        public String attorneyName{get;set;}
        public String attendeeId{get;set;}
        public String attendeeExpedite{get;set;}
        public Boolean isQuantityEdit{get;set;}
        public Boolean isTranscript{get;set;}
        public Boolean isExpedite {get;set;}
        
        public RateSheetItemData(Rate_Sheet_Item__c rtSheet, RateSheetItemData rtData, String key){
            this.key = key;
            this.quantity = Integer.valueOf(rtData.invoiceItem.Quantity__c);
            this.invoiceItem = new Invoice_Item__c(Item__c = rtSheet.Item__c, 
                                                Rate_Sheet_Item__c = rtSheet.Id, Quantity__c=rtData.invoiceItem.Quantity__c,
                                                Units_of_Measure__c =rtSheet.Units_of_Measure__c,
                                                Price__c = rtSheet.Price__c, Invoice_Text__c = rtSheet.Invoice_Text__c,
                                                Order__c = rtSheet.Order_No__c);
            this.attendeeId = rtData.attendeeId;
            this.attendeeExpedite = rtData.attendeeExpedite;
            this.isExpedite = rtData.isExpedite;
            attorneyName = rtData.attorneyName;
            modification = 0;
            if(isExpedite && String.isNotEmpty(rtSheet.Type__c) && rtSheet.Type__c.toLowerCase()=='transcript'){
                if(rtSheet.Rate_Sheet__r.Alternative_Expedite__c){
                    modification = 100;
                }else{
                    modification = getModification(rtSheet, attendeeExpedite);
                }
            }
            invoiceItem.Modification__c = modification;
            invoiceItem.Price__c = invoiceItem.Price__c == NULL ? 0 : invoiceItem.Price__c;
            rtItemDescription = rtSheet.Item_Description__c;
            isQuantityEdit = true;
            isTranscript = false;
        }
        public RateSheetItemData(Rate_Sheet_Item__c rtSheet, String key, Attendee__c attendee, Boolean isExpedite){
            this.key = key;
            this.invoiceItem = new Invoice_Item__c(Item__c = rtSheet.Item__c, 
                                                Rate_Sheet_Item__c = rtSheet.Id, Quantity__c=0,
                                                Units_of_Measure__c =rtSheet.Units_of_Measure__c,
                                                Price__c = rtSheet.Price__c, Invoice_Text__c = rtSheet.Invoice_Text__c,
                                                Order__c = rtSheet.Order_No__c);
            this.quantity = 0;
            this.attendeeId = attendee.Id;
            attorneyName = attendee.Contact__r.Name;
            attendeeExpedite = attendee.Expedite_Level__c;
            modification = 0;
            if(String.isNotEmpty(rtSheet.Type__c) && rtSheet.Type__c.toLowerCase()=='transcript'){
                if(!rtSheet.Rate_Sheet__r.Alternative_Expedite__c){
                    modification = getModification(rtSheet, attendeeExpedite);
                }
            }
            invoiceItem.Modification__c = modification;
            invoiceItem.Price__c = invoiceItem.Price__c == NULL ? 0 : invoiceItem.Price__c;
            rtItemDescription = rtSheet.Item_Description__c;
            isQuantityEdit = true;
            isTranscript = false;
        }
        public RateSheetItemData(Invoice_Item__c invoiceItem, String key, Attendee__c attendee, Boolean isExpedite){
            this.key = key;
            this.invoiceItem = invoiceItem;
            this.invoiceItem.Price__c = invoiceItem.Price__c==NULL ? 0 : invoiceItem.Price__c;
            this.quantity = invoiceItem.Quantity__c!=null ? Integer.valueOf(invoiceItem.Quantity__c) : 0;
            this.attendeeId = attendee.Id;
            this.isExpedite = isExpedite;
            attorneyName = attendee.Contact__r.Name;
            modification = 0;
            invoiceItem.Modification__c = modification;
            isQuantityEdit = false;
            rtItemDescription = '';
            attendeeExpedite = attendee.Expedite_Level__c;
            isTranscript = false;
        }
        
        public Integer getModification(Rate_Sheet_Item__c rsItem, String attendexpedite){
            Integer modification = 0;
            if(rsItem.Default__c == 'Default Original' || rsItem.Default__c == 'Default Copy'){
                if(String.isNotEmpty(attendexpedite)){
                    attendexpedite = attendexpedite.toLowerCase();
                switch on attendexpedite{
                    when 'same day turnaround'{
                        modification = 110;
                    }
                    when 'next day turnaround'{
                        modification = 100;
                    }
                    when '2 day turnaround'{
                        modification = 90;
                    }
                    when '3 day turnaround'{
                        modification = 80;
                    }
                    when '4 day turnaround'{
                        modification = 70;
                    }
                    when '5 day turnaround'{
                        modification = 60;
                    }
                    when '6 day turnaround'{
                        modification = 50;
                    }
                    when '7 day turnaround'{
                        modification = 40;
                    }
                    when '8 day turnaround'{
                        modification = 30;
                    }
                    when '9 day turnaround'{
                        modification = 20;
                    } 
                    when else{
                        modification = 0;
                    }
                }
                }
            }
            return modification;
        }
        /*public RateSheetItemData(Invoice_Item__c invoiceItem, String key, String attName, Id attendeeId){
            this.key = key;
            this.invoiceItem = invoiceItem;
            this.invoiceItem.Price__c = invoiceItem.Price__c==NULL ? 0 : invoiceItem.Price__c;
            this.quantity = invoiceItem.Quantity__c!=null ? Integer.valueOf(invoiceItem.Quantity__c) : 0;
            this.attendeeId = attendeeId;
            isQuantityEdit = false;
            rtItemDescription = '';
            attorneyName = attName;
            isTranscript = false;
        }*/
        
        /*
        public RateSheetItemData(Rate_Sheet_Item__c rtSheet, Integer quantity, String key){
            this(rtSheet, quantity, key, '', null);
            // this.invoiceItem = new Invoice_Item__c(Item__c = rtSheet.Item__c, 
            //                                     Rate_Sheet_Item__c = rtSheet.Id, Quantity__c=quantity,
            //                                     Units_of_Measure__c =rtSheet.Units_of_Measure__c,
            //                                     Price__c = rtSheet.Price__c, Invoice_Text__c = rtSheet.Invoice_Text__c,
            //                                     Order__c = rtSheet.Order_No__c);
            // this.quantity = quantity;
            // invoiceItem.Price__c = invoiceItem.Price__c==NULL ? 0 : invoiceItem.Price__c;
            // rtItemDescription = rtSheet.Item_Description__c;
            // isQuantityEdit = true;
            // this.key = key;
        }
        public RateSheetItemData(Invoice_Item__c invoiceItem, String key){
            this(invoiceItem, key, '', null);
            // this.key = key;
            // this.invoiceItem = invoiceItem;
            // this.invoiceItem.Price__c = invoiceItem.Price__c==NULL ? 0 : invoiceItem.Price__c;
            // this.quantity = invoiceItem.Quantity__c!=null ? Integer.valueOf(invoiceItem.Quantity__c) : 0;
            // isQuantityEdit = false;
            // rtItemDescription = '';
        }
        */
    }
    public class RateSheetTotal{
        public Integer itemCount{get;set;}
        public Decimal total{get;set;}
        public Decimal totalQuantity{get;set;}
        public Decimal invoicedItemCount{get;set;}
        public RateSheetTotal(Integer itemCount, Decimal totalQuantity, Decimal total){
            this.itemCount = itemCount;
            this.totalQuantity = totalQuantity;
            this.total = total;
        }
    }
    
    public class AttendeeData{
        public Boolean isSelect{get;set;}
        public Boolean isAdded{get;set;}
        public Contact con{get;set;}
        public AttendeeData(Contact con,Boolean isSelect, Boolean isAdded){
            this.isSelect = isSelect;
            this.con = con;
            this.isAdded = isAdded;
        }
    }
    
    @future
    private static void sendEmail(String invoiceId, String userId, Id conId){
        String uName='';
        String uId='';
        String eSubject='Payment Receipt';
        if(conId!=null){
            List<Contact> contacts = [SELECT Id, Name FROM Contact WHERE Id=:conId];
            if(!contacts.isEmpty()){
                uName = contacts[0].Name;
                uId = contacts[0].Id;
            }
        }else{
            List<User> users = [SELECT Id, Name, ContactId, Contact.Name FROM User WHERE Id=:userId];
            if(users[0].ContactId!=null){
                uName = users[0].Contact.Name;
                uId = users[0].ContactId;
            }else{
                uName = users[0].Name;
                uId = users[0].Id;
            }
        }
        if(uId!=null){
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            
            message.toAddresses = new String[] { uId};
            List<Invoice__c> invo = [SELECT Id,Name, Deposition__r.Deponent_Name__c, Deposition__r.Deposition_Date__c,
                                        Deposition__r.Event_Type__c, Deposition__r.event_type_lowercase__c,
                                        Deposition__r.Primary_Court_Reporting_Firm__c, 
                                        Deposition__r.Primary_Court_Reporting_Firm__r.Name,
                                        Deposition__r.Primary_Court_Reporting_Firm__r.Accounting_Email_Address__c, 
                                        Deposition__r.Primary_Court_Reporting_Firm__r.Accounting_Phone_Number__c,
                                        (SELECT Id, Item__r.Name, Units_of_Measure__c, Quantity__c, Price__c, Order__c,Total_Price__c,
                                            Attendee__r.Contact__r.Name
                                            FROM Invoice_Items__r ORDER BY Order__c)
                                        FROM Invoice__c WHERE Id=:invoiceId];
            if(!invo.isEmpty()){
                String depDate='';
                if(String.isNotEmpty(invo[0].Deposition__r.Event_Type__c)){
                    eSubject+=' - ' + invo[0].Deposition__r.Event_Type__c;
                }
                if(String.isNotEmpty(invo[0].Deposition__r.Deponent_Name__c)){
                    eSubject+=' of '+ invo[0].Deposition__r.Deponent_Name__c;
                }
                if(invo[0].Deposition__r.Deposition_Date__c!=null){
                    depDate = invo[0].Deposition__r.Deposition_Date__c.format();
                    eSubject+=' on '+ depDate;
                }
                String depName = (String.isNotBlank(invo[0].Deposition__r.Deponent_Name__c ) ? invo[0].Deposition__r.Deponent_Name__c : '');
                String htmlText='Hi '+uName +',<br/><br/>'
                
                    +'Thank you for your assistance with the '
                    + (String.isNotBlank(invo[0].Deposition__r.event_type_lowercase__c ) ? invo[0].Deposition__r.event_type_lowercase__c : '')
                    +' of '+depName+' on '+ depDate+'. '
                    +'All of your billable services for this job are detailed on payment receipt # '+invo[0].Name+'.';
                    if(invo[0].Deposition__r.Primary_Court_Reporting_Firm__c!=null){
                        Boolean isFrmEmail = false;
                        if(invo[0].Deposition__r.Primary_Court_Reporting_Firm__r.Accounting_Email_Address__c!=null
                            || invo[0].Deposition__r.Primary_Court_Reporting_Firm__r.Accounting_Email_Address__c!=null){
                            
                            htmlText+='If you have any questions, please ';
                            if(invo[0].Deposition__r.Primary_Court_Reporting_Firm__r.Accounting_Email_Address__c!=null){
                                htmlText+='email '+invo[0].Deposition__r.Primary_Court_Reporting_Firm__r.Accounting_Email_Address__c;
                                isFrmEmail = true;
                            }
                            if(invo[0].Deposition__r.Primary_Court_Reporting_Firm__r.Accounting_Phone_Number__c!=null){
                                htmlText+=(isFrmEmail ? ' or ' : '' ) + 'call '+invo[0].Deposition__r.Primary_Court_Reporting_Firm__r.Accounting_Phone_Number__c;
                            }
                            htmlText+='.<br/>';
                        }
                    }
                    htmlText+='<br/>Here are the details related to Invoice: '+invo[0].Name +'<br/><br/>'
                    +'<b>Deponent Name</b>: '+ depName
                    +', <b>Deposition Date</b>: ' + invo[0].Deposition__r.Deposition_Date__c.format();
                
                if(!invo[0].Invoice_Items__r.isEmpty()){
                    
                    htmlText+='<br/><br/> ';//Here are related items:<br/><br/>
                            // <th>Order No</th>
                    htmlText+='<table><thead> <tr><th>Attendee</th><th> Item Name </th><th> Quantity</th><th> Total Price</th></tr> </thead>'
                        +'<tbody>';
                    Decimal total=0;
                    for(Invoice_Item__c inItem : invo[0].Invoice_Items__r){
                        String attName = inItem.Attendee__c!=null ? inItem.Attendee__r.Contact__r.Name : '';
                        htmlText+='<tr>'
                        // +'<td>'+inItem.Order__c+'</td>'
                        +'<td>'+inItem.Attendee__r.Contact__r.Name+'</td>'
                        +'<td>'+inItem.Item__r.Name+'</td>'
                        +'<td style="text-align: center;">'+inItem.Quantity__c+'</td>'
                        +'<td style="text-align: right">$'+inItem.Total_Price__c+'</td>'
                        +'</tr> ';
                        total+=inItem.Total_Price__c;
                    }
                    htmlText+='<tr>'
                    +'<td colspan="2"><b>Total</b></td>'
                    +'<td style="text-align: right">$'+total+'</td>'
                    +'</tr> ';
                    htmlText+='</tbody></table>';
                }
                
                message.optOutPolicy = 'FILTER';
                message.subject = eSubject;//'Invoice created: ' + invo[0].Name;
                // message.plainTextBody = 'This is the message body.';
                message.htmlBody = htmlText;
                Messaging.SingleEmailMessage[] messages = 
                    new List<Messaging.SingleEmailMessage> {message};
                         Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                if (results[0].success) {
                    System.debug('The email was sent successfully.');
                } else {
                    System.debug('The email failed to send: '
                          + results[0].errors[0].message);
                }
            }
        }
    }
    
    
    public void onAddCopyParty(){
        addNewAttendee = true;
        isSearchAttendee = false;
        isaddSearch = false;
        newContact = new Contact();
        conSearch = new Deposition__c();
        conInput = new ContactInput();
    }
    
    public void onNewAttendee(){
        // if(String.isBlank( newContact.LastName)){
        if(String.isBlank( conInput.LastName)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'Last Name should not be blank!'));
            return;
        }
        try{
            if(!isaddSearch){
                isaddSearch = true;
                onSearch();
                if(!searchContacts.isEmpty()){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'Party(s) found with the email, have a look on the list!'));
                    isSearchAttendee = true;
                    addNewAttendee = true;
                    return;
                }
            }
            isaddSearch = false;
            newContact = new Contact(FirstName = conInput.firstName, LastName = conInput.lastName, email = conInput.Email,
                                        Phone = conInput.phone, Alt_Phone__c = conInput.mPhone);
            if(String.isNotEmpty(conInput.accountId)){
                newContact.AccountId = conInput.accountId;
            }
            insert newContact;
            Attendee__c att = new Attendee__c(Role__c='Attorney');
            if(depositionRec.Id!=NULL){
                att.Deposition__c = depositionRec.Id;
            }
            att.Deposition_Services__c = depositionRec.Deposition_Services__c;
            att.Contact__c = newContact.Id;
            if(String.isNotBlank(depositionRec.Expedite__c)){
                att.Expedite_Level__c = depositionRec.Expedite__c;
            }
            List<Contact> contacts = [SELECT Id, Name, Account.Name FROM Contact WHERE Id=: newContact.Id];
            att.Contact__r = contacts[0];
            Boolean isSynVideo = depService.contains('Synchronized Video');
            attendeeWrapperList.add(new AttendeeWrapper(attendeeWrapperList.size(),att, depService, !NoTranscript ));
            attendeeWrapperList[attendeeWrapperList.size()-1].firmName = contacts[0].Account.Name;
        }catch(Exception excp){
            System.debug(excp.getstackTracestring());
            System.debug(excp.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'Not able to add new Party, Contact to Administrator!'));
        }
        addNewAttendee = false;
        isSearchAttendee = false;
    }
    String depService{
        get{
            return String.isNotEmpty(depositionRec.Deposition_Services__c) ? depositionRec.Deposition_Services__c : '';
        }
    }
    public void onCancelNewAttendee(){
        addNewAttendee = false;
        isSearchAttendee = false;
        newContact = new Contact();
        conSearch = new Deposition__c();
        conInput = new ContactInput();
    }
    public List<SelectOption> accounts{
        get{
            if(accounts == NULL){
                accounts = new List<SelectOption>{new SelectOption('', '--none--')};
                for(Account acc : [SELECT Id, Name FROM Account WHERE Industry = 'Law Firm']){
                    accounts.add(new SelectOption(acc.Id, acc.Name));
                }
            }
            return accounts;
        }set;
    }
    
    public void onSearch(){
        addNewAttendee = false;
        isSearchAttendee = true;
        searchContacts = new List<AttendeeData>();
        Set<Id> conIds = new Set<Id>();
        for(Attendee__c at: [Select Id, Contact__c FROM Attendee__c WHERE Deposition__c =: deposId AND Contact__c != NULL]){
            conIds.add(at.Contact__c);
        }
        for(AttendeeWrapper atData: attendeeWrapperList){
            if(atData.atten!=NULL && atData.atten.Contact__c !=NULL){
                conIds.add(atData.atten.Contact__c);
            }
        }
        String query = 'SELECT Id, Name, Account.Name,Account.Industry FROM Contact '
            			+'WHERE Email like \''+conInput.email+'%\' ' 
            			+'AND Account.Industry in (\'Law Firm\',\'Corporation\') '
            			+' LIMIT 2000';
        // 'AND Account.Industry !=\'Court Reporting\'
        System.debug(query);
        isAlreadyMember = false;
        partyAddedMsg = '';
        for(List<Contact> contacts :Database.query(query) ){
            for(Contact con:contacts){
                Boolean isAdded = conIds.contains(con.Id);
                if(isAdded){
                    isAlreadyMember = true;
                }
                if(isAdded && partyAddedMsg == ''){
                    partyAddedMsg = con.Name +' has already been added as a party to this'
                        +(String.isNotEmpty(depositionRec.event_type_lowercase__c) ? ' ' +depositionRec.event_type_lowercase__c : '')
                        +'.';
                }
                // if(con.Account.Industry!='Court Reporting'){
                    searchContacts.add(new AttendeeData(con, false, isAdded ));
                // }
            }
        }
        if(searchContacts.size() > 1 && isAlreadyMember){
            isAlreadyMember = false;
        }else if(searchContacts.size() == 1 && !isAlreadyMember){
            searchContacts[0].isSelect = true;
            onSaveSearch();
        }else if(searchContacts.isEmpty()){
            if(isaddSearch== null || !isaddSearch){
                String email = conInput.email;
                onAddCopyParty();
                conInput.email = email;
            }
        }
        
    }
    public void onSearchEnable(){
        addNewAttendee = false;
        isSearchAttendee = true;
        newContact = new Contact();
        conSearch = new Deposition__c();
        searchContacts = new List<AttendeeData>();
        conInput = new ContactInput();
    }
    public void onCancelSearch(){
        isSearchAttendee = false;
        addNewAttendee = false;
    }
    public void onSaveSearch(){
        Boolean isSelected = false;
        Boolean isSynVideo = depService.contains('Synchronized Video');
        for(AttendeeData atData : searchContacts){
            if(atData.isSelect){
                isSelected = true;
                Attendee__c att = new Attendee__c(Role__c='Attorney');
                if(depositionRec.Id!=NULL){
                    att.Deposition__c = depositionRec.Id;
                }
                att.Deposition_Services__c = depositionRec.Deposition_Services__c;
                att.Contact__c = atData.con.Id;
                if(String.isNotBlank(depositionRec.Expedite__c)){
                    att.Expedite_Level__c = depositionRec.Expedite__c;
                }
                att.Contact__r = atData.con;
                AttendeeWrapper atw = new AttendeeWrapper(attendeeWrapperList.size(),att, depService, !NoTranscript);
                atw.firmName = atData.con.Account.Name;
                attendeeWrapperList.add(atw);
            }
        }
        if(!isSelected){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Select atleast one copy party!'));
            return;
        }
        isSearchAttendee = false;
        addNewAttendee = false;
        searchContacts = new List<AttendeeData>();
    }
}