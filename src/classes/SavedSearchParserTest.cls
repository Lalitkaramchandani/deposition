@isTest
private class SavedSearchParserTest {

    @isTest
    private static void testParse() {
        String json = '{\"error\":false,\"message\":\"OK\",\"data\":{\"page\":1,\"sort_by\":\"Filing Date\",\"active\":true,\"scheduled_days\":[\"monday\",\"tuesday\",\"wednesday\",\"thursday\",\"friday\"],\"query\":[{\"search_terms\":[\"Case Management Conference\",\"Case Mangement\",\"Scheduling Order\",\"Scheduling Management\"],\"scope\":\"Contains Any\",\"attribute\":\"Docket\",\"proximity\":\"Anywhere\"}],\"criteria\":\"(0)\",\"filters\":[{\"filter_type\":\"filing_date\",\"field\":\"last_n_days\",\"theDate\":\"210\"},{\"filter_type\":\"jurisdiction\",\"field\":\"courthouse\",\"keys\":[478]},{\"filter_type\":\"case_type\",\"field\":\"name\",\"keys\":[105,124,128]}],\"search_id\":1451,\"search_name\":\"CMC Docket Search - 150 Days\"}}';
        SavedSearchParser obj = SavedSearchParser.parse(json);
        System.assert(obj != null);
    }
}