class GetOrders{
  String orId;
  String ordersTotalPrice;
  String ordersTotalProfit;
  String shippingPrice;
  String deliveredStatus;
  String shippingNumber;
  String tax;
  String invoiceNumber;
  String theDateTime;
  String paymentMethod;
  String symbol;
  String amount;
  String theCode;
  String couponType;
  String storeName;

  GetOrders({required this.orId, required this.ordersTotalPrice, required this.ordersTotalProfit, required this.shippingPrice, required this.deliveredStatus, required this.shippingNumber, required this.tax, required this.invoiceNumber, required this.theDateTime, required this.paymentMethod, required this.symbol, required this.amount, required this.theCode, required this.couponType, required this.storeName});

  GetOrders.fromJson(Map json)
      : orId = json['orId'],
        ordersTotalPrice = json['ordersTotalPrice'],
        ordersTotalProfit = json['ordersTotalProfit'],
        shippingPrice = json['shippingPrice'],
        deliveredStatus = json['deliveredStatus'],
        shippingNumber = json['shippingNumber'],
        tax = json['tax'],
        invoiceNumber = json['invoiceNumber'],
        theDateTime = json['theDateTime'],
        paymentMethod = json['paymentMethod'],
        symbol = json['symbol'],
        amount = json['amount'],
        theCode = json['theCode'],
        couponType = json['couponType'],
        storeName = json['storeName'];

}