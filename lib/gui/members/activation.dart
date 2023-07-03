import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:supplyplatform/components/funcs.dart';
import 'package:supplyplatform/components/styles.dart';

class Activation extends StatefulWidget{
  Activation(this.theFullName,this.theEmailAddress,this.theMobileNumber,this.thePassword,this.deviceId,this.mytoken, this.activationCode,this.countryId,this.userKind);
  String theFullName;
  String theEmailAddress;
  String theMobileNumber;
  String thePassword;
  String deviceId = '';
  String mytoken;
  String activationCode;
  String countryId;
  String userKind;
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _ActivationState(theFullName,theEmailAddress,theMobileNumber,thePassword,deviceId,mytoken,activationCode,countryId,userKind);
  }

}

class _ActivationState extends State<Activation>{
  _ActivationState(this.theFullName,this.theEmailAddress,this.theMobileNumber,this.thePassword,this.deviceId,this.mytoken,this.activationCode,this.countryId,this.userKind);
  String theFullName;
  String theEmailAddress;
  String theMobileNumber;
  String thePassword;
  String deviceId = '';
  String mytoken;
  String activationCode ;
  String countryId;
  String userKind;

  final TextEditingController _getActivationCode = TextEditingController();
  late String theLanguage;
  late TextAlign theAlignment;

  late Timer _timer;
  int _start = 120;

  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey();
  late FocusNode myFocusNode;
  final _formKey = GlobalKey<FormState>();

  var funcs = Funcs();
  var styles = Styles();

  @override
  void initState(){
    super.initState();
    startTimer();
    getSharedData();

  }

  @override
  void dispose(){
    _timer.cancel();
    super.dispose();
  }

  getSharedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      theLanguage = prefs.getString('theLanguage')!;

