public class GrantedFilesCntrl {
    public string contactId{get;set;}
    public String depositionId{get;set;}
    public List<File_Access__c>getAccessFiles(){
        return [select Id,File__r.File_Type__c,File__r.File_Size_KB__c,File__r.File_Name__c,File__c,File__r.Deposition__r.Primary_Court_Reporting_Firm__r.Name
              From File_Access__c WHERE Attendee__r.Deposition__c=:depositionId
                AND Attendee__r.Contact__c=:contactId];
    }
}