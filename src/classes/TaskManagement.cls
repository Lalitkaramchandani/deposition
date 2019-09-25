public class TaskManagement {
  public static Boolean isExecuted = false;
  
  public static void updateAccount(List<Task> lstTask) {
    if(isExecuted == true) return;
    
    isExecuted = true;
    Set<Id> setAccountID = new Set<Id>();
    for(Task task :lstTask) {
      setAccountID.add(task.AccountID);
    }
    
    Map<Id,Account> mpAccount = new Map<Id,Account>([SELECT OwnerID from 
                                                     Account WHERE ID IN :setAccountID]);
    List<Task> lstCopyTask = new List<Task>();
    
    for(Task task :lstTask) {
      Account account = mpAccount.get(task.AccountId);
      if(account != null) {
        lstCopyTask.add(new Task(Id = task.Id,Account_Owner__c = account.OwnerId));
      }
    }
    
    update lstCopyTask;
  }

}