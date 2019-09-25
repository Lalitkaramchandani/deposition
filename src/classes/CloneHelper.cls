Public class CloneHelper{
    //Pass the parameters as 1. Parent Object API Name, 2. Source record id, 3. API Name of the related field, 4. Child Object API Name
    Public static Sobject cloneObject(String objName, String recId, String parentFieldApiName, String childObjName){
        string qryStr = prepareQuery(objName, 'Id', recId);
        Sobject sobj = database.query(qryStr);
        Sobject clonedSObj = sobj.clone(false, true);
        if(objName=='Invoice__c'){
            clonedSobj.put('Invoice_Date__c', System.today());
            clonedSobj.put('Clone__c', true);
        }
        insert clonedSObj;
        if(childObjName != null && parentFieldApiName != null){
            string childQry = prepareQuery(childObjName, parentFieldApiName, recId);
            List<Sobject> sobjList = database.query(childQry);
            List<Sobject> clonedSobjList = sobjList.deepClone(false);
            for(Sobject s : clonedSobjList){
                s.put(parentFieldApiName, clonedSObj.id);//Changing the parent id
                
            }
            insert clonedSobjList;
        }
        return clonedSObj;
    }
    //This method is used to prepare the desired query string by passing the objectname and where clause condition
    private static String prepareQuery(String sobjName, String fieldName, String recId){
        system.debug('$$$'+sobjName);
        system.debug('$$$'+fieldName);
        system.debug('$$$'+recId);
        Map<String, Schema.SObjectField> fieldsMap = Schema.getGlobalDescribe().get(sobjName.toLowerCase()).getDescribe().Fields.getMap();
        String fields = '';
        for(Schema.SObjectField sf : fieldsMap.values()) {
            Schema.DescribeFieldResult fr = sf.getDescribe();
            if(fr.isCreateable())
                fields += fr.getName()+',';
        }
        if(fields.endsWith(','))
            fields = fields.substring(0,fields.lastIndexOf(','));
        String qryString = 'Select ' +fields+' from '+sobjName+' where '+fieldName+' = \''+recId+'\'';
        return qryString;
    }
}