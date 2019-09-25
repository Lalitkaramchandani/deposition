/**************************************************
                Name        : CommunitiesSelfRegControllerTest
                Author      : Rajendra Rathore
                Purpose     : Test class for CommunitiesSelfRegController Apex Class
                Created Date: 17 March 2016
                
                Modification History:
*****************************************************/
@IsTest public with sharing class CommunitiesSelfRegControllerTest {
    @IsTest(SeeAllData=true) 
    public static void TestCommunitiesSelfRegController() {
        CommunitiesSelfRegController controller = new CommunitiesSelfRegController();
        controller.firstName = 'FirstName';
        controller.lastName = 'LastName';
        
        controller.communityNickname = 'test';
        
        // registerUser will always return null when the page isn't accessed as a guest user
        System.assert(controller.registerUser() == null);    
        controller.email = 'test@force.com';
        controller.registerUser();
        controller.acceptTermAndConditions  = true;
        controller.registerUser();
        controller.password = 'abcd1234';
        controller.confirmPassword = 'abcd123';
        
        Account accountNewInsert = new Account(name ='Community Account') ;
        insert accountNewInsert;
        
        List<Contact> LewContact = new List<Contact>();                               
        Contact con1 = new Contact(LastName ='testCon',ownerId=userinfo.getuserid(),AccountId = accountNewInsert.Id,email='test@force.com');
        
        insert con1; 
        
        controller.registerUser();
        controller.registerUser();
    }    
}