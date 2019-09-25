/**************************************************
                Name        : TestAccessToken
                Author      : Rajendra Rathore
                Purpose     : Test class for AccessToken Apex class
                Created Date: 10 JULY 2016
                
                Modification History:
*****************************************************/
@isTest
public class TestAccessToken{
  public Static String json= '{"access_token" : "ya29.CjMbAzXpjWp5l6EvO6zBRAnwmM4Aoho-I8LwRb4EXU9EzVlUwSSMzeE1LH74MxJNNxBznT4",'
                             + '         "token_type" : "Bearer",         "expires_in" : 3600}';
  @isTest
  private static void Test_AccessToken(){
      AccessToken.parse(json);
  }
}