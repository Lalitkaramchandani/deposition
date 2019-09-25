@isTest
private class ContactAndAccountsMatchWebhookCntrlTest {
	
	@isTest 
	static void test_ContactAndAccountsMatch() {
		String data = '{"webhook_type": "Lexitas_Contact_Account_Match", "industry": "Law Firm", "data_delivery_date": "2019-05-06", "case_from_filing_date": "20190228", "case_to_filing_date": "20190307", "csv_file_link": "https://s3.amazonaws.com/codaxtr.misc/codaxtr-central/production/nextgen/client_data/2019-05-06/UC_Lexitas_Contact_Account_Federal_Match_20190228_to_20190307.csv?AWSAccessKeyId=ASIA3CVJQ3EFHUHEIRXP&Signature=ZwzrAMYWPo7%2BMVAGtjcs%2FAnwvF4%3D&x-amz-security-token=AgoJb3JpZ2luX2VjEBQaCXVzLWVhc3QtMSJGMEQCIEvBJd4dBSgk0iK2e66dcakOT6qldeeJ7Am3Om59jSyeAiArn70e0JbLvV0sCRxwcDe8wmXZrnV%2FT4dndfMCkAXMHSrjAwj9%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F8BEAAaDDc2MTYzODQ3NjA0MiIMJ21AnkjvJc%2Bn8QehKrcDWOB1bSzvMx5WxP50WWQYMHwpECIO9MTSIemYlFDc4wWBhRFjqU51KQN9kci8oM1VUvrP7f1pwUFB7eQ%2ByAvaHsID%2B4%2Ft5ck6NXALNf%2FXR3kbYGASdvKgpHzDf%2BcNExlv4ICXHsH2ACMJTNXcIR%2B0HqDNR4WqnFQAbFy4f4yCy%2F4v6QPP4jF2KYI112AGXa4IpXHXWsANlmHlJMSVkrtda0V8jojbRhzZwhdpPs84Qc4BFujX1%2Bx1nVloBhm3A06cCkgV8FkWSynxV2zUaKOljlFjnR0gu54NEsBTJsgGkYEdaUkEjfJopdtoiauWYrK44yNPaYDIVGuPMeWxXrQ8dXPJAWYBIQfQdBanxL81k5bi8CE0lSXfbyi37E3NvYm56VLLjJ5Kbja2eZvyHXNNpDNxX2lZ1%2F2DctWtfORI3Cij%2BhKWPC%2FdUNhI3nRsWNBo1cfEQy3g%2B8WeUcOAErhCLPokXOaMayOLJhK5Esy41DfU7Md4x%2B9ApWTHAHXna4FGrcSyFfTI7V5%2BeLjU8%2FP5aaxGtGuRX2pwdL5JomuML3pWFsAyEV2hAXBejSUXUg%2FaM52%2BkOgrtjDR1L7mBTq1AeaiP9LlF9ePyjt%2Ffob8prDs1eN8MHLzyV%2BnADV76OUK57wGZ0mDo5Bw4YO4QUB4dMmsavXPv9epSod5umb8azyg2GMYk5SVMWroIndjZIM7pMoXsVn9S1gGcCSW2Q0SROSI%2FRl8XuWlX831w1GFe8Q6qW0cEnvt04y7vfxOHCS6DzdQoLBwoLPMpCAW3q48L8a3spQillSR%2B1XbRA%2BOUpaDkDIzsU%2BjeZiT%2B5m3gy9u52wg73o%3D&Expires=1557117962", "jurisdiction": ["pacer"]}';
		ContactAndAccountsMatchWebhookCntrl ctlr = new ContactAndAccountsMatchWebhookCntrl();
		PageReference pg = Page.ContactAndAccountsMatchWebhook;
		Test.setCurrentPage(pg);
		pg.getParameters().put('data',data);
		Test.setMock(HttpCalloutMock.class, new ContactAccountMatchCalloutMock(200, 'Ok'));
		Test.startTest();
		ctlr.init();
		Test.stopTest();
	    List<Unicourt_Case_Lead_JSON__c> csvRecList = [select id, JSON_String__c, Is_Processed__c from Unicourt_Case_Lead_JSON__c];
	    System.assert(csvRecList.size() > 0);
	    List<Case_Leads__c> caseList = [select id from Case_Leads__c];
	   // System.assert(caseList.size() > 0);
	}

