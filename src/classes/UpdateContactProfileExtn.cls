/**
                    Name            :  UpdateContactProfileExtn 
                    Date            :  26/07/2015
                    Descriptiion    : This class is used by UpdateContactProfile VF page that accept contact id as parameters
                                      and updated contact following fields values:
                                        ·         Beverage - Affinity_Beverage__c

                                        ·         College - Affinity_College__c
                                        
                                        ·         Hobby - Affinity_Hobby__c
                                        
                                        ·         Hometown - Affinity_Hometown__c
                                        
                                        ·         Law School - Affinity_Law_School__c
                                        
                                        ·         Movie - Affinity_Movie__c
                                        
                                        ·         Restaurant - Affinity_Restaurant__c
                                        
                                        ·         Sports Team - Affinity_Sports_Team__c
*/
public class UpdateContactProfileExtn {
    public Contact cont{get;set;}
    public Boolean isErr{get;set;}
    public Boolean isSuccess{get;set;}
    public string msg{get;set;}
    public string selectedLawSchoold{get;set;}
    public string affinityBeverage{get;set;}
    public string affinityCollege{get;set;}
    public string affinityHobby{get;set;}
    public string affinityHometown{get;set;}
    public string affinityMovie{get;set;}
    public string affinityRestaurant{get;set;}
    public string affinitySportsTeam{get;set;}
    public UpdateContactProfileExtn(ApexPages.StandardController controller) {
        selectedLawSchoold = affinityBeverage = affinityCollege = affinityHobby ='';
        affinityHometown = affinityMovie= affinityRestaurant=affinitySportsTeam='';
        List<contact>lstContacts = [select id,Name,Affinity_Law_School__c,Affinity_Beverage__c,
                                   Affinity_College__c,Affinity_Hobby__c,Affinity_Hometown__c,
                                   Affinity_Movie__c,  Affinity_Restaurant__c,Affinity_Sports_Team__c   
                                   FROM Contact WHERE Id =: controller.getId()];
        if(lstContacts.size()>0){
            cont=lstContacts[0];
            selectedLawSchoold = cont.Affinity_Law_School__c;
            affinityBeverage = cont.Affinity_Beverage__c;
            affinityCollege = cont.Affinity_College__c;
            affinityHobby = cont.Affinity_Hobby__c;
            affinityHometown = cont.Affinity_Hometown__c;
            affinityMovie= cont.Affinity_Movie__c;
            affinityRestaurant= cont.Affinity_Restaurant__c;
            affinitySportsTeam= cont.Affinity_Sports_Team__c;
        }else
            cont = new Contact(); 
        msg = '';
        isErr = isSuccess = false;
        
    }
    
    public List<SelectOption> getLawSchools(){
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Contact.Affinity_Law_School__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        options.add(new SelectOption('-None-','-None-'));
        for(Schema.PicklistEntry f : ple){
           options.add(new SelectOption(f.getLabel(), f.getLabel()));
        }       
        return options;
    }
    public void saveContact(){
        isErr = isSuccess = false;
        try{
            cont.Affinity_Law_School__c= selectedLawSchoold;
            cont.Affinity_Beverage__c = affinityBeverage  ;
            cont.Affinity_College__c = affinityCollege ;
            cont.Affinity_Hobby__c = affinityHobby ;
            cont.Affinity_Hometown__c = affinityHometown ;
            cont.Affinity_Movie__c = affinityMovie;
            cont.Affinity_Restaurant__c = affinityRestaurant;
            cont.Affinity_Sports_Team__c = affinitySportsTeam;
            update cont; 
            isSuccess = true;
            msg = '<Strong>Success!</strong> Your contact profile successfully updated. ';
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Your profile successfully updated. '));  
        }catch(Exception e){
            isErr = true;
            msg = '<Strong>Error! </strong>'+ e.getMessage();
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Fatal,e.getMessage()));
        }
    }
}