      if(theLanguage == 'ar'){
        theAlignment = TextAlign.right;
      }else{
        theAlignment = TextAlign.left;
      }

    });
  }



  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
          (Timer timer) => setState(
            () {
          if (_start < 1) {
            timer.cancel();
          } else {
            _start = _start - 1;
            if(_start == 0){
              FocusManager.instance.primaryFocus?.unfocus();
              setState(() {
                activationCode = 'osamaOSR';
              });
            }
          }
        },
      ),
    );
  }

  void _sendActiveCode(String activationCode){
    styles.onLoading(context);

    http.post(Uri.parse(funcs.mainLink+'api/sendActivationCode'), body: {
      "activationCode" : activationCode,
      "theMobileNumber": theMobileNumber,

    }).then((result) async{
      var theResult = json.decode(result.body);
      if(theResult['code'].toString() == '77'){
        Navigator.of(context, rootNavigator: true).pop();
      }else{
        Navigator.of(context, rootNavigator: true).pop();
      }
    }).catchError((error) {
      print(error);
      Navigator.of(context, rootNavigator: true).pop();
    });

  }

  void _regenerateActivationCode(){
    setState(() {
      activationCode = funcs.generateActivationCode();
      _sendActiveCode(activationCode);
      print(activationCode);
      _start = 120;
      _getActivationCode.text = '';
    });
    startTimer();
  }


  void _register_member() async{

    print(activationCode);

    String enteredActivationCode = _getActivationCode.text.trim();
    if(enteredActivationCode == activationCode && int.parse(activationCode) > 0 ){

      styles.onLoading(context);

      theMobileNumber = funcs.replaceArabicNumber(theMobileNumber);
      theMobileNumber = funcs.removeCharacterFromMobile(theMobileNumber);

      http.post(Uri.parse(funcs.mainLink+'api/registerMember'), body: {
        "fullName" : theFullName,
        "emailAddress": theEmailAddress,
        "mobileNumber": theMobileNumber,
        "thePassword": thePassword,
        "theLanguage": theLanguage,
       "deviceId": deviceId,
        "fcmToken": mytoken,
        "countryId": countryId,
        "LogInType":userKind

      }).then((result) async{
        var theResult = json.decode(result.body);

        if(theResult['resultFlag'] == 'done'){
          Navigator.of(context, rootNavigator: true).pop();

      if(userKind=='shop') {
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
  await prefs.setString('mobileNumber', mobileNumber);
  await prefs.setString('emailAddress', emailAddress);
  await prefs.setString('theLanguage', theLanguage);
  await prefs.setInt('currencyId', currencyId);
  await prefs.setString('currencySymbol', currencySymbol);
  await prefs.setDouble('currencyExchange', double.parse(currencyExchange));
  await prefs.setBool('isLogin', true);
  await prefs.setInt('cartCount', cartCount);
  await prefs.setString('LogInType', 'shop');


  Navigator.of(context).pushNamedAndRemoveUntil(
      '/MainPage', (Route<dynamic> route) => false);
}
        else if (userKind=='store' ||userKind=='factory' ){
        String storeId = theResult['theResult'][0]['stId'];
        String storeName = theResult['theResult'][0]['storeName'];
        String storeEmail = theResult['theResult'][0]['emailAddress'];
        String storeMobile=theResult['theResult'][0]['mobileNumber'];
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('storeId', storeId);
        await prefs.setString('storeName', storeName);
        await prefs.setString('storeEmail', storeEmail);
        await prefs.setString('storeMobile', storeMobile);
        await prefs.setString('LogInType', userKind);

        Navigator.of(context).pushNamedAndRemoveUntil(
            '/StoreDashboard', (Route<dynamic> route) => false);}

      else {
        String deliveryId = theResult['theResult'][0]['stId'];
        String deliveryName = theResult['theResult'][0]['storeName'];
        String deliveryEmail = theResult['theResult'][0]['emailAddress'];
        String deliveryMobile=theResult['theResult'][0]['mobileNumber'];
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('deliveryId', deliveryId);
        await prefs.setString('deliveryName', deliveryName);
        await prefs.setString('deliveryEmail', deliveryEmail);
        await prefs.setString('deliveryMobile', deliveryMobile);
        await prefs.setString('LogInType', userKind);

        Navigator.of(context).pushNamedAndRemoveUntil(
            '/DeliveryDash', (Route<dynamic> route) => false);}



        }else if(theResult['resultFlag'] == 'duplicate'){
          styles.showSnackBar(scaffoldKey, context, context.localeString('mobile_number_already_registered'),'error','forget_password');
          Navigator.of(context, rootNavigator: true).pop();
        }else if(theResult['resultFlag'] == 'duplicate_email'){
          styles.showSnackBar(scaffoldKey, context, context.localeString('email_already_registered'),'error','');
          Navigator.of(context, rootNavigator: true).pop();
        }else{
          styles.showSnackBar(scaffoldKey, context, context.localeString('error_occurred'),'error','forget_password');
          Navigator.of(context, rootNavigator: true).pop();
        }
      }).catchError((error) {
        styles.showSnackBar(scaffoldKey, context, context.localeString('error_occurred'),'error','');
        Navigator.of(context, rootNavigator: true).pop();
      });

    }else{
      styles.showSnackBar(scaffoldKey,context,context.localeString('activation_code_not_correct'),'error','');
    }
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      key: scaffoldKey,
      appBar: styles.theAppBar(context, theLanguage='en', false, '' , true, false, '0'),
      body: Stack(
        children: [
          Container(
            color: Colors.white,
          ),
          Container(
            height: 350,
            decoration: const BoxDecoration(
                color: Color.fromRGBO(0, 0, 51, 1),
                borderRadius: BorderRadius.only(bottomLeft:Radius.circular(35),bottomRight: Radius.circular(35))),
          ),
          Positioned(
            top: 30,
            left: 10,
            right: 10,
            bottom: 0,
            child: Container(
              padding:const EdgeInsets.only(left: 10.0, right: 10.0),
              height: 210,

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
              child: GestureDetector(
                onTap: ()=> FocusScope.of(context).requestFocus(FocusNode()),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    children: <Widget>[
                      const SizedBox(height: 20.0,),
                      const Padding(padding: EdgeInsets.only(top: 20.0)),
                      Text(context.localeString('activation_code'), style: const TextStyle(color: Color.fromRGBO(0, 0, 51, 1), fontSize: 25.0), textAlign: TextAlign.center),
                      Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.only(right: 40.0, left: 40.0, top: 20.0),
                        child: Text(context.localeString('activation_sent_to') + ' ' + theMobileNumber, style: const TextStyle(color: Colors.black, fontSize: 15.0),),

                      ),
                      const Padding(padding: EdgeInsets.only(top: 30.0)),
                      Container(
                        child: Column(
                          children: <Widget>[
                            const Padding(padding: EdgeInsets.only(top: 30.0)),
                            Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.only(right: 20.0, left: 20.0, top: 10.0),
                              child: Text(_start.toString() + ' sec', style: const TextStyle(color: Colors.black, fontSize: 17.0),),
                            ),
                            Container(
                              padding: const EdgeInsets.only(right: 20.0, left: 20.0, top: 10.0),
                              child: TextFormField(
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return context.localeString('field_is_empty').toString();
                                  }else if(value.length < 5) {
                                    return context.localeString('number_must_be_five').toString();
                                  }
                                  return null;
                                },
                                autocorrect: false,
                                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w300),
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  border: UnderlineInputBorder(borderRadius:BorderRadius.circular(7.0),),
                                  prefixIcon: const Icon(Icons.sms, color: Colors.black54),
                                  hintText: context.localeString('activation_code').toString(), hintStyle:  const TextStyle(fontFamily: 'Cairo', color: Colors.black54),
                                  fillColor: Colors.white,
                                  filled: true,
                                ),
                                controller: _getActivationCode,
                                keyboardType: TextInputType.number,
                                maxLength: 5,
                                maxLines: 1,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.only(right: 40.0, left: 40.0, top: 20.0),
                              child: ElevatedButton(
                                onPressed: (){
                                  if (_formKey.currentState!.validate()) {
                                    _register_member();
                                  }
                                },
                                style:ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.only(right: 20.0, left: 20.0, top: 5.0, bottom: 5.0 ),
                                  elevation: 0.0,
                                  primary: Color.fromRGBO(194, 171, 131, 1),
                                  shape: styles.circleBtn(),
                                ) ,

                                child: Text(context.localeString('check'),style: TextStyle(color: Colors.white), textAlign: TextAlign.center),


                              ),
                            ),
                            const Padding(padding: EdgeInsets.only(top: 30.0)),
                          ],
                        ),
                      )

                    ],
                  ),
                ),
              ),
            ),
          ),

        ],
      ),
      bottomNavigationBar: _start == 0 ? Container(
        height: 50.0,
        width: double.infinity,
        color: Colors.green,
        child: GestureDetector(
          onTap: ()=> _regenerateActivationCode(),
          child: Container(
            color: Colors.transparent,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(10.0),
            child: Text(context.localeString('resend_activation_code'), style: styles.activeBtn,),
          ),
        ),
      ):Container(height: 0.0,),
    );
  }

}