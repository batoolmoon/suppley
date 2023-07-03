import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supplyplatform/components/funcs.dart';
import 'package:supplyplatform/components/styles.dart';
import 'package:supplyplatform/components/bottom_navigation_bar.dart';
import 'package:supplyplatform/module/get_data.dart';
import 'package:supplyplatform/module/get_cart.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:supplyplatform/gui/addresses/add_edit_address.dart';
import 'package:supplyplatform/module/get_addresses.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../../module/get_cart.dart';

class Cart extends StatefulWidget{
  const Cart({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _CartState();
  }
}

enum SingingCharacter {cash_on_delivery,visa_mastercard}

class _CartState extends State<Cart>{

  late String memberId;
  late String theLanguage='en';
  late int cartCount;
  late bool isLoading = true;
  late String deviceId;
  late bool isLogin;
  late int currencyId = 1;
  late double currencyExchange;
  late TextAlign theAlignment;
  late Alignment theTopAlignment;
  late TextDirection theDirection;
  String cartTotalPrice = '0.0';
  int couponDiscountValue = 0;
  String couponId = '0';
  String couponType = '';
  late String generalNote = '';
  bool loadingPrices = false;
  late String addressId = '0';
  late String shippingPrice = '0.0';
  late double taxValue = 0.0;
  late bool orderSent = false;
  var delivery_company='';
  List deliveryListFromApi = [];
  late SingingCharacter _paymentMethods = SingingCharacter.cash_on_delivery;
  final TextEditingController _getCoupon = TextEditingController();
  final TextEditingController _getOrderNotes = TextEditingController();

  String deliveryCompanyId="0";
  int index=0;
  var funcs = Funcs();
  var styles = Styles();

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  List<String> deliveryCompanyList = [];
  List<String> deliveryCompanyIdList = [];
  var cartList = <GetCart>[];
  var addressList = <GetAddresses>[];





  _getDataList() {
    GetData.getDataList(funcs.mainLink+'api/getCartData/$theLanguage/$isLogin/$memberId/$currencyId').then((response) {
      print("Member "+memberId);
      setState(() {
        Iterable list = json.decode(response.body);
        cartList = list.map((model) => GetCart.fromJson(model)).toList();
        isLoading = false;
      });
    });
  }

