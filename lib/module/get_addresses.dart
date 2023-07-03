class GetAddresses{
  String adId;
  String fullName;
  String theTitle;
  String theArea;
  String theCity;
  String theCountry;
  String street;
  String mobileNumber;
  String addressDetails;

  GetAddresses({required this.adId, required this.fullName, required this.theTitle, required this.theArea, required this.theCity, required this.theCountry, required this.street, required this.mobileNumber, required this.addressDetails});

  GetAddresses.fromJson(Map json)
      : adId = json['adId'],
        fullName = json['fullName'],
        theTitle = json['theTitle'],
        theArea = json['theArea'],
        theCity = json['theCity'],
        theCountry = json['theCountry'],
        street = json['street'],
        mobileNumber = json['mobileNumber'],
        addressDetails = json['addressDetails'];

}