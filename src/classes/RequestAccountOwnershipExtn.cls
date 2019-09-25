public class RequestAccountOwnershipExtn {
    public Account accnt {get;set;}
    public RequestAccountOwnershipExtn(ApexPages.StandardController controller) {
        accnt = new Account(Id=controller.getId());
        
    }
    
    public PageReference requestOwnerShip(){
        try{
            User usr = [select id,Manager.Email,DelegatedApproverId From User WHERE id=:userinfo.getUserId()];
            accnt.Manager_Email__c  = NULL;
            accnt.Delegated_Approver_Email__c  = NULL;
            if(usr.Manager.Email!= NULL)
                accnt.Manager_Email__c = usr.Manager.Email;
            if(usr.DelegatedApproverId != NULL){
                List<User>lstUsers = [select id,Email From User WHERE Id=:usr.DelegatedApproverId ];
                if(lstUsers.size()>0)
                    accnt.Delegated_Approver_Email__c = lstUsers[0].Email;
            }
            accnt.Requested_Owner__c = Userinfo.getUserId();
            update accnt;
            // Create an approval request for the account
            Approval.ProcessSubmitRequest req1 = 
                new Approval.ProcessSubmitRequest();
            req1.setComments(accnt.Reason_To_Request__c);
            req1.setObjectId(accnt.id);
            
            // Submit on behalf of a specific submitter
            req1.setSubmitterId(Userinfo.getUserId()); 
            
            // Submit the record to specific process and skip the criteria evaluation
            req1.setProcessDefinitionNameOrId('Request_for_Account_Ownership');
            req1.setSkipEntryCriteria(true);
        
            // Submit the approval request for the account
            Approval.ProcessResult result = Approval.process(req1);
            
            
            return new PageReference('/'+accnt.id);
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Fatal,e.getMessage()));
            
        }
        return null;
    }

}