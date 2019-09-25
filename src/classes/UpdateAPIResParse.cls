public class UpdateAPIResParse {
        
        public Result result;
        
        public class Result {
            public String case_id;
            public String status;
            public String updated_time;
        }
        
        
        public static UpdateAPIResParse parse(String json) {
            return (UpdateAPIResParse) System.JSON.deserialize(json, UpdateAPIResParse.class);
        }
    }