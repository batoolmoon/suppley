

class GetStores{
  String stId;
  String storeName;
  String thePhoto;
  String isClosed;
   String theType;
  GetStores({required this.stId, required this.storeName, required this.thePhoto, required this.isClosed ,required this.theType });

  GetStores.fromJson(Map json)
      : stId = json['stId'],
        storeName = json['storeName'],
        thePhoto = json['thePhoto'],
        isClosed = json['isClosed'],
        theType  =   json['theType'];

}