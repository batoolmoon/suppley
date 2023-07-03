import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:supplyplatform/components/bottom_navigation_bar.dart';
import 'package:supplyplatform/module/get_data.dart';
import 'package:supplyplatform/module/get_coupons.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:supplyplatform/components/funcs.dart';
import 'package:supplyplatform/components/styles.dart';

class Coupons extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _CouponsState();
  }

}

class _CouponsState extends State<Coupons>{


  late String memberId;
  late String fullName = '';
  late String theLanguage = '';
  late bool isLogin = false;

  late TextAlign theAlignment;
  late Alignment theTopAlignment;
  bool isLoading = true;

  late String notificationsCount = '0';

  var funcs = Funcs();
  var styles = Styles();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  var couponsList = <GetCoupons>[];

  _getDataList() {
    GetData.getDataList(funcs.mainLink+'api/getCoupons/$theLanguage').then((response) {
      setState(() {
        Iterable list = json.decode(response.body);
        couponsList = list.map((model) => GetCoupons.fromJson(model)).toList();
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

    });
  }

  getUnreadNotificationsCount() async{
    if(isLogin == true){
      notificationsCount = await funcs.getUnreadNotificationsCount();
      setState(() {});
    }
  }

  copyCode(String theCode){
    Clipboard.setData(ClipboardData(text: theCode));
    styles.showSnackBar(scaffoldKey,context,context.localeString('coupon_code_copied'),'','');
  }

  Widget widgetCouponsList(){

    return ListView.builder(
      itemCount: couponsList.length,
      itemBuilder: (BuildContext context, int index) =>
          Column(
            children: <Widget>[
              ListTile(
                title: Text(couponsList[index].theTitle, style: styles.paragraphTitle, textAlign: theAlignment),
                trailing: ElevatedButton(
                  onPressed: ()=> copyCode(couponsList[index].theCode),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.only(right: 20.0, left: 20.0, top: 5.0, bottom: 5.0 ),
                    elevation: 0.0,
                    primary:  Theme.of(context).secondaryHeaderColor,
                    shape: styles.circleBtn(),
                  ),

                  child: Text(context.localeString('copy_coupon'), style: Theme.of(context).textTheme.button, textAlign: TextAlign.center),

                  //todo

                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      alignment: theTopAlignment,
                      child: Row(
                        children: [
                          Text(context.localeString('coupon_code'), style: styles.paragraphTitle, textAlign: theAlignment),
                          Text(couponsList[index].theCode, style: styles.paragraphTitle, textDirection: ui.TextDirection.ltr, textAlign: theAlignment)
                        ],
                      ),
                    ),
                    couponsList[index].storeName.isNotEmpty ? Container(
                      alignment: theTopAlignment,
                      child: Text(context.localeString('coupon_store') + couponsList[index].storeName, style: styles.greenTitle, textAlign: theAlignment),
                    ):Container(
                      alignment: theTopAlignment,
                      child: Text(context.localeString('coupon_all_store'), style: styles.greenTitle, textAlign: theAlignment),
                    ),
                    Container(
                      alignment: theTopAlignment,
                      child: couponsList[index].theType == 'fixed' ? Text(context.localeString('coupon_amount') + '${couponsList[index].amount} JOD', style: styles.couponDiscount, textAlign: theAlignment) : Text(context.localeString('coupon_amount') + '${couponsList[index].amount} %', style: styles.couponDiscount, textAlign: theAlignment),
                    ),
                    Container(
                      alignment: theTopAlignment,
                      child: Text(context.localeString('finish_at') + DateFormat('dd/MM/yyyy').format(DateTime.parse(couponsList[index].endDate)), style: styles.couponDate, textAlign: theAlignment),
                    ),
                  ],
                ),
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
      appBar: styles.theAppBar(context, theLanguage, isLogin, context.localeString('coupons') , true, true, notificationsCount),
      body: Container(
        child: couponsList.isNotEmpty || isLoading == true ? widgetCouponsList() :
        Container(
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
      ),
      floatingActionButton: isLoading == true ? styles.loadingPage(context):Container(),
      bottomNavigationBar: BottomNavigationBarWidget(3),
    );
  }

}