  @override
  void initState(){
    super.initState();
    getSharedData().then((result){
      _getDataList();
      getCartTotalPriceBeforeOrder();
      if(isLogin == true){
        _getAddressesDataList();
      }
      getGeneralNotes().then((result) {
        setState(() {
          generalNote = result['generalnNotesData'][0]['theDetails'];
          getDelivery();
        });
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  getSharedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(mounted){
      setState(() {
        isLogin = prefs.getBool('isLogin')!;
        memberId = prefs.getString('memberId')!;
        theLanguage = prefs.getString('theLanguage')!;
       cartCount = prefs.getInt('cartCount')!;
        deviceId = prefs.getString('deviceId')!;
        currencyId = prefs.getInt('currencyId')!;
        currencyExchange = prefs.getDouble('currencyExchange')!;

        if(isLogin == true){
          memberId = memberId;
        }else{
       memberId = deviceId;
        }

        if(theLanguage == 'ar'){
          theAlignment = TextAlign.right;
          theTopAlignment = Alignment.topRight;
          theDirection = TextDirection.rtl;
        }else{
          theAlignment = TextAlign.left;
          theTopAlignment = Alignment.topLeft;
          theDirection = TextDirection.ltr;
        }

      });
    }
  }

  getDelivery() async {
    isLoading = true;
    GetData.getDataList(funcs.mainLink+'api/getDeliveryCompanies').then((response) {
      setState(() {
        deliveryListFromApi = json.decode(response.body);
        for (var e in deliveryListFromApi) {
          setState(() {

            deliveryCompanyList.add(e['storeName']);
            deliveryCompanyIdList.add(e['stId']);
          });
        }
        deliveryCompanyList.insert(0, context.localeString("nothing"));
        deliveryCompanyIdList.insert(0,"0");
     delivery_company=deliveryCompanyList.first;
        isLoading = false;
      });
    });
  }

  getCartTotalPriceBeforeOrder() async{

    cartTotalPrice = await funcs.getCartTotalPriceBeforeOrder(currencyId, isLogin);

    if(cartTotalPrice != null && double.parse(cartTotalPrice) > 0.0){
      setState(() {
        cartTotalPrice = cartTotalPrice;
       // print("Cart "+cartTotalPrice);
      });
    }else{
      setState(() {
        //print("Cart "+cartTotalPrice);
        cartTotalPrice = '0.0';

      });
    }

  }

//  _deliveryAddress(){
//    if(isLogin == true){
//      Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => DeliveryAddress(couponDiscountValue,couponId)));
//    }else{
//      styles.needLoginModalBottomSheet(context);
//    }
//  }

  Future<Map> changeCartQuantity(String actionType, String orderId) async{

      String myUrl = funcs.mainLink+'api/changeCartQuantity/$actionType/$isLogin/$memberId/$orderId/';
      print("actionType "+actionType);
      print("isLogin "+isLogin.toString());
      print("orderId "+orderId);

    http.Response response = await http.post(Uri.parse(myUrl), headers: {"Accept": "application/text"});
    return json.decode(response.body);
  }

  void minusQty(String orderId, int currentQuantity, int minCount) async {
    print("Min.C "+minCount.toString());
    if (currentQuantity - 1 == 0 || currentQuantity - 1 < minCount){
      styles.showSnackBar(scaffoldKey, context,context.localeString('you_cannot_change_qty_less_than_min_count').toString(),'error','');
    }else{
      setState(() {
        loadingPrices = true;
        cartTotalPrice = '0.0';
      });
      Map data = await(changeCartQuantity('minus',orderId));
      if(data['theResult'] == 1){

        setState(() {
          cartCount = cartCount - 1;
        });

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('cartCount', cartCount);

        await Future.delayed(const Duration(seconds: 3), (){});
        getCartTotalPriceBeforeOrder();
//        _getDataList();
        setState(() {
          loadingPrices = false;
        });
      }else{
        //Navigator.of(context, rootNavigator: true).pop();
        print('Error');
      }
    }
  }

  void addQty(String orderId, int currentQuantity, int productAvailableQuantity) async{
    if(productAvailableQuantity > 0 && currentQuantity + 1 > productAvailableQuantity){
      print('OK');
    }else{
      setState(() {
        loadingPrices = true;
        cartTotalPrice = '0.0';
      });
      Map data = await(changeCartQuantity('add',orderId));
      if(data['theResult'] == 1){

        setState(() {
          cartCount = cartCount + 1;
        });

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('cartCount', cartCount);

        await Future.delayed(const Duration(seconds: 3), (){});
        getCartTotalPriceBeforeOrder();

        setState(() {
          loadingPrices = false;
        });

      }else{
        //Navigator.of(context, rootNavigator: true).pop();
        print('Error');
      }
    }
  }


  void alertDialog(context, String theTitle, String theContent, String orderId, String selectedQuantity) {
    String yes = Locales.string(context, 'yes');
    String no = Locales.string(context, 'no');

    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(theTitle, style: styles.dialogData, textAlign: TextAlign.center,),
        content: Text(theContent, style: styles.dialogData, textAlign: TextAlign.center,),

        actions: [
          TextButton(
            onPressed: (){
              Navigator.of(context, rootNavigator: true).pop();
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.only(right: 20.0, left: 20.0, top: 5.0, bottom: 5.0 ),
            ),

            child: Text(no, style: styles.dialogData),
          ),
          TextButton (

            onPressed: (){
              Navigator.of(context, rootNavigator: true).pop();
              removeItemFromCart(orderId,selectedQuantity);
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.only(right: 20.0, left: 20.0, top: 5.0, bottom: 5.0 ),
            ),

            child: Text(yes, style: styles.dialogData),
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
//            side: BorderSide(color: Colors.red)
        ),
      ),
    );
  }


  void removeItemFromCart(String orderId, String selectedQuantity) async{

    styles.onLoading(context);
    http.post(Uri.parse(funcs.mainLink+'api/removeItemFromCart'), body: {
      "memberId" : memberId,
      "orderId" : orderId,
      "isLogin" : isLogin.toString()
    }).then((result) async{
      var theResult = json.decode(result.body);
      if(theResult['resultFlag'] == 1){
        _getDataList();
        getCartTotalPriceBeforeOrder();
        Navigator.of(context, rootNavigator: true).pop();

        setState(() {
          cartCount = cartCount - int.parse(selectedQuantity) ;
        });
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('cartCount', cartCount);
      }else{
        styles.showSnackBar(scaffoldKey,context,context.localeString('error_occurred'),'error','');
        Navigator.of(context, rootNavigator: true).pop();
      }
    }).catchError((error) {
      print(error);
      styles.showSnackBar(scaffoldKey,context,context.localeString('error_occurred'),'error','');
      Navigator.of(context, rootNavigator: true).pop();
    });
  }


  void makeAnOrder( ) async{

    String thePaymentMethod = _paymentMethods.toString().substring(_paymentMethods.toString().indexOf('.') + 1);
    styles.onLoading(context);

    print("mem2 "+memberId);
    print("add "+addressId);
    print("cop "+couponId);
    print(thePaymentMethod);

    http.post(Uri.parse(funcs.mainLink+'api/makeAnOrder'), body: {
      "memberId" : memberId,
      "addressId" : addressId,
      "couponId" : couponId,
      "paymentMethod" : thePaymentMethod,
      "deliveryNote" : _getOrderNotes.text.trim(),
      "stId":deliveryCompanyId,
    }).then((result) async{
      var theResult = json.decode(result.body);
      if(theResult['resultFlag'] == 1){
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('cartCount', 0);
        setState(() {
          cartTotalPrice = '0.0';
          addressId = '0';
          orderSent = true;
        });
        getCartTotalPriceBeforeOrder();
        Navigator.of(context, rootNavigator: true).pop();

        styles.showSnackBar(scaffoldKey,context,context.localeString('order_successfully_text').toString(),'success','');

        await Future.delayed(const Duration(seconds: 2));
        Navigator.of(context).pushNamedAndRemoveUntil('/Orders',(Route<dynamic> route) => false);

      }else if(theResult['resultFlag'] == 'inactive'){
        styles.showSnackBar(scaffoldKey,context,context.localeString('inactive_account').toString(),'error','');
        Navigator.of(context, rootNavigator: true).pop();
      }else{
        styles.showSnackBar(scaffoldKey,context,context.localeString('error_occurred').toString(),'error','');
        Navigator.of(context, rootNavigator: true).pop();
      }
    }).catchError((error) {
      print(error);
      styles.showSnackBar(scaffoldKey,context,context.localeString('error_occurred'),'error','');
      Navigator.of(context, rootNavigator: true).pop();
    });
  }

  Widget widgetCartListData(dataList,index){

    return GestureDetector(
      child: Container(

        padding: const EdgeInsets.only(top:10.0, right: 10.0, bottom: 1.0, left: 10.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                    width: 80.0,
                    height: 80.0,
                    decoration: BoxDecoration(
                      image: cartList[index].thePhoto != null && cartList[index].thePhoto != '' ? DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(funcs.mainLink+"public/uploads/php/files/products/thumbnail/${cartList[index].thePhoto}"),
                      ):const DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage('images/default.png',)
                      ),
                    )
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                    child: Column(
                      children: [
                        Container(
                          child: RichText(
                            overflow: TextOverflow.ellipsis,
                            strutStyle: const StrutStyle(fontSize: 16.0),
                            textAlign: theAlignment,
                            text: TextSpan(
                                style: styles.productPriceTitleView,
                                text: cartList[index].storeName
                            ),
                          ),
                          width: double.infinity,
                        ),
                        Container(
                          child: RichText(
                            overflow: TextOverflow.ellipsis,
                            strutStyle: const StrutStyle(fontSize: 17.0),
                            textAlign: theAlignment,
                            text: TextSpan(
                                style: styles.productNameView,
                                text: cartList[index].productTitle
                            ),
                          ),
                          width: double.infinity,
                        ),
                        Container(
                          child: RichText(
                            overflow: TextOverflow.ellipsis,
                            strutStyle: const StrutStyle(fontSize: 16.0),
                            textAlign: theAlignment,
                            text: TextSpan(
                                style: styles.productPriceTitleView,
                                text: cartList[index].priceSizeTitle
                            ),
                          ),
                          width: double.infinity,
                        ),
                        // cartList[index].tagTitle != null ? Container(
                        //   child: RichText(
                        //     overflow: TextOverflow.ellipsis,
                        //     strutStyle: const StrutStyle(fontSize: 16.0),
                        //     textAlign: theAlignment,
                        //     text: TextSpan(
                        //         style: styles.productPriceTitleView,
                        //        // text: cartList[index].tagTitle
                        //     ),
                        //   ),
                        //   width: double.infinity,
                        // ):Container(),

                        Row(
                          children: [
                            Expanded(
                              child: cartList[index].theDiscount == '0.00' ? Container(
                                width: double.infinity,
                                child: Text(funcs.getTotalPrice(cartList[index].thePrice,cartList[index].theDiscount, int.parse(cartList[index].selectedQuantity), currencyExchange/*, cartList[index].categoryProfit*/).toStringAsFixed(2) + ' ${cartList[index].symbol}', style: styles.productPrice, textAlign: theAlignment),
                              ):
                              Column(
                                children: <Widget>[
                                  Container(
                                    child: Text(funcs.getPriceBeforeDiscount(cartList[index].thePrice,cartList[index].theDiscount, int.parse(cartList[index].selectedQuantity), currencyExchange/*,cartList[index].categoryProfit*/).toStringAsFixed(2) + ' ${cartList[index].symbol}', style: styles.lineThroughPrice, textAlign: theAlignment),
                                    width: double.infinity,
                                  ),
                                  Container(
                                    child: Text(funcs.getPriceAfterDiscount(cartList[index].thePrice,cartList[index].theDiscount, int.parse(cartList[index].selectedQuantity), currencyExchange/*,cartList[index].categoryProfit*/).toStringAsFixed(2)+ ' ${cartList[index].symbol}', style: styles.discountPrice, textAlign: theAlignment),
                                    width: double.infinity,
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    width: 35.0,
                                    height: 35.0,
                                    decoration: ShapeDecoration(
                                      color:  Color.fromRGBO(194, 171, 131, 1),
                                      shape: styles.circleBtn(),
                                    ),
                                    child: IconButton(
                                      onPressed: (){
                                        minusQty(cartList[index].orId,int.parse(cartList[index].selectedQuantity),int.parse(cartList[index].minCount));
                                        setState(() {
                                          if(int.parse(cartList[index].selectedQuantity) - 1 >= int.parse(cartList[index].minCount)){
                                            cartList[index].selectedQuantity = (int.parse(cartList[index].selectedQuantity) - 1).toString();
                                          }
                                        });
                                      },
                                      padding: const EdgeInsets.all(2.0),
                                      icon: const Icon(Icons.keyboard_arrow_down_sharp),
                                      color: Colors.white,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(cartList[index].selectedQuantity, style: const TextStyle(fontSize: 20.0, color: Colors.black87), textAlign: TextAlign.center,),
                                  ),
                                  Container(
                                    width: 35,
                                   height: 35,
                                    decoration: ShapeDecoration(
                                      color: Color.fromRGBO(194, 171, 131, 1),
                                      shape: styles.circleBtn(),
                                    ),
                                    child: IconButton(
                                      onPressed: (){
                                        addQty(cartList[index].orId,int.parse(cartList[index].selectedQuantity), int.parse(cartList[index].productAvailableQuantity));
                                        setState(() {
                                          if(int.parse(cartList[index].productAvailableQuantity) > int.parse(cartList[index].selectedQuantity) + 1){
                                            cartList[index].selectedQuantity = (int.parse(cartList[index].selectedQuantity) + 1).toString();
                                          }
                                        });
                                      },
                                      padding: const EdgeInsets.all(2.0),
                                      icon: const Icon(Icons.keyboard_arrow_up_sharp),
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 15.0,),
                        Align(
                          alignment: theTopAlignment,
                          child: ElevatedButton(
                            style:ElevatedButton.styleFrom(
                                elevation: 0.0,
                              primary: styles.deleteColor,
                              shape: styles.circleBtn(),
                            ) ,
                            onPressed: ()=> alertDialog(context,context.localeString('delete_cart_dialog_title'),context.localeString('delete_cart_dialog_content'),cartList[index].orId,cartList[index].selectedQuantity),
                            child: Text(context.localeString('delete_btn'),style: Theme.of(context).textTheme.button, textAlign: theAlignment),



                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),

            const SizedBox(height: 5.0,),
            const Divider(),
          ],
        ),
      ),
    );
  }


  void checkCoupon() async{
    String theCoupon =  _getCoupon.text.trim();
    styles.onLoading(context);
    http.post(Uri.parse(funcs.mainLink+'api/checkCoupon'), body: {
      "memberId" : memberId,
      "theCoupon" : theCoupon,
    }).then((result) async{
      var theResult = json.decode(result.body);
      if(theResult['resultFlag'] == 'expired'){
        styles.showSnackBar(scaffoldKey, context,Locales.string(context, 'coupon_expired_text'),'error','');
        Navigator.of(context, rootNavigator: true).pop();
      }else if(theResult['resultFlag'] == 'not_found'){
        styles.showSnackBar(scaffoldKey, context,Locales.string(context, 'coupon_not_found_text'),'error','');
        Navigator.of(context, rootNavigator: true).pop();
      }else if(theResult['resultFlag'] == 'not_same_store'){
        styles.showSnackBar(scaffoldKey, context,Locales.string(context, 'coupon_not_same_store'),'error','');
        Navigator.of(context, rootNavigator: true).pop();
      }else if(theResult['resultFlag'] == 'is_used'){
        styles.showSnackBar(scaffoldKey, context,Locales.string(context, 'coupon_used_before_text'),'error','');
        Navigator.of(context, rootNavigator: true).pop();
      }else if(theResult['resultFlag'] == 'out_of_count'){
        styles.showSnackBar(scaffoldKey, context,Locales.string(context, 'coupon_out_of_count'),'error','');
        Navigator.of(context, rootNavigator: true).pop();
      }else{
        int theAmount = int.parse(theResult['resultFlag'][0]['amount']);

        setState(() {
          couponDiscountValue = theAmount;
          couponId = theResult['resultFlag'][0]['coId'];
          couponType = theResult['resultFlag'][0]['theType'];
        });
        getCartTotalPriceBeforeOrder();
        Navigator.of(context, rootNavigator: true).pop();
      }
    }).catchError((error) {
      print(error);
      styles.showSnackBar(scaffoldKey,context,Locales.string(context, 'error_occurred'),'error','');
      Navigator.of(context, rootNavigator: true).pop();
    });
  }


  _getAddressesDataList() {
    GetData.getDataList(
        funcs.mainLink+'api/getAddresses/$memberId/$theLanguage').then((response) {
      setState(() {
        Iterable list = json.decode(response.body);
        addressList = list.map((model) => GetAddresses.fromJson(model)).toList();
        isLoading = false;
      });
    });
  }

  Widget widgetAddressesList(addressList,index){

    return Column(
      children: <Widget>[
        ListTile(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.only(right: 10.0, left: 10.0, top: 0.0),
                alignment: theTopAlignment,
                child: Text(addressList[index].theTitle, style: styles.paragraphTitle, textAlign: theAlignment),
              ),
              const SizedBox(width: 10.0,),
              int.parse(addressId) > 0 && int.parse(addressList[index].adId) == int.parse(addressId) ? Image.asset(
                'images/right.gif',
                width: 20.0,
              ):Container()
            ],
          ),
          subtitle: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(right: 10.0, left: 10.0, top: 0.0),
                child: Text('''${addressList[index].fullName}
${addressList[index].addressDetails}
${addressList[index].street}
${addressList[index].theArea} - ${addressList[index].theCity} -   ${addressList[index].theCountry} 
${addressList[index].mobileNumber}         
''', textAlign: theAlignment, style:  TextStyle(color: int.parse(addressId) > 0 && int.parse(addressList[index].adId) == int.parse(addressId) ? Colors.green: Colors.black87),),
                alignment: theTopAlignment,
              ),
              Row(
                children: [
                  Container(

                    padding: const EdgeInsets.only(right: 10.0, left: 10.0, top: 10.0),
                    alignment: theTopAlignment,
                    child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      primary:Color.fromRGBO(0,0,91,1),
      shape: styles.circleBtn(),
   ),
                      onPressed: ()=> _addEditAddress(addressList[index].adId),

                      child: Text(context.localeString('edit_btn'),style: Theme.of(context).textTheme.button, textAlign: TextAlign.center),



                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(right: 10.0, left: 10.0, top: 10.0),
                    alignment: theTopAlignment,
                    child: ElevatedButton(
                      onPressed: (){
                        setState(() {
                          addressId = addressList[index].adId;
                          getShippingPrices(index,addressList[index].adId);
                        });
                      },
                      style:ElevatedButton.styleFrom(
                        padding: const EdgeInsets.only(right: 20.0, left: 20.0, top: 5.0, bottom: 5.0 ),
                        elevation: 0.0,
                        primary: Color.fromRGBO(194, 171, 131, 1),
                        shape: styles.circleBtn(),
                      ) ,

                      child: Text(context.localeString('select_address'),style: Theme.of(context).textTheme.button, textAlign: TextAlign.center),

                    ),
                  ),
                ],
              )
            ],
          ),
        ),
        const Divider(),
      ],
    );

  }

  getShippingPrices(index,addressId) async{
    styles.onLoading(context);
    var myUrl = Uri.parse(funcs.mainLink+'api/getShippingPrices/$memberId/$addressId/$cartTotalPrice');
    http.Response response = await http.get(myUrl, headers: {"Accept": "application/json"});
    try{
      Navigator.of(context, rootNavigator: true).pop();
      var theShippingPrice = json.decode(response.body);
      if(theShippingPrice['shippingOfferFlag'] == true){

        setState(() {
          shippingPrice = (double.parse(theShippingPrice['shippingPrice']) * currencyExchange).toStringAsFixed(2);
        });
        getCartTotalPriceBeforeOrder();
      }else{
        setState(() {
          shippingPrice = (double.parse(theShippingPrice['shippingPrice']) * currencyExchange).toStringAsFixed(2);
        });
        getCartTotalPriceBeforeOrder();
      }

    }catch(e){
      print(e);
    }
  }

  _addEditAddress(String addressId){
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => AddEditAddress(addressId,'DeliveryAddress',couponDiscountValue,couponId)));
  }

  Future<Map> getGeneralNotes() async{
    setState(() {
      isLoading = true;
    });
    var result;
    var myUrl = Uri.parse(funcs.mainLink+'api/getGeneralNotes/$theLanguage/orders');
    http.Response response = await http.get(myUrl, headers: {"Accept": "application/json"});
    try{
      setState(() {
        isLoading = false;
      });
      result = json.decode(response.body);
    }catch(e){
      print(e);
    }
    return result;
  }

  Future<bool> _onWillPop() async{
    Navigator.pop(context,true);
    return false;
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          foregroundColor: Colors.white,
          backgroundColor: Theme.of(context).primaryColor,
          title: Text(context.localeString('cart'), style: styles.appBarStyle),
          automaticallyImplyLeading: false,
        ),
        body: cartList.isNotEmpty ? CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          physics: const ClampingScrollPhysics(),
          controller: _scrollController,
          slivers: <Widget>[
            SliverGrid(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: MediaQuery.of(context).size.width / 1,
                childAspectRatio: MediaQuery.of(context).size.width / (240),
//                childAspectRatio: 0.7,
                mainAxisSpacing: 1.0,
                crossAxisSpacing: 1.0,
              ),
              delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                  return widgetCartListData(cartList,index);
                },
                childCount: cartList.length,
              ),
            ),

