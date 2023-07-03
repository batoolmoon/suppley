class GetNews{
  String neId;
  String theTitle;
  String thePhoto;

  GetNews({required this.neId, required this.theTitle, required this.thePhoto});

  GetNews.fromJson(Map json)
      : neId = json['neId'],
        theTitle = json['theTitle'],
        thePhoto = json['thePhoto'];

}