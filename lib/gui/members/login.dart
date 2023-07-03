import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supplyplatform/gui/members/forget_password.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supplyplatform/components/funcs.dart';
import 'package:supplyplatform/components/styles.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:fl_country_code_picker/fl_country_code_picker.dart';


class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _LoginState();
  }
}

class _LoginState extends State<Login> {
  final TextEditingController _getmobileNumber = TextEditingController();
  final TextEditingController _getPassword = TextEditingController();

  final countryPicker = const FlCountryCodePicker();
  CountryCode?_countryCode;
  String ?countryCode;
  late String theLanguage;
  late String deviceId;
  late TextAlign theAlignment;
  String loginType = '';
  String mytoken = '';
  String userkind = "select";
  var kindRegister = [
    'select',
    //"store",
    'shop',
    'factory',
    'delivery_company'
  ];

  var funcs = Funcs();
  var styles = Styles();

  bool _isObscure = true;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  late FirebaseMessaging messaging;

  // var maskFormatter = MaskTextInputFormatter(
  //     mask: '##-####-####', filter: {"#": RegExp(r'[0-9]')});

  @override
  void initState() {
    super.initState();

    messaging = FirebaseMessaging.instance;
    messaging.getToken().then((value) {
      setState(() {
        mytoken = value.toString();
      });
    });

    getSharedData();
  }

  getSharedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {

      theLanguage = prefs.getString('theLanguage')!;
      deviceId = prefs.getString('deviceId')!;

      if (theLanguage == 'ar') {
        theAlignment = TextAlign.right;
      } else {
        theAlignment = TextAlign.left;
      }
    });
  }

  void _login() async {
    styles.onLoading(context);

    String themobileNumber = "${_countryCode!.dialCode.toString()}${_getmobileNumber.text}".trim();
    String thePassword = _getPassword.text.trim();

    themobileNumber = funcs.replaceArabicNumber(themobileNumber);
    themobileNumber = funcs.removeCharacterFromMobile(themobileNumber);
    http.post(Uri.parse(funcs.mainLink + 'api/loginMember'), body: {
      "mobileNumber": themobileNumber.trim(),
      "password": thePassword.trim(),
      "deviceId": deviceId,
      "mytoken": mytoken,
      "theType": loginType
    }).then((result) async {
      var theResult = json.decode(result.body);
print (loginType);
      if (theResult['resultFlag'] == 'done') {
      // Navigator.of(context, rootNavigator: true).pop();
       if(loginType=="shop"){
         Navigator.of(context, rootNavigator: true).pop();
        String memberId = theResult['theResult'][0]['meId'];
        String fullName = theResult['theResult'][0]['fullName'];
        String mobileNumber = theResult['theResult'][0]['mobileNumber'];
        String emailAddress = theResult['theResult'][0]['emailAddress'];
        int currencyId = int.parse(theResult['theResult'][0]['currencyId']);
        String currencySymbol = theResult['theResult'][0]['currencySymbol'];
        String currencyExchange = theResult['theResult'][0]['currencyExchange'];
        int cartCount = int.parse(theResult['theResult'][0]['cartCount']);

        if (cartCount > 0) {
          cartCount = cartCount;
        } else {
          cartCount = 0;
        }
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('memberId', memberId);
        await prefs.setString('fullName', fullName);
        await prefs.setString('emailAddress', emailAddress);
        await prefs.setString('mobileNumber', mobileNumber);
        await prefs.setInt('currencyId', currencyId);
        await prefs.setString('currencySymbol', currencySymbol);
        await prefs.setDouble('currencyExchange', double.parse(currencyExchange));
        await prefs.setBool('isLogin', true);
        await prefs.setInt('cartCount', cartCount);
        await prefs.setString('LogInType', 'shop');
         print("storeId "+memberId);
         print("storeName "+fullName);
         print("storeEmail "+emailAddress);
         print("storeMobile "+mobileNumber);
         print("LogInType "+loginType);
        Navigator.of(context).pushNamedAndRemoveUntil(
            '/MainPage', (Route<dynamic> route) => false);

       }

       else if(loginType=="store"|| loginType=="factory"  ){
         Navigator.of(context, rootNavigator: true).pop();
         String storeId = theResult['theResult'][0]['stId'];
         String storeName = theResult['theResult'][0]['storeName'];
         String storeEmail = theResult['theResult'][0]['emailAddress'];
         String storeMobile=theResult['theResult'][0]['mobileNumber'];
         SharedPreferences prefs = await SharedPreferences.getInstance();
         await prefs.setString('storeId', storeId);
         await prefs.setString('storeName', storeName);
         await prefs.setString('storeEmail', storeEmail);
         await prefs.setString('storeMobile', storeMobile);
         await prefs.setBool('isLogin', true);
         await prefs.setString('LogInType', loginType);
print("storeId "+storeId);
print("storeName "+storeName);
print("storeEmail "+storeEmail);
print("storeMobile "+storeMobile);
print("LogInType "+loginType);
         Navigator.of(context).pushNamedAndRemoveUntil(
             '/StoreDashboard', (Route<dynamic> route) => false);

       }

       else {
         Navigator.of(context, rootNavigator: true).pop();
         String deliveryId = theResult['theResult'][0]['stId'];
         String deliveryName = theResult['theResult'][0]['storeName'];
         String deliveryEmail = theResult['theResult'][0]['emailAddress'];
         String deliveryMobile=theResult['theResult'][0]['mobileNumber'];
         SharedPreferences prefs = await SharedPreferences.getInstance();
         await prefs.setString('deliveryId', deliveryId);
         await prefs.setString('deliveryName', deliveryName);
         await prefs.setString('deliveryEmail', deliveryEmail);
         await prefs.setString('deliveryMobile', deliveryMobile);
         await prefs.setBool('isLogin', true);
         await prefs.setString('LogInType', "delivery_company");

         print("storeId "+deliveryId);
         print("storeName "+deliveryName);
         print("storeEmail "+deliveryEmail);
         print("storeMobile "+deliveryMobile);
         print("LogInType "+loginType);
         Navigator.of(context).pushNamedAndRemoveUntil(
             '/DeliveryDash', (Route<dynamic> route) => false);}

       }

       else if (theResult['resultFlag'] == 'not_found') {
        styles.showSnackBar(
            scaffoldKey,
            context,
            context.localeString('check_login_information'),
            'error',
            'forget_password');
        Navigator.of(context, rootNavigator: true).pop();
      } else if (theResult['resultFlag'] == 'inactive') {
        styles.showSnackBar(scaffoldKey, context,
            context.localeString('login_inactive'), 'error', '');
        Navigator.of(context, rootNavigator: true).pop();
      } else {
        styles.showSnackBar(scaffoldKey, context,
            context.localeString('error_occurred'), 'error', '');
        Navigator.of(context, rootNavigator: true).pop();
      }
    }).catchError((error) {
print("Iam in error");

      styles.showSnackBar(scaffoldKey, context,
          context.localeString('error_occurred'), 'error', '');
      Navigator.of(context, rootNavigator: true).pop();
    });
  }



  void enterAsGuest() async{
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
//    Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => new Categories('0','categoryTitle')));
  }

  void changeLoginType(String memberType) {
    setState(() {
      loginType=memberType;
    });
    print(loginType);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      key: scaffoldKey,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            color: Colors.white,
          ),
          Container(
            height: 350,
            decoration: const BoxDecoration(
                color: Color.fromRGBO(0, 0, 51, 1),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(35),
                    bottomRight: Radius.circular(35))),
          ),
          Positioned(
            top: 30,
            left: 10,
            right: 10,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              height: 110,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(35)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 40,
                      offset: Offset(8, 15), // Shadow position
                    ),
                  ]),
              margin: EdgeInsets.all(25),
              child: ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                children: [
                  const Padding(
                    padding:
                        EdgeInsets.only(left: 15.0, top: 80.0, right: 15.0),
                  ),
                  Container(
                    alignment: Alignment.topCenter,
                    child: Image.asset(
                      'images/logo.png',
                      width: 200.0,
                    ),
                  ),
                  const Padding(padding: EdgeInsets.only(top: 10.0)),
                  Container(
                    padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                    margin: const EdgeInsets.fromLTRB(10, 5, 10, 10),
                    child: Column(
                      children: [
                        const Padding(padding: EdgeInsets.only(top: 10.0)),
                        Text(context.localeString('login_page_title'),
                            style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 19.0,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center),
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.only(
                              right: 20.0, left: 20.0, top: 40.0),
                          margin: const EdgeInsets.only(
                              right: 20.0, left: 20.0, top: 8.0),
                          child: DropdownButton(
                            //underline: Container(),
                            isExpanded: true,
                            dropdownColor: Colors.white,
                            value: userkind,
                            items: kindRegister.map((String kind) {
                              return DropdownMenuItem(
                                value: kind,
                                child: Center(
                                    child: Text(
                                  context.localeString(kind).toString(),
                                  style: const TextStyle(
                                    color: Color.fromRGBO(0, 0, 51, 1),
                                    fontSize: 15,
                                  ),
                                )),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {

                                userkind = newValue!;
                                changeLoginType(userkind);
                              });
                            },
                          ),
                        ),
                        Container(
                          color: Colors.white,
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(5,0, 5, 0),
                            child: TextField(
                              autocorrect: false,
                              style: const TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w300),
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                prefixIcon: Container(
                                  color: Colors.white,

                                  padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),

                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      GestureDetector(
                                        onTap: () async {
                                          final country_code= await countryPicker.showPicker(context: context);
                                          setState(() {
                                            _countryCode=country_code;
                                          });
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(color: Color.fromRGBO(0, 0, 51, 1),borderRadius: BorderRadius.circular(5)),
                                           padding :const EdgeInsets.fromLTRB(10,5, 10, 5),
                                          child: Text(
                                            _countryCode?.dialCode??"+1",style: TextStyle(color: Colors.white),
                                          ),

                                            
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                enabledBorder: UnderlineInputBorder(
                                    borderRadius: BorderRadius.circular(7.0)),
                                hintText: context
                                    .localeString('mobile_number')
                                    .toString(),
                                hintStyle: styles.inputTextHintStyle,
                                fillColor: Colors.white,
                                hintTextDirection: TextDirection.ltr,
                                filled: true,
                              ),
                              controller: _getmobileNumber,
                              //inputFormatters: [maskFormatter],
                              keyboardType: TextInputType.phone,
                              maxLines: 1,

                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(
                              right: 5.0, left: 5.0, top: 20.0),
                          child: TextField(
                            autocorrect: false,
                            style: const TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w300),
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              border: UnderlineInputBorder(
                                  borderRadius: BorderRadius.circular(7.0)),
                              prefixIcon: const Icon(Icons.lock,
                                  color: Color.fromRGBO(254, 197, 2, 1)),
                              hintText:
                                  context.localeString('password').toString(),
                              hintStyle: styles.inputTextHintStyle,
                              fillColor: Colors.white,
                              filled: true,
                              suffixIcon: IconButton(
                                  icon: Icon(
                                    _isObscure
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.black54,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isObscure = !_isObscure;
                                    });
                                  }),
                            ),
                            controller: _getPassword,
                            obscureText: _isObscure,
                            keyboardType: TextInputType.text,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(
                              right: 40.0, left: 40.0, top: 20.0),
                          child: ElevatedButton(
                            onPressed: () {
                              if (loginType ==context.localeString("shop")
                                ) {

                                _login();

                              } else {
                                _login();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.only(
                                  right: 30.0,
                                  left: 30.0,
                                  top: 5.0,
                                  bottom: 5.0),
                              primary: Color.fromRGBO(194, 171, 131, 1),
                              shape: styles.circleBtn(),
                              elevation: 0.0,
                            ),

                            child: Text(context.localeString('login_btn'),
                                style: TextStyle(color: Colors.white),
                                textAlign: TextAlign
                                    .center), //Theme.of(context).textTheme.button
                          ),
                        ),
                        const Padding(padding: EdgeInsets.only(top: 30.0)),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Container(),
                      ),
                      Container(
                          child: TextButton(
                        child: Text(context.localeString('do_not_have_account'),
                            style: const TextStyle(
                                color: Color.fromRGBO(0, 0, 51, 1),
                                fontSize: 16.0),
                            textAlign: TextAlign.center),
                        onPressed: () => Navigator.of(context)
                            .pushNamedAndRemoveUntil(
                                '/Register', (Route<dynamic> route) => false),
                      )),
                      Container(
                          child: TextButton(
                              child: Text(
                                  context.localeString('forget_password'),
                                  style: const TextStyle(
                                      color: Color.fromRGBO(0, 0, 51, 1),
                                      fontSize: 16.0),
                                  textAlign: TextAlign.center),
                              onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ForgetPassword()),
                                  ))),
                      Expanded(
                        child: Container(),
                      ),
                    ],
                  ),
                  Center(
                      child: TextButton(
                    child: Text(context.localeString('enter_as_guest'),
                        style: const TextStyle(
                            color: Color.fromRGBO(0, 0, 51, 1), fontSize: 16.0),
                        textAlign: TextAlign.center),
                    onPressed: () => enterAsGuest(),
                  )),
                  const Padding(padding: EdgeInsets.only(bottom: 20.0)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
