import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supplyplatform/components/bottom_navigation_bar.dart';
import 'package:supplyplatform/gui/orders/order_details.dart';
import 'package:supplyplatform/components/funcs.dart';
import 'package:supplyplatform/components/styles.dart';
import 'package:supplyplatform/module/get_data.dart';
import 'package:supplyplatform/module/get_orders.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:supplyplatform/components/drawer.dart';

class Orders extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _OrdersState();
  }

}

class _OrdersState extends State<Orders>{

  late String memberId;
  late String fullName = '';
  late String theLanguage = 'en';
  late bool isLogin = false;

  late TextAlign theAlignment;
  late Alignment theTopAlignment;
  bool isLoading = true;
  late String orderNumberTitle;
  int pageId = 1;

  late String notificationsCount = '0';

  var funcs = Funcs();
  var styles = Styles();

  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  var ordersList = <GetOrders>[];

  _getDataList() {
    GetData.getDataList(funcs.mainLink+'api/getOrders/$memberId/$pageId').then((response) {
      setState(() {
        Iterable list = json.decode(response.body);
        ordersList = list.map((model) => GetOrders.fromJson(model)).toList();
        isLoading = false;
      });
    });

  }

  @override
  void initState(){
    super.initState();
    getSharedData().then((result) {
      getUnreadNotificationsCount();
      _getDataList();

      Timer.periodic(const Duration(seconds: 10), (timer) {
        _getDataList();
      });

    });
    _scrollController.addListener((){
      if(_scrollController.position.pixels == _scrollController.position.maxScrollExtent){
        pageId = pageId + 1;
        setState(() {
          isLoading = true;
          _getDataList();
        });
      }
    });
  }

  @override
  void dispose(){
    super.dispose();
  }

  getSharedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      theLanguage = prefs.getString('theLanguage')!;
      memberId = prefs.getString('memberId')!;
      fullName = prefs.getString('fullName')!;
      isLogin = prefs.getBool('isLogin')!;

      if(theLanguage == 'ar'){
        theAlignment = TextAlign.right;
        theTopAlignment = Alignment.topRight;
      }else{
        theAlignment = TextAlign.left;
        theTopAlignment = Alignment.topLeft;
      }

