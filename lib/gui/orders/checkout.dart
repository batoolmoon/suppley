//import 'package:flutter/material.dart';
//import 'dart:convert';
//import 'package:shared_preferences/shared_preferences.dart';
//import 'package:supplyplatform/components/funcs.dart';
//import 'package:supplyplatform/components/styles.dart';
//import 'package:supplyplatform/components/bottom_navigation_bar.dart';
//import 'package:supplyplatform/module/get_data.dart';
//import 'package:supplyplatform/module/get_addresses.dart';
//import 'package:flutter_locales/flutter_locales.dart';
//
//
//class Checkout extends StatefulWidget{
//  @override
//  State<StatefulWidget> createState() {
//    // TODO: implement createState
//    return _CheckoutState();
//  }
//}
//
//class _CheckoutState extends State<Checkout>{
//
//  late String memberId;
//  late String theLanguage;
//  late bool isLogin;
//  late int sharedCartCount;
//  late int currencyId;
//  late double currencyExchange;
//  late TextAlign theAlignment;
//  late Alignment theTopAlignment;
//  bool isLoading = true;
//  String cartTotalPrice = '0.0';
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
//        funcs.mainLink+'api/getAddresses/$memberId/$theLanguage').then((response) {
//      setState(() {
//        Iterable list = json.decode(response.body);
//        addressList = list.map((model) => GetAddresses.fromJson(model)).toList();
//        isLoading = false;
//      });
//    });
//  }
//
//  @override
//  void initState(){
//    super.initState();
//    getSharedData().then((result){
//      _getDataList();
//      getCartTotalPriceBeforeOrder();
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
//        isLogin = prefs.getBool('isLogin')!;
//        currencyId = prefs.getInt('currencyId')!;
//        currencyExchange = prefs.getDouble('currencyExchange')!;
//
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
//  getCartTotalPriceBeforeOrder() async{
//    cartTotalPrice = await funcs.getCartTotalPriceBeforeOrder(currencyId, isLogin, 0);
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
//
//  _addEditAddress(String addressId){
////    Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => new AddEditAddress(addressId,'DeliveryAddress')));
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
//            title: Text(addressList[index].theTitle, style: Theme.of(context).textTheme.headline2, textAlign: theAlignment),
//            subtitle: Column(
//              children: [
//                Container(
//                  child: Text('''${addressList[index].fullName}
//${addressList[index].addressDetails}
//${addressList[index].street}
//${addressList[index].theCity} -   ${addressList[index].theCountry}
//${addressList[index].mobileNumber}
//''', textAlign: theAlignment),
//                  alignment: theTopAlignment,
//                ),
//                Row(
//                  children: [
//                    theLanguage == 'ar' ? Expanded(
//                      child: Container(),
//                    ):Container(),
//                    Container(
//                      padding: const EdgeInsets.only(right: 10.0, left: 10.0, top: 10.0),
//                      alignment: theTopAlignment,
//                      child: ElevatedButton(
//                        onPressed: ()=> _addEditAddress(addressList[index].adId),
//                        padding: const EdgeInsets.only(right: 20.0, left: 20.0, top: 5.0, bottom: 5.0 ),
//                        child: Text(context.localeString('edit_btn'),style: Theme.of(context).textTheme.button, textAlign: TextAlign.center),
//                        color: Theme.of(context).secondaryHeaderColor,
//                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
//                        elevation: 0.0,
//                      ),
//                    ),
//                    Container(
//                      padding: const EdgeInsets.only(right: 10.0, left: 10.0, top: 10.0),
//                      alignment: theTopAlignment,
//                      child: ElevatedButton(
//                        onPressed: ()=> _addEditAddress(addressList[index].adId),
//                        padding: const EdgeInsets.only(right: 20.0, left: 20.0, top: 5.0, bottom: 5.0 ),
//                        child: Text(context.localeString('select_address'),style: Theme.of(context).textTheme.button, textAlign: TextAlign.center),
//                        color: Theme.of(context).secondaryHeaderColor,
//                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
//                        elevation: 0.0,
//                      ),
//                    ),
//                    theLanguage != 'ar' ? Expanded(
//                      child: Container(),
//                    ):Container(),
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
//        appBar: AppBar(
//          title: Text(context.localeString('checkout_title'), style: styles.checkoutPageTitle),
//          automaticallyImplyLeading: false,
//        ),
//        body: isLoading == false ? Container(
//          child: Column(
//            children: [
//              Expanded(
//                child: addressList.isNotEmpty || isLoading == true ? widgetAddressesList():Container()
//              ),
//              Container(
//                color: const Color.fromRGBO(245, 245, 245, 1),
//                child: Row(
//                  children: <Widget>[
//                    Expanded(
//                      child: ListTile(
//                        title: Text(context.localeString('total_price'),style: const TextStyle(color: Colors.black87, fontSize: 13.0), textAlign: TextAlign.center),
//                        subtitle: Text('$cartTotalPrice TL',style: styles.productPrice, textAlign: TextAlign.center),
//                      ),
//                    ),
//                    Expanded(
//                      child: ElevatedButton(
//                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(30.0), bottomLeft: Radius.circular(30.0))),
//                        elevation: 0.0,
//                        onPressed: (){
//                          if(double.parse(cartTotalPrice) > 0){
////                            _checkout();
//                          }else{
//                            null;
//                          }
//                        },
//                        padding: const EdgeInsets.only(right: 20.0, left: 20.0, top: 5.0, bottom: 5.0 ),
//                        child: Text(context.localeString('continue'),style: Theme.of(context).textTheme.button, textAlign: TextAlign.center),
//                        color: double.parse(cartTotalPrice) > 0 ? Colors.red: Colors.grey,
//                      ),
//                    ),
//                  ],
//                ),
//              )
//            ],
//          )
//        ):Container(),
//        floatingActionButton: isLoading == true ? styles.loadingPage(context):Container(),
//        bottomNavigationBar: BottomNavigationBarWidget(2),
//      ),
//    );
//  }
//
//}