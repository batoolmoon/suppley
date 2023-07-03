class GetTransferMethods{
  String paId;
  String title1;
  String theValue;
  String theValue2;

  GetTransferMethods({required this.paId, required this.title1, required this.theValue, required this.theValue2});

  GetTransferMethods.fromJson(Map json)
      : paId = json['paId'],
        title1 = json['title1'],
        theValue = json['theValue'],
        theValue2 = json['theValue2'];

}