            SliverList(
                delegate: SliverChildListDelegate([
                  Container(
                    padding: const EdgeInsets.only(right: 20.0, left: 20.0, top: 0.0, bottom: 10.0 ),
                    child: Text(context.localeString('addresses'), style: styles.paragraphTitle,),
                    width: double.infinity,
                  ),
                ])
            ),

            addressList.isNotEmpty ? SliverGrid(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: MediaQuery.of(context).size.width / 1,
                childAspectRatio: MediaQuery.of(context).size.width / (290),
//                childAspectRatio: 0.7,
                mainAxisSpacing: 0.0,
                crossAxisSpacing: 0.0,
              ),
              delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                  return widgetAddressesList(addressList,index);
                },
                childCount: addressList.length,
              ),
            ):SliverList(
                delegate: SliverChildListDelegate([
                  Container(
                    padding: const EdgeInsets.only(right: 40.0, left: 40.0, top: 20.0, bottom: 30.0),
                    child: Column(
                      children: [
                        Text(context.localeString('you_do_not_have_address'), style: styles.paragraphText, textAlign: TextAlign.center,),
                        IconButton(
                          icon: const Icon(Icons.add, size: 30.0,),
                          tooltip: context.localeString('add_new_address'),
                          onPressed: () {
                            if(isLogin == true){
                              _addEditAddress('0');
                            }else{
                              styles.needLoginModalBottomSheet(context);
                            }
                          },
                        ),
                        Text(context.localeString('add_new_address'))
                      ],
                    ),
                  ),
                ])
            ),
            SliverList(delegate: SliverChildListDelegate(
              [
                Container(
                    padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                    child: Row(
                      children: [
                        Text(context.localeString("select_delivery_company"), style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color:Colors.black ), textAlign: theAlignment),
                        SizedBox(width:5,),
                        Icon(Icons.local_shipping)
                      ],
                    )),
                Container(
                  padding:EdgeInsets.all(10),
                  margin:EdgeInsets.all(10),

                  child: DropdownSearch<String>(
                    popupProps: PopupProps.menu(
                      showSearchBox: true,
                      showSelectedItems: true,
                    ),
                    items: deliveryCompanyList.toList(),
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        hintText: context.localeString("select"),
                        label: Text(context.localeString("select")),
                      ),
                    ),
                    onChanged:(val){
                      print(val);
                      print(deliveryCompanyList.indexOf(val!));
                      var index=deliveryCompanyList.indexOf(val!);
                      index=deliveryCompanyList.indexOf(val!);
                      deliveryCompanyId=deliveryCompanyIdList[index].toString();
                      print("Id "+deliveryCompanyId);
                    } ,
                  selectedItem: delivery_company,
                  )
                ),
                Divider(),
              ]
            ),

            ),
            SliverList(
                delegate: SliverChildListDelegate([
                  Container(
                    padding: const EdgeInsets.only(right: 20.0, left: 20.0, top: 0.0, bottom: 0.0 ),
                    child: Text(context.localeString('coupon_code_title'), style: styles.paragraphTitle,),
                    width: double.infinity,
                    height: 30.0,
                  ),
                  couponDiscountValue == 0 ? Container(
                    child : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          margin: const EdgeInsets.only(top:10) ,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.only(right: 20.0, left: 20.0, top: 0.0, bottom: 5.0 ),
                          child: ElevatedButton(
                            onPressed: (){
                              if(isLogin == true){
                                checkCoupon();
                              }else{
                                styles.needLoginModalBottomSheet(context);
                              }
                            },
                            style:ElevatedButton.styleFrom(

                              padding: const EdgeInsets.only(right: 20.0, left: 20.0, top: 5.0, bottom: 5.0 ),
                              elevation: 0.0,
                              primary: Color.fromRGBO(194, 171, 131, 1),
                                shape: styles.circleBtn()
                            ) ,

                            child: Text(context.localeString('check_coupon'), style:Theme.of(context).textTheme.button, textAlign: TextAlign.center),



                          ),
                        ),
                        Expanded(
                          child: Container(

                            alignment: Alignment.topCenter,
                            padding: const EdgeInsets.only(right: 40.0, left: 40.0, top: 10.0),
                            margin:const EdgeInsets.only(right: 40.0, left: 40.0, top: 10.0) ,
                            child: TextField(
                              style: styles.inputTextStyle,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                hintText: context.localeString('coupon').toString(), hintStyle:  styles.inputTextHintStyle,
                              ),
                              controller: _getCoupon,
                              keyboardType: TextInputType.text,
                              maxLines: null,
                            ),
                          ),
                        )
                      ],
                    ),
                    color: const Color.fromRGBO(255, 255, 255, 1),
                    margin: const EdgeInsets.only(bottom: 25.0),
                  ):Container(
                    child: Text(couponType == 'fixed' ? context.localeString('coupon_discount_amount_title') + ' $couponDiscountValue JOD' : context.localeString('coupon_discount_amount_title') + ' $couponDiscountValue%', style: styles.couponValueYouWinTitle, textDirection: theDirection, textAlign: TextAlign.center),
                    width: double.infinity,
                    height: 30.0,
                    color: Colors.green,
                    margin: const EdgeInsets.only(bottom: 20.0, top: 10.0, right: 15.0, left: 15.0),
                  ),

                  const Divider()
                ])
            ),

            SliverList(
                delegate: SliverChildListDelegate([
                  Container(
                    padding: const EdgeInsets.only(right: 10.0, left: 10.0, top: 0.0, bottom: 5.0 ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(

                          title: Text(context.localeString('cash_on_delivery').toString()),
                          leading: Radio(

                            activeColor: Theme.of(context).primaryColor,
                            value: SingingCharacter.cash_on_delivery,
                            groupValue: _paymentMethods,
                            onChanged: (SingingCharacter? value) {
                              setState(() {
                                _paymentMethods = value!;
                              });
                            },
                          ),
                        ),
                        ListTile(
                          trailing: Icon(Icons.credit_card),
                          title: Text(context.localeString('visa_mastercard').toString()),
                          leading: Radio(
                            activeColor: Theme.of(context).primaryColor,
                            value: SingingCharacter.visa_mastercard,
                            groupValue: _paymentMethods,
                            onChanged: (SingingCharacter? value) {
                              setState(() {
                                _paymentMethods = value!;
                              });
                            },
                          ),
                        ),


                        generalNote.isNotEmpty ? Container(
                          padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                          child: Text(context.localeString('note'), style: styles.paragraphTitle, textAlign: theAlignment,),
                        ):Container(),
                        generalNote.isNotEmpty ? Container(
                          padding: const EdgeInsets.only(top: 5, left: 20, right: 20, bottom: 50),
                          child: Text(generalNote, style: styles.paragraphText, textAlign: theAlignment,),
                        ):Container(),

                        Container(
                          padding: const EdgeInsets.only(right: 30.0, left: 30.0, bottom: 30.0, top: 20.0),
                          child: TextField(
                            style: styles.inputTextStyle,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                                hintText: context.localeString('delivery_note'), hintStyle:  styles.inputTextHintStyle,
                                fillColor: Colors.white
                            ),
                            controller: _getOrderNotes,
                            keyboardType: TextInputType.text,
                            maxLines: 3,
                          ),
                        ),
                      ],
                    ),
                  )
                ])
            ),

            SliverList(
                delegate: SliverChildListDelegate([

                  Container(
                    color: const Color.fromRGBO(245, 245, 245, 1),
                    child: Column(
                      children: [
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: ListTile(
                                title: Text(context.localeString('total_price'), style: const TextStyle(color: Colors.black87, fontSize: 13.0), textAlign: TextAlign.center),
                                subtitle: double.parse(cartTotalPrice) > 0.0 ?
                                Text(cartTotalPrice.toString() +' '+ cartList[0].symbol,style: styles.productPrice, textAlign: TextAlign.center):
                                SizedBox(
                                  height: 3.0,
                                  child: LinearProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor), backgroundColor: const Color.fromRGBO(245, 245, 245, 1), minHeight: 1,),
                                ),
                              ),
                            ),
                            Expanded(
                              child: ListTile(
                                title: Text(context.localeString('shipping_price'),style: const TextStyle(color: Colors.black87, fontSize: 13.0), textAlign: TextAlign.center),
                                subtitle: Text(shippingPrice.toString() +' '+ cartList[0].symbol,style: styles.productPrice, textAlign: TextAlign.center),
                              ),
                            ),
                            taxValue > 0.0 ? Expanded(
                              child: ListTile(
                                title: Text(context.localeString('tax'),style: const TextStyle(color: Colors.black87, fontSize: 13.0), textAlign: TextAlign.center),
                                subtitle:  Text(funcs.getTax(cartTotalPrice, shippingPrice, taxValue).toString() + ' ' +  cartList[0].symbol,style: styles.productPrice, textAlign: TextAlign.center),
                              ),
                            ):Container(),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: ListTile(
                                title: Text(context.localeString('payment_price'),style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13.0), textAlign: TextAlign.center),
                                subtitle: Text(funcs.getPaymentPrice(cartTotalPrice, shippingPrice, taxValue, couponDiscountValue, couponType).toStringAsFixed(2) +' '+ cartList[0].symbol,style: styles.productPrice, textAlign: TextAlign.center),
                                //subtitle: Text(cartTotalPrice +' ' + cartList[0].symbol,style: styles.productPrice, textAlign: TextAlign.center),
                              ),
                            ),
                            Expanded(
                              child: ElevatedButton(
                                style:ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.only(right: 10.0, left: 10.0, top: 5.0, bottom: 5.0 ),
                                  elevation: 0.0,
                                    shape: styles.circleBtn(),
                                   primary: double.parse(cartTotalPrice) > 0.0 && int.parse(addressId) > 0 && _paymentMethods != null ? styles.nextColor: Color.fromRGBO(254, 197, 2, 1),
                                ) ,


                                onPressed: (){
                                  if (addressId=="0"){ print (addressId); styles.showSnackBar(scaffoldKey, context, Locales.string(context,"put_address"), 'error', '');}
                                  if(double.parse(cartTotalPrice) > 0.0 && double.parse(addressId) >0 && _paymentMethods != null){
                                    if(isLogin==true){
                                    print("order ");}
                                    else{styles.needLoginModalBottomSheet(context);}
                                    makeAnOrder();
                                  }else{
                                    null;
                                  }
                                },

                                child: Text(context.localeString('make_order'),style: Theme.of(context).textTheme.button, textAlign: TextAlign.center),

                              ),
                            ),
                            const SizedBox(width: 10.0),
                          ],
                        )
                      ],
                    ),

                  )

                ])
            )

          ],
        ):Container(
          alignment: Alignment.center,
          child: Column(
            children: <Widget>[
              Image.asset(
                'images/nodatafound.png',
                width: 200.0,
              ),
              Text(context.localeString('no_data')),
            ],
          ),
        ),
        floatingActionButton: isLoading == true ? styles.loadingPage(context):Container(),
        bottomNavigationBar: BottomNavigationBarWidget(2),

      ),
    );
  }

}







