/**************************************************
                Name        : ForgotPasswordController
                Author      : Rajendra Rathore
                Purpose     : An apex page controller that exposes the site forgot password functionality
                Created Date: 12 May 2016
                
                Modification History:
*****************************************************/
public with sharing class ForgotPasswordController {
    public String username {get; set;}   
    Boolean userFound=false; 
    public ForgotPasswordController() {
        username  ='';
    }
    
    public PageReference forgotPassword() {
        if(username =='')
            return null;
        List<User>lstUsers = [select id from User WHERE Username=:username AND Profile.Name='Customer Community Login User(Custom)'];
        if(lstUsers.size()>0){
            System.resetPassword(lstUsers[0].Id,true);
            PageReference pr = Page.ForgotPasswordConfirm;
            pr.setRedirect(true);
            return pr;
        }else{
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'User not found.'));
        }
        
        
        
        return null;
    }
    
     public static testMethod void testForgotPasswordController() {
        // Instantiate a new controller with all parameters in the page
        ForgotPasswordController controller = new ForgotPasswordController();
        controller.username = 'test@salesforce.com';        
    
        System.assertEquals(controller.forgotPassword(),null); 
    }
}