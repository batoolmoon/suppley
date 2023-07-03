//import 'package:flutter/material.dart';
//import 'package:http/http.dart' as http;
//import 'dart:convert';
//import 'package:shared_preferences/shared_preferences.dart';
//import 'package:supplyplatform/components/funcs.dart';
//import 'package:supplyplatform/components/styles.dart';
//import 'package:supplyplatform/components/bottom_navigation_bar.dart';
//import 'package:supplyplatform/module/get_data.dart';
//import 'package:supplyplatform/module/get_addresses.dart';
//import 'package:flutter_locales/flutter_locales.dart';
//import 'package:supplyplatform/gui/addresses/add_edit_address.dart';
//import 'package:supplyplatform/gui/orders/select_payment.dart';
//import 'package:supplyplatform/gui/orders/cart.dart';
//
//class DeliveryAddress extends StatefulWidget{
//  DeliveryAddress(this.couponDiscountValue, this.couponId);
//  int couponDiscountValue;
//  String couponId;
//
//  @override
//  State<StatefulWidget> createState() {
//    // TODO: implement createState
//    return _DeliveryAddressState(couponDiscountValue, couponId);
//  }
//}
//
//class _DeliveryAddressState extends State<DeliveryAddress>{
//  _DeliveryAddressState(this.couponDiscountValue, this.couponId);
//  int couponDiscountValue;
//  String couponId;
//
//  late String memberId;
//  late String fullName;
//  late String theLanguage;
//  late bool isLogin;
//  late int sharedCartCount;
//  late int currencyId;
//  late double currencyExchange;
//  late TextAlign theAlignment;
//  late Alignment theTopAlignment;
//  late bool isLoading = true;
//  late String cartTotalPrice = '0.0';
//  late String addressId = '0';
//  late String currencySymbol = '';
//  late double shippingPrice = 0.0;
//
//  var funcs = Funcs();
//  var styles = Styles();
//
//  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
//
//  var addressList = <GetAddresses>[];
//
//  _getDataList() {
//    GetData.getDataList(
//      funcs.mainLink+'api/getAddresses/$memberId/$theLanguage').then((response) {
//        setState(() {
//          Iterable list = json.decode(response.body);
//          addressList = list.map((model) => GetAddresses.fromJson(model)).toList();
//          isLoading = false;
//        });
//      });
//  }
//
//  @override
//  void initState(){
//    super.initState();
//    getSharedData().then((result){
//      _getDataList();
//      getCartTotalPriceBeforeOrder();
//      getCurrency().then((result) {
//        setState(() {
//          currencySymbol = result['currencyData'][0]['currencySymbol'];
//        });
//      });
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
//        fullName = prefs.getString('fullName')!;
//        theLanguage = prefs.getString('theLanguage')!;
//        isLogin = prefs.getBool('isLogin')!;
//        currencyId = prefs.getInt('currencyId')!;
//        currencyExchange = prefs.getDouble('currencyExchange')!;
//        if(theLanguage == 'ar'){
//          theAlignment = TextAlign.right;
//          theTopAlignment = Alignment.topRight;
//        }else{
//          theAlignment = TextAlign.left;
//          theTopAlignment = Alignment.topLeft;
//        }
//
//      });
//    }
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
//
//  }
//
//  getShippingPrices(index,addressId) async{
//    styles.onLoading(context);
//    var myUrl = Uri.parse(funcs.mainLink+'api/getShippingPrices/$memberId/$addressId/$cartTotalPrice');
//    http.Response response = await http.get(myUrl, headers: {"Accept": "application/json"});
//    try{
//      Navigator.of(context, rootNavigator: true).pop();
//      var theShippingPrice = json.decode(response.body);
//      if(theShippingPrice['shippingOfferFlag'] == true){
//
//        setState(() {
//          shippingPrice = double.parse(theShippingPrice['shippingPrice']) * currencyExchange;
//        });
//      }else{
//        setState(() {
//          shippingPrice = double.parse(theShippingPrice['shippingPrice']) * currencyExchange;
//        });
//      }
//
//    }catch(e){
//      print(e);
//    }
//  }
//
//
//  _addEditAddress(String addressId){
//    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => AddEditAddress(addressId,'DeliveryAddress',couponDiscountValue,couponId)));
//  }
//
//  Widget widgetAddressesList(){
//
//    return ListView.builder(
//      itemCount: addressList.length,
//      itemBuilder: (BuildContext context, int index) =>
//      Column(
//        children: <Widget>[
//          ListTile(
//            title: Row(
//              children: [
//                Container(
//                  alignment: theTopAlignment,
//                  child: Text(addressList[index].theTitle, style: Theme.of(context).textTheme.headline2, textAlign: theAlignment),
//                ),
//                const SizedBox(width: 10.0,),
//                int.parse(addressId) > 0 && int.parse(addressList[index].adId) == int.parse(addressId) ? Image.assets(
//                  'images/right.gif',
//                  width: 20.0,
//                ):Container()
//              ],
//            ),
//            subtitle: Column(
//              children: [
//                Container(
//                  child: Text('''${addressList[index].fullName}
//${addressList[index].addressDetails}
//${addressList[index].street}
//${addressList[index].theArea} - ${addressList[index].theCity} -   ${addressList[index].theCountry}
//${addressList[index].mobileNumber}
//''', textAlign: theAlignment, style:  TextStyle(color: int.parse(addressId) > 0 && int.parse(addressList[index].adId) == int.parse(addressId) ? Colors.green: Colors.black87),),
//                  alignment: theTopAlignment,
//                ),
//                Row(
//                  children: [
//                    Container(
//                      padding: const EdgeInsets.only(right: 10.0, left: 10.0, top: 10.0),
//                      alignment: theTopAlignment,
//                      child: ElevatedButton(
//                        onPressed: ()=> _addEditAddress(addressList[index].adId),
//                        padding: const EdgeInsets.only(right: 20.0, left: 20.0, top: 5.0, bottom: 5.0 ),
//                        child: Text(context.localeString('edit_btn'),style: Theme.of(context).textTheme.button, textAlign: TextAlign.center),
//                        color: Theme.of(context).secondaryHeaderColor,
//                        shape: styles.circleBtn(),
//                        elevation: 0.0,
//                      ),
//                    ),
//                    Container(
//                      padding: const EdgeInsets.only(right: 10.0, left: 10.0, top: 10.0),
//                      alignment: theTopAlignment,
//                      child: ElevatedButton(
//                        onPressed: (){
//                          setState(() {
//                            addressId = addressList[index].adId;
//                            getShippingPrices(index,addressList[index].adId);
//                          });
//                        },
//                        padding: const EdgeInsets.only(right: 20.0, left: 20.0, top: 5.0, bottom: 5.0 ),
//                        child: Text(context.localeString('select_address'),style: Theme.of(context).textTheme.button, textAlign: TextAlign.center),
//                        color: Theme.of(context).secondaryHeaderColor,
//                        shape: styles.circleBtn(),
//                        elevation: 0.0,
//                      ),
//                    ),
//                  ],
//                )
//              ],
//            ),
//          ),
//          const Divider(),
//        ],
//      ),
//    );
//
//  }
//
//  _onWillPop() async{
//    return Navigator.of(context).push(PageRouteBuilder(
//      pageBuilder: (context, animation, anotherAnimation){
//        return const Cart();
//      },
//      transitionsBuilder: (context, animation, secondaryAnimation, child) {
//
//        return FadeTransition(
//          opacity:animation,
//          child: child,
//        );
//      },
//    ));
//  }
//
//  @override
//  Widget build(BuildContext context) {
//
//    return WillPopScope(
//      onWillPop: ()=> _onWillPop(),
//      child: Scaffold(
//        key: scaffoldKey,
//        appBar: styles.theAppBar(context, theLanguage, isLogin, context.localeString('checkout_title') , true, false, '0'),
//        body: isLoading == false ? Container(
//            child: Column(
//              children: [
//                Expanded(
//                    child: addressList.isNotEmpty || isLoading == true ? widgetAddressesList():
//                    Container(
//                      padding: const EdgeInsets.all(30.0),
//                      child: Column(
//                        children: [
//                          Text(context.localeString('you_do_not_have_address'), style: Theme.of(context).textTheme.bodyText1, textAlign: TextAlign.center,),
//                          IconButton(
//                            icon: const Icon(Icons.add, size: 30.0,),
//                            tooltip: context.localeString('add_new_address'),
//                            onPressed: () {
//                              _addEditAddress('0');
//                            },
//                          ),
//                          Text(context.localeString('add_new_address'))
//                        ],
//                      ),
//                    )
//                ),
//                Container(
//                  color: const Color.fromRGBO(245, 245, 245, 1),
//                  child: Row(
//                    children: <Widget>[
//                      Expanded(
//                        child: ListTile(
//                          title: Text(context.localeString('total_price'),style: styles.priceTitle, textAlign: TextAlign.center),
//                          subtitle: double.parse(cartTotalPrice) > 0.0 ?
//                                    Text(cartTotalPrice + ' ' + currencySymbol,style: styles.productPrice, textAlign: TextAlign.center):
//                                    SizedBox(
//                                      height: 3.0,
//                                      child: LinearProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor), backgroundColor: const Color.fromRGBO(245, 245, 245, 1), minHeight: 1,),
//                                    ),
//                        ),
//                      ),
//                      Expanded(
//                        child: ListTile(
//                          title: Text(context.localeString('shipping_price'),style: styles.priceTitle, textAlign: TextAlign.center),
//                          subtitle: Text(shippingPrice.toStringAsFixed(2) + ' $currencySymbol',style: styles.productPrice, textAlign: TextAlign.center),
//                        ),
//                      ),
//                      Expanded(
//                        child: ElevatedButton(
//                          shape: styles.circleBtn(),
//                          elevation: 0.0,
//                          onPressed: (){
//                            if(double.parse(cartTotalPrice) > 0 && double.parse(addressId) > 0){
//                              Navigator.push(context, MaterialPageRoute(builder: (context) => SelectPayment(addressId, shippingPrice.toStringAsFixed(1), couponDiscountValue,couponId)),);
//                            }else{
//                              null;
//                            }
//                          },
//                          padding: const EdgeInsets.only(right: 10.0, left: 10.0, top: 5.0, bottom: 5.0 ),
//                          child: Text(context.localeString('continue'),style: Theme.of(context).textTheme.button, textAlign: TextAlign.center),
//                          color: double.parse(addressId) > 0 ? styles.nextColor: Colors.grey,
//                        ),
//                      ),
//                      const SizedBox(width: 10.0),
//                    ],
//                  ),
//                )
//              ],
//            )
//        ):Container(),
//        floatingActionButton: isLoading == true ? styles.loadingPage(context):Container(),
//        bottomNavigationBar: BottomNavigationBarWidget(1),
////        drawer: DrawerClass(isLogin, fullName),
//      ),
//    );
//  }
//
//}