class GetProducts{
  String prId;
  String theTitle;
  String priceId;
  String categoryId;
  String rateCount;
  String theRate;
  String thePrice;
  String theDiscount;
  String minCount;
  String thePhoto;
  String isOffer;
  String offerExpiryDate;
  String symbol;
  String categoryTitle;
  String storeId;
  String storeName;
  String isFav;

  GetProducts({required this.prId, required this.theTitle, required this.priceId, required this.thePrice, required this.theDiscount, required this.thePhoto, required this.symbol, required this.categoryTitle, required this.rateCount, required this.theRate, required this.isOffer, required this.offerExpiryDate, required this.storeName, required this.storeId,required this.categoryId,required this.minCount,required this.isFav});

  GetProducts.fromJson(Map json)
      : prId = json['prId'],
        theTitle = json['theTitle'],
        priceId = json['priceId'],
        thePrice = json['thePrice'],
        theDiscount = json['theDiscount'],
        thePhoto = json['thePhoto'],
        symbol = json['symbol'],
        categoryTitle = json['categoryTitle'],
        rateCount = json['rateCount'],
        theRate = json['theRate'],
        isOffer = json['isOffer'],
        offerExpiryDate = json['offerExpiryDate'],
        storeName = json['storeName'],
        storeId = json['storeId'],
        categoryId = json['categoryId'],
        isFav= json['isFav'],
        minCount = json['minCount'];

}