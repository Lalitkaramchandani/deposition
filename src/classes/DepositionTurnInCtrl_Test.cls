@isTest
private class DepositionTurnInCtrl_Test {
    static void setupFiles(Deposition__c dep){
        GrantingFileAccessToUsersExtn cntrl = new GrantingFileAccessToUsersExtn(new ApexPages.StandardController(dep));
        cntrl.init();
        cntrl = new GrantingFileAccessToUsersExtn(new ApexPages.StandardController(dep));
        cntrl.callInitFullTextSearch();
        if( cntrl.lstFiles == NULL){
            cntrl.lstFiles = new List<S3FileModel >();
            cntrl.lstFiles.add(new S3FileModel(new AWS_S3_Object__c(File_Name__c='test',File_Id__c='test'),false));
            cntrl.lstFiles.add(new S3FileModel(new AWS_S3_Object__c(File_Name__c='test2',File_Id__c='test2'),false));
        }
        for(S3FileModel s3File : cntrl.lstFiles){
            s3File.isSelected= true;
        }
        cntrl.saveFiles();  
    }
    @isTest
	private static void tunrinprocess() {
        TestFactory tFact = new TestFactory();
        List<Deposition__c> depositions = tFact.depositions;
        List<Attendee__c> attendees = tFact.attendees;
        Deposition__c dep = depositions[0];
        DateTime now = System.now();
        DateTime nowNextHour = System.now().addHours(1);
        Time nowt = Time.newInstance(now.hour(), now.minute(),0,0);
        Time nowNextt = Time.newInstance(nowNextHour.hour(), nowNextHour.minute(),0,0);
        
        dep.Start_Time__c = now;
        dep.Stop_Time__c = nowNextHour;
        // dep.Starts_Time__c=nowt;
        // dep.Ends_Time__c=nowNextt;
        update dep;
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            setupFiles(dep);
            
            Test.setCurrentPageReference(Page.DepositionTurnIn);
            Apexpages.currentPage().getParameters().put('id', depositions[0].Id);
            
            System.runAs(tFact.communtiyUser){
                DepositionTurnInCtrl control = new DepositionTurnInCtrl();
                control.getDepositionExpedite();
                control.postInit();
                System.debug('>'+control.pageNo);
                System.assert(control.curUserAttendee != null);
                System.debug('code '+control.getAccessCode());
                System.debug('getAccessToken '+DepositionTurnInCtrl.getAccessToken());
                System.debug('fileinfo '+DepositionTurnInCtrl.getFileInfo('test',''));
                
                control.loaduploaded();
                
                // turnin 1 screen
                control.curUserAttendee.Recap_Notes__c = 'recap';
                control.curUserAttendee.Shipping_Notes__c = 'shipping';
                control.NoTranscript = true; // making as No Transcript
                
                control.nextStep();
                
                // turnin 2 screen
                if(control.curUserRole == 'Court Reporter'){
                    // control.depositionRec. = ''
                    control.depositionRec.Transcript_page_count__c = '10';
                    control.depositionRec.Exhibit_Page_Count__c ='10';
                    control.depositionRec.Errata_Needed__c = false;
                    control.depositionRec.Errata_Notes__c = 'notes';
                    // control.depositionRec.start_ = 'notes';
                    
                }else if(control.curUserRole == 'Videographer/Technician'){
                    
                }
                System.debug('>'+control.pageNo);
            }
        Test.stopTest();
	}
    
