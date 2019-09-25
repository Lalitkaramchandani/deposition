/*************************************************************************
 *Computes date according to business days calculation
 ***************************************************************************/
trigger businessDaysCalculation on Deposition__c(before insert, before update) {

    private Map < String, Integer > mpExpedite = new Map < String, Integer > {
        'Same day turnaround' => 0,
        'Next day turnaround' => 1,
        '2 day turnaround' => 2,
        '3 day turnaround' => 3,
        '4 day turnaround' => 4,
        '5 day turnaround' => 5,
        '6 day turnaround' => 6,
        '7 day turnaround' => 7,
        '8 day turnaround' => 8,
        '9 day turnaround' => 9
    };
    /*********************Added for filling Case Description into Deposition********/
    Set < Id > caseIds = new Set < Id > ();
    for (Deposition__c dep: trigger.new) {
        caseIds.add(dep.Deposition_Group__c);
    }
    System.debug('=========caseIds===' + caseIds);
    Map < Id, Case__c > idCaseMap = new Map < Id, Case__c > ([Select Description__c, Billing_Notes__c from Case__c where id in : caseIds]);
    System.debug('=========idCaseMap===' + idCaseMap);
    for (Deposition__c dep: trigger.new) {
        if (dep.Deposition_Group__c != null) {
            if (idCaseMap.get(dep.Deposition_Group__c) != null)
                dep.description__c = idCaseMap.get(dep.Deposition_Group__c).description__c;
            dep.Case_Billing_Notes__c = idCaseMap.get(dep.Deposition_Group__c).Billing_Notes__c;
        }
    }
    /*******************************************************************************/

    if (Trigger.isUpdate && Trigger.isBefore) {
        try {
            DepositionManager depManager = new DepositionManager();
            depManager.setChangeLog(Trigger.New);
        } catch (Exception ex) { //Catch any catchable exception
            System.debug('***********EXCEPTION OCCURRED************' + ex);
            DepositionManager.sendEmail(ex);
        }
    }

    BusinessHours bh = [SELECT Id FROM BusinessHours WHERE IsDefault = true];
    for (Deposition__c deposition: Trigger.New) {
        if (!isChanged(deposition) ) continue;
        
        if(deposition.Expedite__c != 'Custom' ){
            System.debug('******');
            if(deposition.Due_Date_To_The_Client_Computed__c == NULL || 
            (Trigger.isUpdate && (deposition.Expedite__c!= trigger.oldmap.get(deposition.id).Expedite__c
             ||  deposition.VIP_Level__c!= trigger.oldmap.get(deposition.id).VIP_Level__c || 
                 deposition.Deposition_Date__c!= trigger.oldmap.get(deposition.id).Deposition_Date__c
             ) ))
                deposition.Due_Date_To_The_Client_Computed__c = computeDueDateToClient(deposition);
            System.debug('***Due Date***' + deposition.Due_Date_To_The_Client_Computed__c);
    
            /*if (deposition.VIP_Level__c == NULL && (deposition.Expedite__c == '6 day turnaround' || deposition.Expedite__c == '7 day turnaround' || deposition.Expedite__c == '8 day turnaround' || deposition.Expedite__c == '9 day turnaround' || deposition.Expedite__c == 'None' || deposition.Expedite__c == null)) {
                deposition.Transcript_Due_From_Reporter_Computed__c = getBusinessDate(deposition.Due_Date_To_The_Client_Computed__c, -2);
            } else {
                deposition.Transcript_Due_From_Reporter_Computed__c = deposition.Due_Date_To_The_Client_Computed__c;
            }*/
            deposition.Transcript_Due_From_Reporter_Computed__c = deposition.Due_Date_To_The_Client_Computed__c;
        }
        System.debug('***Transcript_Due_From_Reporter_Computed__c***' + deposition.Transcript_Due_From_Reporter_Computed__c);
        //deposition.
    }

    private Date computeDueDateToClient(Deposition__c deposition) {
        Date dt = deposition.Deposition_Date__c;
        Integer days = mpExpedite.get(deposition.Expedite__c);
        /**
             If the job is not expedited (i.e. Expedite Level = None) and 
             VIP Level – VIP1 or VIP2, then the standard turnaround time should be
              eight business days instead of usual ten.
        */
        if ((deposition.Expedite__c == NULL || deposition.Expedite__c == 'None') && (deposition.VIP_Level__c == 'VIP 1' || deposition.VIP_Level__c == 'VIP 2'))
            days = 8; // Default Business days,
        else if (days == null) {
            days = 10; // Default Business days,
        }
        if (days == 0) return dt;
        return getBusinessDate(dt, days);
        /*}
        if(deposition.Turnaround__c != null) {
          return getBusinessDate(dt,Integer.valueOf(deposition.Turnaround__c));
        }
        //return dt;*/
    }

    private Date getBusinessDateBackwards(Date inputDate, Integer days) {
        DateTime input = DateTime.newInstanceGMT(inputDate.Year(), inputDate.Month(), inputDate.Day(), 0, 0, 0);
        DateTime backDate = input.addDays(days * -1);
        System.debug('**************backDate**********' + backDate);
        System.debug('************inputDate**********' + input);
        Long hours = days * 24 * 60L * 60L * 1000L;
        System.debug('***********hours**********' + hours);
        Long diffHours = BusinessHours.diff(bh.id, backDate, inputDate);
        while (diffHours < hours) {
            backDate = backDate.addDays(-1);
            diffHours = BusinessHours.diff(bh.id, backDate, inputDate);
            System.debug('***********Diff Hours**********' + diffHours);
            System.debug('***********back Date**********' + backDate);
        }
        return backDate.dateGMT();

    }


    private Date getBusinessDate(Date inputDate, Integer days) {
        if (inputDate == null) {
            return null;
        }

        if (days < 0) {
            return getBusinessDateBackwards(inputDate, days * -1);
        }

        DateTime input = DateTime.newInstanceGMT(inputDate.Year(), inputDate.Month(), inputDate.Day(), 0, 0, 1);
        System.debug('*******Input*****' + input);
        Integer expand = days > 0 ? 1 : -1;
        Long hours = (days * 24) + expand;
        System.debug('********************Hours************' + hours);
        System.debug('************' + hours * 60L * 60L * 1000L);
        DateTime dtComputedTime = BusinessHours.addGMT(bh.id,
            input,
            hours * 60L * 60L * 1000L);
        System.debug('*********dtComputedTime****' + dtComputedTime);
        System.debug('***********DATEGMT*****' + dtComputedTime.dateGMT());
        return dtComputedTime.dateGMT();
    }

    private Boolean isChanged(Deposition__c deposition) {
        if(Trigger.isInsert || (Trigger.isUpdate &&
         (deposition.Expedite__c != trigger.oldmap.get(deposition.id).Expedite__c  || 
          deposition.VIP_Level__c != trigger.oldmap.get(deposition.id).VIP_Level__c ||
          deposition.Deposition_Date__c!= trigger.oldmap.get(deposition.id).Deposition_Date__c
         )))
            return true;
        return false;
    }

}