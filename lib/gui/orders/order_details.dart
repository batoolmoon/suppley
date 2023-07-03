import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supplyplatform/components/funcs.dart';
import 'package:supplyplatform/components/styles.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:supplyplatform/module/get_data.dart';
import 'package:supplyplatform/module/get_order_products.dart';

class OrderDetails extends StatefulWidget{
  OrderDetails(this.invoiceNumber);
  String invoiceNumber;

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _OrderDetailsState(invoiceNumber);
  }

}

class _OrderDetailsState extends State<OrderDetails>{
  _OrderDetailsState(this.invoiceNumber);
  late String invoiceNumber;
  late String memberId;
  late bool isLogin;
  late String theLanguage="en";
  late int currencyId;
  late double currencyExchange;
  late TextAlign theAlignment;
  bool isLoading = true;
  String orderTotalPrice = '0.0';

  var funcs = Funcs();
  var styles = Styles();

  var orderDetailsList = <GetOrderProducts>[];
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  _getDataList() {
    print("in"+invoiceNumber);
    GetData.getDataList(funcs.mainLink+'api/getOrdersDetails/$theLanguage/$memberId/$invoiceNumber').then((response) {
      setState(() {
        Iterable list = json.decode(response.body);
        print(json.decode(response.body));
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
        memberId = prefs.getString('memberId')!;
        theLanguage = prefs.getString('theLanguage')!;
        isLogin = prefs.getBool('isLogin')!;
        currencyId = prefs.getInt('currencyId')!;
        currencyExchange = prefs.getDouble('currencyExchange')!;

        if(theLanguage == 'ar'){
          theAlignment = TextAlign.right;
        }else{
          theAlignment = TextAlign.left;
        }
        getCartTotalPriceAfterOrder();
      });
    }
  }

  getCartTotalPriceAfterOrder() async{
    orderTotalPrice = await funcs.getCartTotalPriceAfterOrder(memberId,invoiceNumber);

    if(orderTotalPrice != null && double.parse(orderTotalPrice) > 0.0){
      setState(() {
        orderTotalPrice = orderTotalPrice;
      });
    }else{
      setState(() {
        orderTotalPrice = '0';
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
          styles.widgetProducts(scaffoldKey,context, isLogin, memberId, double.parse(orderDetailsList[0].currencyExchange), orderDetailsList,index,'orders',currencyId),
    );
  }


  @override
  Widget build(BuildContext context) {


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