	@isTest 
	static void test_ContactAndAccountsMatchWithExcptn() {
		String data = '{"webhook_type": "Lexitas_Contact_Account_Match", "industry": "Law Firm", "data_delivery_date": "2019-05-06", "case_from_filing_date": "20190228", "case_to_filing_date": "20190307", "csv_file_link": "https://s3.amazonaws.com/codaxtr.misc/codaxtr-central/production/nextgen/client_data/2019-05-06/UC_Lexitas_Contact_Account_Federal_Match_20190228_to_20190307.csv?AWSAccessKeyId=ASIA3CVJQ3EFHUHEIRXP&Signature=ZwzrAMYWPo7%2BMVAGtjcs%2FAnwvF4%3D&x-amz-security-token=AgoJb3JpZ2luX2VjEBQaCXVzLWVhc3QtMSJGMEQCIEvBJd4dBSgk0iK2e66dcakOT6qldeeJ7Am3Om59jSyeAiArn70e0JbLvV0sCRxwcDe8wmXZrnV%2FT4dndfMCkAXMHSrjAwj9%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F8BEAAaDDc2MTYzODQ3NjA0MiIMJ21AnkjvJc%2Bn8QehKrcDWOB1bSzvMx5WxP50WWQYMHwpECIO9MTSIemYlFDc4wWBhRFjqU51KQN9kci8oM1VUvrP7f1pwUFB7eQ%2ByAvaHsID%2B4%2Ft5ck6NXALNf%2FXR3kbYGASdvKgpHzDf%2BcNExlv4ICXHsH2ACMJTNXcIR%2B0HqDNR4WqnFQAbFy4f4yCy%2F4v6QPP4jF2KYI112AGXa4IpXHXWsANlmHlJMSVkrtda0V8jojbRhzZwhdpPs84Qc4BFujX1%2Bx1nVloBhm3A06cCkgV8FkWSynxV2zUaKOljlFjnR0gu54NEsBTJsgGkYEdaUkEjfJopdtoiauWYrK44yNPaYDIVGuPMeWxXrQ8dXPJAWYBIQfQdBanxL81k5bi8CE0lSXfbyi37E3NvYm56VLLjJ5Kbja2eZvyHXNNpDNxX2lZ1%2F2DctWtfORI3Cij%2BhKWPC%2FdUNhI3nRsWNBo1cfEQy3g%2B8WeUcOAErhCLPokXOaMayOLJhK5Esy41DfU7Md4x%2B9ApWTHAHXna4FGrcSyFfTI7V5%2BeLjU8%2FP5aaxGtGuRX2pwdL5JomuML3pWFsAyEV2hAXBejSUXUg%2FaM52%2BkOgrtjDR1L7mBTq1AeaiP9LlF9ePyjt%2Ffob8prDs1eN8MHLzyV%2BnADV76OUK57wGZ0mDo5Bw4YO4QUB4dMmsavXPv9epSod5umb8azyg2GMYk5SVMWroIndjZIM7pMoXsVn9S1gGcCSW2Q0SROSI%2FRl8XuWlX831w1GFe8Q6qW0cEnvt04y7vfxOHCS6DzdQoLBwoLPMpCAW3q48L8a3spQillSR%2B1XbRA%2BOUpaDkDIzsU%2BjeZiT%2B5m3gy9u52wg73o%3D&Expires=1557117962", "jurisdiction": ["pacer"]}';
		ContactAndAccountsMatchWebhookCntrl ctlr = new ContactAndAccountsMatchWebhookCntrl();
		PageReference pg = Page.ContactAndAccountsMatchWebhook;
		Test.setCurrentPage(pg);
		pg.getParameters().put('data',data);
		// Test.setMock(HttpCalloutMock.class, new ContactAccountMatchCalloutMock(200, 'Ok'));
		Test.startTest();
		ctlr.init();
		Test.stopTest();
	     List<Webhook_Log__c> wList = [select id from Webhook_Log__c];
	    System.assert(wList.size() > 0);
	}
	
