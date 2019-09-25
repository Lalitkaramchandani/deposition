public Class ContactHelper{
    public static void updateContactAttendee(List<Contact>lstContacts,Map<Id,Contact>oldmap){
        set<Id>setContactIds = new Set<Id>();
        set<Id>setContactIdsForUserUpdate = new Set<Id>();
        for(Contact con : lstContacts){
            if(con.VIP_Level__c != oldmap.get(con.id).VIP_Level__c)
                setContactIds.add(con.id);
            if(con.Default_CR_Firm__c!= oldmap.get(con.id).Default_CR_Firm__c)
                setContactIdsForUserUpdate.add(con.id);
        }
        
        if(setContactIds.size()>0){
            List<Attendee__c >lstAttendees = [select id From Attendee__c  WHERE Contact__c IN : setContactIds];
            update lstAttendees ;
        }
        if(setContactIdsForUserUpdate.size()>0){
            List<User>lstUsers = [select id From User WHERE ContactID IN : setContactIdsForUserUpdate];
            if(lstUsers.size()>0)
                update lstUsers;
        }
        
    }
}