@IsTest
public class AccConMatchParserTest {
	
	static testMethod void testParse() {
		String json = '{\"webhook_type\": \"Lexitas_Account_Match\", \"industry\": \"Law Firm\", \"data_delivery_date\": \"2019-02-04\", \"case_from_filing_date\": \"20181129\", \"case_to_filing_date\": \"20181206\", \"csv_file_link\": \"https://s3.amazonaws.com/codaxtr.misc/codaxtr-central/production/nextgen/client_data/2019-02-04/UC_Lexitas_Account_Federal_Match_20181129_to_20181206.csv?AWSAccessKeyId=ASIA3CVJQ3EFAZQ5PG7Q&Signature=2PsLVZHdhZ2kMQ5MCUibS0hNifc%3D&x-amz-security-token=FQoGZXIvYXdzEJ3%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEaDCQaqDJFgOuru9O%2FKiK3AyymvkXoeHmueF4jsFLX5pQIt6ezqvqAqEKkaZJaZ9aX8RPBYv1xlIvJL9szV%2BiIVga2ACR40Fv1AL2wTzqafoC2nAIQkOMTQfYj9j26GPm6zq7ozPR1YnL7G9ilx7oVIJ61%2FThgKJ52Jnm9DvesHOTXZVAZfuc6iEo3EJvbNvrgyDix8zRH4xfGF71fsQr3esvNQgctEjqOfvI9XxR2CB%2FJoP4zFJ%2FAN9lAomUy555qNO2Mwig6Yad%2Br%2FLpkmOx3X86DS0EdwL9lmgbr7O2tgiNl6eH21LKY5sqh7MHSRY%2F1N%2BxG6wU%2F%2BGFl7rSjQ3A%2F1pd%2BHVauVvrA0WZc%2FF8s3dCZGvL%2FcEAb4M7kD4zv6AJJcMpizhmMqYBdLrhXRlSxEXHnBFIKtOIoqrQ5y%2FEEmaphRwNdN3on0KA4zndUd4Zc2L9BhC5gs4mfjw7SQvNfVc0SIak8nYmfNazzxchlScsMwgud7mQv%2BBydcC51JHxJyeNVLMV89W6gRrU%2B9IsYZ9Kl93MclucQyK6zLWqBsjkJxcn0Iaoc7GZs2pEADmqiujH9TCxpbTl7gTttyKVGK5SkIqrOVko0ePe4gU%3D&Expires=1549258011\", \"jurisdiction\": [\"pacer\"]}';
		AccConMatchParser obj = AccConMatchParser.parse(json);
		System.assert(obj != null);
	}
}