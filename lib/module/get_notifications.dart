class GetNotifications{
  String noId;
  String theTitle;
  String theDetails;
  String theType;
  String typeId;

  GetNotifications({required this.noId, required this.theTitle, required this.theDetails, required this.theType, required this.typeId});

  GetNotifications.fromJson(Map json)
      : noId = json['noId'],
        theTitle = json['theTitle'],
        theDetails = json['theDetails'],
        theType = json['theType'],
        typeId = json['typeId'];

}