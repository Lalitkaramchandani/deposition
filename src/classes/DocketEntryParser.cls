public class DocketEntryParser {

	public class Docket_entries {
		public List<String> document_id_list;
		public Integer order;
		public String boundary;
		public String text;
		public String entryDate;
		public String updated;
	}

	public Boolean error;
	public String message;
	public Data data;

	public class Data {
		public List<Docket_entries> docket_entries;
		public String last_key;
	}

	
	public static DocketEntryParser parse(String json) {
		return (DocketEntryParser) System.JSON.deserialize(json, DocketEntryParser.class);
	}
}