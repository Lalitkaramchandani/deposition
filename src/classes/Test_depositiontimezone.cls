@isTest
private class Test_depositiontimezone{
    
    static testMethod void myUnitTest3() {
        Deposition__c d=new Deposition__c(Deposition_Date__c=system.today(),Time_Zone__c='Central',Deposition_Time__c='11:42 AM',Vidyo_Room__c='1');
        insert d;
    }
    static testMethod void myUnitTest8() {
        Deposition__c d=new Deposition__c(Deposition_Date__c=system.today(),Time_Zone__c='Central',Deposition_Time__c='11 AM.',Vidyo_Room__c='2');
        insert d;
    }
    static testMethod void myUnitTest9() {
        Deposition__c d=new Deposition__c(Deposition_Date__c=system.today(),Time_Zone__c='Central',Deposition_Time__c='11 P.M.',Vidyo_Room__c='3');
        insert d;
    }
    static testMethod void myUnitTest10() {
        Deposition__c d=new Deposition__c(Deposition_Date__c=system.today(),Time_Zone__c='Central',Deposition_Time__c='11 PM.',Vidyo_Room__c='4');
        insert d;
    }
    static testMethod void myUnitTest11() {
        Deposition__c d=new Deposition__c(Deposition_Date__c=system.today(),Time_Zone__c='Central',Deposition_Time__c='11:44',Vidyo_Room__c='5');
        insert d;
    }
    static testMethod void myUnitTest4() {
        Deposition__c d=new Deposition__c(Deposition_Date__c=system.today(),Time_Zone__c='Central',Deposition_Time__c='11:42 A.M.',Vidyo_Room__c='6');
        insert d;
    }
    static testMethod void myUnitTest5() {
        Deposition__c d=new Deposition__c(Deposition_Date__c=system.today(),Time_Zone__c='Central',Deposition_Time__c='11:42 A.M',Vidyo_Room__c='7');
        insert d;
    }
    static testMethod void myUnitTest7() {
        Deposition__c d=new Deposition__c(Deposition_Date__c=system.today(),Time_Zone__c='Central',Deposition_Time__c='9',Vidyo_Room__c='8');
        insert d;
    }
    static testMethod void myUnitTest6() {
        Deposition__c d=new Deposition__c(Deposition_Date__c=system.today(),Time_Zone__c='Central',Deposition_Time__c='21:42 P.M',Vidyo_Room__c='9');
        insert d;
        Deposition__c d1=new Deposition__c(Deposition_Date__c=system.today(),Time_Zone__c='Central',Deposition_Time__c='11:42 PM.',Vidyo_Room__c='10');
        insert d1;
    }
    static testMethod void myUnitTest() {
    Deposition__c d=new Deposition__c(Deposition_Date__c=system.today(),Time_Zone__c='Central',Deposition_Time__c='11:42 PM',Vidyo_Room__c='11');
    insert d;
   
   
    }
    static testMethod void myUnitTest1() {
    Deposition__c d=new Deposition__c(Deposition_Date__c=system.today(),Time_Zone__c='Pecific',Deposition_Time__c='12:42',Vidyo_Room__c='17');
    insert d;
    Deposition__c d1=new Deposition__c(Deposition_Date__c=system.today(),Time_Zone__c='Central',Deposition_Time__c='11 AM',Vidyo_Room__c='18');
    insert d1;
    Deposition__c d11=new Deposition__c(Deposition_Date__c=system.today(),Time_Zone__c='Central',Deposition_Time__c='5:42',Vidyo_Room__c='19');
    insert d11;
    d.Deposition_Time__c='03:40 PM';
    d.Time_Zone__c='Eastern';
    update d;
    d.Deposition_Time__c='03:40 a.M';
    d.Time_Zone__c='Mountain';
    update d;
    d.Deposition_Time__c='03:40 p.M';
    d.Time_Zone__c='Mountain';
    update d;
    }
    static testMethod void myUnitTest2() {
    Deposition__c d=new Deposition__c(Deposition_Date__c=system.today(),Time_Zone__c='Pecific',Deposition_Time__c='12:42',Vidyo_Room__c='20');
    insert d;
    Deposition__c d1=new Deposition__c(Deposition_Date__c=system.today(),Time_Zone__c='Central',Deposition_Time__c='11',Vidyo_Room__c='21');
    insert d1;
    Deposition__c d11=new Deposition__c(Deposition_Date__c=system.today(),Time_Zone__c='Central',Deposition_Time__c='5:42',Vidyo_Room__c='22');
    insert d11;
    d.Deposition_Time__c='9:40 A.M.';
    d.Deposition_Date__c=system.today();
    d.Time_Zone__c='Eastern';
    update d;
    d.Deposition_Time__c='9';
    d.Deposition_Date__c=system.today();
    d.Time_Zone__c='Eastern';
    update d;
    d.Deposition_Time__c='9 AM';
    d.Deposition_Date__c=system.today();
    d.Time_Zone__c='Eastern';
    update d;
    }
    }