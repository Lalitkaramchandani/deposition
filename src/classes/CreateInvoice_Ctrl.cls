/**
Name             : CreateInvoice_Ctrl
Date             : 19 Nov 2015
Descripition     : This class is used by CreateInvoice VF page for creating a invoice record
for a attendee and allow user to select rate sheet for invoice.

*/ 
public class CreateInvoice_Ctrl{
    
    public String selectedRateSheet {
        get;
        set;
    }
    
    string attendeeID;
    public Boolean isAttendeeLocked{get;set;}
    public Attendee__c attendee {
        get;
        set;
    }
    public Contact tempContact {
        get;
        set;
    }
    public boolean showLookupRateSheet {
        get;
        set;
    }
    public Deposition__c dep{get;set;}
    public State_Rules__c stateRules{get;set;}
    public String type {get;set;}
    public boolean showTypelookup {get;set;}
    
    public CreateInvoice_Ctrl() {
        isAttendeeLocked = false;
        attendeeID = apexpages.currentpage().getparameters().get('id');
        stateRules = new State_Rules__c();
        attendee = new Attendee__c ();
        dep = new Deposition__c();
        showTypelookup=false;
        type='';
        
        if (attendeeID != null && attendeeID != '') {
            attendee = [select id, name, Deposition_Location__c,Is_locked_to_Create_Invoice__c,Locked_By__c, Deposition_Location__r.name, Deposition__r.Deposition_Location__c, 
                        Deposition__r.State__c, Contact__r.name, Contact__r.Rate_Sheet__c, Contact__r.Rate_Sheet__r.name, 
                        Contact__r.AccountId, Contact__r.Account.Rate_Sheet__c, Contact__r.Account.Rate_Sheet__r.name,Contact__r.Account.Name,
                        Account_Name__c, Deposition__r.Case_Name__c, Deposition__r.Deposition_Group__r.name,
                        Deposition__r.Deposition_Group__r.Rate_Sheet__c, Deposition__r.Deposition_Group__r.Rate_Sheet__r.name,
                        Deposition__r.Corporate_Client_Source__c, Deposition__r.Billing_Notes__c, Standing_Orders_del__c,
                        Contact__r.Account.Industry,Deposition__r.Event_Location__c,Deposition__c,Deposition__r.Event_Type_Lowercase__c,Deposition__r.Primary_CR_Firm__c
                        ,Deposition__r.Insurance_Claim_Info__c,Deposition__r.Claims_Professional__c,Deposition__r.Matter_Number__c
                        ,Deposition__r.VIP_Level__c,Deposition__r.Attorney_Count__c ,Deposition__r.Deposition_Group__c,
                        Contact__r.Account.Financial_Notes__c, Contact__r.Financial_Notes__c
                        FROM Attendee__c where id = : attendeeID
                       ];
            dep.id = attendee.Deposition__c;
            dep.State__c = attendee.Deposition__r.State__c;
            if(dep.State__c == NULL ||dep.State__c == '')
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'To create this invoice, please select the state where the '+ attendee.Deposition__r.Event_Type_Lowercase__c+' occurred.'));
            if(attendee.Is_locked_to_Create_Invoice__c & attendee.Locked_By__c != UserInfo.getName()){
                isAttendeeLocked = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This Attendee is locked, '+ attendee.Locked_By__c +' is trying to create invoice for this Attendee.'));
            }
            
                

        }
        tempContact = new Contact();
        showLookupRateSheet = false;
        loadStateRules();
        
        if(attendee!=null && attendee.Contact__c!=null && attendee.Contact__r.Account.Industry!=null && 
           attendee.Contact__r.Account.Industry=='Court Reporting' && attendee.Deposition__c!=null && 
           string.isnotBlank(attendee.Deposition__r.Primary_CR_Firm__c) && 
           !(attendee.Contact__r.Account.Name.containsIgnoreCase('Lexitas')|| attendee.Contact__r.Account.Name.containsIgnoreCase('NextGen') 
             ||attendee.Contact__r.Account.Name.containsIgnoreCase('Independent Court Reporters') ||attendee.Contact__r.Account.Name.containsIgnoreCase('Jensen') 
             ||attendee.Contact__r.Account.Name.containsIgnoreCase('Deitz')) ){
                 showTypelookup=true;
             }
    }
    public void lockInvoice(){
        if(!attendee.Is_locked_to_Create_Invoice__c){
                Attendee__c lockAttendee = new Attendee__c(Id = attendeeID, Is_locked_to_Create_Invoice__c = true, Locked_By__c = UserInfo.getName() );
                update lockAttendee;
            }
    }
    public void saveDeposition(){
        try{
            update dep;
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
    }
    private void loadStateRules(){
        if (attendee.Deposition__r.State__c != null) {
            List<State_Rules__c>lstStateRules = [select id,Rule__c From State_Rules__c 
                                                 WHERE Name =:attendee.Deposition__r.State__c];
            if(lstStateRules.size()>0){
                stateRules = lstStateRules[0];
            }
        }
    }
    public List < SelectOption > getInvoiceTypes() {
        List < SelectOption > options = new List < SelectOption > ();
        options.add(new SelectOption('Client', 'Client:We are providing court reporting services on a networked job.'));
        options.add(new SelectOption('Reporter', 'Reporter: We hired them as the court reporter.'));
        options.add(new SelectOption('Video/Tech', 'Video/Tech'));
        
        return options;
    }
    
    public List < SelectOption > getRateSheets() {
        
        List < SelectOption > options = new List < SelectOption > ();
        //options.add(new SelectOption('', '--None--'));
        
        if (attendee.Deposition__r.Deposition_Group__c != null && attendee.Deposition__r.Deposition_Group__r.Rate_Sheet__c != null) {
            options.add(new SelectOption(attendee.Deposition__r.Deposition_Group__r.Rate_Sheet__c, attendee.Deposition__r.Deposition_Group__r.Rate_Sheet__r.name));
        }
        if (attendee.Contact__c != null && attendee.Contact__r.Rate_Sheet__c != null) {
            options.add(new SelectOption(attendee.Contact__r.Rate_Sheet__c, attendee.Contact__r.Rate_Sheet__r.name));
        }
        if (attendee.Contact__c != null && attendee.Contact__r.Account != null && attendee.Contact__r.Account.Rate_Sheet__c != null) {
            options.add(new SelectOption(attendee.Contact__r.Account.Rate_Sheet__c, attendee.Contact__r.Account.Rate_Sheet__r.name));
        }
        if (attendee.Deposition__r.Corporate_Client_Source__c != null) {
            List < Rate_Sheet__c > rateSheets = Database.query('SELECT Id,name FROM Rate_Sheet__c WHERE Name LIKE \'' + '%' + attendee.Deposition__r.Corporate_Client_Source__c + '%\' or Name = \'Copy Side\'');
            for (Rate_Sheet__c curRateSheet: rateSheets) {
                options.add(new SelectOption(curRateSheet.id, curRateSheet.name));
            }
        }
        String standardRatesheetName = '';
        if (attendee.Contact__r.Account.Industry == 'Court Reporting') {
            type = 'Reporter';
            standardRatesheetName  = 'Rack Rate Sheet - Reporter';
        } else if (attendee.Contact__r.Account.Industry == 'Law Firm' || 
                   attendee.Contact__r.Account.Industry == 'Corporation'
                   || attendee.Contact__r.Account.Industry == 'Insurance'
                   || attendee.Contact__R.Account.Industry =='Government/Courts') {
                       type = 'Client';
                       standardRatesheetName  = 'Rack Rate Sheet - Client';
                   }if (attendee.Contact__r.Account.Industry == 'Videography') {
                       type = 'Video/Tech';
                       standardRatesheetName  = 'Rack Rate Sheet - Videographer';
                   }     
        if (attendee.Deposition__r.State__c != null) {
            if (type != null) {
                string queryString = 'SELECT Id, name FROM Rate_Sheet__c WHERE Type__c=\'' + type + '\' and  Name LIKE \'' + '%' + attendee.Deposition__r.State__c + '%\'';
                List < Rate_Sheet__c > rateSheets = Database.query(queryString);
                for (Rate_Sheet__c curRateSheet: rateSheets) {
                    options.add(new SelectOption(curRateSheet.id, curRateSheet.name));
                } 
            }
        }
        if(options.size()==1){
            List < Rate_Sheet__c > rateSheets = Database.query('SELECT Id,name FROM Rate_Sheet__c WHERE Type__c=\'' + type + '\' and  Name LIKE \'%Standard%\'');
            for (Rate_Sheet__c curRateSheet: rateSheets) {
                options.add(new SelectOption(curRateSheet.id, curRateSheet.name));
            }
        }
        if(options.size()==0){
            if( standardRatesheetName != ''){
                for (Rate_Sheet__c curRateSheet: [select id,Name FROM Rate_Sheet__c WHERE Name=:standardRatesheetName ]) {
                    options.add(new SelectOption(curRateSheet.id, curRateSheet.name));
                }
            }
        }
        options.add(new SelectOption('Other', 'Other'));
        if(options.size()==1){
            showLookupRateSheet = true;
            
            
            
        }
        if(type =='')
            showTypelookup = true;
        system.debug('$$$'+showTypelookup );
        return options;
    }
    public PageReference deSelectPicklistRateSheet() {
        if (tempContact.Rate_Sheet__c != null)
            selectedRateSheet = '';
        return null;
    }
    
    public PageReference deSelectLookupRateSheet() {
        if (selectedRateSheet != null)
            tempContact.Rate_Sheet__c = null;
        
        if (selectedRateSheet == 'Other') {
            showLookupRateSheet = true;
        } else {
            showLookupRateSheet = false;
        }
        
        return null;
    }
    
    public PageReference PrepareInvoice() {
        string selectedRateSheetID = (selectedRateSheet != 'Other' ? selectedRateSheet : tempContact.Rate_Sheet__c);
        
        if (selectedRateSheetID != null) {
            PageReference nextPageRef = new PageReference('/apex/PrepareInvoice?rateSheetId=' + selectedRateSheetID + '&attendeeId=' + attendee.id+'&type='+type);
            nextPageRef.setRedirect(true);
            return nextPageRef;
        } else {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select a Rate sheet to proceed.');
            ApexPages.addMessage(myMsg);
            return null;
        }
        
    }
    
    public PageReference Cancel() {
        PageReference nextPageRef = new PageReference('/' + attendee.Deposition__c);
        nextPageRef.setRedirect(true);
        return nextPageRef;
    }
}