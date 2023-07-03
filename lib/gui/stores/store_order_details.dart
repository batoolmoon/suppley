import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supplyplatform/components/funcs.dart';
import 'package:supplyplatform/components/styles.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:supplyplatform/module/get_data.dart';
import 'package:supplyplatform/module/get_order_products.dart';

class StoreOrderDetails extends StatefulWidget{
  StoreOrderDetails(this.invoiceNumber, this.orderTotalPrice);
  String invoiceNumber;
  String orderTotalPrice;

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _StoreOrderDetailsState(invoiceNumber,orderTotalPrice);
  }

}

class _StoreOrderDetailsState extends State<StoreOrderDetails>{
  _StoreOrderDetailsState(this.invoiceNumber, this.orderTotalPrice);
  late String invoiceNumber;
  String orderTotalPrice;
  late String storeId;
  late bool isLogin;
  late String theLanguage;
  late TextAlign theAlignment;
  bool isLoading = true;

  var funcs = Funcs();
  var styles = Styles();

  var orderDetailsList = <GetOrderProducts>[];
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  _getDataList() {
    GetData.getDataList(funcs.mainLink+'api/getStoreOrdersDetails/$theLanguage/$storeId/$invoiceNumber').then((response) {
      setState(() {
        Iterable list = json.decode(response.body);
        orderDetailsList = list.map((model) => GetOrderProducts.fromJson(model)).toList();
        isLoading = false;
      });
    });

  }

  @override
  void initState(){
    super.initState();
    getSharedData().then((result) {
      _getDataList();
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
        storeId = prefs.getString('storeId')!;
        theLanguage = prefs.getString('theLanguage')!;
        isLogin = prefs.getBool('isLogin')!;

        if(theLanguage == 'ar'){
          theAlignment = TextAlign.right;
        }else{
          theAlignment = TextAlign.left;
        }

      });
    }
  }



  Widget widgetProductsData(){

    return GridView.builder(
      itemCount: orderDetailsList.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: MediaQuery.of(context).size.width / (790),
      ),
      shrinkWrap: false,
      itemBuilder: (BuildContext context, int index) =>
          styles.widgetProductsForStores(scaffoldKey,context, isLogin, storeId, double.parse(orderDetailsList[0].currencyExchange), orderDetailsList,index,'orders',1),
    );
  }


  @override
  Widget build(BuildContext context) {

    // TODO: implement build
    return Scaffold(
      key: scaffoldKey,
      appBar: styles.theAppBar(context, theLanguage, isLogin, context.localeString('order_details') + ' $invoiceNumber' , true, false, '0'),
      body: isLoading == false ? Container(
        child: widgetProductsData() ,
      ):Container(),
      bottomNavigationBar: Container(
        height: 90.0,
        color: const Color.fromRGBO(245, 245, 245, 1),
        child: Row(
          children: <Widget>[
            Expanded(
              child: ListTile(
                title: Text(context.localeString('total_price'),style: const TextStyle(color: Colors.black87, fontSize: 16.0), textAlign: TextAlign.center),
                subtitle: Text('$orderTotalPrice ' + orderDetailsList[0].symbol,style: const TextStyle(color: Colors.black87, fontSize: 16.0), textAlign: TextAlign.center),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: isLoading == true ? styles.loadingPage(context):Container(),
    );
  }

}