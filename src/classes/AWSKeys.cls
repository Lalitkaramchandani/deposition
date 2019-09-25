public class AWSKeys {
    
    public class AWSKeysException extends Exception {}
    
    Amazon_S3_Configuration__c  keyObj = null;
    public string key { get { return keyObj.key__c; } private set; }
    public string secret { get { return keyObj.secret__c; } private set; }
    // constructor
    public AWSKeys(string name) {
        try {
            keyObj = [select key__c,secret__c,id from Amazon_S3_Configuration__c limit 1]; 

        } catch (QueryException queryEx) {
            system.debug('Error when querying the AWSKey__c custom object. Did not find any record with name of ['+name+']. Please make sure the name is correct or create a record with the proper AWS credentials and retry.');
            //ApexPages.addMessages(queryEx);
            throw new AWSKeysException('Error when querying the AWSKey__c custom object. Did not find any record with name of ['+name+']. Please make sure the name is correct or create a record with the proper AWS credentials and retry.');
            //keyObj = new AWSKey__c( key__c='not set', secret__c='not set' );
        } 
        //don't catch other exceptions, let them fall through to the calling class....  
    }
    
    static testmethod void testInstance() {
        try{
            AWSKeys k = new AWSKeys('badname');
        }catch(AWSKeysException AWSExcept){
            system.debug('here: ' +AWSExcept.getTypeName());
            system.assert(AWSExcept.getTypeName().contains('AWSKeys.AWSKeysException'));
        }

    }
    

}