      orderNumberTitle = context.localeString('order_number');

    });
  }

  getUnreadNotificationsCount() async{
    if(isLogin == true){
      notificationsCount = await funcs.getUnreadNotificationsCount();
      setState(() {});
    }
  }

  _openOrderDetailsPage(String invoiceNumber){
    print("invo"+invoiceNumber);
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => OrderDetails(invoiceNumber.toString())));
  }

  _cancelMyOrder(String invoiceNumber){
    if(invoiceNumber.isNotEmpty){
      styles.onLoading(context);
      http.post(Uri.parse(funcs.mainLink+'api/cancelMyOrder'), body: {
        "memberId" : memberId,
        "invoiceNumber" : invoiceNumber
      }).then((result) async{
        var theResult = json.decode(result.body);
        if(theResult['resultFlag'] == 'done'){
          Navigator.of(context, rootNavigator: true).pop();
          _getDataList();
          styles.showSnackBar(scaffoldKey,context,context.localeString('cancel_my_order_successfully').toString(),'success','');
        }else if(theResult['resultFlag'] == 'order_accepted'){
          styles.showSnackBar(scaffoldKey,context,context.localeString('orders_accepted_cannot_cancel'),'error','');
          Navigator.of(context, rootNavigator: true).pop();
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
  }


  Widget widgetOrdersList(){

    return ListView.builder(
      itemCount: ordersList.length,
      controller: _scrollController,
      itemBuilder: (BuildContext context, int index) =>
      Column(
        children: <Widget>[
          Column(
            children: <Widget>[

              ListTile(
                title: Text('''$orderNumberTitle : ${ordersList[index].invoiceNumber}''', style: TextStyle(color: Colors.black  , fontSize: 12), textAlign: theAlignment),
                subtitle: Column(
                crossAxisAlignment:CrossAxisAlignment.start,
                  children: [
                    Text(DateFormat('dd/MM/yyyy').format(DateTime.parse(ordersList[index].theDateTime)) + ' - ' + DateFormat('HH:mm').format(DateTime.parse(ordersList[index].theDateTime)), style: const TextStyle(color: Colors.black45, fontSize: 13.0), textAlign: theAlignment),
                  ],
                ),
                trailing: Text(funcs.getTotalPriceWithCoupon(ordersList[index].ordersTotalPrice,ordersList[index].amount,ordersList[index].couponType,ordersList[index].shippingPrice,ordersList[index].tax, ordersList[index].ordersTotalProfit).toString() + ' ${ordersList[index].symbol}', style: styles.ordersPrice, textAlign: theAlignment),

              ),

              Container(
                  alignment: theTopAlignment,
                  padding: const EdgeInsets.only(right: 15.0, left: 15.0),
                  child: Text(ordersList[index].storeName, style: styles.paragraphTitle, textAlign: theAlignment)
              ),

              // payment method
              ordersList[index].paymentMethod == 'cash_on_delivery' ? Container(
                  alignment: theTopAlignment,
                  padding: const EdgeInsets.only(right: 15.0, left: 15.0),
                  child: Text(context.localeString('cash_on_delivery'), style: styles.orderShippingPrice, textAlign: theAlignment)
              ):Container(),
              ordersList[index].paymentMethod == 'visa_mastercard' ? Container(
                  alignment: theTopAlignment,
                  padding: const EdgeInsets.only(right: 15.0, left: 15.0),
                  child: Text(context.localeString('visa_mastercard'), style: styles.orderShippingPrice, textAlign: theAlignment)
              ):Container(),


              ordersList[index].paymentMethod == 'other' ? Container(
                  alignment: theTopAlignment,
                  padding: const EdgeInsets.only(right: 15.0, left: 15.0),
                  child: Text(context.localeString('others_payment_title'), style: styles.orderShippingPrice, textAlign: theAlignment)
              ):Container(),


              double.parse(ordersList[index].shippingPrice) > 0.0 ?
              Container(
                alignment: theTopAlignment,
                padding: const EdgeInsets.only(right: 15.0, left: 15.0),
                child: Text(context.localeString('shipping_price') + ' ${ordersList[index].shippingPrice} ${ordersList[index].symbol}', style: styles.orderShippingPrice, textAlign: theAlignment),
              ):Container(),

              double.parse(ordersList[index].tax) > 0.0 ?
              Container(
                alignment: theTopAlignment,
                padding: const EdgeInsets.only(right: 15.0, left: 15.0),
                child: Text(context.localeString('tax') + ' ${ordersList[index].tax} ${ordersList[index].symbol}', style: styles.orderShippingPrice, textAlign: theAlignment),
              ):Container(),

              double.parse(ordersList[index].deliveredStatus) != 0 && double.parse(ordersList[index].deliveredStatus) != 1 && ordersList[index].shippingNumber != null?
              Container(
                alignment: theTopAlignment,
                padding: const EdgeInsets.only(right: 15.0, left: 15.0),
                child: Text(context.localeString('shipping_number') + ordersList[index].shippingNumber, style: styles.orderShippingPrice, textAlign: theAlignment),
              ):Container(),

              ordersList[index].theCode != '' ? Container(
                alignment: theTopAlignment,
                padding: const EdgeInsets.only(right: 15.0, left: 15.0),
                child:Text(context.localeString('coupon') + ' ${ordersList[index].theCode}', style: styles.orderShippingPrice, textAlign: theAlignment),
              ):Container(),

              // status
              const SizedBox(height: 10.0,),
              ordersList[index].deliveredStatus == '0' ?
              Container(
                alignment: theTopAlignment,
                padding: const EdgeInsets.only(right: 15.0, left: 15.0),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  ),
                  padding: const EdgeInsets.only(right: 15.0, left: 15.0),
                  child: Text(context.localeString('canceled_status'), style: const TextStyle(color: Colors.white, fontSize: 14.0), textAlign: TextAlign.center),
                ),
              ):Container(),

              ordersList[index].deliveredStatus == '1' ?
              Container(
                alignment: theTopAlignment,
                padding: const EdgeInsets.only(right: 15.0, left: 15.0),
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  ),
                  padding: const EdgeInsets.only(right: 15.0, left: 15.0),
                  child: Text(context.localeString('received_status'), style: const TextStyle(fontWeight:FontWeight.bold  ,color: Colors.green, fontSize: 14.0), textAlign: TextAlign.center),
                ),
              ):Container(),
              const SizedBox(height: 10.0,),
              GestureDetector(
                onTap: (){_openOrderDetailsPage(ordersList[index].invoiceNumber );},
                child: Container(
                  alignment: theTopAlignment,
                  padding: const EdgeInsets.only(right: 15.0, left: 15.0),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color.fromRGBO(194, 171, 131, 1),
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                    padding: const EdgeInsets.only(right: 15.0, left: 15.0),
                    child: Text(context.localeString('view_details'), style: const TextStyle(color: Colors.white, fontSize: 14.0), textAlign: TextAlign.center),
                  ),
                ),
              ),
              const SizedBox(height: 10.0,),
              ordersList[index].deliveredStatus == '2' ?
              Container(
                alignment: theTopAlignment,
                padding: const EdgeInsets.only(right: 15.0, left: 15.0),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  ),
                  padding: const EdgeInsets.only(right: 15.0, left: 15.0),
                  child: Text(context.localeString('confirmed_status'), style: const TextStyle(color: Colors.white, fontSize: 14.0), textAlign: TextAlign.center),
                ),
              ):Container(),

              ordersList[index].deliveredStatus == '3' ?
              Container(
                alignment: theTopAlignment,
                padding: const EdgeInsets.only(right: 15.0, left: 15.0),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.brown,
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  ),
                  padding: const EdgeInsets.only(right: 15.0, left: 15.0),
                  child: Text(context.localeString('shipped_status'), style: const TextStyle(color: Colors.white, fontSize: 14.0), textAlign: TextAlign.center),
                ),
              ):Container(),

              ordersList[index].deliveredStatus == '4' ?
              Container(
                alignment: theTopAlignment,
                padding: const EdgeInsets.only(right: 15.0, left: 15.0),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  ),
                  padding: const EdgeInsets.only(right: 15.0, left: 15.0),
                  child: Text(context.localeString('delivered_status'), style: const TextStyle(color: Colors.white, fontSize: 14.0), textAlign: TextAlign.center),
                ),
              ):Container(),

              ordersList[index].deliveredStatus == '1' ?
              Container(
                padding: const EdgeInsets.only(right: 40.0, left: 40.0, top: 20.0),
                child: ElevatedButton(
                  onPressed: (){_cancelMyOrder(ordersList[index].invoiceNumber); print ("invo "+ordersList[index].invoiceNumber);},
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.only(right: 20.0, left: 20.0, top: 5.0, bottom: 5.0 ),
                    elevation: 0.0,
                    primary: Colors.red,
                    shape: styles.circleBtn(),
                  ),

                  child: Text(context.localeString('cancel_my_order'),style: Theme.of(context).textTheme.button, textAlign: TextAlign.center),



                ),
              ):Container(),

            ],
          ),
          const Divider(),
        ],
      ),
    );


  }

  @override
  Widget build(BuildContext context) {

    // TODO: implement build
    return Scaffold(
      key: scaffoldKey,
      appBar: styles.theAppBar(context, theLanguage, isLogin, context.localeString('my_orders') , true, true, notificationsCount),
      body: Container(
        child: widgetOrdersList()
      ),
      floatingActionButton: isLoading == true ? styles.loadingPage(context):Container(),
      bottomNavigationBar: BottomNavigationBarWidget(3),
      drawer: DrawerClass(isLogin, fullName),
    );
  }

}