class GetOrderProducts{

  late String orId;
  late String prId;
  late String theTitle;
  late String priceSizeTitle; // for order details
  late String totalPrice; // for order details
  late String totalProfit; // for order details
  late String priceId;
  late String thePrice;
  late String theDiscount;
  late String thePhoto;
  late String symbol = '0.0';
  late String currencyExchange = '0.0'; // for order details
  late String selectedQuantity; // for order details
  late String categoryTitle;
  late String rateCount;
  late String theRate;
  late String isOffer;
  late String offerExpiryDate;
  late String isFav;
 late String optionTitle;

  GetOrderProducts({required this.orId,required this.prId, required this.theTitle, required this.priceSizeTitle, required this.totalPrice, required this.totalProfit, required this.priceId, required this.thePrice, required this.theDiscount, required this.thePhoto, required this.symbol, required this.currencyExchange, required this.selectedQuantity,required this.categoryTitle ,required this.rateCount, required this.theRate, required this.isOffer, required this.offerExpiryDate,required this.isFav ,required this.optionTitle});

  GetOrderProducts.fromJson(Map json)
      : prId = json['prId'],
        orId = json['orId'],
        theTitle = json['theTitle'],
        priceSizeTitle = json['priceSizeTitle'],
        totalPrice = json['totalPrice'],
        totalProfit = json['totalProfit'],
        priceId = json['priceId'],
        thePrice = json['thePrice'],
        theDiscount = json['theDiscount'],
        thePhoto = json['thePhoto'],
        symbol = json['symbol'],
        currencyExchange = json['currencyExchange'],
        selectedQuantity = json['selectedQuantity'],
        categoryTitle = json['categoryTitle'],
        rateCount = json['rateCount'],
        theRate = json['theRate'],
        isOffer = json['isOffer'],
        offerExpiryDate = json['offerExpiryDate'],
         isFav=json['isFav'],
      optionTitle = json['optionTitle'];

}