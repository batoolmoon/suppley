import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supplyplatform/gui/members/edit_profile.dart';
import 'package:supplyplatform/gui/addresses/addresses.dart';
import 'package:supplyplatform/gui/members/login.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:supplyplatform/components/bottom_navigation_bar.dart';
import 'package:supplyplatform/gui/products/favourite.dart';
import 'package:supplyplatform/gui/notifications.dart';
import 'package:supplyplatform/components/drawer.dart';
import 'package:supplyplatform/gui/coupons.dart';
import 'package:supplyplatform/gui/orders/orders.dart';
import 'package:supplyplatform/components/funcs.dart';
import 'package:supplyplatform/components/styles.dart';
import 'package:supplyplatform/gui/currencies.dart';

class Settings extends StatefulWidget{
  const Settings({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _SettingsState();
  }

}

class _SettingsState extends State<Settings>{
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  late String memberId;
  late String theLanguage="en";
  late int currencyId;
  late double currencyExchange;
  late String currencySymbol;
  late String pageTitle;
  late String fullName;
  late bool isLogin = false;
  late TextAlign theAlignment = TextAlign.right;
  late String hideShowCurrencyValue = '0';
  late String notificationsCount = '0';

  var funcs = Funcs();
  var styles = Styles();

  @override
  void initState(){
    super.initState();
    getSharedData().then((result) {
      getUnreadNotificationsCount();
      hideShowCurrency().then((result) {
        setState(() {
          hideShowCurrencyValue = result['theData'][0];
        });
      });
    });
  }

  getSharedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(mounted){
      setState(() {
        memberId = prefs.getString('memberId')!;
        fullName = prefs.getString('fullName')!;
        theLanguage = prefs.getString('theLanguage')!;
        isLogin = prefs.getBool('isLogin')!;
        currencyId = prefs.getInt('currencyId')!;
        currencyExchange = prefs.getDouble('currencyExchange')!;
        currencySymbol = prefs.getString('currencySymbol')!;

        if(theLanguage == 'ar'){
          theAlignment = TextAlign.right;
        }else{
          theAlignment = TextAlign.left;
        }
      });
    }
  }

  Future<Map> hideShowCurrency() async{

    var result;
    var myUrl = Uri.parse(funcs.mainLink+'api/hideShowCurrency/');
    http.Response response = await http.get(myUrl, headers: {"Accept": "application/json"});
    try{
      result =  json.decode(response.body);
    }catch(e){
      print(e);
    }
    return result;
  }

  getUnreadNotificationsCount() async{
    if(isLogin == true){
      notificationsCount = await funcs.getUnreadNotificationsCount();
      setState(() {});
    }
  }


  @override
  Widget build(BuildContext context) {

    // TODO: implement build
    return Scaffold(
      appBar: styles.theAppBar(context, theLanguage, isLogin, context.localeString('settings') , true, true, notificationsCount),
      body: ListView(
        children: <Widget>[

          Container(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0),
            child: Column(
              children: [

                isLogin == true ? ListTile(
                  title: Text(context.localeString('edit_profile'), style: styles.listTileStyle2),
                  leading: Icon(Icons.edit),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfile()),);
                  },
                ):ListTile(
                  title: Text(context.localeString('login_page_title'), style: styles.listTileStyle2),
                  leading: Icon(Icons.login),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Login()),);
                  },
                ),
                const Divider(),

                ListTile(
                  title: Text(context.localeString('favourite'), style: styles.listTileStyle2),
                  leading: Icon(Icons.favorite_outline_outlined),
                  onTap: () {
                    if(isLogin == true){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Favourite()),);
                    }else{
                      styles.needLoginModalBottomSheet(context);
                    }
                  },
                ),
                const Divider(),

                ListTile(
                  title: Text(context.localeString('my_orders'), style: styles.listTileStyle2),
                  leading: Icon(Icons.local_grocery_store_rounded),
                  onTap: () {
                    if(isLogin == true){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Orders()),);
                    }else{
                      styles.needLoginModalBottomSheet(context);
                    }
                  },
                ),
                const Divider(),


                ListTile(
                  title: Text(context.localeString('your_address'), style: styles.listTileStyle2),
leading: Icon(Icons.location_on_outlined),
                  onTap: () {
                    if(isLogin == true){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Addresses()),);
                    }else{
                      styles.needLoginModalBottomSheet(context);
                    }
                  },
                ),

                const Divider(),
                int.parse(hideShowCurrencyValue) > 0 ? ListTile(
                  title: Text(context.localeString('currency_title'), style: styles.listTileStyle2),

                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Currencies()),);
                  },
                ):Container(),
                int.parse(hideShowCurrencyValue) > 0 ? const Divider():Container(),

                ListTile(
                  title: Text(context.localeString('coupons'), style: styles.listTileStyle2),
                  leading: Icon(Icons.card_giftcard),
                  onTap: () {
                    if(isLogin == true){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Coupons()),);
                    }else{
                      styles.needLoginModalBottomSheet(context);
                    }
                  },
                ),
                const Divider(),

                ListTile(
                  title: Text(context.localeString('notifications'), style: styles.listTileStyle2),
                  leading: Icon(Icons.notifications_active_outlined),
                  onTap: () {
                    if(isLogin == true){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Notifications()),);
                    }else{
                      styles.needLoginModalBottomSheet(context);
                    }
                  },
                ),
              ],
            ),
          ),


          const SizedBox(height: 30.0,),

        ],
      ),
      bottomNavigationBar: BottomNavigationBarWidget(3),
      drawer: DrawerClass(isLogin, fullName),
    );
  }

}