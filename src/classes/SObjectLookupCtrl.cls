public without sharing class SObjectLookupCtrl {
    public String objectName	{get;set;}
    public String fieldName		{get;set;}
    public String lkName		{get;set;}
    public String lkSearch		{get;set;}
    public String lkId			{get;set;}
    public list<sObject> targetList {get;set;}
    public SObjectLookupCtrl(){
        try{
            targetList = new List<sObject>();
            String lkObject = ApexPages.currentPage().getParameters().get('lkObject');
            objectName = (String.isNotBlank(lkObject) ? lkObject.replaceAll('%',' ') : '');
            
            String lkField = ApexPages.currentPage().getParameters().get('lkField');
            fieldName = (String.isNotBlank(lkField) ? lkField.replaceAll('%',' ') : '');
            
            String programName = ApexPages.currentPage().getParameters().get('lknm');
            if(String.isNotBlank(programName))
                lkName = programName.replaceAll('%',' ');
            
            String lookupId = ApexPages.currentPage().getParameters().get('lkId');
            lkId = (String.isNotBlank(lookupId) ? lookupId.replaceAll('%',' ') : '');
            
            String searchText = ApexPages.currentPage().getParameters().get('lksrch');
            
            if(String.isNotBlank(searchText)){
                lkSearch = searchText.replaceAll('%',' ');
            }
            
            onGo();
        }
        catch(exception e){
        }
    }
    public PageReference onGo(){
        try{
            String queryStr;
            lkSearch = String.isNotBlank(lkSearch) ? lkSearch.trim() : '';
            queryStr = 'SELECT ' + fieldName + ' FROM ' + objectName;

            String additionalFilter = '';
            String filter ='';
            if(String.isNotEmpty(lkSearch)){
                filter = ' WHERE ( ' + fieldName + ' like \'%'+ String.escapeSingleQuotes(lkSearch) +'%\' ) ';
            }
            System.debug(objectName);
            if(objectName== 'Account'){
                filter += (filter!='' ? ' AND ' : ' WHERE ')+ 'Industry in (\'Law Firm\',\'Corporation\') ';
            }
            System.debug('queryStr ' + queryStr + filter);
            queryStr += ' LIMIT 100 ';
            
            targetList = Database.query(queryStr + filter);
        }catch(Exception e){
        }
        return null;
    }
}