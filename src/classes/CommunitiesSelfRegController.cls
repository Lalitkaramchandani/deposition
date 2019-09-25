/**************************************************
                Name        : CommunitiesSelfRegController
                Author      : Rajendra Rathore
                Purpose     :An apex page controller that supports self registration of users in communities that allow self registration
                Created Date: 17 March 2016
                
                Modification History:
*****************************************************/
public class CommunitiesSelfRegController {
    public String firmName{get;set;}
    public String firstName {get; set;}
    public String lastName {get; set;}
    public String email {get; set;}
    public String password {get; set {password = value == null ? value : value.trim(); } }
    public String confirmPassword {get; set { confirmPassword = value == null ? value : value.trim(); } }
    public String communityNickname {get; set { communityNickname = value == null ? value : value.trim(); } }
    public String CompanyName{get;set;}
    Contact con = new Contact();
    String communityName= '';
    public Boolean acceptTermAndConditions{get;set;}
    public String errMsg{get;set;}
    String baseUrl = '';
    public Boolean hideForm{get;set;}
    public CommunitiesSelfRegController() {
       acceptTermAndConditions = false;
       hideForm  =false;
       List<Network>lstNetworks = [SELECT id, name FROM Network ORDER By Name  LIMIT 1];
       if(lstNetworks.size()>0)
           communityName = lstNetworks[0].Name.replaceAll(' ','');
       baseUrl= 'https://'+ApexPages.currentPage().getHeaders().get('X-Salesforce-Forwarded-To')+'/';   
       email = ApexPages.currentpage().getParameters().get('email'); 
       String firm = Apexpages.currentPage().getParameters().get('firm');
       if(firm != NULL && firm.trim().length()>0){
           
           Cookie Cookie= new Cookie('firmCookie', null,null,0,false);
           ApexPages.currentPage().setCookies(new Cookie[]{Cookie});
           Cookie= new Cookie('firmCookie', firm,null,-1,false);
           ApexPages.currentPage().setCookies(new Cookie[]{Cookie});
       }
    }
    
   

