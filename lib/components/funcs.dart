import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Funcs {

  final String mainLink = 'https://se-supply.com/';

  late bool isLogin = false;
  late String memberId = '0';
  late String deviceId = '';

  Random rnd = Random();

  generateActivationCode() {
    int min = 10000,
        max = 99999;
    int r = min + rnd.nextInt(max - min);
    return r.toString();
  }

  Future<String> getMemberSessionId() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isLogin = prefs.getBool('isLogin')!;
    memberId = prefs.getString('memberId')!;
   deviceId = prefs.getString('deviceId')!;

    if(isLogin == true){
      return memberId;
    }
    else{
      return deviceId;
    }
  }

  generateMemberTokenId() async{

    SharedPreferences prefs = await SharedPreferences.getInstance();
    memberId = prefs.getString('memberId')!;

    var myUrl = Uri.parse(mainLink+'api/generateMemberTokenId');
    await http.post(myUrl, body: {
    "memberId": memberId,
    }).then((result) async{
      var theResult = json.decode(result.body);

      if(theResult['resultFlag'] == 'done'){
        String tokenId = theResult['tokenId'];
        await prefs.setString('tokenId', tokenId);
      }else{

      }
    }).catchError((error) {

    });
  }

  double getPriceBeforeDiscount(String thePrice, String theDiscount, int _selectedQuantity, double currencyExchange/*, String categoryProfit*/){
    double myDouble = (double.parse(thePrice) * currencyExchange) * _selectedQuantity;
    return myDouble; //+ getProfit(thePrice, _selectedQuantity);
  }

  double getPriceAfterDiscount(String thePrice, String theDiscount, int _selectedQuantity, double currencyExchange/*, String categoryProfit*/){
//    double myDouble = ((double.parse(thePrice) * (100 - double.parse(theDiscount))) / 100) * _selectedQuantity;
    double myDouble = (double.parse(theDiscount) * currencyExchange ) * _selectedQuantity;
    return myDouble ;//+ getProfit(theDiscount, _selectedQuantity/*, categoryProfit*/);
  }

  double getTotalPrice(String thePrice, String theDiscount,int _selectedQuantity, double currencyExchange/*, String categoryProfit*/){
    double theTotalPrice;
    if(double.parse(theDiscount) == 0.0){
      theTotalPrice = (double.parse(thePrice) * currencyExchange) * _selectedQuantity;
      theTotalPrice = theTotalPrice; //+ getProfit(thePrice, _selectedQuantity/*, categoryProfit*/);
    }else{
      theTotalPrice = getPriceAfterDiscount(thePrice,theDiscount, _selectedQuantity, currencyExchange/*, categoryProfit*/);
    }
    return theTotalPrice;
  }


  Future<String> getUnreadNotificationsCount() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    memberId = prefs.getString('memberId')!;

    var result;
    var myUrl = Uri.parse(mainLink+'api/getUnreadNotificationsCount/$memberId');
    http.Response response = await http.get(myUrl, headers: {"Accept": "application/json"});
    try{
      List theData = json.decode(response.body);
      result =  theData[0]['theCount'].toString();
    }catch(e){
      print(e);
    }
    return result;
  }

  Future<String> getCartTotalPriceBeforeOrder(int currencyId, bool isLogin ) async{
    String memberSessionId = await getMemberSessionId();

    var result;
    var myUrl = Uri.parse(mainLink+'api/getCartTotalPriceBeforeOrder/$memberSessionId/$isLogin/$currencyId');
 //print("sess "+memberSessionId);
    http.Response response = await http.get(myUrl, headers: {"Accept": "application/json"});
    try{
      List ordersTotalPrice = json.decode(response.body);
      if(ordersTotalPrice[0]['ordersTotalPrice'] != null){
        double theValue = double.parse(ordersTotalPrice[0]['ordersTotalPrice']);
        result =  theValue.toStringAsFixed(2);
        print(result);
      }else{

        result = '0.0';
      }
    }catch(e){
      print('error');
    }

    return result;
  }

  Future<String> getCartTotalPriceAfterOrder(String memberId, String invoiceNumber) async{

    var result;
    var myUrl = Uri.parse(mainLink+'api/getCartTotalPriceAfterOrder/$memberId/$invoiceNumber');
    http.Response response = await http.get(myUrl, headers: {"Accept": "application/json"});

    try{
      List ordersTotalPrice = json.decode(response.body);
      if(ordersTotalPrice[0]['ordersTotalPrice'] != null){
        result = (double.parse(ordersTotalPrice[0]['ordersTotalPrice']) + double.parse(ordersTotalPrice[0]['ordersTotalProfit'])).toStringAsFixed(2);
      }else{
        result = '0.0';
      }
    }catch(e){
      print('error');
    }

    return result;
  }

  Future<String> getRate(String productId) async{
    var result;
    var myUrl = Uri.parse(mainLink+'api/getProductRate/$productId');
    http.Response response = await http.get(myUrl, headers: {"Accept": "application/json"});
    try{
      var rate = json.decode(response.body);
      //print(rate['theResult']);
      result =  rate['theResult'].toString();
    }catch(e){
      print('error');
    }
    return result;
  }

  Future<String> getStoreRate(String storeId) async{
    var result;
    var myUrl = Uri.parse(mainLink+'api/getStoreRate/$storeId');
    http.Response response = await http.get(myUrl, headers: {"Accept": "application/json"});
    try{
      var rate = json.decode(response.body);
      //print(rate['theResult']);
      result =  rate['theResult'].toString();
    }catch(e){
      print('error');
    }
    return result;
  }

  double getTotalPriceWithCoupon(String thePrice, String couponAmount, String couponType, String shippingPrice, String tax, String totalOrderProfit){
    if(couponAmount == 'null'){
      couponAmount = '0';
    }

    double totalPrice = 0.0;
    if(couponType == 'fixed'){
      totalPrice = (double.parse(thePrice) + double.parse(shippingPrice) + double.parse(tax) + double.parse(totalOrderProfit) - double.parse(couponAmount));
    }else{
      totalPrice = ((double.parse(thePrice) * (100 - double.parse(couponAmount))) / 100) + double.parse(shippingPrice) + double.parse(tax) + double.parse(totalOrderProfit);
    }


    return double.parse(totalPrice.toStringAsFixed(2));
  }



  Future<String> addToCart( bool isLogin, String storeId, String productId, String priceId, String optionId, int quantity, int currencyId) async{



    var response;
    String memberSessionId = await getMemberSessionId();

//    String totalPrice = getTotalPrice(thePrice,theDiscount,quantity,currencyExchange).toString();
    await http.post(Uri.parse(mainLink+'api/addToCart'), body: {

      "memberId" : memberSessionId,
      "storeId" : storeId,
      "productId": productId,
      "priceId": priceId,
      "optionId": optionId,
      "currencyId": currencyId.toString(),
      "selectedQuantity": quantity.toString(),
      "isLogin": isLogin.toString()



    }).then((result) async{
      var theResult = json.decode(result.body);
      response = theResult['theResult'].toString();
    }).catchError((error) {
      print(error);
      response = '0';
      print("mem "+memberId);
      print("p "+priceId);
      print("optionId " + optionId);
      print("store "+storeId);
      print("productId " + productId);
 print("selectedQuantity "+quantity.toString());
 print("isLogin "+isLogin.toString());
 print("currencyId "+currencyId.toString());



    });

    return response;
  }


  Future<String> rateProduct(bool isLogin, double theRate, String memberId, String productId) async{
    var response;
    if(isLogin == true) {
      await http.post(Uri.parse(mainLink+'api/rateProduct'), body: {
        "memberId" : memberId,
        "productId": productId,
        "theRate": theRate.toString(),
      }).then((result) async{
        var theResult = json.decode(result.body);
        response = theResult['theResult'].toString();
      }).catchError((error) {
        print(error);
        response = '0';
      });
    }else{
      response = '0';
    }
    return response;
  }

  Future<String> rateStore(bool isLogin, double theRate, String memberId, String storeId) async{
    var response;
    if(isLogin == true) {
      await http.post(Uri.parse(mainLink+'api/rateStore'), body: {
        "memberId" : memberId,
        "storeId": storeId,
        "theRate": theRate.toString(),
      }).then((result) async{
        var theResult = json.decode(result.body);
        response = theResult['theResult'].toString();
      }).catchError((error) {
        print(error);
        response = '0';
      });
    }else{
      response = '0';
    }
    return response;
  }

  Future<String> removeItemFromFavourite(String memberId, String productId) async{
    var response;

    await http.post(Uri.parse(mainLink+'api/removeItemFromFavourite'), body: {
      "memberId" : memberId,
      "productId": productId,
    }).then((result) async{
      var theResult = json.decode(result.body);
      response = theResult['theResult'].toString();
    }).catchError((error) {
      print(error);
      response = '0';
    });

    return response;
  }

  Future<String> getPlaceRate(String placeId) async{
    var result;
    var myUrl = Uri.parse(mainLink+'api/getPlaceRate/$placeId');
    http.Response response = await http.get(myUrl, headers: {"Accept": "application/json"});
    try{
      var rate = json.decode(response.body);
      //print(rate['theResult']);
      result =  rate['theResult'].toString();
    }catch(e){
      print('error');
    }
    return result;
  }

  Future<String> ratePlace(bool isLogin, double theRate, String memberId, String placeId) async{
    var response;
    if(isLogin == true) {
      await http.post(Uri.parse(mainLink+'api/ratePlace'), body: {
        "memberId" : memberId,
        "placeId": placeId,
        "theRate": theRate.toString(),
      }).then((result) async{
        var theResult = json.decode(result.body);
        response = theResult['theResult'].toString();
      }).catchError((error) {
        print(error);
        response = '0';
      });
    }else{
      response = '0';
    }
    return response;
  }

  String replaceArabicNumber(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '۳', '٤', '٥', '٦', '٧', '٨', '٩'];

    for (int i = 0; i < english.length; i++) {
      input = input.replaceAll(arabic[i], english[i]);
    }

    return input;
  }

  String removeCharacterFromMobile(String input) {
    const space = ['', '', '00', '', ''];
    const characters = ['(', ')','+','-',' '];

    for (int i = 0; i < space.length; i++) {
      input = input.replaceAll(characters[i], space[i]);
    }

    return input;
  }

  double getTax(String thePrice, String shippingPrice, double taxValue){
    // for total cart + shipping price
    double theTax = (((double.parse(thePrice) + double.parse(shippingPrice)) * taxValue) / 100);
    return double.parse(theTax.toStringAsFixed(1));
  }

  double getPaymentPrice(String thePrice, String shippingPrice, double taxValue, int couponCodeDiscountAmount, couponType){
    taxValue = getTax(thePrice, shippingPrice, taxValue);
    //double paymentPrice = (double.parse(thePrice) + double.parse(shippingPrice) + taxValue);
//    double paymentPrice = (double.parse(thePrice) + taxValue);
    double paymentPrice = 0.0;
    if(couponType == 'fixed'){
      paymentPrice = ((double.parse(thePrice) + double.parse(shippingPrice)) - couponCodeDiscountAmount);
    }else{
      paymentPrice = (double.parse(thePrice) * ((100 - couponCodeDiscountAmount)/100)) + double.parse(shippingPrice);
    }

    return double.parse(paymentPrice.toStringAsFixed(2));
  }

  double getProfit(String thePrice, int selectedQty/*, String categoryProfit*/){
    double productPrice;
    double profitValue = (double.parse(thePrice)/* * double.parse(categoryProfit)*/); // /100;
    productPrice = profitValue * selectedQty;

    return double.parse(productPrice.toStringAsFixed(2));
  }

}
