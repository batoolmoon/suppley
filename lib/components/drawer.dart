import 'package:flutter/material.dart';
import 'package:supplyplatform/gui/contact_details.dart';
import 'package:supplyplatform/gui/members/edit_profile.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:supplyplatform/gui/text_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:supplyplatform/components/funcs.dart';
import 'package:supplyplatform/components/styles.dart';
import 'package:supplyplatform/gui/members/login.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:supplyplatform/gui/about.dart';
import 'package:supplyplatform/gui/news.dart';
import 'package:supplyplatform/gui/driver_join.dart';
import 'package:supplyplatform/gui/change_language.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DrawerClass extends StatefulWidget{
  DrawerClass(this.isLogin, this.fullName);
  bool isLogin;
  String fullName;

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    // ignore: no_logic_in_create_state
    return _DrawerClassState(isLogin, fullName);
  }
}

class _DrawerClassState extends State<DrawerClass>{
  _DrawerClassState(this.isLogin, this.fullName);
  bool isLogin;
  String fullName;
  late int cartCount;
  late String memberId;
  late String mobileNumber = '';
  late String emailAddress = '';
  late String theLanguage = 'en';
  late String LogInType;
  late int currencyId;
  late double currencyExchange;
  late String currencySymbol;
  late TextAlign theAlignment = TextAlign.left;
  late Alignment theTopAlignment = Alignment.topRight;
  late TextDirection theDirection = TextDirection.ltr;
late String deviceId;
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
        isLogin=prefs.getBool('isLogin')!;
        memberId = prefs.getString('memberId')!;
        mobileNumber = prefs.getString('mobileNumber')!;
        fullName=prefs.getString('fullName')!;
        emailAddress = prefs.getString('emailAddress')!;
        theLanguage = prefs.getString('theLanguage')!;
        currencyId = prefs.getInt('currencyId')!;
        currencyExchange = prefs.getDouble('currencyExchange')!;
        currencySymbol = prefs.getString('currencySymbol')!;
        cartCount=  prefs.getInt('cartCount')!;
       LogInType=prefs.getString('LogInType')!;
       //deviceId= prefs.getString('deviceId')!;
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
      "LogInType" : "shop",
      "memberId":memberId
    }).then((value) async{
      logout();
    }).catchError((error){ print (error);});

  }

  void logout() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //print('deviceId  '+deviceId);
    print('cartCount '+ cartCount.toString());
    print('memberId  '+memberId);
    print('fullName  '+fullName);
    print('mobileNumber  '+mobileNumber);
    print('emailAddress  '+emailAddress);
    print('currencyId  '+currencyId.toString());
    print('currencySymbol  '+currencySymbol);
    print('currencyExchange  '+currencyExchange.toString());
    print('isLogin  '+isLogin.toString());
   prefs.clear();

     await prefs.setInt('cartCount', 0);
     await prefs.setString('memberId', '0');
     await prefs.setString('deviceId', '');
     await prefs.setString('fullName', '');
     await prefs.setString('mobileNumber', '');
     await prefs.setString('emailAddress', '');
     await prefs.setInt('currencyId', 1);
     await prefs.setString('currencySymbol', 'Jod');
     await prefs.setDouble('currencyExchange', 1.00);
     await prefs.setBool('isLogin', false);
     await prefs.setString('LogInType', 'shop');


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
      backgroundColor: const Color.fromRGBO(0, 0, 50, 1),
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[

          Container(
            padding: const EdgeInsets.only(top: 30.0, bottom: 20.0),
            color: const Color.fromRGBO(0, 0, 50, 1),
            child: Container(
              child: Column(
                children: <Widget>[
                  Material(
                    borderRadius: const BorderRadius.all(Radius.circular(50.0)),
                    elevation: 10.0,
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
                            child: Text(isLogin == true ? fullName : context.localeString('guest_name'), style: const TextStyle(color: Colors.white, fontSize: 16), textAlign: TextAlign.center,),
                          ),
                          isLogin == true ? Padding(
                            padding: const EdgeInsets.all(0),
                            child: Text(mobileNumber, style: const TextStyle(color: Colors.white, fontSize: 13), textAlign: TextAlign.center,),
                          ):Container(),
                        ],
                      )
                  ),
                ],
              ),
            ),
          ),

          isLogin == true ? ListTile(


            title: Text(context.localeString('edit_profile'), style: styles.listTileStyle),
            leading: FaIcon(FontAwesomeIcons.userEdit, size: 20.0, color:  Colors.white70),
            dense: true,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfile()),);
            },
          ):ListTile(

            title: Text(context.localeString('login_page_title'), style: styles.listTileStyle),
            leading: FaIcon(FontAwesomeIcons.signInAlt, size: 20.0, color:  Colors.white70),
            dense: true,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => Login()),);
            },
          ),



          ListTile(

            title: Text(context.localeString('about'), style: styles.listTileStyle),
            leading: FaIcon(FontAwesomeIcons.file, size: 20.0, color:  Colors.white70),
            dense: true,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => About()),);
            },
          ),


          ListTile(

            title: Text(context.localeString('news'), style: styles.listTileStyle),
            leading: FaIcon(FontAwesomeIcons.newspaper, size: 20.0, color: Colors.white70),
            dense: true,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => News()),);
            },
          ),


          ListTile(

            title: Text(context.localeString('change_language'), style: styles.listTileStyle),
            leading: FaIcon(FontAwesomeIcons.language, size: 20.0, color: Colors.white70),
            dense: true,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => ChangeLanguage()),);
            },
          ),


          ListTile(

            title: Text(context.localeString('privacy_policy'), style: styles.listTileStyle),
            leading: FaIcon(FontAwesomeIcons.fileInvoice, size: 20.0, color:  Colors.white70),
            dense: true,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => TextData('privacy')),);
            },
          ),


          ListTile(

            title: Text(context.localeString('terms_and_conditions'), style: styles.listTileStyle),
            leading: FaIcon(FontAwesomeIcons.fileInvoice, size: 20.0, color: Colors.white70),
            dense: true,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => TextData('terms_and_conditions')),);
            },
          ),


          ListTile(

            title: Text(context.localeString('shippingـreturn'), style: styles.listTileStyle),
            leading: FaIcon(FontAwesomeIcons.fileInvoice, size: 20.0, color:  Colors.white70),
            dense: true,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => TextData('shipping_returns')),);
            },
          ),


          ListTile(

            title: Text(context.localeString('contact'), style: styles.listTileStyle),
            leading: FaIcon(FontAwesomeIcons.mobileAlt, size: 20.0, color:  Colors.white70),
            dense: true,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => ContactDetails('1','')),);
            },
          ),


          isLogin == true ? ListTile(
            title: Text(context.localeString('logout'), style: styles.listTileStyle),
            leading: FaIcon(FontAwesomeIcons.powerOff, size: 20.0, color:  Colors.white70),
            onTap: () {
              logout();
//              Navigator.of(context, rootNavigator: true).pop();
            },
          ):Container(),

      isLogin==true?
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
          ):Container(),
        ],
      ),
    );
  }

}

