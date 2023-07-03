import 'package:flutter/material.dart';
import 'package:supplyplatform/gui/contact_details.dart';
import 'package:flutter/services.dart';
import 'package:supplyplatform/gui/text_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:supplyplatform/components/funcs.dart';
import 'package:supplyplatform/components/styles.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:supplyplatform/gui/about.dart';
import 'package:supplyplatform/gui/change_language.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;

import '../gui/stores/change_store_language.dart';

class StoreDrawerClass extends StatefulWidget{
  StoreDrawerClass(this.isLogin, this.storeName);
  bool isLogin;
  String storeName;

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    // ignore: no_logic_in_create_state
    return _StoreDrawerClassState(isLogin, storeName);
  }
}

class _StoreDrawerClassState extends State<StoreDrawerClass>{
  _StoreDrawerClassState(this.isLogin, this.storeName);
  bool isLogin=true;
  String storeName;
  late String LogInType;
  late String storeId;
  late String storeMobile = '';
  late String theLanguage = '';
  late String storeEmail = '';
  late TextAlign theAlignment = TextAlign.left;
  late Alignment theTopAlignment = Alignment.topRight;
  late TextDirection theDirection = TextDirection.ltr;

  var funcs = Funcs();
  var styles = Styles();

  @override
  void initState(){
    super.initState();

    getSharedData().then((result) {

    });

  }

  getSharedData() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(mounted){
      setState(() {
        LogInType= prefs.getString('LogInType')!;
        storeId = prefs.getString('storeId')!;
        storeEmail=prefs.getString('storeEmail')!;
        storeMobile = prefs.getString('storeMobile')!;
        theLanguage = prefs.getString('theLanguage')!;


        if(theLanguage == 'ar'){
          theAlignment = TextAlign.right;
          theDirection = TextDirection.rtl;
          theTopAlignment = Alignment.topRight;
        }else{
          theAlignment = TextAlign.left;
          theDirection = TextDirection.ltr;
          theTopAlignment = Alignment.topRight;
        }
      });
    }
  }

  Future<void> initPlatformState() async {
   String deviceId;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
    deviceId = (await PlatformDeviceId.getDeviceId)!;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('deviceId', deviceId);

    } on PlatformException {
    deviceId = 'Failed to get deviceId.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  void deleteAccoutnt() async{
    http.post(Uri.parse(funcs.mainLink+'api/deleteAccount'), body: {
        "LogInType" : LogInType,
        "storeId":storeId
    }).then((value) async{
logout();
    }).catchError((error){ print (error);});

  }

  void logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
      await prefs.setString('storeId', '');
      await prefs.setString('storeName', '');
      await prefs.setString('storeEmail', '');
      await prefs.setString('storeMobile', '');
      await prefs.setString('LogInType', '');
       await prefs.setBool('isLogin', false);
    initPlatformState();

//    print(theLanguage);
    Locales.change(context, theLanguage);
    await prefs.setString('theLanguage', theLanguage);
    Navigator.of(context).pushNamedAndRemoveUntil('/Login',(Route<dynamic> route) => false);
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Drawer(
      backgroundColor: Color.fromRGBO(0, 0, 51, 1),
      child: ListView(

        padding: EdgeInsets.zero,
        children: <Widget>[

          Container(
            padding: const EdgeInsets.only(top: 30.0, bottom: 20.0),
            color: Color.fromRGBO(0, 0, 51, 1),
            child: Container(
              child: Column(
                children: <Widget>[
                  Material(
                    borderRadius: const BorderRadius.all(Radius.circular(50.0)),
                    elevation: 10.0,
                    color: Colors.white,
                    child: Container(
                        height: 80.0,
                        width: 80.0,
                        margin: const EdgeInsets.all(3.0),
                        decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(50.0)),
                            color:  const Color.fromRGBO(0, 0, 50, 1),
                            image: DecorationImage(
                                fit: BoxFit.contain,
                                image: AssetImage('images/inside_logo.png',)
                            )
                        )
                    ),
                  ),
                  const SizedBox(height: 10.0,),
                  Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.only(left: 15.0, right: 15.0),
//                      height: 50.0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(0),
                            child: Text(storeName, style: const TextStyle(color: Colors.white, fontSize: 16), textAlign: TextAlign.center,),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(0),
                            child: Text(storeMobile, style: const TextStyle(color: Colors.white, fontSize: 13), textAlign: TextAlign.center,),
                          ),
                        ],
                      )
                  ),
                ],
              ),
            ),
          ),

          ListTile(
            tileColor: Color.fromRGBO(0, 0, 51, 1),
            title: Text(context.localeString('about'), style: styles.listTileStyle),
            leading: FaIcon(FontAwesomeIcons.file, size: 20.0, color: Colors.white),
            dense: true,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => About()),);
            },
          ),


          ListTile(
            tileColor: Color.fromRGBO(0, 0, 51, 1),
            title: Text(context.localeString('change_language'), style: styles.listTileStyle),
            leading: FaIcon(FontAwesomeIcons.language, size: 20.0, color: Colors.white),
            dense: true,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => ChangeStoreLanguage()),);
            },
          ),


          ListTile(
            tileColor: Color.fromRGBO(0, 0, 51, 1),
            title: Text(context.localeString('privacy_policy'), style: styles.listTileStyle),
            leading: FaIcon(FontAwesomeIcons.fileInvoice, size: 20.0, color: Colors.white),
            dense: true,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => TextData('privacy')),);
            },
          ),


          ListTile(
            tileColor: Color.fromRGBO(0, 0, 51, 1),
            title: Text(context.localeString('terms_and_conditions'), style: styles.listTileStyle),
            leading: FaIcon(FontAwesomeIcons.fileInvoice, size: 20.0, color: Colors.white),
            dense: true,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => TextData('terms_and_conditions')),);
            },
          ),


          ListTile(
            tileColor: Color.fromRGBO(0, 0, 51, 1),
            title: Text(context.localeString('shippingـreturn'), style: styles.listTileStyle),
            leading: FaIcon(FontAwesomeIcons.fileInvoice, size: 20.0, color:Colors.white),
            dense: true,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => TextData('shipping_returns')),);
            },
          ),


          ListTile(
            tileColor: Color.fromRGBO(0, 0, 51, 1),
            title: Text(context.localeString('contact'), style: styles.listTileStyle),
            leading: FaIcon(FontAwesomeIcons.mobileAlt, size: 20.0, color: Colors.white),
            dense: true,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => ContactDetails('1','')),);
            },
          ),


          isLogin == true ? ListTile(
            title: Text(context.localeString('logout'), style: styles.listTileStyle),
            leading: FaIcon(FontAwesomeIcons.powerOff, size: 20.0, color: Colors.white),
            onTap: () {
              logout();
         //    Navigator.of(context, rootNavigator: true).pop();
            },
          ):Container(),
          ListTile(
            tileColor: Color.fromRGBO(0, 0, 51, 1),
            title: Text(context.localeString('delete_acc'), style: styles.listTileStyle),
            leading: FaIcon(FontAwesomeIcons.windowClose, size: 20.0, color: Colors.white),
            dense: true,
            onTap: () {
              deleteAccoutnt();
              // Navigator.pop(context);
              // Navigator.push(context, MaterialPageRoute(builder: (context) => ChangeLanguage()),);
            },
          ),
          const SizedBox(height: 100.0,)
        ],
      ),
    );
  }

}

