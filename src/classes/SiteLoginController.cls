/**
 * An apex page controller that exposes the site login functionality
 */
global with sharing class SiteLoginController {
    global String username {get; set;}
    global String password {get; set;}
    
    global SiteLoginController(){
         String selectedFirm = Apexpages.currentPage().getParameters().get('firm');
        Cookie Cookie= new Cookie('firmCookie', null,null,0,false);
        ApexPages.currentPage().setCookies(new Cookie[]{Cookie});
        Cookie= new Cookie('firmCookie', selectedFirm,null,-1,false);
        ApexPages.currentPage().setCookies(new Cookie[]{Cookie});
        
    }
    global PageReference login() {
       
        String loginInNewTab = Apexpages.currentPage().getParameters().get('loginInNewTab');
        
        
        String startUrl = '';
        if(loginInNewTab!= NULL && loginInNewTab=='true')
            startUrl ='/CommunityLoginSuccess';
        else startUrl ='/Portal';
        return Site.login(username, password, startUrl);
    }
    
   
    public static testMethod void testSiteLoginController() {
        // Instantiate a new controller with all parameters in the page
        SiteLoginController controller = new SiteLoginController();
        controller.username = 'qwerty1'; 
        controller.password = 'qwerty1';    
        controller.login();            
                                   
    }    
    
}