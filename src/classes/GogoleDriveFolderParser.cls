public class GogoleDriveFolderParser{
    public String id;   //0B3EaxhqyEcP2WGZGX0tfQ0xvMW8
    public String downloadUrl;
    public static GogoleDriveFolderParser parse(String json){
        return (GogoleDriveFolderParser) System.JSON.deserialize(json, GogoleDriveFolderParser.class);
    }

    /*static testMethod void testParse() {
        String json=        '{'+
        ' "kind": "drive#file",'+
        ' "id": "0B3EaxhqyEcP2WGZGX0tfQ0xvMW8",'+
        ' "etag": "\"3GjDSTzy841RsmcBo4Ir-DLlp20/MTQ4NjIxMTI1MDEwNg\"",'+
        ' "selfLink": "https://www.googleapis.com/drive/v2/files/0B3EaxhqyEcP2WGZGX0tfQ0xvMW8",'+
        ' "alternateLink": "https://drive.google.com/drive/folders/0B3EaxhqyEcP2WGZGX0tfQ0xvMW8",'+
        ' "embedLink": "https://drive.google.com/embeddedfolderview?id=0B3EaxhqyEcP2WGZGX0tfQ0xvMW8",'+
        ' "iconLink": "https://ssl.gstatic.com/docs/doclist/images/icon_11_collection_list_1.png",'+
        ' "title": "SFDCFolderIDGoogleDrive",'+
        ' "mimeType": "application/vnd.google-apps.folder",'+
        ' "labels": {'+
        '  "starred": false,'+
        '  "hidden": false,'+
        '  "trashed": false,'+
        '  "restricted": false,'+
        '  "viewed": true'+
        ' },'+
        ' "createdDate": "2017-02-04T12:27:30.106Z",'+
        ' "modifiedDate": "2017-02-04T12:27:30.106Z",'+
        ' "modifiedByMeDate": "2017-02-04T12:27:30.106Z",'+
        ' "lastViewedByMeDate": "2017-02-04T12:27:30.106Z",'+
        ' "markedViewedByMeDate": "1970-01-01T00:00:00.000Z",'+
        ' "version": "2377007",'+
        ' "parents": ['+
        '  {'+
        '   "kind": "drive#parentReference",'+
        '   "id": "0AHEaxhqyEcP2Uk9PVA",'+
        '   "selfLink": "https://www.googleapis.com/drive/v2/files/0B3EaxhqyEcP2WGZGX0tfQ0xvMW8/parents/0AHEaxhqyEcP2Uk9PVA",'+
        '   "parentLink": "https://www.googleapis.com/drive/v2/files/0AHEaxhqyEcP2Uk9PVA",'+
        '   "isRoot": true'+
        '  }'+
        ' ],'+
        ' "userPermission": {'+
        '  "kind": "drive#permission",'+
        '  "etag": "\"3GjDSTzy841RsmcBo4Ir-DLlp20/WGuID6Q6X6aghiht6zdQe6r6JVY\"",'+
        '  "id": "me",'+
        '  "selfLink": "https://www.googleapis.com/drive/v2/files/0B3EaxhqyEcP2WGZGX0tfQ0xvMW8/permissions/me",'+
        '  "role": "owner",'+
        '  "type": "user"'+
        ' },'+
        ' "quotaBytesUsed": "0",'+
        ' "ownerNames": ['+
        '  "Jason Primuth"'+
        ' ],'+
        ' "owners": ['+
        '  {'+
        '   "kind": "drive#user",'+
        '   "displayName": "Jason Primuth",'+
        '   "isAuthenticatedUser": true,'+
        '   "permissionId": "16144978477857669596",'+
        '   "emailAddress": "gdrive@nextgenreporting.com"'+
        '  }'+
        ' ],'+
        ' "lastModifyingUserName": "Jason Primuth",'+
        ' "lastModifyingUser": {'+
        '  "kind": "drive#user",'+
        '  "displayName": "Jason Primuth",'+
        '  "isAuthenticatedUser": true,'+
        '  "permissionId": "16144978477857669596",'+
        '  "emailAddress": "gdrive@nextgenreporting.com"'+
        ' },'+
        ' "editable": true,'+
        ' "copyable": false,'+
        ' "writersCanShare": true,'+
        ' "shared": false,'+
        ' "explicitlyTrashed": false,'+
        ' "appDataContents": false,'+
        ' "spaces": ['+
        '  "drive"'+
        ' ]'+
        '}';
        fromJSON obj = parse(json);
        System.assert(obj != null);
    }*/
}