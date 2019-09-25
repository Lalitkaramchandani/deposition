public class SavedSearchParser {

    public class Filters {
        public String filter_type;
        public String field;
        public String theDate;
        public List<Integer> keys;
    }

    public Boolean error;
    public String message;
    public Data data;

    public class Query {
        public List<String> search_terms;
        public String scope;
        public String attribute;
        public String proximity;
    }

    public class Data {
        public Integer page;
        public String sort_by;
        public Boolean active;
        public List<String> scheduled_days;
        public List<Query> query;
        public String criteria;
        public List<Filters> filters;
        public String search_id;
        public String search_name;
    }

    
    public static SavedSearchParser parse(String json) {
        return (SavedSearchParser) System.JSON.deserialize(json, SavedSearchParser.class);
    }
    
    
}