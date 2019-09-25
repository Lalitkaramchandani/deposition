global class ListClass
{
    webservice static string goNext(Id localId) { 
        return doProcess(localId, 1);
    }
    webservice static string goPrev(Id localId) { 
       return doProcess(localId, -1);    
    }
    
    private static string doProcess(Id localId, Integer i){
        Invoice__c inv=   [select id, name from Invoice__c where id=:localId limit 1];  
        Integer current=Integer.valueOf(inv.Name);
        Integer currentLength=string.valueOf(inv.Name).length();
        string s=string.valueOf(current+i);
        Integer diff=currentLength-s.length();
        string diffStr='00000000000'.left(diff);
        s=diffStr+s;
        system.debug('s::'+s);
        List<Invoice__c> lst=  [select id from Invoice__c where name=:s ];
        if(lst.size()>0){
            system.debug('Id::'+lst[0].Id);
            return lst[0].Id;
        }else{
            return '';
        }
    }
}