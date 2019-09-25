@isTest
public class ContactAccountMatchCalloutMock implements HttpCalloutMock {

    protected Integer code;
    protected String status;
    protected String body;
 
     public HTTPResponse respond(HTTPRequest req) {

        HttpResponse res = new HttpResponse();
        res.setBody(this.body);
        res.setStatusCode(this.code);
        res.setStatus(this.status);
        res.setHeader('Content-Type', 'application/csv');
        return res;
    }

    public ContactAccountMatchCalloutMock(Integer code, String status) {
        this.code = code;
        this.status = status;
        this.body = '"Industry","First Name","Last Name","Account Name","Account ID","Encrypted Case ID","Filing Date","Court Attorney Name","Court Law Firm","UniCourt Normalized Attorney Name","BAR Attorney Name","BAR Law Firm","BAR State","BAR Number"'+'\n'+'"Law Firm","Richard","Abbott","Abbott Law Firm LLC","001A0000014V0dR","F5FB4IRJDI4UAJMNHROUFDLKMFJBC0925","2019-03-06","Richard L Abbott","Abbott Law Firm, LLC","","","","",""'+'\n'+'"Law Firm","Richard","Shenkan","Shenkan Injury Lawyers","001A0000014q5c9","FVEBYIBHDAKTCF3UHU3GUJLLNJLBA0770","2019-03-05","Richard E. Shenkan Esq.","Shenkan Injury Lawyers LLC","","","","",""'+'\n'+'"Law Firm","Blaine","Holbrook","Evans, Rowe & Holbrook-San Antonio","001A000001SVpto","GFGCAJBLDQ5UEJ4PHZPUJDTOM5MRI0936","2019-02-28","Matthew Miles Edwards","Evans, Rowe & Holbrook, P.C.","","","","",""'+'\n'+'"Law Firm","Neil","Shevlin","New York Office of the Attorney General","001A000001IiNk7","GNHCEJRNDY6UIKMRIBQUNELPOFORO0947","2019-03-06","Matthew Colangelo","NEW YORK STATE OFFICE OF THE ATTORNEY GENERAL","","","","",""'+'\n'+'"Law Firm","Neil","Shevlin","New York Office of the Attorney General","001A000001IiNk7","GNHCEJRNDYNTOHL2IM6HAK3QNNOBS0767","2019-03-06","Barbara D. Underwood","New York State Office of the Attorney General","","","","",""'+'\n'+'"Law Firm","Neil","Shevlin","New York Office of the Attorney General","001A000001IiNk7","GJGSCJJMDUNDMHDZII5W6KTPNJOBM0766","2019-03-06","Barbara D. Underwood","New York State Office of the Attorney General","","","","",""'+'\n'+'"Law Firm","Neil","Shevlin","New York Office of the Attorney General","001A000001IiNk7","GRHSGJZOD4ODQHT3IQ6XCLDRNRPBU0768","2019-03-06","Barbara D. Underwood","New York State Office of the Attorney General","","","","",""'+'\n'+'"Law Firm","Neil","Shevlin","New York Office of the Attorney General","001A000001IiNk7","GVICIKBPEAOTSH34IU7HELLSONNRU0769","2019-03-06","David Lawrence III","New York State Office of the Attorney General","","","","",""'+'\n'+'"Law Firm","Neil","Shevlin","New York Office of the Attorney General","001A000001IiNk7","GBFR6IZKDMMDIGTXIA4W2KDNNZLBS0773","2019-03-06","Barbara D. Underwood","New York State Office of the Attorney General","","","","",""'+'\n';
    }

}