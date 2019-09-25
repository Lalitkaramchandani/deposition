@isTest
public class TestDepositionClone {

    public static void descObj() {
            
            List<Deposition__c> depositions = new List<Deposition__c>{};
            
            
            String companyString;

            Deposition__c testDeposition = new Deposition__c(Case_Name__c ='Test1');
            depositions.add(testDeposition);
            insert depositions;
            
            companyString = depositions[0].id;
            
        
             ApexPages.StandardController sc = new ApexPages.StandardController(depositions[0]);
             DepositionCloneCtrl testdeposi = new DepositionCloneCtrl(sc);
             testdeposi.onsave();
             testdeposi.recCount=0;
             testdeposi.onsave();
             testdeposi.recCount=2;
             testdeposi.onsave();
        
        
        }
        
        static testmethod void testDepositionsClone(){
            descObj();
        }
    
    
    

}