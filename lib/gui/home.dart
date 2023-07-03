import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:supplyplatform/components/styles.dart';

class Home extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _HomeState();
  }

}



class _HomeState extends State<Home> with SingleTickerProviderStateMixin{

  var styles = Styles();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose(){
    super.dispose();
  }

  void goToMainPage(String theLanguage) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('theLanguage', theLanguage);
    await prefs.setBool('isLogin', false);
    await prefs.setString('memberId', '0');
    await prefs.setString('fullName', '');
    await prefs.setString('mobileNumber', '');
    await prefs.setString('emailAddress', '');
    await prefs.setString('deviceId', '');
    await prefs.setInt('currencyId', 1);
    await prefs.setString('currencySymbol', 'Jod');
    await prefs.setDouble('currencyExchange', 1.00);
    await prefs.setInt('cartCount', 0);
    await prefs.setString('LogInType', 'shop');

    Locales.change(context, theLanguage);
    Navigator.of(context).pushNamedAndRemoveUntil('/MainPage',(Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
//    final double width = MediaQuery.of(context).size.width;
    // TODO: implement build
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Stack(

        children: <Widget>[
          Container(
            color:Colors.white,
          ),
          Container(
            height: 350,
            decoration: const BoxDecoration(
                color: Color.fromRGBO(0, 0, 51, 1),
                borderRadius: BorderRadius.only(bottomLeft:Radius.circular(35),bottomRight: Radius.circular(35))),
          ),
          Positioned(
            top:60,
            left: 10,
            right: 10,
            bottom:70,
            child: Container(
              padding:const EdgeInsets.only(left: 10.0, right: 10.0),
              height: 110,

              decoration: const BoxDecoration(color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(35))
                  , boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 40,
                      offset: Offset(8, 15), // Shadow position
                    ),
                  ]),
              margin:EdgeInsets.all(25),
              child: ListView(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.only(top: 70.0, bottom: 40.0),
                    alignment: Alignment.center,
                    child: Image.asset(
                      'images/logo.png',
                      width: 200.0,
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: Text(context.localeString('welcome_application_name'), style: const TextStyle( color:Color.fromRGBO(0, 0, 51, 1), fontFamily: 'Cairo', fontSize: 20.0),),
                  ),
                  const SizedBox(height: 70.0,),

                     Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(right: 0.0, left: 0.0, top: 1.0),
                          child: ElevatedButton(
                            onPressed: ()=> goToMainPage('en'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.only(right: 70.0, left: 70.0, top: 10.0, bottom: 10.0 ),
                              elevation: 0.0,
                               shape: styles.circleBtn(),
                              primary: Color.fromRGBO(194, 171, 131, 1),
                            ),
                            child: Text('English',style: TextStyle(color: Colors.white), textAlign: TextAlign.center),



                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(right: 0.0, left: 0.0, top: 10.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.only(right: 70.0, left: 70.0, top: 10.0, bottom: 10.0 ),
                              elevation: 0.0,
                             shape: styles.circleBtn(),
                              primary: Color.fromRGBO(194, 171, 131, 1),
                              ),
                            onPressed: ()=> goToMainPage('ar'),
                            child: Text('العربية',style: TextStyle(color: Colors.white), textAlign: TextAlign.center),


                          ),
                        ),
                        const SizedBox(height: 100.0,),
                      ],
                    ),

                ],

              ),
            ),
          ),

        ],
      ),

    );
  }

}