/**************************************************
                Name        : FirmInfoCntrl
                Author      : Rajendra Rathore
                Purpose     : That class are used for getting firm information.
                Created Date: 09 JUNE 2016
                
                Modification History:
*****************************************************/
public class FirmInfoCntrl{
    public FirmInfoCntrl(){   
    }
    public Firm__c getFirm(){
        Firm__c firm = new Firm__c();
        String firmName = '';
        Cookie firmCookie = ApexPages.currentPage().getCookies().get('firmCookie');
        
        firmName = 'NextGen Reporting';
        if(firmCookie != null && firmCookie.getValue()!= null){
            firmName = firmCookie.getValue(); 
            
        }
       
        List<Firm__c>lstFirms = [select Id,Name,Phone__c,Community_Header__c,Community_Footer__c,Scheduling_Email_Address__c,Production_Email_Address__c
                                   From Firm__c WHERE Name =:firmName];
        if(lstFirms.size()>0){
            firm = lstFirms[0];
        }
        
        return firm;
    }
    
}