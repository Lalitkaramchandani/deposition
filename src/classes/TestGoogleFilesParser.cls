/**************************************************
                Name        : TestGoogleFilesParser
                Author      : Rajendra Rathore
                Purpose     : Test class for GoogleFilesParser Apex class
                Created Date: 10 JULY 2016
                
                Modification History:
*****************************************************/
@isTest
public  class TestGoogleFilesParser{
  public static String json =      '{'+
        '   "kind": "drive#fileList",'+
        '   "etag": "",'+
        '   "selfLink": "https://www.googleapis.com/drive/v2/files?q=0B3EaxhqyEcP2WVp2OVRKR2ZaZ2s",'+
        '   "files": [{'+
        '"id": "string",'+
         '"name": "string"'+
        '   }],'+
        '   "items": [{'+
        '       "kind": "drive#file",'+
        '       "id": "0B3EaxhqyEcP2Y1RQcW1ReDN6VGs",'+
        '       "etag": "1TJQgR03e3kullTvmPoNa3p7rGU/MTQ2NzkzOTIyNjg2Mg",'+
        '       "selfLink": "https://www.googleapis.com/drive/v2/files/0B3EaxhqyEcP2Y1RQcW1ReDN6VGs",'+
        '       "webContentLink": "https://docs.google.com/a/nextgenreporting.com/uc?id=0B3EaxhqyEcP2Y1RQcW1ReDN6VGs&export=download",'+
        '       "alternateLink": "https://drive.google.com/a/nextgenreporting.com/file/d/0B3EaxhqyEcP2Y1RQcW1ReDN6VGs/view?usp=drivesdk",'+
        '       "embedLink": "https://video.google.com/get_player?ps=docs&partnerid=30&docid=0B3EaxhqyEcP2Y1RQcW1ReDN6VGs&BASE_URL=http://docs.google.com/",'+
        '       "iconLink": "https://ssl.gstatic.com/docs/doclist/images/icon_11_video_list.png",'+
        '       "thumbnailLink": "https://lh6.googleusercontent.com/4ATWuonxZdL6hWr9bopVCmAPN9UlRnQuQmNRtAofgzScff7Oh6Yd-2QJvwpfCTJpI4hdLg=s220",'+
        '       "title": "2016-36374+Harold+Pillsbury+1.mp4",'+
        '       "mimeType": "video/mp4",'+
        '       "createdDate": "2016-07-07T21:58:54.875Z",'+
        '       "modifiedDate": "2016-07-08T00:53:46.862Z",'+
        '       "modifiedByMeDate": "2016-07-07T21:58:54.875Z",'+
        '       "lastViewedByMeDate": "2016-07-08T15:29:49.859Z",'+
        '       "markedViewedByMeDate": "1970-01-01T00:00:00.000Z",'+
        '       "FileSize": 100'+
        ''+
        ''+
        '   }]'+
        ''+
        '}';
  @isTest
  private static void Test_GoogleFilesParser(){
      GoogleFilesParser.parse(json);
  }
}