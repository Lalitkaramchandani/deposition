/**
                                    Name             : PrepareInvoice_Ctrl
                                    Date             : 21 Nov 2015
                                    Descripition     : This class is used by PrepareInvoice VF page for prepare a invoice record
                                                       for a attendee and allow user to modify the invoice item prices, modification, Quantity etc.
                                                       
*/ 
public class PrepareInvoice_Ctrl {
    public static Integer counter = 0;
    public boolean showQuantity {get;set;}
    string attendeeID;
    public Attendee__c attendee {get;set;}
    public String selectedRateSheet{get;set;}
    public String selectedRateSheetName{get;set;}
    public List < InvoiceRateSheetItem > lstInvoiceItems{get;set;}
    public List < InvoiceRateSheetItem > nextListInvoiceItems{get;set;}
    public boolean nextPageMode{get;set;}
    public Invoice__c newInvoice{get;set;}
    public string rateSheetName{get;set;}
    public List<SelectOption>lstRateSheetItems{get;set;}
    Map<Id,Rate_Sheet_Item__c>mapRateSheeItems = new Map<Id,Rate_Sheet_Item__c>();
    public Integer selectedIndex{get;set;}
    public PrepareInvoice_Ctrl() {
        selectedIndex = 0;
        attendeeID = apexpages.currentpage().getparameters().get('attendeeId');
        newInvoice = new Invoice__c();
        Set<String>setStateNames = new Set<String>();
        if (attendeeID != null && attendeeID != '') {
            attendee = [select id,Role__c, Deposition_Date__c,Deposition__c,Contact__r.AccountId, Deposition_Location__c, Deposition_Location__r.name,
                       Deposition__r.Deposition_Location__c,Deposition__r.Case_Name__c, Deposition__r.Deponent_Name__c,
                       Deposition__r.Billing_Notes__c, Deposition__r.Corporate_Client_Source__c, 
                       Deposition__r.Transcript_page_count__c,Standing_Orders_del__c, Deposition__r.Page_Count__c, 
                       Deposition__r.Exhibit_page_count__c, Deposition__r.Post_event_Notes__c, Contact__r.Account.Industry
                       ,Deposition__r.Event_Location__c,Primary_Attorney__c,Deposition__r.Deposition_Time__c ,Deposition__r.Expedite__c ,
                       Deposition__r.Deposition_Services__c,Deposition__r.Summary_of_Billable_Services__c,
                       Deposition__r.Insurance_Claim_Info__c,Deposition__r.Claims_Professional__c
                       ,Deposition__r.State__c,Deposition__r.Matter_Number__c,
                       Contact__r.Account.Financial_Notes__c, Contact__r.Financial_Notes__c
                       FROM Attendee__c 
                       WHERE  id = : attendeeID
            ];
           
            if(attendee.Primary_Attorney__c == false){
                List<Attendee__c>lstPrimaryAttorney = [select Id,Contact__r.AccountId FROM Attendee__c WHERE Primary_Attorney__c= TRUE
                                                       AND ID !=: attendee.Id AND Deposition__c=:attendee.Deposition__c
                                                       AND Contact__r.AccountId  =:attendee.Contact__r.AccountId];
                if(lstPrimaryAttorney.size()>0)
                    attendee.Primary_Attorney__c= TRUE;
            }
            newInvoice = new Invoice__c(Attendee__c = attendee.id, Contact__c = attendee.Contact__c,
                                      Deposition__c = attendee.Deposition__c,
                                      Claim_No_Text__c= attendee.Deposition__r.Insurance_Claim_Info__c,
                                      Claims_Professional_Text__c= attendee.Deposition__r.Claims_Professional__c,
                                      Matter_Number_Text__c= attendee.Deposition__r.Matter_Number__c,
                                       Type__c = apexpages.currentpage().getparameters().get('type'),
                                       Deponent_Name__c=attendee.Deposition__r.Deponent_Name__c
                                       ,Ordering_Party__c=attendee.Primary_Attorney__c);
        
        }
        selectedRateSheet = apexpages.currentpage().getparameters().get('rateSheetId');
        Rate_Sheet__c rateSheet=[select id,Name, Show_Quantity_Column__c, Show_Rate_Column__c, Show_Rows__c,Payment_Term_Days__c
                                 FROM Rate_Sheet__c WHERE id=:selectedRateSheet ];
                                 
        rateSheetName = rateSheet.Name;
        newInvoice.Rate_Sheet__c = rateSheet.id;
        newInvoice.Show_Quantity_Column__c=rateSheet.Show_Quantity_Column__c;
        newInvoice.Show_Rate_Column__c=rateSheet.Show_Rate_Column__c;
        newInvoice.Show_Rows__c =rateSheet.Show_Rows__c ;
        newInvoice.Payment_Term_Days__c=rateSheet.Payment_Term_Days__c;
        
        lstInvoiceItems = new List < InvoiceRateSheetItem > ();
        lstRateSheetItems = new List<SelectOption>();
        lstRateSheetItems.add(new SelectOption('','--None--'));
        if (selectedRateSheet != null) {
            Map<String,List<Rate_Sheet_Item__c>>mapRateSheeItem = new Map<String,List<Rate_Sheet_Item__c>>();
            List < Rate_Sheet_Item__c > lstRSI = [select id, name, Price__c,State__c, Item__c,Item__r.Name, Units_of_Measure__c,Default__c,Invoice_Text__c from Rate_Sheet_Item__c
                                                  
                                                  where Rate_Sheet__c = : selectedRateSheet
                                                  AND State__c Includes ('All States', :attendee.Deposition__r.State__c)
                                                  AND Item__c != NULL
                                                  ORDER By Order_No__c ASC,Item__r.Order_No__c, Item__r.Name
                                                  ];
            for(Rate_Sheet_Item__c rateSheetItem: lstRSI ){
                String ratesheetState = rateSheetItem.State__c!= NULL ?rateSheetItem.State__c: '' ;
                List<Rate_Sheet_Item__c> lstRateSheetItems = new List<Rate_Sheet_Item__c>();
                
                if(ratesheetState.indexOf(attendee.Deposition__r.State__c)!= -1){
                    ratesheetState = attendee.Deposition__r.State__c;
                    lstRateSheetItems.add(rateSheetItem);
                }
                else if(ratesheetState.indexOf('All States')!= -1){
                    ratesheetState = 'All States';
                    lstRateSheetItems = mapRateSheeItem.get(rateSheetItem.Item__c+'-'+rateSheetItem.Default__c+'-'+ratesheetState);
                    if(lstRateSheetItems == NULL)
                        lstRateSheetItems = new List<Rate_Sheet_Item__c>();
                    lstRateSheetItems.add(rateSheetItem);
                }
                mapRateSheeItem.put(rateSheetItem.Item__c+'-'+rateSheetItem.Default__c+'-'+ratesheetState,lstRateSheetItems);
                
            }
            
            set<Id>setAddedRateSheeItemIds = new Set<Id>();
            List<Rate_Sheet_Item__c> lstRateSheetItemToAdd = new List<Rate_Sheet_Item__c>();
            for (Rate_Sheet_Item__c rsi: lstRSI) {
                String keyValue = rsi.Item__c+'-'+rsi.Default__c;
                if(mapRateSheeItem.containskey(keyValue+'-'+attendee.Deposition__r.State__c)){
                    lstRateSheetItemToAdd= mapRateSheeItem.get(keyValue+'-'+attendee.Deposition__r.State__c);
                }else if(mapRateSheeItem.containskey(keyValue+'-All States')){
                    lstRateSheetItemToAdd= mapRateSheeItem.get(keyValue+'-All States');
                }
                for(Rate_Sheet_Item__c rateSheetItem: lstRateSheetItemToAdd){
                    if( rateSheetItem.Item__c != NULL){
                       // system.debug('##$$'+rsi.Item__r.Name);
                        //if(rateSheetItem.Item__r.Name!='Appearance Fee'  || (rateSheetItem.Item__r.Name=='Appearance Fee' && attendee.Primary_Attorney__c ==true)){
                            if(setAddedRateSheeItemIds.contains(rateSheetItem.id)==false){
                                lstInvoiceItems.add(new InvoiceRateSheetItem(rateSheetItem, attendee,newInvoice.Type__c));
                                lstRateSheetItems.add(new SelectOption(rateSheetItem.Id,rateSheetItem.Item__r.Name));
                                mapRateSheeItems.put(rateSheetItem.Id,rateSheetItem);
                            }
                            setAddedRateSheeItemIds.add(rateSheetItem.id);
                        //}
                    }
                }
                
            }
            lstInvoiceItems.add(new InvoiceRateSheetItem(new Rate_Sheet_Item__c(), attendee,newInvoice.Type__c));
            
        }

        nextPageMode = false;
        showQuantity = false;
    }
    public void itemChanged(){
        if(selectedIndex >=0){
            InvoiceRateSheetItem invRateSheetItem = lstInvoiceItems[selectedIndex];
            
            lstInvoiceItems[selectedIndex] = new InvoiceRateSheetItem(mapRateSheeItems.get((invRateSheetItem.selectedItemId)), attendee,newInvoice.Type__c);
            
        }
    }
    public PageReference next() {
        nextListInvoiceItems = new List < InvoiceRateSheetItem > ();
        Integer RSItemcounter = 1;
        for (InvoiceRateSheetItem temp: lstInvoiceItems) {
            //if(mapRateSheeItems.containsKey(temp.selectedItemId))
            //    temp.rsItem = mapRateSheeItems.get((temp.selectedItemId));
            if (temp != null && temp.quantity != null && String.ValueOf(temp.quantity) != '') {
                try {
                    Decimal d = Decimal.valueOf(temp.quantity);
                    temp.IntQuantity = d;
                } catch (Exception e) {
                    temp.rsItem.Price__c.addError('Quantity for this item is not Numeric value');
                    return null;
                }
                temp.calculateTotalPrice();
                temp.order = RSItemcounter;
                RSItemcounter++;
                nextListInvoiceItems.add(temp);
            }
        }
        nextPageMode = true;

        return null;
    }

