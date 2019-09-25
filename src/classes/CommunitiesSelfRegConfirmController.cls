/**
 * An apex page controller that takes the user to the right start page based on credentials or lack thereof
 */
public class CommunitiesSelfRegConfirmController {
    
    public CommunitiesSelfRegConfirmController() {}
    
    public PageReference  restPassword(){
        /*List<User>lstUsers = [select Id,UserName From User where Id=:Apexpages.currentpage().getParameters().get('userId')];
        if(lstUsers.size()>0){
            System.resetPassword(lstUsers[0].Id,true);
            PageReference pr = Page.CommunitiesSelfRegConfirm;
            pr.setRedirect(true);
            return pr;
           
        }*/
        return null;
        
            
    }
}