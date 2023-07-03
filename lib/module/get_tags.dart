class GetTags{
  String optionId;
  String theTitle;

  GetTags({required this.optionId, required this.theTitle});

  GetTags.fromJson(Map json)
      : optionId = json['optionId'],
        theTitle = json['theTitle'];

}