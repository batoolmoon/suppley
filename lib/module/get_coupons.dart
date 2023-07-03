class GetCoupons{
  String theTitle;
  String theCode;
  String amount;
  String endDate;
  String theType;
  String storeName;

  GetCoupons({required this.theTitle, required this.theCode, required this.amount, required this.endDate, required this.theType, required this.storeName});

  GetCoupons.fromJson(Map json)
      : theTitle = json['theTitle'],
        theCode = json['theCode'],
        amount = json['amount'],
        endDate = json['endDate'],
        theType = json['theType'],
        storeName = json['storeName'];

}