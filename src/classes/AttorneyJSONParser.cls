public class AttorneyJSONParser {

	public class Potentials {
		public String attorney_potential_id {get;set;} 
		public String address {get;set;} 
		public String city {get;set;} 
		public String state {get;set;} 
		public String zipcode {get;set;} 
		public Boolean court_verified {get;set;} 

		public Potentials(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'attorney_potential_id') {
							attorney_potential_id = parser.getText();
						} else if (text == 'address') {
							address = parser.getText();
						} else if (text == 'city') {
							city = parser.getText();
						} else if (text == 'state') {
							state = parser.getText();
						} else if (text == 'zipcode') {
							zipcode = parser.getText();
						} else if (text == 'court_verified') {
							court_verified = parser.getBooleanValue();
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

	public AttorneyJSONParser(JSONParser parser) {
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
						System.debug(LoggingLevel.WARN, 'AttorneyJSONParser consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	public class Phones {
		public String num {get;set;} 
		public String type_Z {get;set;} // in json: type

		public Phones(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'num') {
							num = parser.getText();
						} else if (text == 'type') {
							type_Z = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Phones consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Entities_Y {
		public String attorney_entity_id {get;set;} 
		public List<Potentials> potentials {get;set;} 
		public List<Phones_Z> phones {get;set;} 
		public List<String> emails {get;set;} 

		public Entities_Y(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'attorney_entity_id') {
							attorney_entity_id = parser.getText();
						} else if (text == 'potentials') {
							potentials = arrayOfPotentials(parser);
						} else if (text == 'phones') {
							phones = arrayOfPhones_Z(parser);
						} else if (text == 'emails') {
							emails = arrayOfString(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'Entities_Y consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Attorneys {
		public String attorney_id {get;set;} 
		public List<Entities> entities {get;set;} 
		public String fullname {get;set;} 
		public String firm {get;set;} 
		public String bar_number {get;set;} 
		public String prefix {get;set;} 
		public String suffix {get;set;} 
		public String firstname {get;set;} 
		public String middlename {get;set;} 
		public String lastname {get;set;} 
		public List<Attorney_types> attorney_types {get;set;} 

		public Attorneys(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'attorney_id') {
							attorney_id = parser.getText();
						} else if (text == 'entities') {
							entities = arrayOfEntities(parser);
						} else if (text == 'fullname') {
							fullname = parser.getText();
						} else if (text == 'firm') {
							firm = parser.getText();
						} else if (text == 'bar_number') {
							bar_number = parser.getText();
						} else if (text == 'prefix') {
							prefix = parser.getText();
						} else if (text == 'suffix') {
							suffix = parser.getText();
						} else if (text == 'firstname') {
							firstname = parser.getText();
						} else if (text == 'middlename') {
							middlename = parser.getText();
						} else if (text == 'lastname') {
							lastname = parser.getText();
						} else if (text == 'attorney_types') {
							attorney_types = arrayOfAttorney_types(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'Attorneys consuming unrecognized property: '+text);
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
		public List<Attorneys> attorneys {get;set;} 
		public Boolean more_attorneys {get;set;} 

		public Data(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'requested_case_id') {
							requested_case_id = parser.getText();
						} else if (text == 'requested_page_number') {
							requested_page_number = parser.getText();
						} else if (text == 'attorneys') {
							attorneys = arrayOfAttorneys(parser);
						} else if (text == 'more_attorneys') {
							more_attorneys = parser.getBooleanValue();
						} else {
							System.debug(LoggingLevel.WARN, 'Data consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Attorney_types {
		public String attorney_type {get;set;} 
		public Boolean active {get;set;} 

		public Attorney_types(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'attorney_type') {
							attorney_type = parser.getText();
						} else if (text == 'active') {
							active = parser.getBooleanValue();
						} else {
							System.debug(LoggingLevel.WARN, 'Attorney_types consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Phones_Z {

		public Phones_Z(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						{
							System.debug(LoggingLevel.WARN, 'Phones_Z consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Entities {
		public String attorney_entity_id {get;set;} 
		public List<Potentials> potentials {get;set;} 
		public List<Phones> phones {get;set;} 
		public List<String> emails {get;set;} 

		public Entities(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'attorney_entity_id') {
							attorney_entity_id = parser.getText();
						} else if (text == 'potentials') {
							potentials = arrayOfPotentials(parser);
						} else if (text == 'phones') {
							phones = arrayOfPhones(parser);
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
		public String attorney_entity_id {get;set;} 
		public List<Potentials> potentials {get;set;} 
		public List<Phones_Z> phones {get;set;} 
		public List<Phones_Z> emails {get;set;} 

		public Entities_Z(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'attorney_entity_id') {
							attorney_entity_id = parser.getText();
						} else if (text == 'potentials') {
							potentials = arrayOfPotentials(parser);
						} else if (text == 'phones') {
							phones = arrayOfPhones_Z(parser);
						} else if (text == 'emails') {
							emails = arrayOfPhones_Z(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'Entities_Z consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	
	public static AttorneyJSONParser parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new AttorneyJSONParser(parser);
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
	




    private static List<Phones_Z> arrayOfPhones_Z(System.JSONParser p) {
        List<Phones_Z> res = new List<Phones_Z>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Phones_Z(p));
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



    private static List<Entities_Z> arrayOfEntities_Z(System.JSONParser p) {
        List<Entities_Z> res = new List<Entities_Z>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Entities_Z(p));
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



    private static List<Attorneys> arrayOfAttorneys(System.JSONParser p) {
        List<Attorneys> res = new List<Attorneys>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Attorneys(p));
        }
        return res;
    }



    private static List<Entities_Y> arrayOfEntities_Y(System.JSONParser p) {
        List<Entities_Y> res = new List<Entities_Y>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Entities_Y(p));
        }
        return res;
    }


    private static List<Attorney_types> arrayOfAttorney_types(System.JSONParser p) {
        List<Attorney_types> res = new List<Attorney_types>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Attorney_types(p));
        }
        return res;
    }


    private static List<Phones> arrayOfPhones(System.JSONParser p) {
        List<Phones> res = new List<Phones>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Phones(p));
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
}