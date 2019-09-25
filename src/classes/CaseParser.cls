public class CaseParser{
    public boolean error;
    public String message;  //OK
    public cls_data data;
    public class cls_data { 
        public cls_caseObj caseObj;
        public String docket_entries_token;
        public String attorneys_token;
        public String parties_token;
       

    }
    public class cls_caseObj {
        public cls_case_meta case_meta;
        public cls_parties[] parties;
        public cls_attorneys[] attorneys;
        public cls_judges[] judges;
        public Boolean more_parties;
        public Boolean more_attorneys; 
    }
    public class cls_case_meta {
        public String case_number;  //3:18-CV-00477
        public String case_name;    //Cisco Systems, Inc. Et Al V. Beccela'S Etc., Llc
        public String filing_date;  //2018-01-22 00:00:00
        public String last_updated_date;    //2018-01-23 05:06:25
        public String case_type;    //Trademark
        public String case_type_subcategory;    //Intellectual Property
        public String case_type_category;   //Civil
        public String case_status;  //Other Pending
        public String case_status_category; //Pending
        public String courthouse;   //California Northern District
        public String jurisdiction; //U.S. District Courts
        public String county;
        public String state;    //CA
        public String case_id;  //EVABIGA7FJADEFEBMUWWDBDBK5GAM1014
    }
    public class cls_county {
    }
    public class cls_parties {
        public String party_id; //FZER2IKGIY2UMFYXIBMGJDLBMFHRI0906
        public cls_party_types[] party_types;
        public cls_entities[] entities;
        public String fullname; //Beccela'S Etc., Llc
        public String prefix;
        public String firstname;    //Beccela'S Etc., Llc
        public String middlename;
        public String lastname;
        public String suffix;
        public String entity_type;  //Company
    }
    public class cls_party_types {
        public String party_type;   //Defendant
        public boolean active;
        public String representation_type;  //Unrepresented
        public cls_attorney_association[] attorney_association;
    }
    public class cls_attorney_association {
        public String attorney_type;    //Lead Attorney
        public String attorney_id;  //E5BBMGRBFRBDIFUDM4XWBBTALJGAQ1007
        public boolean active;
    }
    public class cls_entities {
        public String attorney_entity_id;   //EI6RCFI4E46S6EL6MIVFY7KVLBFQS1011
        public cls_potentials[] potentials;
        public cls_phones[] phones;
        public String[] emails;
    }
    
    public class cls_attorneys {
        public String attorney_id;  //EI6RCFI4E46S6EL6MIVFY7KVLBFQS1011
        public cls_entities[] entities;
        public String fullname; //Richard Joseph Nelson
        public String firm; //Sideman & Bancroft Llp
        public String bar_number;
        public String prefix;
        public String suffix;
        public String firstname;    //Richard
        public String middlename;   //Joseph
        public String lastname; //Nelson
    }
    public class cls_potentials {
        public String attorney_potential_id;    //EM7BEFQ5FA7DAET7MMVV27K6KVEQW1012
        public String address;  //One Embarcadero Center, 22Nd Floor
        public String city; //San Francisco
        public String state;    //CA
        public String zipcode;  //94111
        public boolean court_verified;
    }
    public class cls_phones {
        public String num;  //4153921960
        public String type; //Default
    }
    public class cls_emails {
       public String emailAddress;
    }
    
    public class cls_judges {
        public String judge_id; //FFCBQHBDFZCDMGEFNEYV7ATCLVJBA1009
        public String fullname; //Jacqueline Scott Corley
        public String prefix;
        public String suffix;
        public String firstname;    //Jacqueline
        public String middlename;   //Scott
        public String lastname; //Corley
    }
    public static CaseParser parse(String json){
        return (CaseParser) System.JSON.deserialize(json, CaseParser.class);
    }

    static testMethod void testParse() {
        String json=        '{ '+
        '  "error": false,'+
        '  "message": "OK",'+
        '  "data":{'+
        '      "caseObj":{'+
        '         "case_meta":{'+
        '            "case_number":"3:18-CV-00477",'+
        '            "case_name":"Cisco Systems, Inc. Et Al V. BeccelaS Etc., Llc",'+
        '            "filing_date":"2018-01-22 00:00:00",'+
        '            "last_updated_date":"2018-01-23 05:06:25",'+
        '            "case_type":"Trademark",'+
        '            "case_type_subcategory":"Intellectual Property",'+
        '            "case_type_category":"Civil",'+
        '            "case_status":"Other Pending",'+
        '            "case_status_category":"Pending",'+
        '            "courthouse":"California Northern District",'+
        '            "jurisdiction":"U.S. District Courts",'+
        '            "county":null,'+
        '            "state":"CA",'+
        '            "case_id":"EVABIGA7FJADEFEBMUWWDBDBK5GAM1014"'+
        '         },'+
        '         "parties":['+
        '            {'+
        '               "party_id":"FZER2IKGIY2UMFYXIBMGJDLBMFHRI0906",'+
        '               "party_types":['+
        '                  {'+
        '                     "party_type":"Defendant",'+
        '                     "active":true,'+
        '                     "representation_type":"Unrepresented",'+
        '                     "attorney_association":['+
        ''+
        '                     ]'+
        '                  }'+
        '               ],'+
        '               "entities":['+
        ''+
        '               ],'+
        '               "fullname":"BeccelaS Etc., Llc",'+
        '               "prefix":null,'+
        '               "firstname":"BeccelaS Etc., Llc",'+
        '               "middlename":null,'+
        '               "lastname":null,'+
        '               "suffix":null,'+
        '               "entity_type":"Company"'+
        '            },'+
        '            {'+
        '               "party_id":"F5FB4ISHI43EOGAYIFMWLDTCMJIBM0907",'+
        '               "party_types":['+
        '                  {'+
        '                     "party_type":"Plaintiff",'+
        '                     "active":true,'+
        '                     "representation_type":"Attorney Represented",'+
        '                     "attorney_association":['+
        '                        {'+
        '                           "attorney_type":"Attorney",'+
        '                           "attorney_id":"EI6RCFI4E46S6EL6MIVFY7KVLBFQS1011",'+
        '                           "active":true'+
        '                        }'+
        '                     ]'+
        '                  }'+
        '               ],'+
        '               "entities":['+
        ''+
        '               ],'+
        '               "fullname":"Cisco Systems, Inc.",'+
        '               "prefix":null,'+
        '               "firstname":"Cisco Systems, Inc.",'+
        '               "middlename":null,'+
        '               "lastname":null,'+
        '               "suffix":null,'+
        '               "entity_type":"Company"'+
        '            },'+
        '            {'+
        '               "party_id":"GBFR6I2IJA3UQGIZIJNGND3DMNIRQ0908",'+
        '               "party_types":['+
        '                  {'+
        '                     "party_type":"Plaintiff",'+
        '                     "active":true,'+
        '                     "representation_type":"Attorney Represented",'+
        '                     "attorney_association":['+
        '                        {'+
        '                           "attorney_type":"Attorney",'+
        '                           "attorney_id":"EI6RCFI4E46S6EL6MIVFY7KVLBFQS1011",'+
        '                           "active":true'+
        '                        }'+
        '                     ]'+
        '                  }'+
        '               ],'+
        '               "entities":['+
        ''+
        '               ],'+
        '               "fullname":"Cisco Technology, Inc.",'+
        '               "prefix":null,'+
        '               "firstname":"Cisco Technology, Inc.",'+
        '               "middlename":null,'+
        '               "lastname":null,'+
        '               "suffix":null,'+
        '               "entity_type":"Company"'+
        '            }'+
        '         ],'+
        '         "attorneys":['+
        '            {'+
        '               "attorney_id":"EI6RCFI4E46S6EL6MIVFY7KVLBFQS1011",'+
        '               "entities":['+
        '                  {'+
        '                     "attorney_entity_id":"EI6RCFI4E46S6EL6MIVFY7KVLBFQS1011",'+
        '                     "potentials":['+
        '                        {'+
        '                           "attorney_potential_id":"EM7BEFQ5FA7DAET7MMVV27K6KVEQW1012",'+
        '                           "address":"One Embarcadero Center, 22Nd Floor",'+
        '                           "city":"San Francisco",'+
        '                           "state":"CA",'+
        '                           "zipcode":"94111",'+
        '                           "court_verified":true'+
        '                        }'+
        '                     ],'+
        '                     "phones":['+
        '                        {'+
        '                           "num":"4153921960",'+
        '                           "type":"Default"'+
        '                        },'+
        '                        {'+
        '                           "num":"4153920827",'+
        '                           "type":"Fax"'+
        '                        }'+
        '                     ],'+
        '                     "emails":['+
        '                        "rnelson@sideman.com"'+
        '                     ]'+
        '                  }'+
        '               ],'+
        '               "fullname":"Richard Joseph Nelson",'+
        '               "firm":"Sideman & Bancroft Llp",'+
        '               "bar_number":null,'+
        '               "prefix":null,'+
        '               "suffix":null,'+
        '               "firstname":"Richard",'+
        '               "middlename":"Joseph",'+
        '               "lastname":"Nelson"'+
        '            }'+
        '         ],'+
        '         "judges":['+
        '            {'+
        '               "judge_id":"FFCBQHBDFZCDMGEFNEYV7ATCLVJBA1009",'+
        '               "fullname":"Jacqueline Scott Corley",'+
        '               "prefix":null,'+
        '               "suffix":null,'+
        '               "firstname":"Jacqueline",'+
        '               "middlename":"Scott",'+
        '               "lastname":"Corley"'+
        '            }'+
        '         ]'+
        '      }'+
        '   }'+
        '}';
        CaseParser obj = parse(json);
        System.assert(obj != null);
    }
}