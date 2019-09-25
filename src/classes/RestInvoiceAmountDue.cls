@RestResource(urlMapping='/invoice/amountdue/*')
global with sharing class RestInvoiceAmountDue {
    
    // https://instance.salesforce.com/services/apexrest/invoice/amountdue/

    @HttpGet
    global static Decimal doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String invoiceNo = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        List<Invoice__c> invoices = [SELECT Id,name, Due_Amount__c FROM Invoice__c WHERE Name=:invoiceNo ];
        if(!invoices.isEmpty()){
            return invoices[0].Due_Amount__c!=null ? invoices[0].Due_Amount__c:0;
        }
        return 0;
    }
    
}