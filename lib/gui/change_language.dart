import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:supplyplatform/components/styles.dart';
import 'package:supplyplatform/components/funcs.dart';

class ChangeLanguage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ChangeLanguageState();
  }

}

class _ChangeLanguageState extends State<ChangeLanguage>{

  late String memberId='0' ;
  late String theLanguage='en';
  late String LogInType='shop' ;
  late bool isLogin;
  late TextAlign theAlignment;
  late TextDirection theDirection;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  var funcs = Funcs();
  var styles = Styles();

  @override
  void initState(){
    super.initState();
    getSharedData();
  }

  getSharedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(mounted){
      setState(() {
        theLanguage = prefs.getString('theLanguage')!;
        LogInType=prefs.getString('LogInType')!;
        isLogin = prefs.getBool('isLogin')!;
        if(LogInType == 'shop'){
          memberId = prefs.getString('memberId')!;
        }
        if(theLanguage == 'ar'){
          theAlignment = TextAlign.right;
          theDirection = TextDirection.rtl;
        }else{
          theAlignment = TextAlign.left;
          theDirection = TextDirection.ltr;
        }
      });
    }
  }

  changeLanguage(String theLanguage) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('theLanguage', theLanguage);
    Locales.change(context, theLanguage);

    if(isLogin == true && LogInType==context.localeString('shop')){
      http.post(Uri.parse(funcs.mainLink+'api/changeLanguage'), body: {
        "memberId": memberId,
        "theLanguage": theLanguage,
      }).then((result) async{

        var theResult = json.decode(result.body);

        if(theResult['theResult'] == true){
          print("yess");
          Navigator.of(context).pushNamedAndRemoveUntil('/MainPage',(Route<dynamic> route) => false);}
        else{
          styles.showSnackBar(scaffoldKey,context,context.localeString('error_occurred'),'error','');
        }
      }).catchError((error) {
        print(error);
        styles.showSnackBar(scaffoldKey,context,context.localeString('error_occurred'),'error','');
      });


      }else{Navigator.of(context).pushNamedAndRemoveUntil('/MainPage',(Route<dynamic> route) => false);}




  }

  @override
  Widget build(BuildContext context) {

    // TODO: implement build
    return Scaffold(
      key: scaffoldKey,
      appBar: styles.theAppBar(context, theLanguage, true, context.localeString('change_language') , true, false, '0'),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text('English', textDirection: theDirection, style:TextStyle(color: Colors.black), textAlign: theAlignment),
            onTap: () {
              changeLanguage('en');
            },
          ),
          const   Divider(),
          ListTile(
            title: Text('العربية', textDirection: theDirection, style: TextStyle(color: Colors.black), textAlign: theAlignment),
            onTap: () {
              changeLanguage('ar');
            },
          ),
          const Divider(),
        ],
      ),
    );
  }

}