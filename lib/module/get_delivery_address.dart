class GetDeliveryAddresses{
  String adId;
  String fullName;
  String theTitle;
  String theCity;
  String theCountry;
  String street;
  String mobileNumber;
  String addressDetails;
  String shippingPrice;

  GetDeliveryAddresses({required this.adId, required this.fullName, required this.theTitle, required this.theCity, required this.theCountry, required this.street, required this.mobileNumber, required this.addressDetails, required this.shippingPrice});

  GetDeliveryAddresses.fromJson(Map json)
      : adId = json['adId'],
        fullName = json['fullName'],
        theTitle = json['theTitle'],
        theCity = json['theCity'],
        theCountry = json['theCountry'],
        street = json['street'],
        mobileNumber = json['mobileNumber'],
        addressDetails = json['addressDetails'],
        shippingPrice = json['shippingPrice'];

}