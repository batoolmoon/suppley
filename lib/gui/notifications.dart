import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supplyplatform/components/bottom_navigation_bar.dart';
import 'package:supplyplatform/components/drawer.dart';
import 'package:supplyplatform/gui/products/product_details.dart';
import 'package:supplyplatform/module/get_data.dart';
import 'package:supplyplatform/module/get_notifications.dart';
import 'package:supplyplatform/gui/notifications_details.dart';
import 'package:supplyplatform/gui/orders/orders.dart';
import 'package:supplyplatform/gui/new_details.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:supplyplatform/components/funcs.dart';
import 'package:supplyplatform/components/styles.dart';

class Notifications extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _NotificationsState();
  }

}

class _NotificationsState extends State<Notifications>{

  late String memberId;
  late String fullName = '';
  late String theLanguage = 'en';
  late bool isLogin = false;

  late TextAlign theAlignment;
  late TextDirection theDirection;
  bool isLoading = true;

  var funcs = Funcs();
  var styles = Styles();

  var notificationsList = <GetNotifications>[];

  _getDataList() {
    GetData.getDataList(funcs.mainLink+'api/getNotifications/$memberId/$theLanguage/').then((response) {
      setState(() {
        Iterable list = json.decode(response.body);
        notificationsList = list.map((model) => GetNotifications.fromJson(model)).toList();
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
  void dispose(){
    super.dispose();
  }


  getSharedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      theLanguage = prefs.getString('theLanguage')!;
      isLogin = prefs.getBool('isLogin')!;
      memberId = prefs.getString('memberId')!;
      fullName = prefs.getString('fullName')  !;

      if(theLanguage == 'ar'){
      theAlignment = TextAlign.right;
      theDirection = TextDirection.rtl;
      }else{
      theAlignment = TextAlign.left;
      theDirection = TextDirection.ltr;
      }

    });
  }

  _openToProductDetailsPage(String typeId){
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => ProductDetails(typeId.toString()))).then((val)=>val?needToRefresh():print('ddd'));
  }

  _openToNotificationsDetailsPage(String notificationId){
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => NotificationsDetails(notificationId.toString()))).then((val)=>val?needToRefresh():print('ddd'));
  }

  needToRefresh(){
    setState(() {
      _getDataList();
    });
  }

  Widget widgetNotificationsList(){

    return ListView.builder(
      itemCount: notificationsList.length,
      itemBuilder: (BuildContext context, int index) =>
          Column(
            children: <Widget>[
              ListTile(
                title: Text(notificationsList[index].theTitle, style: styles.paragraphTitle, textAlign: theAlignment),
                subtitle: Text(notificationsList[index].theDetails, style: styles.paragraphText, textAlign: theAlignment),
                onTap: (){
                  if(notificationsList[index].theType == 'product'){
                    _openToProductDetailsPage(notificationsList[index].typeId);
                  }else if(notificationsList[index].theType == 'order'){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Orders()),);
                  }else if(notificationsList[index].theType == 'news'){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => NewsDetails(notificationsList[index].typeId))).then((val)=>val?needToRefresh():print('ddd'));
                  }else{
                    _openToNotificationsDetailsPage(notificationsList[index].noId);
                  }
                },
              ),
              const Divider(),
            ],
          ),
    );

  }


  @override
  Widget build(BuildContext context) {


    // TODO: implement build
    return RefreshIndicator(
      displacement: 150,
      backgroundColor: Theme.of(context).secondaryHeaderColor,
      color: Colors.white,
      strokeWidth: 2,
      triggerMode: RefreshIndicatorTriggerMode.onEdge,
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 1500));
        _getDataList();
      },
      child: Scaffold(
        appBar: styles.theAppBar(context, theLanguage, isLogin, context.localeString('notifications') , true, false, '0'),
        body: Container(
            child: widgetNotificationsList()
        ),
        floatingActionButton: isLoading == true ? styles.loadingPage(context):Container(),
        drawer: DrawerClass(isLogin, fullName),
        bottomNavigationBar: BottomNavigationBarWidget(3),
      ),
    );
  }

}
