public with sharing class CourtReporterController {
    public String keywordSearch {get;set;}
    public String contactName {get;set;}
    public Boolean showOtherAccount{get;set;}
    public List<SearchResult> searchResults {get;set;}
    private Deposition__c deposition;
    public List<SelectOption> lstAll {get;set;}
    public List<SelectOption> lstSelected {get;set;}
    public List<SelectOption> lstAllReliability  {get;set;}
    public List<SelectOption> lstSelectedReliability  {get;set;}
    //public List<Attachment> lstAllAttachment {get;set;}
    public string selectedType{get;set;}
    public Transient List<Contact> lstErrorContact {get;set;}
    
    public List<SelectOption>getTypeOptions(){
        List<SelectOption>lstSelectOptions = new List<SelectOption>();
        lstSelectOptions.add(new SelectOption('Court Reporter','Court Reporter'));
        lstSelectOptions.add(new SelectOption('Videographer','Videographer'));
        return lstSelectOptions;
    }
    public PageReference search() {
        
      List<Contact> lstContact = getSearchResults();
      createSearchResults(lstContact);
      return null;
    }
    
    public CourtReporterController(ApexPages.StandardController cntrl) {
        showOtherAccount = false;
        this.deposition = (Deposition__c)cntrl.getRecord();
        this.deposition = [select id,Primary_Court_Reporting_Firm__r.Scheduling_email_address__c,
                        Primary_Court_Reporting_Firm__r.Video_Email_Address__c 
                        FROM Deposition__c WHERE Id=:cntrl.getId()];
        
        keywordSearch = '';
        selectedType = 'Court Reporter';
        populateSelectOption();
        searchResults  = new List<SearchResult>();
        //search();
    }
    

    
    private void populateSelectOption() {
        lstAll = new List<SelectOption>();
        lstSelected = new List<SelectOption>();
        lstAllReliability = new List<SelectOption>();
        lstSelectedReliability  = new List<SelectOption>();
        
        Set<String> mpSelected = new Set<String>();
        Court_Search_Email_Template__c template = Court_Search_Email_Template__c.getInstance();
        if(template != null && template.Default_CR_Status__c != null) {
          mpSelected.addAll(template.Default_CR_Status__c.split(';'));
        }
        
        Schema.DescribeFieldResult result = Contact.CR_Status__c.getDescribe();
        for(Schema.PickListEntry entry :result.getPicklistValues()) {
          if(entry.getValue().startsWith('X -')== false && entry.getValue().startsWith('F -')==false){
              if(mpSelected.contains(entry.getValue())) {
                lstSelected.add(new SelectOption(entry.getValue(),entry.getValue()));
              }
              else {
                lstAll.add(new SelectOption(entry.getValue(),entry.getValue()));
              }
          }
        }
        mpSelected = new Set<String>();
        if(template != null && template.Default_CR_Reliability__c!= null) {
          mpSelected.addAll(template.Default_CR_Reliability__c.split(';'));
        }
        result = Contact.CR_Reliability__c.getDescribe();
        for(Schema.PickListEntry entry :result.getPicklistValues()) {
            if(mpSelected.contains(entry.getValue())) {
                lstSelectedReliability.add(new SelectOption(entry.getValue(),entry.getValue()));
            }
            else {
                lstAllReliability.add(new SelectOption(entry.getValue(),entry.getValue()));
           }
            
        }
    }
    
    
    public PageReference SendEmail() {
      Set<Id> setSelectedContact = getSelectedContact();
      if(setSelectedContact.size() == 0) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning,'Please select at least one contact'));
        return null;
      }
      Id emailTemplateId = getEmailTemplateId();
      if(emailTemplateId == null) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning,'No email template defined, Please check custom settings'));
      return null;
      }

      dispatchEmail(setSelectedContact,emailTemplateId);
      return null;
    }
    
    
    
    public Set<Id> getSelectedContact() {
      Set<Id> setSelectedContact = new Set<Id>();
      for(SearchResult srchResult :searchResults) {
        for(Contact ctc :srchResult.lstContact) {
          String ctcId = ctc.Id;
          if(ApexPages.currentPage().getParameters().get(ctcId) == '1') {
            setSelectedContact.add(ctc.Id);
          }
        }
      }
      return setSelectedContact;
    }
    

    
    public void dispatchEmail(Set<Id> setSelectedContact,Id templateID) {
        List<Messaging.SingleEmailMessage> lstEmail = new List<Messaging.SingleEmailMessage>();
        String fromEmail = deposition.Primary_Court_Reporting_Firm__r.Scheduling_email_address__c;
        if(selectedType  == 'Videographer')
            fromEmail = deposition.Primary_Court_Reporting_Firm__r.Video_Email_Address__c;
        List<OrgWideEmailAddress >lstOrgWideEmails = [select Id,Address from OrgWideEmailAddress WHERE
                                Address =:fromEmail ];
        for(Id contactId :setSelectedContact) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTemplateId(templateID);
            mail.setTargetObjectId(contactId);
            mail.setWhatId(this.deposition.Id);
            if (lstOrgWideEmails.size()>0) {
                mail.setOrgWideEmailAddressId(lstOrgWideEmails[0].Id);
            }
            lstEmail.add(mail);
        }
        List<Messaging.SendEmailResult> lstResult = null;
        try {
          lstResult = Messaging.SendEmail(lstEmail,true);
        }
        catch(System.EmailException ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning,
               'Email could not be sent. Some of the selected contacts have incorrect email address'));
          ApexPages.addMessages(ex);
          return;
        }
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm,'Emails sent successfully'));
        return;
    }
    
    
    private List<Contact> getSearchResults() {
        
        
        
        String searchStr = this.keywordSearch;
        
        if(String.isBlank(keywordSearch)){
          searchStr = '';
        }
        if(searchStr != '')
            searchStr = '%' + searchStr + '%';
        
        List<String> lstSelectedStatus = new List<String>();
        for(SelectOption option :lstSelected){
          lstSelectedStatus.add(option.getValue());
        }
        List<String> lstStrSelectedReliability = new List<String>();
        for(SelectOption option :lstSelectedReliability){
          lstStrSelectedReliability.add(option.getValue());
        }
        String qry = 'SELECT Account.Account_Ranking_Formula__c,Contact_Ranking_Formula__c ,CR_Status__c,Account.Industry,Account.Name,Name,Email,Phone,Description,Recent_Attendee_Date__c,Attendee_Count__c';
        qry += ',MailingCity,MailingState,MailingPostalCode,CR_Reliability__c,LastActivityDate,IsEmailBounced';
        qry +=' FROM Contact WHERE  ';
        qry+= ' Account.Industry IN (\'Court Reporting\',\'Videography\' ) ';
        
        /*if(selectedType == 'Court Reporter')
            qry+= 'Account.Industry IN (\'Court Reporting\',\'Videography\' ) ';
        else
           qry+= 'Account.Industry =\'Videography\' '; */
           
        if(searchStr != ''){
            qry +=' AND  (MailingCity LIKE :searchStr OR OtherCity Like : searchStr ';
            qry +=' OR Coverage_Area__c Like :searchStr ) ';
        }
        
        if(lstSelectedStatus.size() > 0) 
            qry +=' AND  (CR_Status__c IN :lstSelectedStatus OR CR_Status__c =null ) ';
        if(lstStrSelectedReliability.size() > 0) 
            qry +=' AND  (CR_Reliability__c IN :lstStrSelectedReliability OR CR_Reliability__c =null) ';
        if(showOtherAccount  == false){
            qry += selectedType == 'Court Reporter' ? ' AND (Account.Name = \'Independent Court Reporters\' OR Account.Name =\'Technicians\' )' :  ' AND (Account.Name = \'Independent Videographers\' OR Account.Name =\'Technicians\' ) ' ;
        }
        qry +=' ORDER BY Account.Account_Ranking_Formula__c NULLS LAST, Account.Name,Contact_Ranking_Formula__c NULLS LAST,Name  NULLS LAST';
        qry +=' Limit 1000';
        return database.Query(qry);
     
    }
    
    public void createSearchResults(List<Contact> lstContact) {
      this.searchResults = new List<SearchResult>();
      String lastAccountName = '';
      SearchResult lastSearchResult = null;
      
      for(Contact contact :lstContact) {
        if(contact.Account.Name != lastAccountName) {
          lastSearchResult = new SearchResult();
          lastSearchResult.account = contact.Account;
          lastAccountName = contact.Account.Name;
          
          this.searchResults.add(lastSearchResult);
        }
        lastSearchResult.lstContact.add(contact);
      }
    }
    
    public Id getEmailTemplateId() {
      Court_Search_Email_Template__c searchEmailTemplate = Court_Search_Email_Template__c.getInstance(); 
      String templateName = '';
      if(selectedType == 'Court Reporter')
          templateName =searchEmailTemplate.Email_Template_Name__c;
      else
          templateName =searchEmailTemplate.Videographer_Email_Template_Name__c;
      List<EmailTemplate> lstTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName 
                                         = :templateName Limit 1];
      if(lstTemplate.size() > 0) {
        return lstTemplate[0].Id;
      } 
      return null;                                  
    }
    
    //==============================================================//
    //Inner wrapper class that wraps the result
    //==============================================================//
    public class SearchResult {
        public SearchResult() {
          this.account = new Account();
          this.lstContact = new List<Contact>();
        }
        
        public Account account {get;set;}
        public List<Contact> lstContact {get;set;}
    }
    
    
}