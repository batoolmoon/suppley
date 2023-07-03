//import 'package:flutter/material.dart';
//import 'package:http/http.dart' as http;
//import 'dart:convert';
//import 'package:shared_preferences/shared_preferences.dart';
//import 'package:supplyplatform/components/funcs.dart';
//import 'package:supplyplatform/components/styles.dart';
//import 'package:supplyplatform/gui/add_edit_address.dart';
//import 'package:flutter_locales/flutter_locales.dart';
//
//class DeliveryAddress extends StatefulWidget{
//  @override
//  State<StatefulWidget> createState() {
//    // TODO: implement createState
//    return new _DeliveryAddressState();
//  }
//
//}
//
//class _DeliveryAddressState extends State<DeliveryAddress>{
//
//  String memberId;
//  String theLanguage;
//  String fullName;
//  bool isLogin;
//  TextAlign theAlignment;
//  TextDirection theDirection;
//  String cartTotalPrice = '0.0';
//  String finalPrice = '0.0';
//  bool orderDone = false;
//  bool isLoading = false;
//  bool couponIsValid = false;
//  String couponDiscountValue;
//  String addressId = '0';
//  double shippingPrice = 0.0;
//  TextEditingController _getDeliveryNote = new TextEditingController();
//  TextEditingController _getCoupon = new TextEditingController();
//  List<DropdownMenuItem<String>> addressesList = [];
//  FocusNode myFocusNode;
//
//  var funcs = new Funcs();
//  var styles = new Styles();
//
//  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
//
//  @override
//  void initState(){
//    super.initState();
//    myFocusNode = FocusNode();
//    getSharedData();
//  }
//
//  @override
//  void dispose() {
//    // Clean up the focus node when the Form is disposed.
//    myFocusNode.dispose();
//
//    super.dispose();
//  }
//
//  getSharedData() async {
//    SharedPreferences prefs = await SharedPreferences.getInstance();
//    if(mounted){
//      setState(() {
//        memberId = prefs.getString('memberId');
//        fullName = prefs.getString('fullName');
//        theLanguage = prefs.getString('theLanguage');
//        isLogin = prefs.getBool('isLogin');
//
//        if(theLanguage == 'ar'){
//          theAlignment = TextAlign.right;
//          theDirection = TextDirection.rtl;
//        }else{
//          theAlignment = TextAlign.left;
//          theDirection = TextDirection.ltr;
//        }
//        getCartTotalPriceBeforeOrder(0);
//        getAddresses();
//      });
//    }
//  }
//
//  Future<Map> makeAnOrderFunction() async{
//    String deliveryNote =  _getDeliveryNote.text;
//    deliveryNote = deliveryNote.replaceAll('\n', '<br>');
//    String theCoupon =  _getCoupon.text;
//    if(deliveryNote == null || deliveryNote == ''){
//      deliveryNote = '-';
//    }
//    String myUrl = funcs.mainLink+'api/makeAnOrder/$memberId/$addressId/$deliveryNote/$theCoupon/$couponIsValid';
//    http.Response response = await http.post(myUrl, headers: {"Accept": "application/json"});
//    return json.decode(response.body);
//  }
//
//  void makeAnOrder() async{
//    styles.onLoading(context);
//
//    try{
//      Map data = await(makeAnOrderFunction());
//      Navigator.of(context, rootNavigator: true).pop();
//
//      if(data['theResult'] == 0){
//        _showSnackBar(Translations.of(context).text('error_occurred').toString(),'error');
//      }else{
//        orderDone = true;
//        getCartTotalPriceBeforeOrder(0);
//        _showSnackBar(Translations.of(context).text('order_successfully_text').toString(),'success');
//      }
//
//    }catch(e){
//      Navigator.of(context, rootNavigator: true).pop();
//      print(e);
//      _showSnackBar(Translations.of(context).text('error_occurred').toString(),'error');
//    }
//
//  }
//
//
//  Future<Map> checkCouponFunction() async{
//    String theCoupon =  _getCoupon.text;
//    String myUrl = funcs.mainLink+'api/checkCoupon/$memberId/$theCoupon';
//    http.Response response = await http.post(myUrl, headers: {"Accept": "application/json"});
//    return json.decode(response.body);
//  }
//
//  void checkCoupon() async{
//    styles.onLoading(context);
//
//    try{
//      Map data = await(checkCouponFunction());
//      Navigator.of(context, rootNavigator: true).pop();
//
//      if(data['theResult'] == 'expired'){
//        _showSnackBar(Translations.of(context).text('coupon_expired_text').toString(),'error');
//      }else if(data['theResult'] == 'not_found'){
//        _showSnackBar(Translations.of(context).text('coupon_not_found_text').toString(),'error');
//      }else if(data['theResult'] == 'is_used'){
//        _showSnackBar(Translations.of(context).text('coupon_used_before_text').toString(),'error');
//      }else{
//        int theAmount = int.parse(data['theResult'][0]['amount']);
//
//        getCartTotalPriceBeforeOrder(theAmount);
//        couponIsValid = true;
//        couponDiscountValue = theAmount.toString();
//      }
//
//    }catch(e){
//      Navigator.of(context, rootNavigator: true).pop();
//      print(e);
//      _showSnackBar(Translations.of(context).text('error_occurred').toString(),'error');
//    }
//
//  }
//
//  void _showSnackBar(String message, String theType) {
//    _scaffoldKey.currentState.showSnackBar(SnackBar(
//      backgroundColor: theType == 'error' ? Colors.red:Colors.green,
//      content: Text(message, style: TextStyle(fontFamily: 'Cairo'),),
//    ));
//  }
//
//
//  getCartTotalPriceBeforeOrder(int couponCodeDiscountAmount) async{
//    cartTotalPrice = await funcs.getCartTotalPriceBeforeOrder(memberId,couponCodeDiscountAmount);
//
//    if(cartTotalPrice != null && double.parse(cartTotalPrice) > 0.0){
//      setState(() {
//        cartTotalPrice = cartTotalPrice;
//        finalPrice = (double.parse(cartTotalPrice) + shippingPrice).toStringAsFixed(2);
//      });
//    }else{
//      setState(() {
//        cartTotalPrice = '0.0';
//        finalPrice = (double.parse(cartTotalPrice) + shippingPrice).toStringAsFixed(2);
//      });
//    }
//
//  }
//
//  void getAddresses() async{
//    setState(() {
//      isLoading = true;
//    });
//    String myUrl = funcs.mainLink+'api/getAddresses/$memberId/';
//    http.Response response = await http.get(myUrl, headers: {"Accept": "application/json"});
//
//    addressesList.add(new DropdownMenuItem(
//      child: new Text(Translations.of(context).text('please_select_delivery_address')),
//      value: '0',
//    ));
//
//
//
//    try{
//      setState(() {
//        isLoading = false;
//      });
//      var responseData = json.decode(response.body);
//      responseData.forEach((addresses){
//        addressesList.add(new DropdownMenuItem(
//          child: new Text(addresses['theTitle']),
//          value: "${addresses['adId']}",
//        ));
//        setState(() {
//          addressId = addresses['adId'];
//
//          _changeAddress(addressId);
//        });
//      },
//      );
//      addressesList.removeWhere((item) => item.value == '0');
//    }catch(e){
//      print(e);
//    }
//
//  }
//
//  _changeAddress(String e) async{
//    String myUrl = funcs.mainLink+'api/getShippingPrice/$e/$memberId';
//    http.Response response = await http.get(myUrl, headers: {"Accept": "application/json"});
//    var theResult = json.decode(response.body);
//
//    setState(() {
//      addressId = e;
//      shippingPrice = double.parse(theResult['thePrice']);
//      finalPrice = (double.parse(cartTotalPrice) + shippingPrice).toStringAsFixed(2);
//    });
//  }
//
//  _addEditAddress(){
//    Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => new AddEditAddress('0','DeliveryAddress')));
////    Navigator.of(context).pushNamedAndRemoveUntil('/AddEditAddress/0',(Route<dynamic> route) => false);
//  }
//
//
//
//  @override
//  Widget build(BuildContext context) {
//
//    // TODO: implement build
//    return new Scaffold(
//      key: _scaffoldKey,
//      appBar: new AppBar(
//        title: new Text(Translations.of(context).text('confirm_order')),
//      ),
//      body: isLoading ? Center(
//        child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),),
//      ):GestureDetector(
//        onTap: ()=> FocusScope.of(context).requestFocus(new FocusNode()),
//        child: ListView(
//          children: <Widget>[
//            new Container(
//              width: 400.0,
//              padding: EdgeInsets.only(right: 0.0, left: 0.0, top: 20.0),
//              alignment: Alignment.topCenter,
//              child: DropdownButtonHideUnderline(
//                child: ButtonTheme(
//                  alignedDropdown: true,
//                  child: new DropdownButton(
//                    items: addressesList,
//                    value: addressId,
//                    onChanged: (value)=> _changeAddress(value),
//                    //                  isExpanded: true,
//                    //                  isDense: false,
//                  ),
//                ),
//              ),
//            ),
//            new Container(
//              padding: EdgeInsets.only(right: 40.0, left: 40.0, top: 20.0, bottom: 20.0),
//              child: new ElevatedButton(
//                onPressed: ()=> _addEditAddress(),
//                padding: EdgeInsets.only(right: 25.0, left: 25.0, top: 5.0, bottom: 5.0 ),
//                child: new Text(Translations.of(context).text('new_address'),style: new TextStyle(color: Colors.white, fontSize: 20.0), textAlign: TextAlign.center),
//                color: Theme.of(context).primaryColor,
//                textColor: Colors.white,
//                shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
//                elevation: 0.0,
//              ),
//            ),
//            new Divider(height: 15.0,color: Colors.black38,),
//            new Container(
//              padding: EdgeInsets.only(right: 40.0, left: 40.0, bottom: 20.0, top: 5.0),
//              child: new TextField(
//                style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w300),
//                textAlign: TextAlign.center,
//                decoration: new InputDecoration(
//                  hintText: Translations.of(context).text('delivery_note').toString(), hintStyle:  new TextStyle(fontFamily: 'Cairo', color: Colors.black54),
//                ),
//                controller: _getDeliveryNote,
//                focusNode: myFocusNode,
//                maxLines: 5,
//                keyboardType: TextInputType.multiline,
//              ),
//            ),
//            new Container(
//              padding: EdgeInsets.only(right: 40.0, left: 40.0, top: 20.0),
//              child: new Text(Translations.of(context).text('coupon'), style: new TextStyle(color: Colors.black87, fontSize: 17.0), textAlign: theAlignment),
//            ),
//            new Row(
//              children: <Widget>[
//                new Container(
//                  padding: EdgeInsets.only(right: 40.0, left: 40.0, top: 10.0),
//                  child: new ElevatedButton(
//                    shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
//                    elevation: 0.0,
//                    onPressed: (){
//                      checkCoupon();
//                    },
//                    padding: EdgeInsets.only(right: 20.0, left: 20.0, top: 5.0, bottom: 5.0 ),
//                    child: new Text(Translations.of(context).text('check_coupon'),style: new TextStyle(color: Colors.white, fontSize: 20.0), textAlign: TextAlign.center),
//                    color: Theme.of(context).primaryColor,
//                    textColor: Colors.white,
//                  ),
//                ),
//                new Expanded(
//                  child: new Container(
//                    padding: EdgeInsets.only(right: 40.0, left: 40.0, top: 0.0),
//                    child: new TextField(
//                      style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w300),
//                      textAlign: TextAlign.center,
//                      decoration: new InputDecoration(
//                        hintText: Translations.of(context).text('coupon').toString(), hintStyle:  new TextStyle(fontFamily: 'Cairo', color: Colors.black54),
//                      ),
//                      controller: _getCoupon,
//                      keyboardType: TextInputType.text,
//                    ),
//                  ),
//                )
//              ],
//            ),
//            SizedBox(height: 30.0,),
//            new Divider(height: 15.0,color: Colors.black38,),
//            SizedBox(height: 30.0,),
//            int.parse(addressId) > 0 ? new Container(
//              padding: EdgeInsets.only(right: 40.0, left: 40.0, top: 0.0),
//              child: new Text(Translations.of(context).text('order_price') + ' $cartTotalPrice USD', style: new TextStyle(color: Colors.black87, fontSize: 16.0), textDirection: theDirection, textAlign: theAlignment),
//            ):new Container(),
//            couponIsValid == true ? new Container(
//              padding: EdgeInsets.only(right: 40.0, left: 40.0, top: 0.0),
//              child: new Text(Translations.of(context).text('coupon_discount_amount_title') + ' $couponDiscountValue%', style: new TextStyle(color: Colors.green, fontSize: 14.0), textDirection: theDirection, textAlign: theAlignment),
//            ):new Container(),
//            int.parse(addressId) > 0 ? new Container(
//              padding: EdgeInsets.only(right: 40.0, left: 40.0, top: 0.0),
//              child: new Text(Translations.of(context).text('shipping_price') +' ${shippingPrice.toString()} USD', style: new TextStyle(color: Colors.black87, fontSize: 16.0), textDirection: theDirection, textAlign: theAlignment),
//            ):new Container(),
//            SizedBox(height: 80.0,),
//          ],
//        ),
//      ),
//      bottomNavigationBar: new Container(
//        color: Color.fromRGBO(212, 212, 212, 1),
//        child: orderDone == false ? Row(
//          children: <Widget>[
//            Expanded(
//              child: new ListTile(
//                title: new Text(Translations.of(context).text('final_price'),style: new TextStyle(color: Colors.black87, fontSize: 16.0), textAlign: TextAlign.center),
//                subtitle: new Text('$finalPrice USD',style: new TextStyle(color: Colors.black87, fontSize: 16.0), textAlign: TextAlign.center),
//              ),
//            ),
//            Expanded(
//              child: new ElevatedButton(
//                shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.only(topLeft: Radius.circular(30.0), bottomLeft: Radius.circular(30.0))),
//                elevation: 0.0,
//                onPressed: (){
//                  if(int.parse(addressId) > 0){
//                    makeAnOrder();
//                  }else{
//                    null;
//                  }
//                },
//                padding: EdgeInsets.only(right: 20.0, left: 20.0, top: 5.0, bottom: 5.0 ),
//                child: new Text(Translations.of(context).text('make_order'),style: new TextStyle(color: Colors.white, fontSize: 20.0), textAlign: TextAlign.center),
//                color: int.parse(addressId) > 0 ? Colors.red: Colors.grey,
//                textColor: Colors.white,
//              ),
//            ),
//          ],
//        ):new Container(
//          padding: EdgeInsets.only(right:20.0, left: 20.0),
//          child: new ElevatedButton(
//            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.only(topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0))),
//            elevation: 0.0,
//            onPressed: (){
//              Navigator.of(context).pushNamedAndRemoveUntil('/Starter',(Route<dynamic> route) => false);
//            },
//            padding: EdgeInsets.only(right: 20.0, left: 20.0, top: 5.0, bottom: 5.0 ),
//            child: new Text(Translations.of(context).text('back_to_products'),style: new TextStyle(color: Colors.white, fontSize: 20.0), textAlign: TextAlign.center),
//            color: Theme.of(context).primaryColor,
//            textColor: Colors.white,
//          ),
//        ),
//      ),
//    );
//  }
//
//}