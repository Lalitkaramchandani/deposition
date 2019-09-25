/*************************************************************
*Deposition Manager, takes care of Logging changes and future updates
**************************************************************/
public with sharing class DepositionManager {
  
  private static Map<String,List<Schema.DescribeFieldResult>> mapFields = new Map<String,List<Schema.DescribeFieldResult>>();
  private static Boolean isExecuted = false;
  
  
  public void setChangeLog(List<Deposition__c> lstDeposition) {
     if(isExecuted == true) return;
     
     isExecuted = true; 
     for(Deposition__c deposition :lstDeposition) {
       if(deposition.Generate_Change_Log__c != true) {
         continue;
       }
      deposition.Change_Log__c = generatePayLoad(deposition,getFields('Deposition__c',deposition));
    }
  }
  
   public static void sendEmail(Exception ex) {
  	try {
	    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	    String[] toAddress = new String[]{'iyer.salesforce@gmail.com'};
	    mail.setSubject('Exception occurred');
	    mail.setToAddresses(toAddress);
	    String message = ex.getMessage() + '\n<-->';
	    message += ex.getStackTraceString() + '\n<-->';
	    message += ex.getLineNumber() + '\n<-->';
	    message += ex.getTypeName();
	    
	    mail.setPlainTextBody(message);
	    
	    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
  	}
  	catch(Exception e) {
  	  System.debug(e); //Ignore what else can we do
  	}
  }
  
  
  //=========================================================================//
  //Generate String to be logged
  //=========================================================================//
  private static String generatePayLoad(SObject sObj,List<Schema.DescribeFieldResult> llstFields) {
    String payLoad = '';
    SObject oldSObject = Trigger.oldMap.get(sObj.Id);
   
    for(Schema.DescribeFieldResult fieldResult :llstFields){
      String fld =  fieldResult.getName();
      string newFieldValue  =  String.valueOf(sObj.get(fld));     
      
      if(oldSObject != null) {
        String oldFieldValue = String.valueOf(oldSObject.get(fld));
        if(oldFieldValue != newFieldValue) {
          payLoad += fieldResult.getLabel() + ' = ' + newFieldValue;    
          payload += ' ; (Old Value = ' + oldFieldValue + ')';
          payload += '\n';
        }  
      }
     
    }
    if(payload.length() > 32000) {
      return payload.subString(0,32000);
    }
    return payload.trim();
  }
  
  
  //----------------------------------------------------------------------//
  //get All Fields for the SObject,so that we can generate the String
  //----------------------------------------------------------------------//
  private static List<Schema.DescribeFieldResult> getFields(String objectType,SObject sObj) {
    if(mapFields.containsKey(objectType)) {
      return mapFields.get(objectType);
    }
    
    List<Schema.DescribeFieldResult> lstFields = new List<Schema.DescribeFieldResult>();
    
    Court_Search_Email_Template__c template = Court_Search_Email_Template__c.getInstance();
    Set<String> setExcludeFields = new Set<String>();
    
    if(!String.isBlank(template.Exclude_Fields_For_Logging__c)) {
      setExcludeFields.addAll(template.Exclude_Fields_For_Logging__c.split(';'));
    }
    
    //Describe Sobject and get the object Name and token
    Schema.DescribeSObjectResult result = sObj.getSObjectType().getDescribe(); 
    //Get all fields from the token
    Map<String, Schema.SObjectField> fldMap = result.fields.getMap();
    for(String key :fldMap.keyset()) {
      Schema.DescribeFieldResult fldResult =  fldMap.get(key).getDescribe();
      String fldName = fldResult.getName();
      
      if(setExcludeFields.contains(fldName)) {
        continue;
      }
      
      lstFields.add(fldResult);
    }
    //Sort the fields for easy debugging and logging
    //lstFields.sort();
    mapFields.put(objectType,lstFields);
    
    return mapFields.get(objectType);
  }
}