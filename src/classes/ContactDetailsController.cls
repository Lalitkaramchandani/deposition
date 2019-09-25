/**

    Name            :    ContactDetailsController
    Date            :    29 May 2019
    Descriptipon    :    Controller to update Contact details
    Developer       :    lalit karamchandani | email:- lalitkaramchandani27@gmail.com | skype :- lalit.karamchandani93
*/
public without sharing class ContactDetailsController{
    
    public Firm__c firm{get;set;}
    public contact conRec{get;set;}
    public boolean isError{get;set;}
    public boolean isUpdate{get;set;}
    
    public string msg{get;set;}
    public string conId;
    public string conEmail;
    public string isupdated;
    public ContactWrapper conWrap{get;set;}
        
    
    public class ContactWrapper{
        public integer index{get;set;}
        public contact con;
        public string affCollege{get;set;}
        public string affLawScholl{get;set;}
        public string affHomeTown{get;set;}
        public string affSportTeam{get;set;}
        public string affBeverage{get;set;}
        public string affRestaurant{get;set;}
        public string affHobby{get;set;}
        public string affMovie{get;set;}
        
        public ContactWrapper(integer index,contact con){
            this.index=index;
            affCollege=con.Affinity_College__c;
            affLawScholl=con.Affinity_Law_School__c;
            affHomeTown=con.Affinity_Hometown__c;
            affSportTeam=con.Affinity_Sports_Team__c;
            affBeverage=con.Affinity_Beverage__c;
            affRestaurant=con.Affinity_Restaurant__c;
            affHobby=con.Affinity_Hobby__c;
            affMovie=con.Affinity_Movie__c;
        }
    }
    public Firm__c fetchFirm(String firmName){
        if(firmName == NULL || firmName=='' || firmName=='null')
            firmName  = 'NextGen Reporting';
        system.debug('$$'+firmName);
        List<Firm__c>lstFirms = [select id,Name,Web_Page_Footer_HTML__c,Web_Page_Header_HTML__c,Email_Footer_HTML__c,Email_Header_HTML__c,URL__c,
                                 Scheduling_email_address__c,Community_Admin_Email__c,Google_Drive_Folder_Name__c,
                                 Community_Header__c,Community_Footer__c,Phone__c
                                 From Firm__c WHERE Name like: firmName+'%'];
        if(lstFirms.size()>0)
            return lstFirms[0];
        else 
            return new Firm__c();
    }
    public ContactDetailsController(){
        firm = fetchFirm( 'Lexitas');
        isError=false;
        isUpdate=false;
        conId = ApexPages.currentPage().getParameters().get('id');
        conEmail = ApexPages.currentPage().getParameters().get('email');
        isupdated = ApexPages.currentPage().getParameters().get('updated');
        system.debug('*** conId '+conId);
        system.debug('*** conEmail '+conEmail);
        
        if(isupdated=='1'){
            msg='Thank you for this updated information. We appreciate the opportunity to work with you.';
            isUpdate=true;
        }else{
            if(string.isNotBlank(conId) && string.isNotBlank(conEmail)){
                conRec=getByIdContact(conId,conEmail);
                if(conRec==null){
                    isError=true;
                }else{
                    integer index=1;
                    conWrap=new ContactWrapper(index,conRec);
                }
            }else{
                isError=true;
            }  
            if(isError==true){
                msg='Contact not found.';
            }  
        }
           
 
        
    }
    public PageReference save(){
        try{
            
            contact con=new contact(id=conId);
            if(conWrap!=null && isError==false){
               
                con.Affinity_College__c=conWrap.affCollege;
                con.Affinity_Law_School__c=conWrap.affLawScholl;
                con.Affinity_Hometown__c=conWrap.affHomeTown;
                con.Affinity_Sports_Team__c=conWrap.affSportTeam;
                con.Affinity_Beverage__c=conWrap.affBeverage;
                con.Affinity_Restaurant__c=conWrap.affRestaurant;
                con.Affinity_Hobby__c=conWrap.affHobby;
                con.Affinity_Movie__c=conWrap.affMovie;
                update con;
                string redirectURL='/apex/affinity?&updated=1';
                system.debug('** redirectURL '+redirectURL);
                PageReference pageRef = new PageReference(redirectURL);
                pageRef.setRedirect(true);
                return pageRef;
           }
            
           return null; 
            
        }catch(Exception e){
            system.debug('$$$$$$ Exception' +e.getStackTraceString());
            system.debug('$$$$$$ Exception  ' +e.getlinenumber());
            system.debug('$$$$$$ Exception' +e);
            return null;
        }
    }
    public contact getByIdContact(string conid,string conemail){
        list<contact> cons=[SELECT Id, Name, LastName, Affinity_Movie__c,Affinity_Hobby__c,Affinity_Sports_Team__c,
                            Affinity_Hometown__c,Affinity_Law_School__c, Affinity_Restaurant__c, Affinity_Beverage__c ,Affinity_College__c,FirstName, 
                            Email FROM Contact where id=:conid and email=:conemail];
        if(cons!=null && cons.size()>0){
            return cons[0];
        }
        return null;
    }
    
}