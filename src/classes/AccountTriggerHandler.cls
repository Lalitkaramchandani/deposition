public class AccountTriggerHandler {
    
    public static void onBeforeUpdateRoutine(List<Account> newList, Map<Id, Account> oldMap){
        
        for(Account acc : newList){
            //AKA feature put on hold 
            /*
            if(String.isNotBlank(Acc.AKA__c) && Acc.AKA__c != oldMap.get(acc.id).AKA__c){
                acc.AKA__c = removeRepeatValues(acc.AKA__c);
            }
            if(String.isNotBlank(Acc.AKA_Law_Firm__c) && Acc.AKA_Law_Firm__c != oldMap.get(acc.id).AKA_Law_Firm__c){
                acc.AKA_Law_Firm__c = removeRepeatValues(acc.AKA_Law_Firm__c);
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
    } */

}