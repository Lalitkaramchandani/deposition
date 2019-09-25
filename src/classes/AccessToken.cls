/**************************************************
                Name        : AccessToken
                Author      : Rajendra Rathore
                Purpose     : That class are used to parse the reponse that are recived when we make request To Google Drive.
                Created Date: 25 March 2016
                
                Modification History:
*****************************************************/
public class AccessToken{
    public String access_token; 
    public String token_type;   //Bearer
    public Integer expires_in;  //3600
    public static AccessToken parse(String json){
        return (AccessToken) System.JSON.deserialize(json, AccessToken.class);
    }

}