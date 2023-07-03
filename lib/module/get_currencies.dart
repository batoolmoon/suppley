class GetCurrencies{
  String cuId;
  String theTitle;
  String symbol;
  String dollarToCur;

  GetCurrencies({required this.cuId, required this.theTitle, required this.symbol, required this.dollarToCur});

  GetCurrencies.fromJson(Map json)
      : cuId = json['cuId'],
        theTitle = json['theTitle'],
        symbol = json['symbol'],
        dollarToCur = json['dollarToCur'];

}