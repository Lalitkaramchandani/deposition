public with sharing class SearchInvoiceCtrl {
	  private String soql {get;set;}
	  public List<Invoice__c> invoices {get;set;}

      public String sortDir {
        get  { if (sortDir == null) {  sortDir = 'asc'; } return sortDir;  }
        set;
      }

      public String sortField {
        get  { if (sortField == null) {sortField = 'Invoice_Amount__c'; } return sortField;  }
        set;
      }

      public SearchInvoiceCtrl() {
        soql = 'select id,Account__r.name, Name,  Invoice_Amount__c, Deposition__r.Case_Name__c,'+
                                 'Deponent_Name__c,Deposition__r.Claims_Professional__c,Deposition__r.Primary_Court_Reporting_Firm__r.name,Deposition__r.Insurance_Claim_Info__c'+
                                    ' from invoice__c';
        runQuery();
      }

      // toggles the sorting of query from asc<-->desc
      public void toggleSort() {
        // simply toggle the direction
        sortDir = sortDir.equals('asc') ? 'desc' : 'asc';
        // run the query again
        runQuery();
      }

      // runs the actual query
      public void runQuery() {
    	system.debug('soql::'+soql);
        try {
          invoices = Database.query(soql + ' order by ' + sortField + ' ' + sortDir + ' limit 20');
        } catch (Exception e) {
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Ooops!'));
        }

  }

  // runs the search with parameters passed via Javascript
  public PageReference runSearch() {
    String name = Apexpages.currentPage().getParameters().get('name');
    String amountLower = Apexpages.currentPage().getParameters().get('amountLower');
    String amountUpper = Apexpages.currentPage().getParameters().get('amountUpper');
    String onlyUnpaid = Apexpages.currentPage().getParameters().get('OnlyUnpaid');
      system.debug('onlyUnpaid::'+onlyUnpaid);

    soql = 'select id,Account__r.name, Name,  Invoice_Amount__c, Deposition__r.Case_Name__c,'+
                                 'Deponent_Name__c,Deposition__r.Claims_Professional__c,Deposition__r.Primary_Court_Reporting_Firm__r.name,Deposition__r.Insurance_Claim_Info__c'+
                                    ' from invoice__c where name!=null';
      if (!name.equals('')){
    	  soql += ' and name LIKE \'%'+ String.escapeSingleQuotes(name)+ '%\'';
      }
        if (!amountLower.equals('')){
            try{
	            Decimal d=decimal.valueOf(amountLower);
		      soql += ' and Invoice_Amount__c > '+d;
            }catch(Exception e){
            }
        }
      if (!amountUpper.equals('')){
            try{
	            Decimal d=decimal.valueOf(amountUpper);
		      soql += ' and Invoice_Amount__c < '+d;
            }catch(Exception e){
            }
        }
      if (!onlyUnpaid.equals('') && onlyUnpaid=='true'){
            try{
		      soql += ' and Payment_Status__c=\'Unpaid\''; 
            }catch(Exception e){
            }
        }
    // run the query again
    runQuery();
    return null;
  }
}