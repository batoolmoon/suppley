class GetFavourite{
  String faId;
  String prId;
  String theTitle;
  String priceId;
  String thePrice;
  String theDiscount;
  String thePhoto;
  String symbol;
  String categoryTitle;
 // String categoryProfit;
  String rateCount;
  String theRate;
  String isOffer;
  String offerExpiryDate;
  String storeId;
  String storeName;
  String isFav;
  GetFavourite({required this.faId, required this.prId, required this.theTitle, required this.priceId, required this.thePrice, required this.theDiscount, required this.thePhoto, required this.symbol, required this.categoryTitle/*, required this.categoryProfit*/, required this.rateCount, required this.theRate, required this.isOffer, required this.offerExpiryDate, required this.storeId, required this.storeName , required this.isFav});

  GetFavourite.fromJson(Map json)
      : faId = json['faId'],
        prId = json['prId'],
        theTitle = json['theTitle'],
        priceId = json['priceId'],
        thePrice = json['thePrice'],
        theDiscount = json['theDiscount'],
        thePhoto = json['thePhoto'],
        symbol = json['symbol'],
        categoryTitle = json['categoryTitle'],
        //categoryProfit = json['categoryProfit'],
        rateCount = json['rateCount'],
        theRate = json['theRate'],
        isOffer = json['isOffer'],
        offerExpiryDate = json['offerExpiryDate'],
        storeId = json['storeId'],
        storeName = json['storeName'],
         isFav= json['isFav'];

}