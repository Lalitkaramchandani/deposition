public class ContactTriggerHandler {
    
    public static void onBeforeUpdateRoutine(List<Contact> newList, Map<Id, Contact> oldMap){
        
        for(Contact con : newList){
            //AKA feature put on hold
            /*
            if(String.isNotBlank(con.AKA_Attorney__c) && con.AKA_Attorney__c != oldMap.get(con.id).AKA_Attorney__c){
                con.AKA_Attorney__c = removeRepeatValues(con.AKA_Attorney__c);
            }
            */
           
        }
    }
    /*
    private static String removeRepeatValues(String akaList){
        String dedupString;
        Set<String> akaSet = new Set<String>();
        if(String.isNotBlank(akaList)){
            for(String s : akaList.split(';')){
                akaSet.add(s);
            }
            for(String aka : akaSet){
                dedupString = String.isNotBlank(dedupString) ? dedupString+ ';'+ aka : aka;
            }
        }
        return dedupString;
    }
    */

}