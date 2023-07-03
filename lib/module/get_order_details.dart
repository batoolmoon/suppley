class GetOrderDetails{
  String prId;
  String productTitle;
  String selectedQuantity;
  String thePrice;
  String theDiscount;
  String thePhoto;
  String symbol;
  String currencyExchange;
  String priceSizeTitle;


  GetOrderDetails({required this.prId, required this.productTitle, required this.selectedQuantity, required this.thePrice, required this.theDiscount, required this.thePhoto, required this.symbol, required this.currencyExchange, required this.priceSizeTitle});

  GetOrderDetails.fromJson(Map json)
      : prId = json['prId'],
        productTitle = json['productTitle'],
        selectedQuantity = json['selectedQuantity'],
        thePrice = json['thePrice'],
        theDiscount = json['theDiscount'],
        thePhoto = json['thePhoto'],
        symbol = json['symbol'],
        currencyExchange = json['currencyExchange'],
        priceSizeTitle = json['priceSizeTitle'];


}