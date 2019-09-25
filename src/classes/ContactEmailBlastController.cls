public class ContactEmailBlastController {
    public List<wrapperRep> repList{get;set;}
    public String selectedTemplate{get;set;}
    public List<SelectOption> templateOptions{get;set;}
    public ContactEmailBlastController(ApexPages.StandardController controller){
        repList = new List<wrapperRep>();
        String caseId = controller.getId(); 
        system.debug('caseid:: '+caseId);
        
        for(Representation__c rep : [select id, Law_Firm__c,Case__r.Commission__c,Representation_Type__c , Law_Firm_Text__c,Attorney__r.Account.Commission__r.Primary_Rep__c,Attorney__r.Account.Commission__r.Secondary_Rep__c ,Attorney__r.Account.Commission__r.Tertiary_Rep__c, Attorney__c, Attorney__r.email from Representation__c where attorney__c != null and case__c = :caseId]){
            system.debug('rep Attorney__r.Account::: '+rep.Attorney__r.Accountid);
            system.debug('Attorney__r.Account.Commission__c::: '+rep.Attorney__r.Account.Commission__c);
            system.debug('Attorney__r.Account.Commission__r.Primary_Rep__c::: '+rep.Attorney__r.Account.Commission__r.Primary_Rep__c);
            if(isUserAllowedToSendEmail(rep)){
                wrapperRep wrep = new wrapperRep(false, rep);
            	repList.add(wrep);
            }
            
        }
        // prepare Email Tempate options
        templateOptions = new List<SelectOption>();
        templateOptions.add(new SelectOption('','-None-'));
        for(EmailTemplate et : [select id, DeveloperName from EmailTemplate where Folder.name = 'Case Lead']){
            SelectOption option = new SelectOption(et.id,et.DeveloperName);
            templateOptions.add(option);
        }
        
    }
    
    public class wrapperRep {
        public Boolean isSelected{get;set;}
        Public Boolean hasEmailId{get;set;}
        public Representation__c rep{get;set;}
        
        public wrapperRep(Boolean isSelected, Representation__c rep ){
            this.isSelected = isSelected;
            hasEmailId = true;
            this.rep = rep;
            if(rep.attorney__r.email == null){
                hasEmailId = false;
            }
        }
    }
    
    private Boolean isUserAllowedToSendEmail(Representation__c rep){
        String curUserID = UserInfo.getUserId();
        if(curUserID.equals(rep.Attorney__r.Account.Commission__r.Primary_Rep__c))
            return true;
        if(curUserID.equals(rep.Attorney__r.Account.Commission__r.Secondary_Rep__c))
            return true;
        if(curUserID.equals(rep.Attorney__r.Account.Commission__r.Tertiary_Rep__c))
            return true;
        return false;
    }
    public void emailBlast(){
        if(String.isBlank(selectedTemplate)){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Please select Email Template.'));
            return;
        }else{
            List<String> contactEmailList = new List<String>();
            List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
            Set<String> addedTargetList = new Set<String>();
            for(wrapperRep wrep : repList){
                if(wrep.isSelected && !addedTargetList.contains(wrep.rep.Attorney__c)){
                    Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
                    msg.setTargetObjectId(wrep.rep.Attorney__c);
                    msg.setTemplateId(selectedTemplate);
                    msg.setSaveAsActivity(true);
                    msg.setWhatId(wrep.rep.Id);
                    emailList.add(msg);
                    addedTargetList.add(wrep.rep.Attorney__c);
                }
            }
            if(emailList.size() > 0){
                String errors = '' ;
                Boolean emailSent = true;
                List<Messaging.SendEmailResult> results = Messaging.sendEmail(emailList);
                for(Messaging.SendEmailResult result : results){
                    if(!result.isSuccess()){
                        emailSent = false;
                        for(Messaging.SendEmailError err : result.getErrors()){
                            errors = errors + ' '+ err.getMessage()+';';
                        }
                    }
                }
                if(emailSent){
                    ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO, 'Email(s) have been sent.'));
                    }else{
                        ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Error occurred: '+errors));
                    }
                    
                }else{
                    // error "Please select at least 1 contact."
                    ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Please select at least 1 Contact'));
                    return;
                }
            }
            
        }
        
    }