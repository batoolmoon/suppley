import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supplyplatform/gui/stores/store_order_details.dart';
import 'package:supplyplatform/components/funcs.dart';
import 'package:supplyplatform/components/styles.dart';
import 'package:supplyplatform/module/get_data.dart';
import 'package:supplyplatform/module/get_orders.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:supplyplatform/components/store_drawer.dart';

import 'delivery_drawer.dart';

class deliveryStatus extends StatefulWidget{
  deliveryStatus(this.dStatus);
  String dStatus;
  @override

  _deliveryStatusState createState() => _deliveryStatusState(dStatus);

}



class _deliveryStatusState extends State<deliveryStatus>{
  _deliveryStatusState( this.dStatus);

  String dStatus;
  late String storeId;
  late String storeName = '';
  late String theLanguage = '';
  late bool isLogin = false;

  late TextAlign theAlignment;
  late Alignment theTopAlignment;
  bool isLoading = true;
  late String orderNumberTitle = '';
  int pageId = 1;

  var funcs = Funcs();
  var styles = Styles();

  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  var ordersList = <GetOrders>[];

  _getDataList(int pageId) {
    GetData.getDataList(funcs.mainLink+'api/getDeliveryOrders/$storeId/$pageId').then((response) {
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
      _getDataList(pageId);
    });
    _scrollController.addListener((){
      if(_scrollController.position.pixels == _scrollController.position.maxScrollExtent){
        pageId = pageId + 1;
        setState(() {
          isLoading = true;
          _getDataList(pageId);
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
   storeId = prefs.getString('deliveryId')!;
      storeName = prefs.getString('deliveryName')!;
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


  _openOrderDetailsPage(String invoiceNumber,String  orderTotalPrice){
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => StoreOrderDetails(invoiceNumber.toString(), orderTotalPrice)));
  }


  void orderStatusBottomSheet(context, String orderId, String orderNumber){

    String delivered;
    String shipped;

    shipped = Locales.string(context, 'shipped_title');
    delivered = Locales.string(context, 'delivered_title');

    showModalBottomSheet(
        context: context,
        isScrollControlled:true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
        ),

        builder: (BuildContext bc){
          return Container(
            child: Wrap(
              children: <Widget>[
                ListTile(
                  title: Text(orderNumber, style: TextStyle(color: Colors.black, fontFamily: 'Cairo', fontSize: 18.0,), textAlign: TextAlign.center),
                ),
                const Divider(),

                ListTile(
                    title: Text(shipped, style: styles.listTileStyle2, textAlign: TextAlign.center),
                    onTap: (){
                      Navigator.pop(context);
                      _changeOrderStatus(orderNumber,orderId,'3');
                    }
                ),

                ListTile(
                    title: Text(delivered, style: styles.listTileStyle2, textAlign: TextAlign.center),
                    onTap: (){
                      Navigator.pop(context);
                      _changeOrderStatus(orderNumber,orderId,'4');
                    }
                ),

              ],
            ),
          );
        }
    );
  }

  _changeOrderStatus(String invoiceNumber, String orderId, String orderStatus){

    if(invoiceNumber.isNotEmpty){
      styles.onLoading(context);
      http.post(Uri.parse(funcs.mainLink+'api/changeStoreOrderStatus'), body: {
        "storeId" : storeId,
        "invoiceNumber" : invoiceNumber,
        "orderId" : orderId,
        "orderStatus" : orderStatus
      }).then((result) async{
        var theResult = json.decode(result.body);
        if(theResult['resultFlag'] == 'done'){
          Navigator.of(context, rootNavigator: true).pop();
          _getDataList(pageId);
          styles.showSnackBar(scaffoldKey,context,context.localeString('status_changes_successfully').toString(),'success','');
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
                    title: Text('''$orderNumberTitle : ${ordersList[index].invoiceNumber}''', style: TextStyle(fontSize: 12 , color: Colors.black), textAlign: theAlignment),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(DateFormat('dd/MM/yyyy').format(DateTime.parse(ordersList[index].theDateTime)) + ' - ' + DateFormat('HH:mm').format(DateTime.parse(ordersList[index].theDateTime)), style: const TextStyle(color: Colors.black45, fontSize: 13.0), textAlign: theAlignment),
                        Text(context.localeString('name')+":  "+ordersList[index].storeName+'  ' +context.localeString('amount')+":  "+(ordersList[index].amount ),style: TextStyle(fontSize: 15 , color: Colors.black , fontWeight: FontWeight.bold),)
                      ],
                    ),
                    trailing: Text(funcs.getTotalPriceWithCoupon(ordersList[index].ordersTotalPrice,ordersList[index].amount,ordersList[index].couponType,'0.0',ordersList[index].tax, '0').toString() + ' ${ordersList[index].symbol}', style: styles.ordersPrice, textAlign: theAlignment),

                    //  onTap: ()=> _openOrderDetailsPage(ordersList[index].invoiceNumber.ersList[index].invoiceNumber,funcs.getTotalPriceWithCoupon(ordersList[index].ordersTotalPrice,ordersList[index].amount,ordersList[index].couponType,'0.0',ordersList[index].tax, '0').toString()),
                  ),

                  // status
                  dStatus=='0' ?
                  Container(
                    alignment: theTopAlignment,
                    padding: const EdgeInsets.only(right: 15.0, left: 15.0),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      ),
                      padding: const EdgeInsets.only(right: 15.0, left: 15.0),
                      child: Text(context.localeString('canceled_status'), style: const TextStyle(color: Colors.white, fontSize: 14.0), textAlign: TextAlign.center),
                    ),
                  ):Container(),

                 dStatus== '1' ?
                  Container(
                    alignment: theTopAlignment,
                    padding: const EdgeInsets.only(right: 15.0, left: 15.0),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      ),
                      padding: const EdgeInsets.only(right: 15.0, left: 15.0),
                      child: Text(context.localeString('received_status'), style: const TextStyle(color: Colors.white, fontSize: 14.0), textAlign: TextAlign.center),
                    ),
                  ):Container(),

                  dStatus== '2' ?
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

                  dStatus=='3' ?
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

                  dStatus=='4' ?
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

                  // payment method
                  ordersList[index].paymentMethod == 'cash_on_delivery' ? Container(
                      alignment: theTopAlignment,
                      padding: const EdgeInsets.only(right: 15.0, left: 15.0),
                      child: Text(context.localeString('cash_on_delivery'), style: styles.orderShippingPrice, textAlign: theAlignment)
                  ):Container(),
                  ordersList[index].paymentMethod == 'credit' ? Container(
                      alignment: theTopAlignment,
                      padding: const EdgeInsets.only(right: 15.0, left: 15.0),
                      child: Text(context.localeString('credit_card_title'), style: styles.orderShippingPrice, textAlign: theAlignment)
                  ):Container(),

                  ordersList[index].paymentMethod == 'transfer' ? Container(
                      alignment: theTopAlignment,
                      padding: const EdgeInsets.only(right: 15.0, left: 15.0),
                      child: Text(context.localeString('transfer_title'), style: styles.orderShippingPrice, textAlign: theAlignment)
                  ):Container(),

                  ordersList[index].paymentMethod == 'other' ? Container(
                      alignment: theTopAlignment,
                      padding: const EdgeInsets.only(right: 15.0, left: 15.0),
                      child: Text(context.localeString('others_payment_title'), style: styles.orderShippingPrice, textAlign: theAlignment)
                  ):Container(),


//                  double.parse(ordersList[index].shippingPrice) > 0.0 ?
//                  Container(
//                    alignment: theTopAlignment,
//                    padding: const EdgeInsets.only(right: 15.0, left: 15.0),
//                    child: Text(context.localeString('shipping_price') + ' ${ordersList[index].shippingPrice} ${ordersList[index].symbol}', style: styles.orderShippingPrice, textAlign: theAlignment),
//                  ):Container(),

                  double.parse(ordersList[index].tax) > 0.0 ?
                  Container(
                    alignment: theTopAlignment,
                    padding: const EdgeInsets.only(right: 15.0, left: 15.0),
                    child: Text(context.localeString('tax') + ' ${ordersList[index].tax} ${ordersList[index].symbol}', style: styles.orderShippingPrice, textAlign: theAlignment),
                  ):Container(),

//                  double.parse(ordersList[index].deliveredStatus) != 0 && double.parse(ordersList[index].deliveredStatus) != 1 && ordersList[index].shippingNumber != null?
//                  Container(
//                    alignment: theTopAlignment,
//                    padding: const EdgeInsets.only(right: 15.0, left: 15.0),
//                    child: Text(context.localeString('shipping_number') + ordersList[index].shippingNumber, style: styles.orderShippingPrice, textAlign: theAlignment),
//                  ):Container(),

                  ordersList[index].theCode != '' ? Container(
                    alignment: theTopAlignment,
                    padding: const EdgeInsets.only(right: 15.0, left: 15.0),
                    child:Text(context.localeString('coupon') + ' ${ordersList[index].theCode}', style: styles.orderShippingPrice, textAlign: theAlignment),
                  ):Container(),

                  const SizedBox(height: 10.0,),

                  GestureDetector(
                    onTap: (){
                      orderStatusBottomSheet(context, ordersList[index].orId, ordersList[index].invoiceNumber);
                    },
                    child: Container(
                      padding: const EdgeInsets.only(right: 15.0, left: 15.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).secondaryHeaderColor,
                        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                      ),
                      child: Text(context.localeString('change_order_status'), style: const TextStyle(color: Colors.white, fontSize: 14.0), textAlign: TextAlign.center),
                    ),
                  )

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
      appBar: AppBar(title: Text(context.localeString("my_order"),style: styles.appBarStyle, ),
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
        elevation: 0.5,
        actions: [
          IconButton(onPressed: () { Navigator.pop(context); }, icon: Icon(Icons.arrow_back),)
        ],
      ),
      body: Container(
          child: widgetOrdersList()
      ),
      floatingActionButton: isLoading == true ? styles.loadingPage(context):Container(),
      drawer: deliveryDrawerClass(true),
    );
  }

}