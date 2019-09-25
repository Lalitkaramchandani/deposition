/**************************************************
                Name        : CommunityLandingPageCntrl
                Author      : Rajendra Rathore
                Purpose     : That class is used by CommunityLandingPage VF page for check User Type and 
                              Redirect user to selected Frim based community and set cookie for Firm using Cookies.
                Created Date: 09 JUNE 2016
                
                Modification History:
*****************************************************/
public class CommunityLandingPageCntrl{
    public list<SelectOption>firmOptions{get;set;}
    public string selectedFirm{get;set;}
    public CommunityLandingPageCntrl(){
        selectedFirm = Label.Default_CR_Firm;
        String firmParam = Apexpages.currentPage().getParameters().get('firm');
        if(firmParam==NULL || firmParam.trim().length()==0){
            User usr = [select Id,Contact.Default_CR_Firm__c,Contact.Default_CR_Firm__r.Name FROM User where id=:userinfo.getUserId()];
            if(usr.Contact.Default_CR_Firm__c != NULL )
                selectedFirm = usr.Contact.Default_CR_Firm__r.Name;
            system.debug('$$$'+selectedFirm);
        }else{
            selectedFirm = firmParam ;
        }
        
        Cookie Cookie= new Cookie('firmCookie', null,null,0,false);
        ApexPages.currentPage().setCookies(new Cookie[]{Cookie});
        Cookie= new Cookie('firmCookie', selectedFirm,null,-1,false);
        ApexPages.currentPage().setCookies(new Cookie[]{Cookie});
        
        firmOptions = new List<SelectOption>();
        for(Firm__c firm : [select id,Name From Firm__c ]){
            firmOptions.add(new SelectOption(firm.Name,Firm.Name));
        }
        
    }
    
    // Code we will invoke on page load.
    public PageReference forwardToStartPage() {
        String firm = Apexpages.currentPage().getParameters().get('firm');
        if (UserInfo.getUserType()!='Guest') {
           
           PageReference pageRef = new PageReference('/Portal');
           return pageRef;
        }else if(firm != NULL && firm.trim().length()>0){
            selectedFirm = firm;
            return setupCommunityFirm();
        } 
        return null;
    }
    
    public PageReference setupCommunityFirm(){
        Cookie Cookie= new Cookie('firmCookie', null,null,0,false);
        ApexPages.currentPage().setCookies(new Cookie[]{Cookie});
        Cookie= new Cookie('firmCookie', selectedFirm,null,-1,false);
        ApexPages.currentPage().setCookies(new Cookie[]{Cookie});
        
        String loginInNewTab = Apexpages.currentPage().getParameters().get('loginInNewTab');
        PageReference pg ;
        if(loginInNewTab!= NULL && loginInNewTab=='true'){
            pg = new PageReference ('/CommunitiesLoginWithoutTemplate').setRedirect(true);
            pg.getParameters().put('loginInNewTab','true');
        }else
         pg = new PageReference ('/CommunitiesLogin').setRedirect(true);
        pg.getParameters().put('firm',selectedFirm);
         Cookie firmCookie = ApexPages.currentPage().getCookies().get('firmCookie');
        
        return pg;
    }
}