class GetCart{

  String orId;
  String selectedQuantity;
  String productTitle;
  String priceSizeTitle;
  String theDiscount;
  String thePrice;
  String thePhoto;
  String productAvailableQuantity;
  String minCount;
  String theNote;
  String symbol;
  String categoryTitle;
  String storeName;
  String optionTitle;



  GetCart({required this.orId, required this.selectedQuantity, required this.productTitle, required this.thePrice, required this.theDiscount, required this.thePhoto, required this.productAvailableQuantity, required this.theNote, required this.minCount, required this.symbol, required this.categoryTitle,  required this.priceSizeTitle, required this.storeName,required this.optionTitle});

  GetCart.fromJson(Map json)
      : orId = json['orId'],
        selectedQuantity = json['selectedQuantity'],
        productTitle = json['productTitle'],
        thePrice = json['thePrice'],
        theDiscount = json['theDiscount'],
        thePhoto = json['thePhoto'],
        productAvailableQuantity = json['productAvailableQuantity'],
        theNote = json['theNote'],
        minCount = json['minCount'],
        symbol = json['symbol'],
        categoryTitle = json['categoryTitle'],
        //categoryProfit = json['categoryProfit'],
        priceSizeTitle = json['priceSizeTitle'],
        storeName = json['storeName'],
        optionTitle=json["optionTitle"];
        //tagTitle = json['tagTitle'];

}