public class FollowActionWindowController {
    Public String msg{get;set;}
    public String caseId;
    public FollowActionWindowController(ApexPages.StandardController ctlr){
        caseId = ctlr.getId();
        system.debug('caseid:: '+caseId);
        // String userId = Userinfo.getUserId();
        // msg = ManageCaseFollowers.addFollower(caseId, userId);
    }
    
    public void addFollower(){
        String userId = Userinfo.getUserId();
        system.debug('caseid:: '+caseId);
        msg = ManageCaseFollowers.addFollower(caseId, userId);
    }

}