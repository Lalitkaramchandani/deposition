public class PartyJSONParser {

	public class Parties {
		public String party_id {get;set;} 
		public List<Party_types> party_types {get;set;} 
		public List<Entities> entities {get;set;} 
		public String fullname {get;set;} 
		public String prefix {get;set;} 
		public String firstname {get;set;} 
		public String middlename {get;set;} 
		public String lastname {get;set;} 
		public String suffix {get;set;} 
		public String entity_type {get;set;} 

		public Parties(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'party_id') {
							party_id = parser.getText();
						} else if (text == 'party_types') {
							party_types = arrayOfParty_types(parser);
						} else if (text == 'entities') {
							entities = arrayOfEntities(parser);
						} else if (text == 'fullname') {
							fullname = parser.getText();
						} else if (text == 'prefix') {
							prefix = parser.getText();
						} else if (text == 'firstname') {
							firstname = parser.getText();
						} else if (text == 'middlename') {
							middlename = parser.getText();
						} else if (text == 'lastname') {
							lastname = parser.getText();
						} else if (text == 'suffix') {
							suffix = parser.getText();
						} else if (text == 'entity_type') {
							entity_type = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Parties consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Potentials {
		public String party_potential_id {get;set;} 
		public Boolean court_verified {get;set;} 
		public String address {get;set;} 
		public String city {get;set;} 
		public String state {get;set;} 
		public String zipcode {get;set;} 
		public String first_seen_date {get;set;} 

		public Potentials(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'party_potential_id') {
							party_potential_id = parser.getText();
						} else if (text == 'court_verified') {
							court_verified = parser.getBooleanValue();
						} else if (text == 'address') {
							address = parser.getText();
						} else if (text == 'city') {
							city = parser.getText();
						} else if (text == 'state') {
							state = parser.getText();
						} else if (text == 'zipcode') {
							zipcode = parser.getText();
						} else if (text == 'first_seen_date') {
							first_seen_date = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Potentials consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public Boolean error {get;set;} 
	public String message {get;set;} 
	public Data data {get;set;} 

	public PartyJSONParser(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'error') {
						error = parser.getBooleanValue();
					} else if (text == 'message') {
						message = parser.getText();
					} else if (text == 'data') {
						data = new Data(parser);
					} else {
						System.debug(LoggingLevel.WARN, 'PartyJSONParser consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	public class Phones {

		public Phones(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						{
							System.debug(LoggingLevel.WARN, 'Phones consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Party_types {
		public String party_type {get;set;} 
		public Boolean active {get;set;} 
		public String representation_type {get;set;} 
		public List<Attorney_association> attorney_association {get;set;} 

		public Party_types(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'party_type') {
							party_type = parser.getText();
						} else if (text == 'active') {
							active = parser.getBooleanValue();
						} else if (text == 'representation_type') {
							representation_type = parser.getText();
						} else if (text == 'attorney_association') {
							attorney_association = arrayOfAttorney_association(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'Party_types consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Data {
		public String requested_case_id {get;set;} 
		public String requested_page_number {get;set;} 
		public List<Parties> parties {get;set;} 
		public Boolean more_parties {get;set;} 

		public Data(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'requested_case_id') {
							requested_case_id = parser.getText();
						} else if (text == 'requested_page_number') {
							requested_page_number = parser.getText();
						} else if (text == 'parties') {
							parties = arrayOfParties(parser);
						} else if (text == 'more_parties') {
							more_parties = parser.getBooleanValue();
						} else {
							System.debug(LoggingLevel.WARN, 'Data consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Attorney_association {
		public String attorney_type {get;set;} 
		public String attorney_id {get;set;} 
		public Boolean active {get;set;} 

		public Attorney_association(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'attorney_type') {
							attorney_type = parser.getText();
						} else if (text == 'attorney_id') {
							attorney_id = parser.getText();
						} else if (text == 'active') {
							active = parser.getBooleanValue();
						} else {
							System.debug(LoggingLevel.WARN, 'Attorney_association consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Phones_Z {
		public String num {get;set;} 
		public String type_Z {get;set;} // in json: type

		public Phones_Z(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'num') {
							num = parser.getText();
						} else if (text == 'type') {
							type_Z = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Phones_Z consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Entities {
		public List<Phones> phones {get;set;} 
		public String party_entity_id {get;set;} 
		public List<Potentials> potentials {get;set;} 
		public List<String> emails {get;set;} 

		public Entities(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'phones') {
							phones = arrayOfPhones(parser);
						} else if (text == 'party_entity_id') {
							party_entity_id = parser.getText();
						} else if (text == 'potentials') {
							potentials = arrayOfPotentials(parser);
						} else if (text == 'emails') {
							emails = arrayOfString(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'Entities consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Entities_Z {
		public List<Phones_Z> phones {get;set;} 
		public String party_entity_id {get;set;} 
		public List<Potentials> potentials {get;set;} 
		public List<String> emails {get;set;} 

		public Entities_Z(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'phones') {
							phones = arrayOfPhones_Z(parser);
						} else if (text == 'party_entity_id') {
							party_entity_id = parser.getText();
						} else if (text == 'potentials') {
							potentials = arrayOfPotentials(parser);
						} else if (text == 'emails') {
							emails = arrayOfString(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'Entities_Z consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	
	public static PartyJSONParser parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new PartyJSONParser(parser);
	}
	
	public static void consumeObject(System.JSONParser parser) {
		Integer depth = 0;
		do {
			System.JSONToken curr = parser.getCurrentToken();
			if (curr == System.JSONToken.START_OBJECT || 
				curr == System.JSONToken.START_ARRAY) {
				depth++;
			} else if (curr == System.JSONToken.END_OBJECT ||
				curr == System.JSONToken.END_ARRAY) {
				depth--;
			}
		} while (depth > 0 && parser.nextToken() != null);
	}
	
    private static List<Phones> arrayOfPhones(System.JSONParser p) {
        List<Phones> res = new List<Phones>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Phones(p));
        }
        return res;
    }


    private static List<Entities> arrayOfEntities(System.JSONParser p) {
        List<Entities> res = new List<Entities>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Entities(p));
        }
        return res;
    }



    private static List<Potentials> arrayOfPotentials(System.JSONParser p) {
        List<Potentials> res = new List<Potentials>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Potentials(p));
        }
        return res;
    }






    private static List<Phones_Z> arrayOfPhones_Z(System.JSONParser p) {
        List<Phones_Z> res = new List<Phones_Z>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Phones_Z(p));
        }
        return res;
    }







    private static List<Attorney_association> arrayOfAttorney_association(System.JSONParser p) {
        List<Attorney_association> res = new List<Attorney_association>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Attorney_association(p));
        }
        return res;
    }


    private static List<Parties> arrayOfParties(System.JSONParser p) {
        List<Parties> res = new List<Parties>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Parties(p));
        }
        return res;
    }



    private static List<Party_types> arrayOfParty_types(System.JSONParser p) {
        List<Party_types> res = new List<Party_types>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Party_types(p));
        }
        return res;
    }
    private static List<String> arrayOfString(System.JSONParser p) {
        List<String> res = new List<String>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(p.getText());
        }
        return res;
    }
    
    
    

    private static List<Entities_Z> arrayOfEntities_Z(System.JSONParser p) {
        List<Entities_Z> res = new List<Entities_Z>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Entities_Z(p));
        }
        return res;
    }


}