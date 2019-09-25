/*
Author: Jitendra Kumar
Test Class: AccConMatchParserTest

*/
public class AccConMatchParser {

	    public String webhook_type;
        public String industry;
        public String data_delivery_date;
        public String case_from_filing_date;
        public String case_to_filing_date;
        public String csv_file_link;
        public List<String> jurisdiction;

        
        public static AccConMatchParser parse(String json) {
            return (AccConMatchParser) System.JSON.deserialize(json, AccConMatchParser.class);
        }
    

}