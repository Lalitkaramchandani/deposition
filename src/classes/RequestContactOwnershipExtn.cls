public class RequestContactOwnershipExtn {
    public Contact cont{get;set;}
    public RequestContactOwnershipExtn (ApexPages.StandardController controller) {
        cont= new Contact (Id=controller.getId());
        
    }
    
    public PageReference requestOwnerShip(){
        try{
            User usr = [select id,Manager.Email,DelegatedApproverId From User WHERE id=:userinfo.getUserId()];
            cont.Manager_Email__c  = NULL;
            cont.Delegated_Approver_Email__c  = NULL;
            if(usr.Manager.Email!= NULL)
                cont.Manager_Email__c = usr.Manager.Email;
            if(usr.DelegatedApproverId != NULL){
                List<User>lstUsers = [select id,Email From User WHERE Id=:usr.DelegatedApproverId ];
                if(lstUsers.size()>0)
                    cont.Delegated_Approver_Email__c = lstUsers[0].Email;
            }
            cont.Requested_Owner__c = Userinfo.getUserId();
            update cont;
            
            // Create an approval request for the Contact
            Approval.ProcessSubmitRequest req1 = 
                new Approval.ProcessSubmitRequest();
            req1.setComments(cont.Reason_To_Request__c);
            req1.setObjectId(cont.id);
            
            // Submit on behalf of a specific submitter
            req1.setSubmitterId(Userinfo.getUserId()); 
            
            // Submit the record to specific process and skip the criteria evaluation
            req1.setProcessDefinitionNameOrId('Contact_Ownership_Approval_Request');
            req1.setSkipEntryCriteria(true);
        
            // Submit the approval request for the account
            Approval.ProcessResult result = Approval.process(req1);
            return new PageReference('/'+cont.id);
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Fatal,e.getMessage()));
        }
        return null;
    }

}