    public PageReference registerUser() {
        Firm__c firm = new Firm__c();
        String firmName = '';
        
        
        Cookie firmCookie = ApexPages.currentPage().getCookies().get('firmCookie');
        
        firmName = 'NextGen Reporting';
        if(firmCookie != null && firmCookie.getValue() != '')
            firmName = firmCookie.getValue(); 
       
        
        List<Firm__c>lstFirms = [select id,Name,Community_Admin_Email__c,Phone__c,Community_Header__c,Community_Footer__c
                                 FROM Firm__c WHERE Name=:firmName];
        if(lstFirms.size()>0)
            firm = lstFirms[0];
        
        system.debug('$$$'+email);
        errMsg = '';
        if(firstName==null || firstName.trim().length()==0){
            errMsg += '<span>Please enter first name.</span><br/>';  
        } 
        if(lastName==null || lastName.trim().length()==0){
            errMsg += '<span>Please enter last name.</span><br/>';  
        } 
        if(email==null || email.trim().length()==0){
            errMsg += '<span>Please enter a email address.</span><br/>';  
        } 
        if(acceptTermAndConditions  == false){
            errMsg += '<span>Establishing an account with '+Firm.name +' requires accepting our terms of service.</span><br/>';
        }
        if(errMsg !='')
            return null;
        if(errMsg ==''){
            List<Contact>lstContacts = [select id,FirstName,LastName,AccountId,Account.Industry,Email,Account.Name From Contact WHERE Email=:email];
            Boolean sendEmail = false;
            String emailBody = '';
            String newContactURL= baseURL+'003/e?name_firstcon2='+firstName+ '&name_lastcon2='+lastName+'&con15='+email;
            if(lstContacts.size()>0){
                con = lstContacts[0];
                List<User>lstUsers = [select id From User WHERE ContactId =:con.id];
                if(lstUsers.size()>0){
                    errMsg ='<span>An account already exists for that email address. Would you like to <A style="color:white;" HREF="/apex/CommunityForgotPassword">reset your password</A> or <A HREF="/CommunitiesLogin" style="color:white;">try logging in again</A></span>';
                    hideForm = true;
                    return null;
                }else if(con.Account.Industry =='Court Reporting' || con.Account.Industry=='Legal Video'){
                    emailBody = firstName+' '+ lastname+' ('+ email+') has a requested access to the '+firm.Name+' portal. However,  It appears that they work for a ' + con.Account.Industry + ' company. To allow them to have an account, please follow these steps:  <br/><br/>';
                    emailBody += '1.    Go to their <a href="'+ baseURL+con.id+'" target="_blank">contact</a> record in Salesforce. <br/>';
                    emailBody += '2.    Using the button at the top, click “Manage External User” then select “Enable Customer User”<br/>';
                    emailBody += '3.    Under the license type in the upper-right corner, select “Customer Community Login User(Custom)”<br/>';
                    emailBody += '4.    Click “Save”<br/>';
                    hideForm = true;
                    sendEmail = true;
                    con.Default_CR_Firm__c=firm.id;
                    update con;
                    
                }
                if(con.AccountId == NULL){
                    errMsg += 'This contact is not associated with an account. Please add this contact to an account before proceeding';
                    return null;
                }
                
            }else{
                emailBody = firstName+' '+ lastname+' ('+ email+') has a requested access to the '+firm.Name+' portal. However, their email address is not connected to a contact in Salesforce. <br/><br/>';
                emailBody += 'To create an account for them on the ' +firm.Name+' portal, please follow these steps: <br/>';
                emailBody += '1.    <a href="'+ newContactURL+'" target="_blank">Create a new Salesforce contact</a> for them <br/>';
                emailBody += '2.    Click “Manage External User” and select “Enable Customer User” <br/>';
                emailBody += '3.    Under the license type in the upper-right corner, select “Customer Community Login User(Custom)” <br/>';
                emailBody += '4.    Click “Save”<br/>';
                hideForm = true;
                sendEmail = true;
            }
            
            if(sendEmail){
                errMsg = '<span>We have received your request for a new account, and will promptly follow up with you. If you have any questions, please contact ';
                errMsg += '<a HREF="mailto:' + firm.Community_Admin_Email__c+ '">'+ firm.Community_Admin_Email__c+'</a> or ' + Firm.Phone__c+'.</span> ';
                
                Messaging.Singleemailmessage mail = new Messaging.Singleemailmessage();
                mail.setHtmlBody(emailBody );
                mail.setToAddresses(new list<string>{firm.Community_Admin_Email__c != NULL ? firm.Community_Admin_Email__c : 'jprimuth@nextgenreporting.com'});
                mail.setSubject('New User Registration Request');
                List<OrgWideEmailAddress >lstOrgWideEmails = [select Id,Address from OrgWideEmailAddress WHERE
                                Address ='premiervideo@lexitaslegal.com'];
                if (lstOrgWideEmails.size()>0) {
                    mail.setOrgWideEmailAddressId(lstOrgWideEmails[0].Id);
                }                  
                                
                Messaging.sendEmail(new Messaging.Singleemailmessage[] { mail});
                return null;
            }
            
           
        }
        /*Savepoint sp = Database.setSavepoint();
        try{
           
            String userName = con.Email;
            User u = new User();
            u.Username = userName;
            u.Email = con.email;
            u.FirstName = con.firstName;
            u.LastName = con.lastName;
            Integer rand = Math.round(Math.random()*1000);
            communityName = communityName.replaceAll(' ','');
            u.CommunityNickname = con.lastName+communityName+rand ;
            u.CompanyName = con.Account.Name;
            u.ContactId = con.id;
            u.Default_CR_Firm__c = firmName;
            //u.ProfileId = profileId;
            
            String userId = Site.createPortalUser(u, con.AccountId, null);
          
            if (userId != null) { 
                return new PageReference('/CommunitiesSelfRegConfirm?userId='+userId);  
            }
        }Catch(Exception e){
            errMsg ='<span>'+ e.getMessage() +'</span>';
            Database.rollback(sp);
            hideForm = true;
        }*/
        return null;
    }
    
}