import 'dart:convert';
import 'dart:ui';
import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supplyplatform/gui/members/login.dart';
import 'package:supplyplatform/gui/members/activation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supplyplatform/components/funcs.dart';
import 'package:supplyplatform/components/styles.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:supplyplatform/gui/register_textdata.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class Register extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _RegisterState();
  }

}

class _RegisterState extends State<Register>{

  final TextEditingController _getUserName = TextEditingController();
  final TextEditingController _getEmailAddress = TextEditingController();
  final TextEditingController _getMobileNumber = TextEditingController();
  final TextEditingController _getPassword = TextEditingController();
  final countryPicker = const FlCountryCodePicker();
  CountryCode?_countryCode;
  late String theLanguage='en';
  late TextAlign theAlignment;
  late String mytoken = '';
  late String deviceId='';
  late bool contractCheck = false;
  String userkind="Select User";
  String country="Select Country";
  var kindRegister = [
    'Select User',
    'shop',
    'factory',
    'delivery_company'
  ];
  List<DropdownMenuItem<String>> countriesList = [];
  String countryId = '0';

  bool isLoading=false;
  bool _isObscure = true;

  var funcs = Funcs();
  var styles = Styles();


  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  late FocusNode myFocusNode;
  final _formKey = GlobalKey<FormState>();

  late FirebaseMessaging messaging;

  //var maskFormatter = MaskTextInputFormatter(mask: '##-####-####', filter: { "#": RegExp(r'[0-9]') });

  @override
  void initState(){
    super.initState();

    messaging = FirebaseMessaging.instance;
    messaging.getToken().then((value){
      setState(() {
        mytoken = value.toString();
      });
    });


    getSharedData().then((result) {
      getCountries();
    });

  }

  void getCountries() async{
    setState(() {
      isLoading = true;
    });
    var myUrl = Uri.parse('${funcs.mainLink}api/getCountries/$theLanguage/');
    http.Response response = await http.get(myUrl, headers: {"Accept": "application/json"});

    countriesList.add(DropdownMenuItem(
      value: '0',
      child: SizedBox(
        width: double.infinity,
        child: Text(context.localeString('please_select'), style:TextStyle(color: Colors.black,fontSize: 17 ), textAlign: TextAlign.center),
      ),
    ));


    try{
      setState(() {
        isLoading = false;
      });
      var responseData = json.decode(response.body);
      responseData.forEach((country){
        countriesList.add(DropdownMenuItem(
          value: "${country['coId']}",
          child: SizedBox(
            width: double.infinity,
            child: Text(country['countryName'], style: styles.inputTextStyle,textAlign: TextAlign.center),
          ),
        ));
      },
      );
    }catch(e){
      print(e);
    }

  }

  _changeCountry(String e) async{
    setState(() {
      countryId = e;
    });

  }


  getSharedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      theLanguage = prefs.getString('theLanguage')!;
      deviceId = prefs.getString('deviceId')!;

