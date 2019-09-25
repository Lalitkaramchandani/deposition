/**************************************************
                Name        : GoogleFilesParser
                Author      : Rajendra Rathore
                Purpose     : That class are used to parse the result of Google Drive Files
                Created Date: 30 March 2016
                
                Modification History:
*****************************************************/
public class GoogleFilesParser{
    public string nextPageToken;
    public String kind; //drive#fileList
    public String etag; //"rCKCAyesbPCaBxGt0eDJcEBQNUI/PuDNsKWQ3McXQusW5JUSWdZXKeU"
    public String selfLink; //https://www.googleapis.com/drive/v2/files?q='0B3EaxhqyEcP2MDNIMzVEV21mUnc'+in+parents
    public cls_items[] items;
    public cls_items[] files;
    public class cls_items {
        public String kind; //drive#file
        public String id;   //0B3EaxhqyEcP2ZGgtVnJ1dFNXcEU
        public String etag; //"rCKCAyesbPCaBxGt0eDJcEBQNUI/MTQ1OTMzOTQ4MDA2MQ"
        public String selfLink; //https://www.googleapis.com/drive/v2/files/0B3EaxhqyEcP2ZGgtVnJ1dFNXcEU
        public String webContentLink;   //https://docs.google.com/a/nextgenreporting.com/uc?id=0B3EaxhqyEcP2ZGgtVnJ1dFNXcEU&export=download
        public String alternateLink;    //https://drive.google.com/a/nextgenreporting.com/file/d/0B3EaxhqyEcP2ZGgtVnJ1dFNXcEU/view?usp=drivesdk
        public String iconLink; //https://ssl.gstatic.com/docs/doclist/images/icon_11_image_list.png
        public String thumbnailLink;    //https://lh6.googleusercontent.com/VuMmz0-fnTMFSJiDB4lI79bLSyPoIkgG6GQoZ7O4B63hvaLb87Wi0juUI8D9VAAWyHGs1g=s220
        public String title;    //0.png
        public String mimeType; //image/png
        public cls_labels labels;
        public datetime createdDate;  //2016-03-30T12:04:40.061Z
        public datetime modifiedDate; //2016-03-30T12:04:40.061Z
        public String modifiedByMeDate; //2016-03-30T12:04:40.061Z
        public String lastViewedByMeDate;   //2016-03-30T12:04:40.061Z
        public String markedViewedByMeDate; //1970-01-01T00:00:00.000Z
        public String version;  //4152
        public cls_parents[] parents;
        public String downloadUrl;  //https://doc-0o-68-docs.googleusercontent.com/docs/securesc/e09o97lk5m7c2sug1d3iutjtmt7nfb4n/kbqruk0rgq5rl5gjsv3kmloem1iamve2/1459339200000/16144978477857669596/16144978477857669596/0B3EaxhqyEcP2ZGgtVnJ1dFNXcEU?h=16056914147552979921&e=download&gd=true
        public string name;
        public String originalFilename; //0.png
        public String fileExtension;    //png
        public String md5Checksum;  //ddeef4f18d5338a1e36f33bffd5b2e77
        public String fileSize; //277
        public String quotaBytesUsed;   //277
        
        public cls_owners[] owners;
        public String lastModifyingUserName;    //Jason Primuth
        public cls_lastModifyingUser lastModifyingUser;
        public boolean editable;
        public boolean copyable;
        public boolean writersCanShare;
        public boolean shared;
        public boolean explicitlyTrashed;
        public boolean appDataContents;
        public String headRevisionId;   //0B3EaxhqyEcP2bzFidmIwb2R5Z2l2eVp1bWdtZnpCc1NkdUtzPQ
        
        
    }
    class cls_labels {
        public boolean starred;
        public boolean hidden;
        public boolean trashed;
        public boolean restricted;
        public boolean viewed;
    }
    class cls_parents {
        public String kind; //drive#parentReference
        public String id;   //0B3EaxhqyEcP2MDNIMzVEV21mUnc
        public String selfLink; //https://www.googleapis.com/drive/v2/files/0B3EaxhqyEcP2ZGgtVnJ1dFNXcEU/parents/0B3EaxhqyEcP2MDNIMzVEV21mUnc
        public String parentLink;   //https://www.googleapis.com/drive/v2/files/0B3EaxhqyEcP2MDNIMzVEV21mUnc
        public boolean isRoot;
    }
    
    public class cls_owners {
        public String kind; //drive#user
        public String displayName;  //Jason Primuth
        public boolean isAuthenticatedUser;
        public String permissionId; //16144978477857669596
        public String emailAddress; //gdrive@nextgenreporting.com
    }
    class cls_lastModifyingUser {
        public String kind; //drive#user
        public String displayName;  //Jason Primuth
        public boolean isAuthenticatedUser;
        public String permissionId; //16144978477857669596
        public String emailAddress; //gdrive@nextgenreporting.com
    }
    class cls_imageMediaMetadata {
        public Integer width;   //26
        public Integer height;  //16
        public Integer rotation;    //0
    }
    
    public static GoogleFilesParser parse(String json){
        return (GoogleFilesParser) System.JSON.deserialize(json, GoogleFilesParser.class);
    }

    
}