public class LeadGenCasesParser{
    
    
    
    public cls_search_metadata search_metadata;
    public cls_results[] results;
    public class cls_1 {
        public cls_search_terms[] search_terms;
        public String attribute;    //docket
        public String proximity;    //5
        public String operator; //is
        public String scope;    //match_any
    }
    public class cls_search_metadata {
        public String search_id;    //1116
        public String search_run_id;    //f6ece591-7045-4262-9571-2afb8e4647e0
        public String hidden_count; //0
        public String total_results;    //4
        public cls_filters[] filters;
        public cls_queries queries;
    }
    public class cls_filters {
        public String field;    //jurisdiction
        public cls_options[] options;
    }
    public class cls_options {
        
    }
    public class cls_queries {
        public cls_terms terms;
        public String criteria; //(1)
    }
    public class cls_terms {
        
    }
    public class cls_search_terms {
        
    }
    public class cls_results {
        public cls_case caseObj;
        public cls_judges[] judges;
        public cls_attorneys[] attorneys;
        public cls_parties[] parties;
        public String search_run_result_id; //f6ece591-7045-4262-9571-2afb8e4647e0.PC.DB1.719421
    }
    
   
    public class cls_data {
        public cls_case caseobj;
        public cls_judges[] judges;
        public cls_attorneys[] attorneys;
        public cls_parties[] parties;
    }
    public class cls_case {
        public String case_type;    //Other
        public String case_type_category;   //Civil
        public String courthouse;   //Arcadia Biltmore Justice Courthouse
        public String case_status_category; //Disposed
        public String jurisdiction; //Maricopa County Justice Courts
        public String state;    //AZ
        public String last_updated_date;    //2016-08-24
        public String case_name;    //Galt Venture Inc Vs Keri Hawkins
        public String county;   //Maricopa
        public String filing_date;  //2009-05-18
        public String case_status;  //Other Disposed
        public String case_id;  //EQ7RGFZLGMVUGEDYMEWGC5K7MFEQW1022
        public String case_type_subcategory;    //Other
        public String case_number;  //CC2009-299678
    }
    public class cls_judges {
        public cls_suffix suffix;
        public String firstname;    //Dean
        public cls_middlename middlename;
        public String lastname; //Wolcott
        public cls_prefix prefix;
        public String fullname; //Wolcott, Dean
        public String judge_id; //EQ7RGFZLGMVUGEDYMEWGC5K7MFEQW1022
    }
    public class cls_suffix {
    }
    public class cls_middlename {
    }
    public class cls_prefix {
    }
    public class cls_attorneys {
        public String firm;
        public cls_bar_number bar_number;
        public cls_suffix suffix;
        public String firstname;    //Milton
        public String attorney_id;  //EQ7RGFZLGMVUGEDYMEWGC73DKVHA21031
        public cls_middlename middlename;
        public String lastname; //Mecham
        public cls_entities[] entities;
        public cls_prefix prefix;
        public String fullname; //Milton Mecham
    }
    public class cls_firm {
    }
   public  class cls_bar_number {
    }
    public class cls_entities {
    }
    public class cls_parties {
        public cls_party_types[] party_types;
        public cls_suffix suffix;
        public String firstname;    //Keri
        public String entity_type;  //Individual
        public cls_middlename middlename;
        public String lastname; //Hawkins
        public cls_entities[] entities;
        public cls_prefix prefix;
        public String party_id; //EM7BEFRKGIVEED3XMAVV27TBLJCQQ1021
        public String fullname; //Keri Hawkins
    }
    public class cls_party_types {
        public boolean active;
        public String party_type;   //Defendant
        public cls_attorney_association[] attorney_association;
        public String representation_type;  //Self Represented
    }
    public class cls_attorney_association {
    }
    public static LeadGenCasesParser parse(String json){
        return (LeadGenCasesParser) System.JSON.deserialize(json, LeadGenCasesParser.class);
    }
    @istest
    static  void testParse() {
        String json=        ''+
        //'{"status": "SUCCESS", "data": {"case": {"case_type": "Other", "case_type_category": "Civil", "courthouse": "Arcadia Biltmore Justice Courthouse", "case_status_category": "Disposed", "jurisdiction": "Maricopa County Justice Courts", "state": "AZ", "last_updated_date": "2016-08-24", "case_name": "Galt Venture Inc Vs Keri Hawkins", "county": "Maricopa", "filing_date": "2009-05-18", "case_status": "Other Disposed", "case_id": "EQ7RGFZLGMVUGEDYMEWGC5K7MFEQW1022", "case_type_subcategory": "Other", "case_number": "CC2009-299678"}, "judges": [{"suffix": null, "firstname": "Dean", "middlename": null, "lastname": "Wolcott", "prefix": null, "fullname": "Wolcott, Dean", "judge_id": "EQ7RGFZLGMVUGEDYMEWGC5K7MFEQW1022"}], "attorneys": [{"firm": null, "bar_number": null, "suffix": null, "firstname": "Milton", "attorney_id": "EQ7RGFZLGMVUGEDYMEWGC73DKVHA21031", "middlename": null, "lastname": "Mecham", "entities": [], "prefix": null, "fullname": "Milton Mecham"}], "parties": [{"party_types": [{"active": true, "party_type": "Defendant", "attorney_association": [], "representation_type": "Self Represented"}], "suffix": null, "firstname": "Keri", "entity_type": "Individual", "middlename": null, "lastname": "Hawkins", "entities": [], "prefix": null, "party_id": "EM7BEFRKGIVEED3XMAVV27TBLJCQQ1021", "fullname": "Keri Hawkins"}, {"party_types": [{"active": true, "party_type": "Garnishee", "attorney_association": [], "representation_type": "Self Represented"}], "suffix": null, "firstname": "Wal-Mart Stores", "entity_type": "Company", "middlename": null, "lastname": null, "entities": [], "prefix": null, "party_id": "EQ7RGFZLGMVUGEDYMEWF473CLNDAU1022", "fullname": "Wal-Mart Stores"}, {"party_types": [{"active": true, "party_type": "Plaintiff", "attorney_association": [{"active": true, "attorney_id": "EQ7RGFZLGMVUGEDYMEWGC73DKVHA21031", "attorney_type": "Attorney"}], "representation_type": "Attorney Represented"}], "suffix": null, "firstname": "Galt Venture Inc", "entity_type": "Company", "middlename": null, "lastname": null, "entities": [], "prefix": null, "party_id": "EVABIGBMGQWEIELZMIWV7ADDLRDQY1023", "fullname": "Galt Venture Inc"}]}, "error": ""}';
        '{"search_metadata": {"search_id": "1453","search_run_id": "9951e497-450a-485b-9374-5278313d48f1" },"results": [{"case": {"case_id":"GNHCEJRNJNGEAGL7IM5WRDTMMVLBW0947","case_type_category": "Civil","case_type_subcategory": "Other","case_type": "Other","case_status_category": "Undetermined","case_status": "Undetermined","state": "CA","courthouse": "Central Justice Center","jurisdiction": "Orange County Superior Courts","case_name": "TANIGUCHI VS YOUNG","case_number": "30-2019-01043117-CU-PT-CJC","filing_date":"2019-01-08","last_updated_date": "2019-01-18","docket": "TRANSACTION NUMBER 12480819 AND RECEIPT NUMBER 12304509.","hidden": false},"judges": [],"attorneys": [],"parties": [],"search_run_result_id": "9951e497-450a-485b-9374-5278313d48f1.CA.ORA.923427"}]}';
        LeadGenCasesParser obj = parse(json);
        System.assert(obj != null);
    }
    
}