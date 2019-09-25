/**************************************************
                Name        : TestFactory
                Author      : Lalit karamchandani
                Purpose     : Class is being setup as Factory for test data, will be maintain in the future for more test cases
                Created Date: 02 May 2019
                
                
*****************************************************/
@isTest
public class TestFactory {

    public String defaultFirm = 'Lexitas';
    String defaultFirmOld = 'NextGen Reporting';
    String defaultRT = 'Test';
    
    public User communtiyUser{
        get{
            if(communtiyUser == null){
                Id p = [select id from profile where name='Customer Community Login User(Custom)'].Id;
                Account ac = new Account(name ='Grazitti') ;
                insert ac; 
                
                // Contact con = new Contact(LastName ='testCon',AccountId = ac.Id);
                // insert con;  
                          
                communtiyUser = new User(alias = 'test123', email='test123@noemail.com',
                        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                        localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                        ContactId = contacts[0].Id,
                        timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
                
                insert communtiyUser;
            }
            return communtiyUser;
        }set;
    }
    
    public User communtiyUser2{
        get{
            if(communtiyUser == null){
                Id p = [select id from profile where name='Customer Community Login User(Custom)'].Id;
                communtiyUser = new User(alias = 'test123', email='test5@test.com',
                        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                        localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                        ContactId = contacts[4].Id,
                        timezonesidkey='America/Los_Angeles', username='tester5@noemail.com');
                
                insert communtiyUser;
            }
            return communtiyUser;
        }set;
    }
    
	public List<Deposition__c> depositions {
	    get{
    	    if(depositions == null){
                /*
                DateTime now = System.now();
                DateTime nowNextHour = System.now().addHours(1);
                Time nowt = Time.newInstance(now.hour(), now.minute(),0,0);
                Time nowNextt = Time.newInstance(nowNextHour.hour(), nowNextHour.minute(),0,0);
                */
    	        depositions = new List<Deposition__c>{
                    new Deposition__c(Deposition_Services__c = 'Court Reporter; LegalView (Remote Video)', Deposition_Date__c = System.today().addDays(5),
                                      Primary_Court_Reporting_Firm__c = firmMap.get(defaultFirm).Id, Deponent_Name__c='test 1',
                                      GOOGLE_DRIVE_FOLDER_ID__C  = 'testdepo1',
                                      Confirm_Interpreter__c = 'Not Sent', Confirm_Reporter__c = 'Not Sent', Confirm_Video_Tech__c = 'Not Sent'),
    	            new Deposition__c(Deposition_Services__c = 'Court Reporter; LegalView (Remote Video)', Deposition_Date__c = System.today().addDays(5),
    	                            Primary_Court_Reporting_Firm__c = firmMap.get(defaultFirmOld).Id, Deponent_Name__c='test 2',
    	                            Confirm_Interpreter__c = 'Not Sent', Confirm_Reporter__c = 'Not Sent', Confirm_Video_Tech__c = 'Not Sent',
    	                            GOOGLE_DRIVE_FOLDER_ID__C  = 'testdepo2'),
    	            new Deposition__c(Deposition_Services__c = 'Court Reporter; LegalView (Remote Video)', Deposition_Date__c = System.today().addDays(-5),
    	                            Primary_Court_Reporting_Firm__c = firmMap.get(defaultFirmOld).Id, Deponent_Name__c='test 2',
    	                            Confirm_Interpreter__c = 'Not Sent', Confirm_Reporter__c = 'Not Sent', Confirm_Video_Tech__c = 'Not Sent',
    	                            GOOGLE_DRIVE_FOLDER_ID__C  = 'testdepo3'),
    	            new Deposition__c(Deposition_Services__c = 'Court Reporter; LegalView (Remote Video)', Deposition_Date__c = System.today().addDays(1),
    	                            Primary_Court_Reporting_Firm__c = firmMap.get(defaultFirm).Id, Deponent_Name__c='test 2',
    	                            Confirm_Interpreter__c = 'Not Sent', Confirm_Reporter__c = 'Not Sent', Confirm_Video_Tech__c = 'Not Sent',
    	                            GOOGLE_DRIVE_FOLDER_ID__C  = 'testdepo4')
    	        };
    	        insert depositions;
    	    }
    	    return depositions;
	    }set;
	}
	
	public List<Account> accounts {
	    get{
    	    if(accounts == null){
    	        accounts = new List<Account>{
    	            new Account(Name='Test 1', Industry='Law Firm'),
    	            new Account(Name='Test 2', Industry='Court Reporting'),
    	            new Account(Name='Test 3', Industry='Law Firm')
    	        };
    	        insert accounts;
    	    }
    	    return accounts;
	    }set;
	}
	public List<Contact> contacts {
	    get{
    	    if(contacts == null){
    	        contacts = new List<Contact>{
    	            new Contact(FirstName = 'Test 1', LastName = 'last', Email='test1@test.com', Default_CR_Firm__c = firmMap.get(defaultFirm).Id,
    	                AccountId = accounts[0].Id, Rate_Sheet__c = rateSheetMap.get(defaultRT).Id,
    	                Alt_Phone__c='0909090909',On_Time__c=1),
    	            new Contact(FirstName = 'Test 2', LastName = 'last', Email='test2@test.com', Default_CR_Firm__c = firmMap.get(defaultFirmOld).Id,
    	                AccountId = accounts[1].Id, Rate_Sheet__c = rateSheetMap.get(defaultRT+'1').Id,
    	                Alt_Phone__c='0909090909',On_Time__c=1),
	                new Contact(FirstName = 'Test 3', LastName = 'last', Email='test3@test.com', Default_CR_Firm__c = firmMap.get(defaultFirm).Id,
    	                AccountId = accounts[2].Id, Rate_Sheet__c = rateSheetMap.get(defaultRT).Id,
    	                Alt_Phone__c='0909090909',On_Time__c=1),
	                new Contact(FirstName = 'Test 4', LastName = 'last', Email='test4@test.com', Default_CR_Firm__c = firmMap.get(defaultFirm).Id,
    	                AccountId = accounts[2].Id, Rate_Sheet__c = rateSheetMap.get(defaultRT).Id,
    	                Alt_Phone__c='0909090909',On_Time__c=0),
	                new Contact(FirstName = 'Test 5', LastName = 'last', Email='test5@test.com', Default_CR_Firm__c = firmMap.get(defaultFirm).Id,
    	                AccountId = accounts[2].Id, Rate_Sheet__c = rateSheetMap.get(defaultRT).Id,
    	                Alt_Phone__c='0909090909',On_Time__c=1)
    	        };
    	        insert contacts;
    	    }
    	    return contacts;
	    }set;
	}
	
	public Map<String, Firm__c> firmMap {
	    get{
    	    if(firmMap == null){
    	        firmMap = new Map<String, Firm__c>{
    	            defaultFirm => new Firm__c( Name='Lexitas',
        	                Community_Header__c='<div class="ngheader"/> ', Community_Footer__c='<p style="color: #ffffff;">test</p>',
                            Email_Header_HTML__c='<div class="ngheader"/>', Email_Footer_HTML__c='<div class=standardtext> </div>',
                            Web_Page_Header_HTML__c='<title>Lexitas | Upload Files </title>', Web_Page_Footer_HTML__c='<div id="bottom_container"> <div id="bottom_navigation">',
                            Scheduling_Email_Address__c='test@test.com', Production_Email_Address__c='test@test.com',
                            Accounting_Email_Address__c='test@test.com'),
                    
                    defaultFirmOld => new Firm__c( Name='NextGen Reporting',
        	                Community_Header__c='<div class="ngheader"/> ', Community_Footer__c='<p style="color: #ffffff;">test</p>',
                            Email_Header_HTML__c='<div class="ngheader"/>', Email_Footer_HTML__c='<div class=standardtext> </div>',
                            Web_Page_Header_HTML__c='<title>Lexitas | Upload Files </title>', Web_Page_Footer_HTML__c='<div id="bottom_container"> <div id="bottom_navigation">',
                            Scheduling_Email_Address__c='test@test.com', Production_Email_Address__c='test@test.com',
                            Accounting_Email_Address__c='test@test.com')
                    
    	        };
    	        insert firmMap.values();
    	    }
    	    return firmMap;
	    }set;
	}
    
    
	public List<Rate_Sheet__c> rateSheets {
	    get{
    	    if(rateSheets == null){
    	        rateSheets = new List<Rate_Sheet__c>{
                    new Rate_Sheet__c(
                        Name = defaultRT, Payment_Term_Days__c='10', Show_Quantity_Column__c=true, Show_Rate_Column__c=true, 
                        Show_Rows__c = true, Type__c = 'Reporter', Show_After_Date_Surcharge__c = false),
                    new Rate_Sheet__c(
                        Name = defaultRT+'1', Payment_Term_Days__c='10', Show_Quantity_Column__c=true, Show_Rate_Column__c=true, 
                        Show_Rows__c = true, Type__c = 'Client', Show_After_Date_Surcharge__c = false),
                    new Rate_Sheet__c(
                        Name = defaultRT+'2', Payment_Term_Days__c='10', Show_Quantity_Column__c=true, Show_Rate_Column__c=true, 
                        Show_Rows__c = true, Type__c = 'Interpreter', Show_After_Date_Surcharge__c = false)
    	        };
    	        insert rateSheets;
    	    }
    	    return rateSheets;
	    }set;
	}
    
    public Map<String, Rate_Sheet__c> rateSheetMap {
	    get{
    	    if(rateSheetMap == null){
    	        rateSheetMap = new Map<String, Rate_Sheet__c>();
    	        for(Rate_Sheet__c rt: rateSheets){
    	            rateSheetMap.put(rt.Name, rt);
    	        }
    	    }
    	    return rateSheetMap;
	    }set;
	}
	
	public List<Item__c> items{
	    get{
    	    if(items == null){
    	        items = new List<Item__c>{
                    new Item__c(Name='Transcript Original',Commissionable__c=true, Description__c = 'Default Original ', Type__c = 'Transcript' ),
                    new Item__c(Name='Transcript oCopy',Commissionable__c=true, Description__c = 'Default Copy ', Type__c = 'Transcript' ),
                    new Item__c(Name='Transcript Expedite',Commissionable__c=true, Description__c = 'Default Expedite ', Type__c = 'Transcript' ),
                    new Item__c(Name='Transcript eCopy',Commissionable__c=true, Description__c = 'Default Realtime ', Type__c = 'Transcript' ),
                    new Item__c(Name='Miscellaneous',Commissionable__c=true, Description__c = ' ', Type__c = 'Miscellaneous'),
                    new Item__c(Name='Appearance Fee',Commissionable__c=true, Description__c = '', Type__c = 'Appearance Fee'),
                    new Item__c(Name='Cancellation',Commissionable__c=true, Description__c = '', Type__c = 'Cancellation'),
                    new Item__c(Name='Video',Commissionable__c=true, Description__c = 'Default Video', Type__c = 'Video')
                    
    	        };
    	        insert items;
    	    }
    	    return items;
	    }set;
	}
	public Map<String, Item__c> itemMap {
	    get{
    	    if(itemMap == null){
    	        itemMap = new Map<String, Item__c>();
    	        for(Item__c item: items){
    	            itemMap.put(item.Name, item);
    	        }
    	    }
    	    return itemMap;
	    }set;
	}
	
	
	public List<Rate_Sheet_Item__c> rtItems{
	    get{
    	    if(rtItems == null){
    	        rtItems = new List<Rate_Sheet_Item__c>();
    	        for(Rate_Sheet__c rt : rateSheets){
    	            
        	        for(Item__c item: items){
        	            Rate_Sheet_Item__c rtItem = new Rate_Sheet_Item__c(
                            Rate_Sheet__c = rt.Id, Item__c = item.Id,
                            Invoice_Text__c = 'invoice of '+ item.Type__c +' '+item.Description__c, Price__c = 12, State__c = 'All States',
                            Default__c = item.Description__c);
                        rtItem = prepareRT(rtItem, item);
                        
                        rtItems.add(rtItem);
        	        }
    	        }
    	        insert rtItems;
    	    }
    	    return rtItems;
	    }set;
	}
	Rate_Sheet_Item__c prepareRT(Rate_Sheet_Item__c rtItem, Item__c item){
	    Switch on item.type__c {
	        when 'Transcript' {
	            rtItem.Units_of_Measure__c = 'Per Page';
	        }
	        when 'Miscellaneous'{
	            rtItem.Units_of_Measure__c = 'Per Job';
	        }
	        when 'Appearance Fee'{
	            rtItem.Units_of_Measure__c = 'Per Job';
	        }
	        when 'Cancellation'{
	            rtItem.Units_of_Measure__c = 'Per Job';
	        }
	        when 'Video'{
	            rtItem.Units_of_Measure__c = 'Per Hour';
	        }
	        when else {
	            
	        } 
	    }
	    return rtItem;
	}
	
	public List<Attendee__c> attendees {
        get{
    	    if(attendees == null){
	            attendees = new List<Attendee__c>();
	            
	            for(Deposition__c depo: depositions){
	                attendees.add(new Attendee__c(Deposition__c = depo.Id, Contact__c = contacts[0].Id, Role__c='Court Reporter'));
	                attendees.add(new Attendee__c(Deposition__c = depo.Id, Contact__c = contacts[1].Id, Role__c='Videographer/Technician'));
	                attendees.add(new Attendee__c(Deposition__c = depo.Id, Contact__c = contacts[2].Id, Role__c='Interpreter'));
	                attendees.add(new Attendee__c(Deposition__c = depo.Id, Contact__c = contacts[3].Id, Role__c='Attorney'));
	            }
	            
	            insert attendees;
    	    }
    	    return attendees;
        }set;
	}
    
    public List<Invoice__c> invoices{
        get{
            if(invoices == null){
                invoices = new List<Invoice__c>();
                Set<Id> ids = new Set<Id>();
                Map<String, String> roles = new Map<String, String>{
                            'Court Reporter'=>'Reporter',
                            'Videographer/Technician'=>'Video/Tech',
                            'Interpreter'=>'Interpreter'};
                for(Attendee__c att:attendees){
                    if(roles.containsKey(att.Role__c)){
                        ids.add(att.Id);
                    }
                }
                
                for(Attendee__c att:[SELECT Id, Contact__c, Deposition__c, Contact__r.AccountId, Deposition__r.Deponent_Name__c,
                                     Role__c, Primary_Attorney__c
                                     FROM Attendee__c WHERE Id in:ids]){
                    Invoice__c newInvoice = new Invoice__c(
                            Attendee__c = att.Id, Contact__c = att.Contact__c,
                            Account__c = att.Contact__r.AccountId,
                            Deposition__c = att.Deposition__c, 
                        	Invoice_Date__c=System.today(),
                            // Ordering_Party__c = att.Primary_Attorney__c,
                            Deponent_Name__c = att.Deposition__r.Deponent_Name__c, 
                            Status__c='Valid');
                    
                    newInvoice.Type__c = roles.get(att.Role__c);
                    invoices.add(newInvoice);
                }
                insert invoices; 
            }
            return invoices;
        }set;
    }
    
    public List<Invoice_Item__c> invoiceItems{
        get{
            if(invoiceItems == null){
                invoiceItems = new List<Invoice_Item__c>();
                Id rtId = rateSheetMap.get(defaultRT).Id;
                for(Invoice__c inv : invoices){
                    for(Rate_Sheet_Item__c rtItem : rtItems){
                        if(rtItem.Rate_Sheet__c == rtId)
                        invoiceItems.add(new Invoice_Item__c(
                            Item__c = rtItem.Item__c, Invoice__c = inv.Id,
                            Rate_Sheet_Item__c = rtItem.Id, Quantity__c=1,
                            Units_of_Measure__c =rtItem.Units_of_Measure__c,
                            Price__c = rtItem.Price__c, Invoice_Text__c = rtItem.Invoice_Text__c,
                            Order__c = rtItem.Order_No__c));
                    }
                }
                insert invoiceItems;
            }
            return invoiceItems;
        }set;
        
    }
    public static List<Twilio_Configuration__c> twilios{
        get{
            if(twilios == null){
                twilios = new List<Twilio_Configuration__c>();
                twilios.add(new Twilio_Configuration__c(Name='test',
                    Account_Name__c='test', Account_SID__c='sid', Auth_Token__c='token', From_Phone_Number__c='34', 
                    Test_Account_SID__c='rtes', Test_Auth_Token__c='te' ));
                insert twilios;
            }
            return twilios;
        }set;
    }
}