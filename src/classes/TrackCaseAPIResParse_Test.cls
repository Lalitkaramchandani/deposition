@IsTest
public class TrackCaseAPIResParse_Test {
	
	static testMethod void testParse() {
		String json = '{\"result\": [{\"tracking_schedule_id\": \"1\", \"tracking_name\": \"Daily\", \"tracked_date\": \"2018-08-31 15:30:38\", \"folder\": [{\"folder_id\": \"2\", \"folder_name\": \"My Folder\", \"case_ids\": [\"EZARKGJAFNATGFMCMYXFZASZMNEQU1006\"]}]}]}';
		TrackCaseAPIResParse obj = TrackCaseAPIResParse.parse(json);
		System.assert(obj != null);
	}
}