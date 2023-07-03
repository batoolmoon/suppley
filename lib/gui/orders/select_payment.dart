//import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
//import 'package:http/http.dart' as http;
//import 'dart:convert';
//import 'package:html2md/html2md.dart' as html2md;
//import 'package:shared_preferences/shared_preferences.dart';
//import 'package:supplyplatform/components/funcs.dart';
//import 'package:supplyplatform/components/styles.dart';
//import 'package:supplyplatform/components/bottom_navigation_bar.dart';
//import 'package:supplyplatform/module/get_data.dart';
//import 'package:supplyplatform/module/get_transfer_methods.dart';
//import 'package:flutter_locales/flutter_locales.dart';
//import 'package:url_launcher/url_launcher.dart';
//
//
//class SelectPayment extends StatefulWidget{
//  SelectPayment(this.addressId,this.shippingPrice,this.couponDiscountValue,this.couponId);
//  String addressId;
//  String shippingPrice;
//  int couponDiscountValue;
//  String couponId;
//
//  @override
//  State<StatefulWidget> createState() {
//    // TODO: implement createState
//    return _SelectPaymentState(addressId,shippingPrice,couponDiscountValue,couponId);
//  }
//}
//
////enum SingingCharacter {other,cash_on_delivery}
//enum SingingCharacter {cash_on_delivery}
//
//class _SelectPaymentState extends State<SelectPayment>{
//
//  _SelectPaymentState(this.addressId,this.shippingPrice,this.couponDiscountValue,this.couponId);
//  String addressId;
//  String shippingPrice;
//  int couponDiscountValue;
//  String couponId;
//
//  late String memberId;
//  late String theLanguage;
//  late String emailAddress;
//  late bool isLogin = false;
//  late int sharedCartCount;
//  late int currencyId;
//  late double currencyExchange = 0.0;
//  late TextAlign theAlignment;
//  late Alignment theTopAlignment;
//  late TextDirection theDirection;
//  bool isLoading = true;
//  late String cartTotalPrice = '0.0';
//  late String whatsappNumber = '';
//  late String whatsappTitle = '';
//  late bool orderSent = false;
//  late String currencySymbol = '';
//  late double taxValue = 0.0;
//
//  late String generalNote = '';
//  late String shippingFullName = '';
//  late String shippingCity = '';
//  late String shippingAddress = '';
//  late String shippingMobileNumber = '';
//
//  var transferMethodsList = <GetTransferMethods>[];
//
//  var funcs = Funcs();
//  var styles = Styles();
//
//  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
//
////  SingingCharacter _paymentMethods = SingingCharacter.credit;
////  late SingingCharacter _paymentMethods;
//  late SingingCharacter _paymentMethods = SingingCharacter.cash_on_delivery;
//
//  @override
//  void initState(){
//    super.initState();
//    getSharedData().then((result){
//      getCartTotalPriceBeforeOrder();
//
//      getTax().then((result) {
//        setState(() {
//          taxValue = double.parse(result['taxData'][0]['tax']);
//        });
//      });
//
//      getGeneralNotes().then((result) {
//        setState(() {
//          generalNote = result['generalnNotesData'][0]['theDetails'];
//        });
//      });
//
//      getCurrency().then((result) {
//        setState(() {
//          currencySymbol = result['currencyData'][0]['currencySymbol'];
//        });
//      });
//
////      _getTransferMethodsList();
//
////      getWhatsappNumber().then((result) {
////        setState(() {
////          whatsappTitle = result['paymentMethodData'][0]['title1'];
////          whatsappNumber = result['paymentMethodData'][0]['theValue'];
////        });
////      });
//
////      getAddressData().then((result) {
////        setState(() {
////          shippingFullName = result['addressData'][0]['fullName'];
////          shippingCity = result['addressData'][0]['city'];
////          shippingAddress = result['addressData'][0]['street'];
////          shippingMobileNumber = result['addressData'][0]['mobileNumber'];
////        });
////      });
//
//    });
//  }
//
//  @override
//  void dispose() {
//    super.dispose();
//  }
//
//  getSharedData() async {
//    SharedPreferences prefs = await SharedPreferences.getInstance();
//    if(mounted){
//      setState(() {
//        memberId = prefs.getString('memberId')!;
//        theLanguage = prefs.getString('theLanguage')!;
//        emailAddress = prefs.getString('emailAddress')!;
//        isLogin = prefs.getBool('isLogin')!;
//        currencyId = prefs.getInt('currencyId')!;
//        currencyExchange = prefs.getDouble('currencyExchange')!;
//        if(theLanguage == 'ar'){
//          theAlignment = TextAlign.right;
//          theTopAlignment = Alignment.topRight;
//          theDirection = TextDirection.rtl;
//        }else{
//          theAlignment = TextAlign.left;
//          theTopAlignment = Alignment.topLeft;
//          theDirection = TextDirection.ltr;
//        }
//
//      });
//    }
//  }
//
//
//  void makeAnOrder() async{
////    String deliveryNote =  _getDeliveryNote.text;
////    deliveryNote = deliveryNote.replaceAll('\n', '<br>');
////    String theCoupon =  _getCoupon.text;
////    if(deliveryNote == null || deliveryNote == ''){
////      deliveryNote = '-';
////    }
//
//
//
//    String thePaymentMethod = _paymentMethods.toString().substring(_paymentMethods.toString().indexOf('.') + 1);
//    styles.onLoading(context);
//
//    print(memberId);
//    print(addressId);
//    print(couponId);
//    print(thePaymentMethod);
//
//    http.post(Uri.parse(funcs.mainLink+'api/makeAnOrder'), body: {
//      "memberId" : memberId,
//      "addressId" : addressId,
//      "couponId" : couponId,
//      "paymentMethod" : thePaymentMethod
//    }).then((result) async{
//      var theResult = json.decode(result.body);
//      if(theResult['resultFlag'] == 1){
//        SharedPreferences prefs = await SharedPreferences.getInstance();
//        await prefs.setInt('sharedCartCount', 0);
//        setState(() {
//          cartTotalPrice = '0.0';
//          addressId = '0';
//          orderSent = true;
//        });
//        getCartTotalPriceBeforeOrder();
//        Navigator.of(context, rootNavigator: true).pop();
//
//        styles.showSnackBar(scaffoldKey,context,context.localeString('order_successfully_text').toString(),'success','');
//
//        await Future.delayed(const Duration(seconds: 2));
//        Navigator.of(context).pushNamedAndRemoveUntil('/Orders',(Route<dynamic> route) => false);
//
//      }else if(theResult['resultFlag'] == 'inactive'){
//        styles.showSnackBar(scaffoldKey,context,context.localeString('inactive_account').toString(),'error','');
//        Navigator.of(context, rootNavigator: true).pop();
//      }else{
//        styles.showSnackBar(scaffoldKey,context,context.localeString('error_occurred').toString(),'error','');
//        Navigator.of(context, rootNavigator: true).pop();
//      }
//    }).catchError((error) {
//      print(error);
//      styles.showSnackBar(scaffoldKey,context,context.localeString('error_occurred'),'error','');
//      Navigator.of(context, rootNavigator: true).pop();
//    });
//  }
//
//  Future<Map> getTax() async{
//    setState(() {
//      isLoading = true;
//    });
//    var result;
//    var myUrl = Uri.parse(funcs.mainLink+'api/getTax/');
//    http.Response response = await http.get(myUrl, headers: {"Accept": "application/json"});
//    try{
//      setState(() {
//        isLoading = false;
//      });
//      result = json.decode(response.body);
//    }catch(e){
//      print(e);
//    }
//    return result;
//  }
//
//  Future<Map> getGeneralNotes() async{
//    setState(() {
//      isLoading = true;
//    });
//    var result;
//    var myUrl = Uri.parse(funcs.mainLink+'api/getGeneralNotes/$theLanguage/orders');
//    http.Response response = await http.get(myUrl, headers: {"Accept": "application/json"});
//    try{
//      setState(() {
//        isLoading = false;
//      });
//      result = json.decode(response.body);
//    }catch(e){
//      print(e);
//    }
//    return result;
//  }
//
////  Future<Map> getAddressData() async{
////    setState(() {
////      isLoading = true;
////    });
////    var result;
////    var myUrl = Uri.parse(funcs.mainLink+'api/getAddressDataForPayment/$theLanguage/$addressId/$memberId');
////    http.Response response = await http.get(myUrl, headers: {"Accept": "application/json"});
////    try{
////      setState(() {
////        isLoading = false;
////      });
////      result = json.decode(response.body);
////    }catch(e){
////      print(e);
////    }
////
////    return result;
////  }
//
////  Future<Map> getWhatsappNumber() async{
////    setState(() {
////      isLoading = true;
////    });
////    var result;
////    var myUrl = Uri.parse(funcs.mainLink+'api/getWhatsappNumberForPayment/');
////    http.Response response = await http.get(myUrl, headers: {"Accept": "application/json"});
////    try{
////      setState(() {
////        isLoading = false;
////      });
////      result = json.decode(response.body);
////    }catch(e){
////      print(e);
////    }
////
////    return result;
////  }
//
//
////  _getTransferMethodsList() {
////    GetData.getDataList(funcs.mainLink+'api/getTransferMethods/').then((response) {
////      setState(() {
////        Iterable list = json.decode(response.body);
////        transferMethodsList = list.map((model) => GetTransferMethods.fromJson(model)).toList();
////        isLoading = false;
////      });
////    });
////  }
//
//  getCartTotalPriceBeforeOrder() async{
//    cartTotalPrice = await funcs.getCartTotalPriceBeforeOrder(currencyId, isLogin, couponDiscountValue);
//    if(cartTotalPrice != null && double.parse(cartTotalPrice) > 0.0){
//      setState(() {
//        cartTotalPrice = cartTotalPrice;
//      });
//    }else{
//      setState(() {
//        cartTotalPrice = '0';
//      });
//    }
//  }
//
//  void _openLink(String theLink) async{
//    await launch(theLink);
//  }
//
//  copyCode(String theCode){
//    Clipboard.setData(ClipboardData(text: theCode));
//    styles.showSnackBar(scaffoldKey,context,context.localeString('iban_copied'),'','');
//  }
//
//  Future<Map> getCurrency() async{
//    setState(() {
//      isLoading = true;
//    });
//    var result;
//    var myUrl = Uri.parse(funcs.mainLink+'api/getCurrency/$currencyId');
//    http.Response response = await http.get(myUrl, headers: {"Accept": "application/json"});
//    try{
//      setState(() {
//        isLoading = false;
//      });
//      result = json.decode(response.body);
//    }catch(e){
//      print(e);
//    }
//
//    return result;
//  }
//
//  Widget widgetTransferMethodsList(){
//
//    return ListView.builder(
//      itemCount: transferMethodsList.length,
//      itemBuilder: (BuildContext context, int index) =>
//      Column(
//        children: <Widget>[
//          ListTile(
//            title: Row(
//              children: [
//                Container(
//                  alignment: theTopAlignment,
//                  child: Text(transferMethodsList[index].title1, style: Theme.of(context).textTheme.headline2, textAlign: theAlignment),
//                ),
//                const SizedBox(width: 10.0,),
//              ],
//            ),
//            subtitle: Container(
//              child: Column(
//                children: [
//                  Container(
//                    alignment: theTopAlignment,
//                    child: Text(html2md.convert(transferMethodsList[index].theValue), textAlign: theAlignment, style: const TextStyle(color: Colors.black87),),
//                  ),
//                  Container(
//                    alignment: theTopAlignment,
//                    child: ElevatedButton(
//                      onPressed: ()=> copyCode(transferMethodsList[index].theValue2),
//                      padding: const EdgeInsets.only(right: 20.0, left: 20.0, top: 5.0, bottom: 5.0 ),
//                      child: Text(context.localeString('copy_iban'),style: Theme.of(context).textTheme.button, textDirection: theDirection, textAlign: TextAlign.center),
//                      color: Theme.of(context).secondaryHeaderColor,
//                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
//                      elevation: 0.0,
//                    ),
//                  ),
//                ],
//              ),
//              alignment: theTopAlignment,
//            ),
//          ),
//          const Divider(),
//        ],
//      ),
//    );
//
//  }
//
//  Future<bool> _onWillPop() async{
//    Navigator.pop(context,true);
//    return false;
//  }
//
//  @override
//  Widget build(BuildContext context) {
//
//    return WillPopScope(
//      onWillPop: _onWillPop,
//      child: Scaffold(
//        key: scaffoldKey,
//        appBar: styles.theAppBar(context, theLanguage, isLogin, context.localeString('select_payment') , true, false, '0'),
//        body: Container(
//            child: Column(
//              children: [
//                Expanded(
//                    child: Container(
//                      padding: const EdgeInsets.all(10.0),
//                      child: Column(
//                        crossAxisAlignment: CrossAxisAlignment.start,
//                        children: [
//                          ListTile(
//                            title: Text(context.localeString('cash_on_delivery').toString()),
//                            leading: Radio(
//                              activeColor: Theme.of(context).primaryColor,
//                              value: SingingCharacter.cash_on_delivery,
//                              groupValue: _paymentMethods,
//                              onChanged: (SingingCharacter? value) {
//                                setState(() {
//                                  _paymentMethods = value!;
//                                });
////                                Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => new Payment(shippingFullName,emailAddress,shippingCity,shippingAddress,shippingMobileNumber,couponId,addressId)));
//                              },
//                            ),
//                          ),
////                          ListTile(
////                            title: Text(context.localeString('credit_card').toString()),
////                            leading: Radio(
////                              activeColor: Theme.of(context).primaryColor,
////                              value: SingingCharacter.credit,
////                              groupValue: _paymentMethods,
////                              onChanged: (SingingCharacter value) {
////                                setState(() {
////                                  _paymentMethods = value;
////                                });
//////                                Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => new Payment(shippingFullName,emailAddress,shippingCity,shippingAddress,shippingMobileNumber,couponId,addressId)));
////                              },
////                            ),
////                          ),
////                          ListTile(
////                            title: Text(context.localeString('transfer').toString()),
////                            leading: Radio(
////                              activeColor: Theme.of(context).primaryColor,
////                              value: SingingCharacter.transfer,
////                              groupValue: _paymentMethods,
////                              onChanged: (SingingCharacter value) {
////                                setState(() {
////                                  _paymentMethods = value;
////                                });
////                              },
////                            ),
////                          ),
////                          transferMethodsList.length > 0 && _paymentMethods == SingingCharacter.transfer ?
////                          Expanded(
////                            child: Container(
////                              padding: EdgeInsets.all(10.0),
////                              child: widgetTransferMethodsList(),
////                            ),
////                          ):new Container(),
////                          ListTile(
////                            title: Text(context.localeString('others_payment').toString()),
////                            leading: Radio(
////                              activeColor: Theme.of(context).primaryColor,
////                              value: SingingCharacter.other,
////                              groupValue: _paymentMethods,
////                              onChanged: (SingingCharacter? value) {
////                                setState(() {
////                                  _paymentMethods = value!;
////                                  print(_paymentMethods);
////                                });
////                              },
////                            ),
////                          ),
////                          _paymentMethods == SingingCharacter.other && whatsappNumber.isNotEmpty ? Container(
////                            child: Text(context.localeString('call_us_via_whatsapp'), style: Theme.of(context).textTheme.bodyText1, textAlign: TextAlign.center,),
////                          ):Container(),
////                          _paymentMethods == SingingCharacter.other && whatsappNumber.isNotEmpty ? Container(
////                            child: ElevatedButton(
////                              onPressed: ()=> _openLink('https://api.whatsapp.com/send?phone=$whatsappNumber'),
////                              padding: const EdgeInsets.only(right: 20.0, left: 20.0, top: 5.0, bottom: 5.0 ),
////                              child: Text(whatsappTitle,style: Theme.of(context).textTheme.button, textAlign: TextAlign.center),
////                              color: Theme.of(context).secondaryHeaderColor,
////                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
////                              elevation: 0.0,
////                            ),
////                          ):Container(
//////                            child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor), strokeWidth: 1.3,),
////                          )
//
//                          generalNote.isNotEmpty ? Container(
//                            padding: const EdgeInsets.only(top: 20, left: 30, right: 30),
//                            child: Text(context.localeString('note'), style: styles.paragraphTitle, textAlign: theAlignment,),
//                          ):Container(),
//                          generalNote.isNotEmpty ? Container(
//                            padding: const EdgeInsets.only(top: 5, left: 30, right: 30),
//                            child: Text(generalNote, style: styles.paragraphText, textAlign: theAlignment,),
//                          ):Container()
//                        ],
//                      ),
//                    )
//                ),
//                orderSent == false ? Container(
//                  color: const Color.fromRGBO(245, 245, 245, 1),
//                  child: Column(
//                    children: [
//                      Row(
//                        children: <Widget>[
//                          Expanded(
//                            child: ListTile(
//                              title: Text(context.localeString('total_price'), style: const TextStyle(color: Colors.black87, fontSize: 13.0), textAlign: TextAlign.center),
//                              subtitle: double.parse(cartTotalPrice) > 0.0 ?
//                              Text(cartTotalPrice +' $currencySymbol',style: styles.productPrice, textAlign: TextAlign.center):
//                              SizedBox(
//                                height: 3.0,
//                                child: LinearProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor), backgroundColor: const Color.fromRGBO(245, 245, 245, 1), minHeight: 1,),
//                              ),
//                            ),
//                          ),
//                          Expanded(
//                            child: ListTile(
//                              title: Text(context.localeString('shipping_price'),style: const TextStyle(color: Colors.black87, fontSize: 13.0), textAlign: TextAlign.center),
//                              subtitle: Text(shippingPrice +' $currencySymbol',style: styles.productPrice, textAlign: TextAlign.center),
//                            ),
//                          ),
//                          taxValue > 0.0 ? Expanded(
//                            child: ListTile(
//                              title: Text(context.localeString('tax'),style: const TextStyle(color: Colors.black87, fontSize: 13.0), textAlign: TextAlign.center),
//                              subtitle:  Text(funcs.getTax(cartTotalPrice, shippingPrice, taxValue).toString() + ' $currencySymbol',style: styles.productPrice, textAlign: TextAlign.center),
//                            ),
//                          ):Container(),
//                        ],
//                      ),
//                      Row(
//                        children: [
//                          Expanded(
//                            child: ListTile(
//                              title: Text(context.localeString('payment_price'),style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13.0), textAlign: TextAlign.center),
//                              subtitle: Text(funcs.getPaymentPrice(cartTotalPrice, shippingPrice, taxValue).toString() +' $currencySymbol',style: styles.productPrice, textAlign: TextAlign.center),
//                            ),
//                          ),
//                          Expanded(
//                            child: ElevatedButton(
//                              shape: styles.circleBtn(),
//                              elevation: 0.0,
//                              onPressed: (){
//                                if(double.parse(cartTotalPrice) > 0.0 && double.parse(addressId) > 0 && _paymentMethods != null){
//                                  makeAnOrder();
//                                }else{
//                                  null;
//                                }
//                              },
//                              padding: const EdgeInsets.only(right: 10.0, left: 10.0, top: 5.0, bottom: 5.0 ),
//                              child: Text(context.localeString('make_order'),style: Theme.of(context).textTheme.button, textAlign: TextAlign.center),
//                              color: double.parse(cartTotalPrice) > 0.0 && double.parse(addressId) > 0 && _paymentMethods != null ? styles.nextColor: Colors.grey,
//                            ),
//                          ),
//                          const SizedBox(width: 10.0),
//                        ],
//                      )
//                    ],
//                  ),
//
//                ):Container(
//                  color: const Color.fromRGBO(245, 245, 245, 1),
//                  child: Row(
//                    children: <Widget>[
//                      Expanded(
//                        child: Container(),
//                      ),
//                      Expanded(
//                        child: ElevatedButton(
//                          shape: styles.circleBtn(),
//                          elevation: 0.0,
//                          onPressed: (){
//                            Navigator.of(context).pushNamedAndRemoveUntil('/Orders',(Route<dynamic> route) => false);
//                          },
//                          padding: const EdgeInsets.only(right: 20.0, left: 20.0, top: 5.0, bottom: 5.0 ),
//                          child: Text(context.localeString('back_to_orders'),style: Theme.of(context).textTheme.button, textAlign: TextAlign.center),
//                          color: styles.nextColor,
//                        ),
//                      ),
//                      Expanded(
//                        child: Container(),
//                      ),
//                    ],
//                  ),
//                )
//              ],
//            )
//        ),
//        bottomNavigationBar: BottomNavigationBarWidget(1),
//      ),
//    );
//  }
//
//}