	@isTest 
	static void test_AccountOnlyMatch() {
		String data = '{"webhook_type": "Lexitas_Contact_Account_Match", "industry": "Law Firm", "data_delivery_date": "2019-05-06", "case_from_filing_date": "20190228", "case_to_filing_date": "20190307", "csv_file_link": "https://s3.amazonaws.com/codaxtr.misc/codaxtr-central/production/nextgen/client_data/2019-05-06/UC_Lexitas_Contact_Account_Federal_Match_20190228_to_20190307.csv?AWSAccessKeyId=ASIA3CVJQ3EFHUHEIRXP&Signature=ZwzrAMYWPo7%2BMVAGtjcs%2FAnwvF4%3D&x-amz-security-token=AgoJb3JpZ2luX2VjEBQaCXVzLWVhc3QtMSJGMEQCIEvBJd4dBSgk0iK2e66dcakOT6qldeeJ7Am3Om59jSyeAiArn70e0JbLvV0sCRxwcDe8wmXZrnV%2FT4dndfMCkAXMHSrjAwj9%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F8BEAAaDDc2MTYzODQ3NjA0MiIMJ21AnkjvJc%2Bn8QehKrcDWOB1bSzvMx5WxP50WWQYMHwpECIO9MTSIemYlFDc4wWBhRFjqU51KQN9kci8oM1VUvrP7f1pwUFB7eQ%2ByAvaHsID%2B4%2Ft5ck6NXALNf%2FXR3kbYGASdvKgpHzDf%2BcNExlv4ICXHsH2ACMJTNXcIR%2B0HqDNR4WqnFQAbFy4f4yCy%2F4v6QPP4jF2KYI112AGXa4IpXHXWsANlmHlJMSVkrtda0V8jojbRhzZwhdpPs84Qc4BFujX1%2Bx1nVloBhm3A06cCkgV8FkWSynxV2zUaKOljlFjnR0gu54NEsBTJsgGkYEdaUkEjfJopdtoiauWYrK44yNPaYDIVGuPMeWxXrQ8dXPJAWYBIQfQdBanxL81k5bi8CE0lSXfbyi37E3NvYm56VLLjJ5Kbja2eZvyHXNNpDNxX2lZ1%2F2DctWtfORI3Cij%2BhKWPC%2FdUNhI3nRsWNBo1cfEQy3g%2B8WeUcOAErhCLPokXOaMayOLJhK5Esy41DfU7Md4x%2B9ApWTHAHXna4FGrcSyFfTI7V5%2BeLjU8%2FP5aaxGtGuRX2pwdL5JomuML3pWFsAyEV2hAXBejSUXUg%2FaM52%2BkOgrtjDR1L7mBTq1AeaiP9LlF9ePyjt%2Ffob8prDs1eN8MHLzyV%2BnADV76OUK57wGZ0mDo5Bw4YO4QUB4dMmsavXPv9epSod5umb8azyg2GMYk5SVMWroIndjZIM7pMoXsVn9S1gGcCSW2Q0SROSI%2FRl8XuWlX831w1GFe8Q6qW0cEnvt04y7vfxOHCS6DzdQoLBwoLPMpCAW3q48L8a3spQillSR%2B1XbRA%2BOUpaDkDIzsU%2BjeZiT%2B5m3gy9u52wg73o%3D&Expires=1557117962", "jurisdiction": ["pacer"]}';
		AccountsMatchOnlyWebhookCntrl ctlr = new AccountsMatchOnlyWebhookCntrl();
		PageReference pg = Page.AccountsMatchOnlyWebhook;
		Test.setCurrentPage(pg);
		pg.getParameters().put('data',data);
		Test.setMock(HttpCalloutMock.class, new ContactAccountMatchCalloutMock(200, 'Ok'));
		Test.startTest();
		ctlr.init();
		Test.stopTest();
		List<Unicourt_Case_Lead_JSON__c> csvRecList = [select id, JSON_String__c, Is_Processed__c from Unicourt_Case_Lead_JSON__c];
	    System.assert(csvRecList.size() > 0);
	    List<Case_Leads__c> caseList = [select id from Case_Leads__c];
	   // System.assert(caseList.size() > 0);
	}
	@isTest 
	static void test_AccountOnlyMatchWithException() {
		String data = '{"webhook_type": "Lexitas_Contact_Account_Match", "industry": "Law Firm", "data_delivery_date": "2019-05-06", "case_from_filing_date": "20190228", "case_to_filing_date": "20190307", "csv_file_link": "https://s3.amazonaws.com/codaxtr.misc/codaxtr-central/production/nextgen/client_data/2019-05-06/UC_Lexitas_Contact_Account_Federal_Match_20190228_to_20190307.csv?AWSAccessKeyId=ASIA3CVJQ3EFHUHEIRXP&Signature=ZwzrAMYWPo7%2BMVAGtjcs%2FAnwvF4%3D&x-amz-security-token=AgoJb3JpZ2luX2VjEBQaCXVzLWVhc3QtMSJGMEQCIEvBJd4dBSgk0iK2e66dcakOT6qldeeJ7Am3Om59jSyeAiArn70e0JbLvV0sCRxwcDe8wmXZrnV%2FT4dndfMCkAXMHSrjAwj9%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F8BEAAaDDc2MTYzODQ3NjA0MiIMJ21AnkjvJc%2Bn8QehKrcDWOB1bSzvMx5WxP50WWQYMHwpECIO9MTSIemYlFDc4wWBhRFjqU51KQN9kci8oM1VUvrP7f1pwUFB7eQ%2ByAvaHsID%2B4%2Ft5ck6NXALNf%2FXR3kbYGASdvKgpHzDf%2BcNExlv4ICXHsH2ACMJTNXcIR%2B0HqDNR4WqnFQAbFy4f4yCy%2F4v6QPP4jF2KYI112AGXa4IpXHXWsANlmHlJMSVkrtda0V8jojbRhzZwhdpPs84Qc4BFujX1%2Bx1nVloBhm3A06cCkgV8FkWSynxV2zUaKOljlFjnR0gu54NEsBTJsgGkYEdaUkEjfJopdtoiauWYrK44yNPaYDIVGuPMeWxXrQ8dXPJAWYBIQfQdBanxL81k5bi8CE0lSXfbyi37E3NvYm56VLLjJ5Kbja2eZvyHXNNpDNxX2lZ1%2F2DctWtfORI3Cij%2BhKWPC%2FdUNhI3nRsWNBo1cfEQy3g%2B8WeUcOAErhCLPokXOaMayOLJhK5Esy41DfU7Md4x%2B9ApWTHAHXna4FGrcSyFfTI7V5%2BeLjU8%2FP5aaxGtGuRX2pwdL5JomuML3pWFsAyEV2hAXBejSUXUg%2FaM52%2BkOgrtjDR1L7mBTq1AeaiP9LlF9ePyjt%2Ffob8prDs1eN8MHLzyV%2BnADV76OUK57wGZ0mDo5Bw4YO4QUB4dMmsavXPv9epSod5umb8azyg2GMYk5SVMWroIndjZIM7pMoXsVn9S1gGcCSW2Q0SROSI%2FRl8XuWlX831w1GFe8Q6qW0cEnvt04y7vfxOHCS6DzdQoLBwoLPMpCAW3q48L8a3spQillSR%2B1XbRA%2BOUpaDkDIzsU%2BjeZiT%2B5m3gy9u52wg73o%3D&Expires=1557117962", "jurisdiction": ["pacer"]}';
		AccountsMatchOnlyWebhookCntrl ctlr = new AccountsMatchOnlyWebhookCntrl();
		PageReference pg = Page.AccountsMatchOnlyWebhook;
		Test.setCurrentPage(pg);
		pg.getParameters().put('data',data);
		//Test.setMock(HttpCalloutMock.class, new ContactAccountMatchCalloutMock(200, 'Ok'));
		Test.startTest();
		ctlr.init();
		Test.stopTest();
		
	    List<Webhook_Log__c> wList = [select id from Webhook_Log__c];
	    System.assert(wList.size() > 0);
	}
	
}