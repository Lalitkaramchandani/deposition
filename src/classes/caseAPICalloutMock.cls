@isTest
public class caseAPICalloutMock implements HttpCalloutMock {
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
    public HTTPResponse respond(HTTPRequest req) {
        
        System.assertEquals('GET', req.getMethod());
        
        // Create a dummy response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(json);
        res.setStatusCode(200);
        return res;
    }
}