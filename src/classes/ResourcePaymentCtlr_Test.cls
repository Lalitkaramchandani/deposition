@isTest
private class ResourcePaymentCtlr_Test {

	@isTest private static void testPayment() {
        
        TestFactory tFact = new TestFactory();
        List<Invoice__c> invoices = tFact.invoices;
        List<Invoice_Item__c> invoiceItems = tFact.invoiceItems;
        System.debug([SELECT Id, Name, Deposition__c, Account__c, Contact__c, Contact__r.Name,Contact__r.Payment_Method__c, Contact__r.ADP_ID__c , Deposition__r.Name, Deposition__r.Deposition_Date__c, Invoice_Date__c, Due_Amount__c  , Deposition__r.Primary_Court_Reporting_Firm__r.Name, Attendee__c,Attendee__r.Role__c FROM Invoice__c  WHERE Type__c!='Client' AND Payment_Status__c !='Paid' AND Status__c='Valid' AND Deposition__c != NULL AND Deposition__r.Primary_Court_Reporting_Firm__c!=null  ORDER BY Invoice_Date__c ASC NULLS LAST LIMIT 10]);
        System.debug([SELECT Type__c,Payment_Status__c,Status__c  FROM Invoice__c  ORDER BY Invoice_Date__c ASC NULLS LAST LIMIT 10]);
        
        Test.startTest();
            ResourcePaymentCtlr control = new ResourcePaymentCtlr();
            System.debug(control.hasNext);
            control.next();
            System.debug(control.hasPrevious);
            control.previous();
            System.debug(control.pageNumber);
            control.last();
            System.debug(control.getTotalPages());
            control.first();
            control.sortExpression='Deposition__r.Name';
            control.doSort();
            Date dToday = System.today();
            control.startDate = dToday.month()+'/'+(dToday.day()-2)+'/'+dToday.year();
            control.endDate = dToday.month()+'/'+(dToday.day()+3)+'/'+dToday.year();
            control.onSearch();
            System.debug('===='+control.invoices.size());
        
        	control.invoices[0].isSelect = false;
            control.onPay();
        	control.invoices[0].isSelect = true;
            control.onPay();
        
        	System.debug(control.header);
        	control.onExport();
        Test.stopTest();
        System.assertEquals(1, [SELECT Count() FROM Payment__c]);
	}

}