    @isTest 
	private static void tunrinprocessGuest() {
        TestFactory tFact = new TestFactory();
        List<Deposition__c> depositions = tFact.depositions;
        List<Attendee__c> attendees = tFact.attendees;
        List<Rate_Sheet_Item__c> rtItems = tFact.rtItems;
        String attendeeId='';
        for(Attendee__c att: attendees){
            if(att.Deposition__c ==depositions[0].Id && att.Role__c=='Court Reporter'){
                attendeeId=att.Id;
                break;
            }
        }
        Deposition__c dep = depositions[0];
        DateTime now = System.now();
        DateTime nowNextHour = System.now().addHours(1);
        Time nowt = Time.newInstance(now.hour(), now.minute(),0,0);
        Time nowNextt = Time.newInstance(nowNextHour.hour(), nowNextHour.minute(),0,0);
        
        // dep.Start_Time__c = now;
        // dep.Stop_Time__c = nowNextHour;
        dep.Starts_Time__c=nowt;
        dep.Ends_Time__c=nowNextt;
        update dep;
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            
        Test.setCurrentPageReference(Page.DepositionTurnIn);
        Apexpages.currentPage().getParameters().put('id', depositions[0].Id);
        Apexpages.currentPage().getParameters().put('attendeeid', attendeeId);
        
        ApexPages.StandardController scontrol = new ApexPages.StandardController(depositions[0]);
        DepositionTurnInCtrl control = new DepositionTurnInCtrl(scontrol);
        control.postInit();
        String expeditedValidationError = control.expeditedValidationError;
        System.assert(control.curUserAttendee != null);
        
        // turnin 1 screen
        control.curUserAttendee.Recap_Notes__c = 'recap';
        control.curUserAttendee.Shipping_Notes__c = 'shipping';
        control.NoTranscript = true; // making as No Transcript
        control.depositionRec.Expedite__c='custom';
        control.depositionRec.Portal_Deposition_Services__c = 'Traditional Video; Realtime; Rough Draft; Interpreter; Synchronized Video';
        control.nextStep();
        control.calculateVideoHour();
        control.calculateVideoHourWithTime();
        List<SelectOption> accounts = control.accounts;
        // turnin 2 screen
        // System.debug('---------->'+control.curUserRole);
        if(control.curUserRole == 'Court Reporter'){
        // System.debug('---------->'+control.curUserRole);
            // control.depositionRec. = ''
            control.depositionRec.Transcript_page_count__c = '10';
            control.depositionRec.Exhibit_Page_Count__c ='10';
            control.depositionRec.Errata_Needed__c = false;
            control.depositionRec.Errata_Notes__c = 'notes';
            // control.depositionRec.start_ = 'notes';
            control.nextStep();
            control.NoTranscript = false; // making as No Transcript
            // turnin 3 screen
            control.nextStep();
            
            control.removeIndex = control.attendeeWrapperList.size()-1;
            control.removeAttendeesRow();
            control.onSearchEnable();
            control.onCancelSearch();
            control.onCancelNewAttendee();
            control.onSearchEnable();
            control.conInput.email = 'test@tests.com';
            control.onSearch();
            control.conInput.firstName = 'lName';
            control.conInput.lastName = 'fName';
            // System.debug('---------->'+control.addNewAttendee);
            control.onNewAttendee();
            control.removeIndex = control.attendeeWrapperList.size()-1;
            control.setFirmName();
            control.onSearchEnable();
            control.conInput.email = 'test5@test.com';
            control.onSearch();
            
            // System.debug('---------->'+control.addNewAttendee);
            control.onSaveSearch();
            control.addAttendeesRow();
            control.removeIndex = control.attendeeWrapperList.size()-1;
            control.removeAttendeesRow();
            // System.debug('===============>'+control.attendeeWrapperList.size());
            control.attendeeWrapperList[0].atten.Primary_Attorney__c = true;
            // turnin 4 screen
            control.nextStep();
            checkAllBoolean(control);
            control.onQuantityChange();
            control.onAddAdditional();
            control.previousStep();
            control.previousStep();
            control.previousStep();
            
        }
        
        Test.stopTest();
	}
    
    @isTest
	private static void tunrinProcessNewAttendee() {
        TestFactory tFact = new TestFactory();
        List<Deposition__c> depositions = tFact.depositions;
        List<Attendee__c> attendees = tFact.attendees;
        List<Rate_Sheet_Item__c> rtItems = tFact.rtItems;
        
        String attendeeId='';
        for(Attendee__c att: attendees){
            if(att.Deposition__c ==depositions[0].Id && att.Role__c=='Videographer/Technician'){
                attendeeId=att.Id;
                break;
            }
        }
        Test.startTest();
        Test.setCurrentPageReference(Page.DepositionTurnIn);
        Apexpages.currentPage().getParameters().put('id', depositions[0].Id);
        Apexpages.currentPage().getParameters().put('attendeeid', attendeeId);
        
        Deposition__c dep = depositions[0];
        DateTime now = System.now();
        DateTime nowNextHour = System.now().addHours(1);
        Time nowt = Time.newInstance(now.hour(), now.minute(),0,0);
        Time nowNextt = Time.newInstance(nowNextHour.hour(), nowNextHour.minute(),0,0);
        
        // dep.Start_Time__c = now;
        // dep.Stop_Time__c = nowNextHour;
        dep.Starts_Time__c=nowt;
        dep.Ends_Time__c=nowNextt;
        update dep;
        ApexPages.StandardController scontrol = new ApexPages.StandardController(depositions[0]);
        DepositionTurnInCtrl control = new DepositionTurnInCtrl(scontrol);
        control.postInit();
        String expeditedValidationError = control.expeditedValidationError;
        System.assert(control.curUserAttendee != null);
        
        // turnin 1 screen
        control.curUserAttendee.Recap_Notes__c = 'recap';
        control.curUserAttendee.Shipping_Notes__c = 'shipping';
        control.NoTranscript = true; // making as No Transcript
        control.depositionRec.Expedite__c='4 day turnaround';
        control.depositionRec.Portal_Deposition_Services__c = 'Traditional Video; Realtime; Rough Draft; Interpreter; Synchronized Video';
        control.nextStep();
        Test.stopTest();
        
	}

    @isTest
	private static void testOther() {
        TestFactory tFact = new TestFactory();
        List<Deposition__c> depositions = tFact.depositions;
        List<Attendee__c> attendees = tFact.attendees;
        List<Rate_Sheet_Item__c> rtItems = tFact.rtItems;
        
        Firm__c dp= DepositionHelper.fetchFirm(tFact.firmMap.get(tFact.defaultFirm).Name);
        FileDetailCtrl control = new FileDetailCtrl(new ApexPages.StandardController(depositions[0]));
    }
	static void checkAllBoolean(DepositionTurnInCtrl control){
	    Boolean check = control.isrtItemsWithType;
	    check = control.isrtItemsPrimary;
	    check = control.isrtItemsOther;
	    check = control.isrtItemsReal;
	    check = control.isrtItemsTrad;
	    check = control.isrtItemsTrans;
	    check = control.showExpeditePrimary;
	    check = control.showExpediteCopy;
	}
}