public class TrackCaseAPIResParse {

	public List<Result> result;

	public class Folder {
		public String folder_id;
		public String folder_name;
		public List<String> case_ids;
	}

	public class Result {
		public String tracking_schedule_id;
		public String tracking_name;
		public String tracked_date;
		public List<Folder> folder;
	}

	
	public static TrackCaseAPIResParse parse(String json) {
		return (TrackCaseAPIResParse) System.JSON.deserialize(json, TrackCaseAPIResParse.class);
	}
}