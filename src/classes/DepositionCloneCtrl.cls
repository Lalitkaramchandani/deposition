public with sharing  class DepositionCloneCtrl{
        public Map<String,Boolean> fieldChecks{set;get;}
        public Deposition__c obj{set;get;}
        private ApexPages.StandardController controller;
        public list<Deposition__c> depositions{get;set;}
        private Set<String> depositionFields = new Set<String>();
        public integer recCount{get;set;}
        public boolean isMultiple{get;set;}
        public Boolean isSaved{get;set;}
        public integer ismulti{get;set;}
        public DepositionCloneCtrl (ApexPages.StandardController controller) {
            this.controller = controller;
            recCount=1;
            isMultiple=false;
            isSaved = false;
            fieldChecks = new Map<String,Boolean> ();
            Map<String, Schema.SobjectField> fields = 
            Schema.SobjectType.Deposition__c.fields.getMap();
            set<String> notInclude = new set<String>{'Cancelled_Time__c','Google_Drive_Folder_Id__c'};
            set<String> defaultSelectedFields = new set<String>{'Case_Name__c','Deposition_Services__c','File_Uploaded_By_Client__c','Hiring_Firm__c',
                                        'Reporter_EOD_Check_In__c','GuestName__c','Deposition_Status__c','GuestEmail__c','Expedite__c','GuestPhone__c','Due_Date_To_The_Client_Computed__c',
                                         'Hiring_Attorney__c','Insurance_Claim_Info__c','Hiring_Attorney_Email__c','Claims_Professional__c','Matter_Number__c','Time_Zone__c',
                                         'Primary_CR_Firm__c','Estimated_Duration__c',
                                         'Event_Type__c','Location_Contact__c','VIP_Level__c','Source__c','Corporate_Client_Source__c','Primary_Court_Reporting_Firm__c'};
            Set<String>setFieldsNames = new Set<String>{'Case_Name__c','Deposition_Services__c','Special_Instructions__c','File_Uploaded_By_Client__c','Hiring_Firm__c',
                                        'Reporter_EOD_Check_In__c','GuestName__c','Deposition_Status__c','GuestEmail__c','Expedite__c','GuestPhone__c','Due_Date_To_The_Client_Computed__c',
                                         'Hiring_Attorney__c','Insurance_Claim_Info__c','Hiring_Attorney_Email__c','Claims_Professional__c',
                                         'Matter_Number__c','Deposition_Date__c', 'Billing_Notes__c', 'Deposition_Time__c', 'Primary_CR_Firm__c','Time_Zone__c','Estimated_Duration__c',
                                         'Deponent_Name__c', 'Event_Type__c',
                                         
                                         'Event_Location__c','Reporter_Instructions__c','Location_Contact__c','Video_Tech_Instructions__c','VIP_Level__c',
                                         'Interpreter_Instructions__c','Source__c','Corporate_Client_Source__c','Primary_Court_Reporting_Firm__c'
                                         ,'Start_Time__c'};
            
            String fieldCSV ='';
           /*for (String s : fields.keySet()) {
            // Only include accessible fields 
            system.debug('*** s '+s +' field '+fields.get(s));
            system.debug('$$$$$ '+fields.get(s).getDescribe().isCreateable());
            
                if (fields.get(s).getDescribe().isAccessible() && fields.get(s).getDescribe().isUpdateable()&&
                    fields.get(s).getDescribe().isCustom() && !notInclude.contains(String.valueof(fields.get(s)))) {
                        depositionFields.add(fields.get(s).getDescribe().getName());
                        fieldCSV+=(fields.get(s).getDescribe().getName())+',';
                        fieldChecks.put(fields.get(s).getDescribe().getName(),defaultSelectedFields.contains(fields.get(s).getDescribe().getName()));
                }
            }
            */
            for (String fieldName : setFieldsNames ) {
                 fieldCSV+=fieldName+',';
                 depositionFields.add(fieldName);     
                 fieldChecks.put(fieldName,defaultSelectedFields.contains(fieldName));
            }
            Deposition__c rec = (Deposition__c)controller.getRecord();
            obj = database.query('SELECT ' + fieldCSV.removeEnd(',') + ' FROM Deposition__c WHERE ID=\'' +rec.id +'\' LIMIT 1');
            obj.Deposition_Status__c = 'Scheduled';
            obj.Reporter_EOD_Check_In__c= false;
            obj.Due_Date_To_The_Client_Computed__c = null;    
            
            
        }
        
        public  List<String> availableFields {
            get {
                controller.reset(); 
                controller.addFields(new List<String>(depositionFields));
                    return new List<String>(depositionFields);
            }
        }   
        public Pagereference onsave(){
            if(recCount<1){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please enter value'));
                return null;
            }
            list<sObject> sobjList=new list<sObject>();
            try{
                for(integer i=0;i<recCount;i++){
                    sObject sObj = Schema.getGlobalDescribe().get('Deposition__c').newSObject() ;
                    system.debug('**** obj '+obj);
                    for(string key: fieldChecks.keyset()){
                        if(fieldChecks.get(key)){
                            system.debug('****** '+key +' ' + fieldChecks.get(key));
                            system.debug('8888888888 '+ obj.get(key));
                            //sObj.Deposition_Date__c='';
                            
                            
                            sObj.put(key, obj.get(key)) ;
                        }
                    }
                   sobjList.add(sObj);
                   system.debug('***** sObj '+sObj);
               }
               system.debug('**** sobjList '+sobjList);
               
               
               if(sobjList.size()>0){
                   insert sobjList;
               }
               if(sobjList.size()==1){
                   
                   system.debug('*** depositions '+depositions);
                   
                   
                  
                   return new pageReference('/'+sobjList[0].id+'/e?retURL=%2F'+sobjList[0].id);
               }else{
                   isMultiple=true;
                   depositions=new list<Deposition__c>();
                   depositions=[select id, name,Deposition_Date__c, Deponent_Name__c, Event_Location__c
                               from Deposition__c where Id IN: sobjList];
                   return null;
               }
               
               
           }catch(Exception e){
               system.debug('****** Exception '+e);
               ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,e.getMessage()));
               return null;
           }
           
           
            //sobject s=new sobject();
            
        }
        
        public void saveDepositions(){
            try{
                update depositions;
                isSaved = true;
            }catch(Exception e){
               ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,e.getMessage()));
              
           }
        }
    
}