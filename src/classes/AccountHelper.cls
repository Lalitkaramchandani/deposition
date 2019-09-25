public Class AccountHelper{
    public static void updateAccountAttendee(List<Account>lstAccounts,Map<Id,Account>oldmap){
        set<Id>setAccountIds = new Set<Id>();
        for(Account acc: lstAccounts){
            if(acc.VIP_Level__c != oldmap.get(acc.id).VIP_Level__c)
                setAccountIds.add(acc.id);
        }
        
        if(setAccountIds.size()>0){
            List<Attendee__c >lstAttendees = [select id From Attendee__c  WHERE Contact__r.AccountId IN: setAccountIds];
            update lstAttendees ;
        }
        
    }
}