    public PageReference addRow() {
        if (lstInvoiceItems != null) {
            lstInvoiceItems.add(new InvoiceRateSheetItem(new Rate_Sheet_Item__c(), attendee,newInvoice.Type__c));
        }
        return null;
    }

    public List<SelectOption> getUnitOfMeasureOptions(){
       List<SelectOption> options = new List<SelectOption>();
            
       Schema.DescribeFieldResult fieldResult =
       Rate_Sheet_Item__c.Units_of_Measure__c.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            
       for( Schema.PicklistEntry f : ple)
       {
          options.add(new SelectOption(f.getLabel(), f.getValue()));
       }       
       return options;
    }
    public class InvoiceRateSheetItem {

        public Rate_Sheet_Item__c rsItem {get;set;}
        Public String quantity{get;set;}
        Public Decimal IntQuantity{get;set;} 
        Public Integer modification{get;set;}
        Public Decimal totalPrice{get;set;}
        Public Integer order{get;set;}
        public string selectedItemId{get;set;}
        public string unitOfMeasure{get;set;}
        public String invoiceText{get;set;}
        public InvoiceRateSheetItem(Rate_Sheet_Item__c rsItem, Attendee__c attendee,String invoiceType) {
            //counter++;
            this.rsItem = rsItem;
            this.selectedItemId = rsItem.id;
            this.unitOfMeasure = rsItem.Units_of_Measure__c;
            this.invoiceText = rsItem.Invoice_Text__c;
            //modification = 0;
            quantity = '';
            //order=counter;
            if (rsItem.Default__c == 'Always') {
                quantity = '1';
            } else if (rsItem.Default__c == 'Default Original' || rsItem.Default__c == 'Default Copy') {
               
                /**
                 When creating an invoice for clients, it should apply the total page count to the default original 
                 and default copy.
                */
                if(invoiceType== 'Client' && attendee.Deposition__r.Page_Count__c != null){
                    if(rsItem.Default__c == 'Default Original' && (attendee.Primary_Attorney__c || attendee.Role__c =='Scheduler'))
                        quantity = attendee.Deposition__r.Page_Count__c.trim();
                    if(rsItem.Default__c == 'Default Copy' && attendee.Primary_Attorney__c == false && attendee.Role__c !='Scheduler')
                        quantity = attendee.Deposition__r.Page_Count__c.trim();
                }
                if(invoiceType == 'Reporter' && attendee.Deposition__r.Transcript_page_count__c != null)
                    quantity = attendee.Deposition__r.Transcript_page_count__c.trim();
            }else if(rsItem.Default__c == 'Default Exhibit' && attendee.Deposition__r.Exhibit_page_count__c!= NULL){
                quantity = attendee.Deposition__r.Exhibit_page_count__c.trim();
            }
            if(rsItem.Default__c =='Default Video' && attendee.Deposition__r.Deposition_Services__c!= NULL
               && attendee.Deposition__r.Deposition_Services__c.contains('Traditional Video') ){
               IntQuantity= 1;
               quantity  ='1';
               
            }
            
                
            if(invoiceType=='Client' && (rsItem.Default__c == 'Default Original' || rsItem.Default__c == 'Default Copy') && attendee.Deposition__r.Expedite__c != NULL && attendee.Deposition__r.Expedite__c !='None'){
                if( attendee.Deposition__r.Expedite__c== 'Same Day Turnaround')
                    this.modification = 110;
                else if( attendee.Deposition__r.Expedite__c== 'Next Day Turnaround')
                    this.modification = 100;
                else if( attendee.Deposition__r.Expedite__c== '2 Day Turnaround')
                    this.modification = 90;
                else if( attendee.Deposition__r.Expedite__c== '3 Day Turnaround')
                    this.modification = 80;
                else if( attendee.Deposition__r.Expedite__c== '4 Day Turnaround')
                    this.modification = 70;
                else if( attendee.Deposition__r.Expedite__c== '5 Day Turnaround')
                    this.modification = 60;
                else if( attendee.Deposition__r.Expedite__c== '6 Day Turnaround')
                    this.modification = 50;
                else if( attendee.Deposition__r.Expedite__c== '7 Day Turnaround')
                    this.modification = 40;
                else if( attendee.Deposition__r.Expedite__c== '8 Day Turnaround')
                    this.modification = 30;
                else if( attendee.Deposition__r.Expedite__c== '9 Day Turnaround')
                    this.modification = 20;
               
            }
            

        }
        public void calculateTotalPrice() {
            if (rsItem != null && rsItem.Price__c != null && IntQuantity != null ) {
                Integer modify = modification != null?modification:0;
                totalPrice = rsItem.Price__c * IntQuantity * (100 +modify ) / 100;
            } else {
                totalPrice = 0;
            }
        }

    }
    public PageReference CreateInvoice() {
        if (attendee.Contact__c != null) {
            newInvoice.Account__c = attendee.Contact__r.AccountID;
        }
        insert newInvoice;
        List < Invoice_Item__c > lstInvoiceItem = new List < Invoice_Item__c > ();
        for (InvoiceRateSheetItem temp: nextListInvoiceItems) {
            if (temp.rsItem.Item__c != null) {
                Invoice_Item__c ii = new Invoice_Item__c(Rate_Sheet_Item__c=temp.rsItem.id,Invoice_Text__c = temp.invoiceText,Invoice__c = newInvoice.id, Item__c = temp.rsItem.Item__c, Modification__c = temp.modification, Price__c = temp.rsItem.Price__c, Quantity__c = temp.intQuantity, Order__c = temp.order, Units_of_Measure__c = temp.unitOfMeasure );
                lstInvoiceItem.add(ii);
            }
        }
        if (lstInvoiceItem.size() > 0) {
            insert lstInvoiceItem;
        }

        /*String urlString = 'https://composer.congamerge.com' +
            '?sessionId=' + UserInfo.getSessionId() +
            '&serverUrl=' + Url.getSalesforceBaseUrl().toExternalForm() + '/services/Soap/u/13.0/' + UserInfo.getOrganizationId() +
            '&id=' + newInvoice.Id;
        */
        
        //PageReference nextPageRef = new PageReference(urlString);
        PageReference nextPageRef = new PageReference('/'+newInvoice.Id);
        nextPageRef.setRedirect(true);
        return nextPageRef;
    }

    public PageReference previous() {
        PageReference nextPageRef = new PageReference('/apex/createInvoice?id=' + attendee.id);
        nextPageRef.setRedirect(true);
        return nextPageRef;
    }

    public PageReference Edit() {
        nextPageMode = false;
        return null;
    }

    /*@RemoteAction
    global static Item__c getItemDetails(String itemId) {
        List<Item__c>lstItems = [select id,Price__c From Item__c WHERE Id=:itemId];
        if(lstItems.size()>0)
            return lstItems[0];
        else
            returnnew Item__c();
        
    }*/
}