      if(theLanguage == 'ar'){
        theAlignment = TextAlign.right;
      }else{
        theAlignment = TextAlign.left;
      }

    });
  }

  checkAccount(){
    styles.onLoading(context);
    String theEmailAddress = _getEmailAddress.text.trim();
    String theMobileNumber =  "${_countryCode!.dialCode.toString()}${_getMobileNumber.text}".trim();

    theMobileNumber = funcs.replaceArabicNumber(theMobileNumber);
    theMobileNumber = funcs.removeCharacterFromMobile(theMobileNumber);


    http.post(Uri.parse(funcs.mainLink+'api/checkEmailForRegister'), body: {
      "emailAddress" : theEmailAddress,
      "mobileNumber" : theMobileNumber,
      "theType":userkind,
    }).then((result) async{
      var theResult = json.decode(result.body);

      if(theResult['resultFlag'] == 'done'){
        Navigator.of(context, rootNavigator: true).pop();
        _sendActiveCode();
      }else if(theResult['resultFlag'] == 'duplicate'){
        styles.showSnackBar(scaffoldKey, context, context.localeString('email_already_registered'),'error','forget_password');
        Navigator.of(context, rootNavigator: true).pop();
      }else if(theResult['resultFlag'] == 'duplicate_mobile'){
        styles.showSnackBar(scaffoldKey, context, context.localeString('mobile_number_already_registered'),'error','forget_password');
        Navigator.of(context, rootNavigator: true).pop();
      }else{
        styles.showSnackBar(scaffoldKey, context, context.localeString('error_occurred'),'error','forget_password');
        Navigator.of(context, rootNavigator: true).pop();
      }
    }).catchError((error) {
      print(error);
     // print (theFullName + " " + theFullName.runtimeType.toString());
      print (theEmailAddress+" " + theEmailAddress.runtimeType.toString());
      print (theMobileNumber+" " + theMobileNumber.runtimeType.toString());
    //  print (thePassword+" " + thePassword.runtimeType.toString());
      styles.showSnackBar(scaffoldKey, context, context.localeString('error_occurred'),'error','');
      Navigator.of(context, rootNavigator: true).pop();
    });
  }

  void _sendActiveCode(){
    styles.onLoading(context);

    String theFullName =  _getUserName.text.trim();
    String theEmailAddress =  _getEmailAddress.text.trim();
    String theMobileNumber = "${_countryCode!.dialCode.toString()}${_getMobileNumber.text.toString()}".trim();
    String thePassword =  _getPassword.text.trim();



    theMobileNumber = funcs.replaceArabicNumber(theMobileNumber);
    theMobileNumber = funcs.removeCharacterFromMobile(theMobileNumber);

    String activationCode =  funcs.generateActivationCode();
print(activationCode);
print(theMobileNumber);

    http.post(Uri.parse(funcs.mainLink+'api/sendActivationCode'), body: {
      "activationCode" : activationCode,
      "theMobileNumber": theMobileNumber,
    }).then((result) async{
      var theResult = json.decode(result.body);
      print("result");
      print(theResult);
      if(theResult['code'].toString() == '77'){
        Navigator.of(context, rootNavigator: true).pop();
        Navigator.push(context, MaterialPageRoute(builder: (context) => Activation(theFullName,theEmailAddress,theMobileNumber,thePassword,deviceId,mytoken,activationCode,countryId,userkind)),);
      }else{
        Navigator.of(context, rootNavigator: true).pop();
      }
    }).catchError((error) {
      print("error  "+error);

      Navigator.of(context, rootNavigator: true).pop();
    });

    print(activationCode);

  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      key: scaffoldKey,
      body: Stack(
        children: [
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
            top: 30,
            left: 10,
            right: 10,
            bottom:0,
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
            child: GestureDetector(
              onTap: ()=> FocusScope.of(context).requestFocus(FocusNode()),
              child: Form(
                key: _formKey,
                child: ListView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          IconButton(
                            onPressed: ()=> Navigator.push(context, MaterialPageRoute(builder: (context) => Login()),),
                            icon: const Icon(Icons.arrow_back_ios),
                            color: Color.fromRGBO(0, 0, 51, 1),
                          )
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 15.0, top:50.0, right: 15.0),
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: Image.asset(
                        'images/logo.png',
                        width: 200.0,
                      ),
                    ),
                    Container(
                        child: Column(
                          children: <Widget>[
                            const Padding(padding: EdgeInsets.only(top: 30.0)),
                            Text(context.localeString('register_page_title'), style: TextStyle(color: Color.fromRGBO(0, 0, 51, 1), fontSize: 19.0,fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                            Padding(padding: const EdgeInsets.only(right: 20.0, left: 20.0, top: 30.0)),

                                  Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                          borderRadius: BorderRadius.circular(8)),

                                    padding:  EdgeInsets.only(right: 20.0, left: 20.0, top: 5.0),
                                      margin:  EdgeInsets.only(right: 20.0, left: 20.0, top: 20.0),
                                      child: DropdownButton(
                                        underline: Container(),
                                        isExpanded: true,
                                        dropdownColor:Colors.white,
                                        value: userkind,
                                        items:kindRegister.map((String kind) {
                                          return DropdownMenuItem(
                                            value: kind,
                                            child: Center(child: Text(context.localeString(kind).toString(),style: TextStyle(color: Colors.black,fontSize: 15),)),
                                          );
                                        }).toList(),

                                        onChanged: (String? newValue) {
                                          setState(() {
                                            userkind = newValue!;
                                          });
                                        },
                                      ),


                                  ),
                            const Padding(padding: EdgeInsets.only(top: 30.0)),
                            Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8)),

                              padding: const EdgeInsets.only(right: 20.0, left: 20.0, top: 5.0),
                              margin: const EdgeInsets.only(right: 20.0, left: 20.0, top: 5.0),
                              width: 400.0,
                              alignment: Alignment.topCenter,
                              child: DropdownButtonFormField(
                                borderRadius: BorderRadius.circular(20.0),
                                validator: (value) => countryId == '0' ? context.localeString('field_is_empty').toString() : null,
                                isExpanded: true,
                                items: countriesList,
                                onChanged: (value)=> _changeCountry(value.toString()),
                                value: countryId,

                              ),
                            ),

                            Container(
                              padding: const EdgeInsets.only(right: 20.0, left: 20.0, top: 30.0),
                              child: TextFormField(
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return context.localeString('field_is_empty').toString();
                                  }else if(value.length < 3) {
                                    return context.localeString('field_must_more_three').toString();
                                  }
                                  return null;
                                },
                                autocorrect: false,
                                style: styles.inputTextStyle,
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  border: UnderlineInputBorder(borderRadius:BorderRadius.circular(7.0)),
                                  prefixIcon: const Icon(Icons.person, color: Color.fromRGBO(254, 197, 2, 1),),
                                  hintText: context.localeString('full_name').toString(), hintStyle:  styles.inputTextHintStyle,
                                  fillColor: Colors.white,
                                  filled: true,
                                ),
                                controller: _getUserName,
                                keyboardType: TextInputType.text,
                                maxLines: 1,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.only(right: 20.0, left: 20.0, top: 30.0),
                              child: TextFormField(
                                validator: (value) {
                                  Pattern pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                                  RegExp regex = RegExp(pattern.toString());
                                  if (value!.isEmpty) {
                                    return context.localeString('field_is_empty').toString();
                                  }else if(!regex.hasMatch(value.trim())) {
                                    return context.localeString('enter_valid_email').toString();
                                  }
                                  return null;
                                },
                                autocorrect: false,
                                style: styles.inputTextStyle,
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  border: UnderlineInputBorder(borderRadius:BorderRadius.circular(7.0)),
                                  prefixIcon: const Icon(Icons.email, color: const Color.fromRGBO(254, 197, 2, 1)),
                                  hintText: context.localeString('email_address').toString(), hintStyle:  styles.inputTextHintStyle,
                                  fillColor: Colors.white,
                                  filled: true,
                                ),
                                controller: _getEmailAddress,
                                keyboardType: TextInputType.emailAddress,
                                maxLines: 1,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.only(right: 20.0, left: 20.0, top: 30.0),
                              child: TextFormField(
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return context.localeString('field_is_empty').toString();
                                  }else if(value.length < 10) {
                                    return context.localeString('mobile_must_more_ten').toString();
                                  }
                                  return null;
                                },
                                autocorrect: false,
                                style: styles.inputTextStyle,
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  border: UnderlineInputBorder(borderRadius:BorderRadius.circular(7.0)),
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
                                  hintText: context.localeString('mobile_number'), hintStyle:  styles.inputTextHintStyle, hintTextDirection: TextDirection.ltr,
                                  fillColor: Colors.white,
                                  filled: true,
                                ),
                                controller: _getMobileNumber,
                                keyboardType: TextInputType.phone,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.only(right: 20.0, left: 20.0, top: 30.0),
                              child: TextFormField(
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return context.localeString('field_is_empty').toString();
                                  }else if(value.length < 6) {
                                    return context.localeString('password_must_more_six').toString();
                                  }
                                  return null;
                                },
                                autocorrect: false,
                                style: styles.inputTextStyle,
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  border: UnderlineInputBorder(borderRadius:BorderRadius.circular(7.0)),
                                  prefixIcon: const Icon(Icons.lock, color: const Color.fromRGBO(254, 197, 2, 1)),
                                  hintText: context.localeString('password').toString(), hintStyle:  styles.inputTextHintStyle,
                                  fillColor: Colors.white,
                                  filled: true,
                                  suffixIcon: IconButton(
                                      icon: Icon(
                                          _isObscure ? Icons.visibility_off : Icons.visibility, color: Colors.black54,),
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
                                alignment: Alignment.topLeft,
                                padding: const EdgeInsets.only(right: 30.0, left: 30.0, top: 20.0),
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      child: contractCheck == false ? const FaIcon(FontAwesomeIcons.checkCircle , color:Color.fromRGBO(0, 0, 51, 1), size: 20.0,) : FaIcon(FontAwesomeIcons.solidCheckCircle, color :Color.fromRGBO(0, 0, 51, 1)  , size: 20.0,),
                                      onTap: (){
                                        if(contractCheck == false){
                                          contractCheck = true;
                                        }else{
                                          contractCheck = false;
                                        }
                                        setState(() {});
                                      },
                                    ),
                                    const SizedBox(width: 10,),
                                    Expanded(
                                      child: GestureDetector(
                                        child: Text(context.localeString('register_privacy_approve' ), style: TextStyle(color: Color.fromRGBO(0, 0, 51, 1)), textAlign: theAlignment),
                                        onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterTextData('privacy')),),
                                      ),
                                    )
                                  ],
                                )
                            ),
                            Container(
                              padding: const EdgeInsets.only(right: 40.0, left: 40.0, top: 20.0),
                              child: ElevatedButton(
                                onPressed: (){
                                  if(contractCheck == true){
                                    if (_formKey.currentState!.validate()) {

                                      checkAccount();
                                    }
                                  }else{
                                    null;
                                  }
                                },
                                style: ElevatedButton.styleFrom(padding: const EdgeInsets.only(right: 30.0, left: 30.0, top: 5.0, bottom: 5.0 ),
                                  primary: contractCheck == false ? Colors.grey :Color.fromRGBO(194, 171, 131, 1),
                                  shape: styles.circleBtn(),
                                  elevation: 0.0,
                                ),

                                child: Text(context.localeString('register_btn'),style: Theme.of(context).textTheme.button, textAlign: TextAlign.center),

                              ),
                            ),

                            const Padding(padding: EdgeInsets.only(top: 30.0)),
                          ],
                        ),
                      ),


                    Center(
                        child: TextButton(
                          child: Text(context.localeString('i_have_account'), style: const TextStyle(color: Color.fromRGBO(0, 0, 51, 1), fontSize: 16.0 , fontWeight:FontWeight.bold ), textAlign: TextAlign.center),
                          onPressed: ()=> Navigator.of(context).pushNamedAndRemoveUntil('/Login',(Route<dynamic> route) => false),
                        )
                    ),
                    const Padding(padding: EdgeInsets.only(bottom: 50.0)),
                  ],
                ),
              ),
            ),
            ),
          )
        ],
      ),
    );
  }

}