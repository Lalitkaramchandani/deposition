@isTest
private class ContactEmailBlastControllerTest {
	@isTest    
    private static void emailBlastTest(){
        Case_leads__c case1 = new Case_Leads__c(Case_Name__c = 'testCase');
        insert case1;
        Commission__c comm = TestUtility.createCommission();
        insert comm;
        Account acc = new Account(name= 'testAccount',Industry='Insurance', Commission__c = comm.id);
        insert acc;
        Contact con = new Contact(FirstName='testCon', lastname = 'test',  Email='test@nextgen.com', accountid = acc.id);
        insert con;
        system.debug('con accountid --- '+con.AccountId);
        Representation__c rep = new Representation__c(Case__c = case1.id,Attorney__c=con.id);
        insert rep;
        Test.startTest();
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        EmailTemplate validEmailTemplate = new EmailTemplate();
        System.runAs(thisUser){
            
            validEmailTemplate.isActive = true;
            validEmailTemplate.Name = 'caselead';
            validEmailTemplate.DeveloperName = 'emailblastTemplate';
            validEmailTemplate.TemplateType = 'text';
            validEmailTemplate.FolderId = UserInfo.getUserId();
            
            insert validEmailTemplate;
        }
        
        
        ApexPages.StandardController sc = new ApexPages.StandardController(case1);
        ContactEmailBlastController controller = new ContactEmailBlastController(sc);
        PageReference pr = Page.ContactEmailBlast;
        Test.setCurrentPage(pr);
        pr.getParameters().put('Id',String.valueOf(case1.Id));
        controller.selectedTemplate = String.valueOf(validEmailTemplate.Id);
        controller.repList[0].isSelected = true;
        
        controller.emailBlast();
		test.stopTest();        
    }
}