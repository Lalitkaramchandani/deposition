@IsTest
public class PartyJSONParserTest {
	
	// This test method should give 100% coverage
	static testMethod void testParse() {
		String json = '{\"error\":false,\"message\":\"OK\",\"data\":{\"requested_case_id\":\"HFKCQLBTHZKEMIUMPFAXRFTSN5OBW0998\",\"requested_page_number\":\"1\",\"parties\":[{\"party_id\":\"FFCBQHBDFZCDMET4NEYWLBLJL5JQY1009\",\"party_types\":[{\"party_type\":\"Debtor\",\"active\":true,\"representation_type\":\"Attorney Represented\",\"attorney_association\":[{\"attorney_type\":\"Attorney\",\"attorney_id\":\"F5FB4IRJDI4UAJMLGVMUFC3DNVMBK0925\",\"active\":true},{\"attorney_type\":\"Attorney\",\"attorney_id\":\"GBFR6IZKDM5ECJUMGZNEHDDENZMRO0926\",\"active\":true},{\"attorney_type\":\"Attorney\",\"attorney_id\":\"GFGCAJBLDQ5UEJ4NG5NUJDLFN5NBS0927\",\"active\":true},{\"attorney_type\":\"Attorney\",\"attorney_id\":\"GJGSCJJMDU6EGKEOHBOELDTGOBNRW0928\",\"active\":true},{\"attorney_type\":\"Attorney\",\"attorney_id\":\"GNHCEJRNDY6UIKMPHFOUND3HOFOB20929\",\"active\":true},{\"attorney_type\":\"Attorney\",\"attorney_id\":\"FNDBUHRFCY2TYIMHGFKT5B27NFKQY0921\",\"active\":true},{\"attorney_type\":\"Attorney\",\"attorney_id\":\"FRDRWHZGC43D2IUIGJLD7CDANJLA40922\",\"active\":true},{\"attorney_type\":\"Attorney\",\"attorney_id\":\"FVEBYIBHDA3T4I4JGNLUBCLBNNLRA0923\",\"active\":true},{\"attorney_type\":\"Attorney\",\"attorney_id\":\"FZER2IJIDE4D6JEKGRMEDCTCNRMBE0924\",\"active\":true},{\"attorney_type\":\"Attorney\",\"attorney_id\":\"F5FB4IRJDI4UAJMLGVMUFC3DNVMRI0925\",\"active\":true},{\"attorney_type\":\"Attorney\",\"attorney_id\":\"GBFR6IZKDM5ECJUMGZNEHDDENZNBM0926\",\"active\":true},{\"attorney_type\":\"Attorney\",\"attorney_id\":\"GFGCAJBLDQ5UEJ4NG5NUJDLFN5NRQ0927\",\"active\":true},{\"attorney_type\":\"Attorney\",\"attorney_id\":\"GJGSCJJMDU6EGKEOHBOELDTGOBOBU0928\",\"active\":true},{\"attorney_type\":\"Attorney\",\"attorney_id\":\"FNDBUHRFCY2TYIMHGFKT5B27NFKRK0930\",\"active\":true},{\"attorney_type\":\"Attorney\",\"attorney_id\":\"FJCRSHJECU2DWIEGGBKD3BS6M5FQW0911\",\"active\":true},{\"attorney_type\":\"Attorney\",\"attorney_id\":\"FNDBUHRFCY2TYIMHGFKT5B27NBGA20912\",\"active\":true},{\"attorney_type\":\"Attorney\",\"attorney_id\":\"FRDRWHZGC43D2IUIGJLD7CDANFGQ60913\",\"active\":true},{\"attorney_type\":\"Attorney\",\"attorney_id\":\"FVEBYIBHDA3T4I4JGNLUBCLBNJHBC0914\",\"active\":true},{\"attorney_type\":\"Attorney\",\"attorney_id\":\"F5FB4IRJDI4UAJMLGVMUFC3DNRIBK0916\",\"active\":true},{\"attorney_type\":\"Attorney\",\"attorney_id\":\"GBFR6IZKDM5ECJUMGZNEHDDENVIRO0917\",\"active\":true},{\"attorney_type\":\"Attorney\",\"attorney_id\":\"GFGCAJBLDQ5UEJ4NG5NUJDLFNZJBS0918\",\"active\":true},{\"attorney_type\":\"Attorney\",\"attorney_id\":\"FJCRSHJECU2DWIEGGBKD3BS6M5FRI0920\",\"active\":true},{\"attorney_type\":\"Attorney\",\"attorney_id\":\"FNDBUHRFCY2TYIMHGFKT5B27NBGQY0912\",\"active\":true},{\"attorney_type\":\"Attorney\",\"attorney_id\":\"FRDRWHZGC43D2IUIGJLD7CDANFHA40913\",\"active\":true},{\"attorney_type\":\"Attorney\",\"attorney_id\":\"FVEBYIBHDA3T4I4JGNLUBCLBNJHRA0914\",\"active\":true},{\"attorney_type\":\"Attorney\",\"attorney_id\":\"FZER2IJIDE4D6JEKGRMEDCTCNNIBE0915\",\"active\":false},{\"attorney_type\":\"Attorney\",\"attorney_id\":\"F5FB4IRJDI4UAJMLGVMUFC3DNRIRI0916\",\"active\":true},{\"attorney_type\":\"Attorney\",\"attorney_id\":\"GFGCAJBLDQ5UEJ4NG5NUJDLFNZJRQ0918\",\"active\":true},{\"attorney_type\":\"Attorney\",\"attorney_id\":\"GJGSCJJMDU6EGKEOHBOELDTGN5KBU0919\",\"active\":true},{\"attorney_type\":\"Attorney\",\"attorney_id\":\"FRDRWHZGC43D2IUIGJLD7CDANFHQ20913\",\"active\":true},{\"attorney_type\":\"Attorney\",\"attorney_id\":\"FVEBYIBHDA3T4I4JGNLUBCLBNJIA60914\",\"active\":true},{\"attorney_type\":\"Attorney\",\"attorney_id\":\"FZER2IJIDE4D6JEKGRMEDCTCNNIRC0915\",\"active\":true},{\"attorney_type\":\"Attorney\",\"attorney_id\":\"GBFR6IZKDM5ECJUMGZNEHDDENVJRK0917\",\"active\":true},{\"attorney_type\":\"Attorney\",\"attorney_id\":\"GFGCAJBLDQ5UEJ4NG5NUJDLFNZKBO0918\",\"active\":true},{\"attorney_type\":\"Attorney\",\"attorney_id\":\"FJCRSHJECU2DWIEGGBKD3BS6M5GRE0920\",\"active\":true},{\"attorney_type\":\"Attorney\",\"attorney_id\":\"FNDBUHRFCY2TYIMHGFKT5B27NBHBI0921\",\"active\":true},{\"attorney_type\":\"Attorney\",\"attorney_id\":\"FRDRWHZGC43D2IUIGJLD7CDANFHRM0922\",\"active\":true},{\"attorney_type\":\"Attorney\",\"attorney_id\":\"FVEBYIBHDA3T4I4JGNLUBCLBNJIQ40914\",\"active\":true},{\"attorney_type\":\"Attorney\",\"attorney_id\":\"FZER2IJIDE4D6JEKGRMEDCTCNNJBA0915\",\"active\":true},{\"attorney_type\":\"Attorney\",\"attorney_id\":\"GBFR6IZKDM5ECJUMGZNEHDDENVKBI0917\",\"active\":true},{\"attorney_type\":\"Attorney\",\"attorney_id\":\"GFGCAJBLDQ5UEJ4NG5NUJDLFNZKRM0918\",\"active\":true},{\"attorney_type\":\"Attorney\",\"attorney_id\":\"GJGSCJJMDU6EGKEOHBOELDTGN5LBQ0919\",\"active\":true},{\"attorney_type\":\"Attorney\",\"attorney_id\":\"FFCBQHBDCQZTUH4FF5JTZBK4L5FRA0910\",\"active\":true},{\"attorney_type\":\"Attorney\",\"attorney_id\":\"FJCRSHJECU2DWIEGGBKD3BS5MBGBE0911\",\"active\":true},{\"attorney_type\":\"Attorney\",\"attorney_id\":\"F5FB4IRJDI4UAJMLGVMUFC3CM5IBE0907\",\"active\":true}]}],\"entities\":[{\"phones\":[],\"party_entity_id\":\"FFCBQHBDFZCDMET4NEYWLBLJL5JQY1009\",\"potentials\":[{\"party_potential_id\":\"FBBROGZCFVBTKEL3NAYGLBLCMZIBC1017\",\"court_verified\":true,\"address\":\"Jacob Javits Federal Bldg, 26 Federal Plaza, Rm 2-128\",\"city\":\"New York\",\"state\":\"NY\",\"zipcode\":\"10278\",\"first_seen_date\":null}],\"emails\":[]}],\"fullname\":\"COMMONWEALTH OF PUERTO RICO\",\"prefix\":null,\"firstname\":\"COMMONWEALTH OF PUERTO RICO\",\"middlename\":null,\"lastname\":null,\"suffix\":null,\"entity_type\":\"Other\"},{\"party_id\":\"FFCBQHCBIEYDWCYSHNKGPA25MFIQ60910\",\"party_types\":[{\"party_type\":\"Not Yet Classified\",\"active\":true,\"representation_type\":\"Attorney Represented\",\"attorney_association\":[{\"attorney_type\":\"Attorney\",\"attorney_id\":\"FVEBYIBHDA3T4I4JGNLUBCLAMBJQ40905\",\"active\":true}]}],\"entities\":[{\"phones\":[{\"num\":\"7872591999\",\"type\":\"Default\"}],\"party_entity_id\":\"FFCBQHCBIEYDWCYSHNKGPA25MFIQ60910\",\"potentials\":[{\"party_potential_id\":\"GZISKKJQHNIUGH4JOY7HHE3PNJMRS0995\",\"court_verified\":true,\"address\":\"9140 Calle Marina - Suite 801\",\"city\":\"Ponce\",\"state\":\"PR\",\"zipcode\":\"00717\",\"first_seen_date\":null}],\"emails\":[]}],\"fullname\":\"SUCESION PASTOR MANDRY MERCADO\",\"prefix\":null,\"firstname\":\"SUCESION\",\"middlename\":\"PASTOR MANDRY\",\"lastname\":\"MERCADO\",\"suffix\":null,\"entity_type\":\"Individual\"}],\"more_parties\":false}}';
		PartyJSONParser r = PartyJSONParser.parse(json);
		System.assert(r != null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		PartyJSONParser.Parties objParties = new PartyJSONParser.Parties(System.JSON.createParser(json));
		System.assert(objParties != null);
		System.assert(objParties.party_id == null);
		System.assert(objParties.party_types == null);
		System.assert(objParties.entities == null);
		System.assert(objParties.fullname == null);
		System.assert(objParties.prefix == null);
		System.assert(objParties.firstname == null);
		System.assert(objParties.middlename == null);
		System.assert(objParties.lastname == null);
		System.assert(objParties.suffix == null);
		System.assert(objParties.entity_type == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		PartyJSONParser.Potentials objPotentials = new PartyJSONParser.Potentials(System.JSON.createParser(json));
		System.assert(objPotentials != null);
		System.assert(objPotentials.party_potential_id == null);
		System.assert(objPotentials.court_verified == null);
		System.assert(objPotentials.address == null);
		System.assert(objPotentials.city == null);
		System.assert(objPotentials.state == null);
		System.assert(objPotentials.zipcode == null);
		System.assert(objPotentials.first_seen_date == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		PartyJSONParser objPartyJSONParser = new PartyJSONParser(System.JSON.createParser(json));
		System.assert(objPartyJSONParser != null);
		System.assert(objPartyJSONParser.error == null);
		System.assert(objPartyJSONParser.message == null);
		System.assert(objPartyJSONParser.data == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		PartyJSONParser.Phones objPhones = new PartyJSONParser.Phones(System.JSON.createParser(json));
		System.assert(objPhones != null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		PartyJSONParser.Party_types objParty_types = new PartyJSONParser.Party_types(System.JSON.createParser(json));
		System.assert(objParty_types != null);
		System.assert(objParty_types.party_type == null);
		System.assert(objParty_types.active == null);
		System.assert(objParty_types.representation_type == null);
		System.assert(objParty_types.attorney_association == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		PartyJSONParser.Data objData = new PartyJSONParser.Data(System.JSON.createParser(json));
		System.assert(objData != null);
		System.assert(objData.requested_case_id == null);
		System.assert(objData.requested_page_number == null);
		System.assert(objData.parties == null);
		System.assert(objData.more_parties == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		PartyJSONParser.Attorney_association objAttorney_association = new PartyJSONParser.Attorney_association(System.JSON.createParser(json));
		System.assert(objAttorney_association != null);
		System.assert(objAttorney_association.attorney_type == null);
		System.assert(objAttorney_association.attorney_id == null);
		System.assert(objAttorney_association.active == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		PartyJSONParser.Phones_Z objPhones_Z = new PartyJSONParser.Phones_Z(System.JSON.createParser(json));
		System.assert(objPhones_Z != null);
		System.assert(objPhones_Z.num == null);
		System.assert(objPhones_Z.type_Z == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		PartyJSONParser.Entities objEntities = new PartyJSONParser.Entities(System.JSON.createParser(json));
		System.assert(objEntities != null);
		System.assert(objEntities.phones == null);
		System.assert(objEntities.party_entity_id == null);
		System.assert(objEntities.potentials == null);
		System.assert(objEntities.emails == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		PartyJSONParser.Entities_Z objEntities_Z = new PartyJSONParser.Entities_Z(System.JSON.createParser(json));
		System.assert(objEntities_Z != null);
		System.assert(objEntities_Z.phones == null);
		System.assert(objEntities_Z.party_entity_id == null);
		System.assert(objEntities_Z.potentials == null);
		System.assert(objEntities_Z.emails == null);
	}
}