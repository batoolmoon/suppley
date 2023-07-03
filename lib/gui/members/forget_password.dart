import 'dart:ui';
import 'dart:convert';
import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supplyplatform/gui/members/login.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:supplyplatform/components/funcs.dart';
import 'package:supplyplatform/components/styles.dart';

class ForgetPassword extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ForgetPasswordState();
  }

}

class _ForgetPasswordState extends State<ForgetPassword>{

  final TextEditingController _getMobileNumber = TextEditingController();
  late String theLanguage;
  late TextAlign theAlignment;
  bool passwordSent = false;
  String loginType = 'member';
  final countryPicker = const FlCountryCodePicker();
  CountryCode?_countryCode;

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  late FocusNode myFocusNode;
  final _formKey = GlobalKey<FormState>();

 // var maskFormatter = MaskTextInputFormatter(mask: '##-####-####', filter: { "#": RegExp(r'[0-9]') });
  String userkind="select_user";
  var kindRegister = [
    'select_user',
    'shop',
    'factory',
    'delivery_company'
  ];

  var funcs = Funcs();
  var styles = Styles();

  @override
  void initState(){
    super.initState();
    getSharedData();

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


  void resetPassword() async{

    styles.onLoading(context);

    String theMobileNumber = "${_countryCode!.dialCode.toString()}${_getMobileNumber.text}".trim();

    theMobileNumber = funcs.replaceArabicNumber(theMobileNumber);
    theMobileNumber = funcs.removeCharacterFromMobile(theMobileNumber);

    http.post(Uri.parse(funcs.mainLink+'api/resetPassword'), body: {
      "mobileNumber": theMobileNumber,
      "theType":userkind,

    }).then((result) async{
      var theResult = json.decode(result.body);
      if(theResult['code'].toString() == '77'){
        setState(() {
          passwordSent = true;
        });
        styles.showSnackBar(scaffoldKey,context,context.localeString('new_password_sent').toString(),'success','');
        Navigator.of(context, rootNavigator: true).pop();
      }else if(theResult['resultFlag'] == 'error'){
        styles.showSnackBar(scaffoldKey,context,context.localeString('phone_not_found').toString(),'error','');
        Navigator.of(context, rootNavigator: true).pop();
      }
    }).catchError((error) {
      print(error);
      styles.showSnackBar(scaffoldKey, context, context.localeString('error_occurred'),'error','');
      Navigator.of(context, rootNavigator: true).pop();
    });
  }

  void resetStorePassword() async{

    styles.onLoading(context);

    String theMobileNumber = "${_countryCode!.dialCode.toString()}${_getMobileNumber.text}".trim();

    theMobileNumber = funcs.replaceArabicNumber(theMobileNumber);
    theMobileNumber = funcs.removeCharacterFromMobile(theMobileNumber);

    http.post(Uri.parse(funcs.mainLink+'api/resetStorePassword'), body: {
      "mobileNumber": theMobileNumber,
      "theType":userkind,
    }).then((result) async{
      var theResult = json.decode(result.body);
      if(theResult['code'].toString() == '77'){
        setState(() {
          passwordSent = true;
        });
        styles.showSnackBar(scaffoldKey,context,context.localeString('new_password_sent').toString(),'success','');
        Navigator.of(context, rootNavigator: true).pop();
      }else if(theResult['resultFlag'] == 'error'){
        styles.showSnackBar(scaffoldKey,context,context.localeString('phone_not_found').toString(),'error','');
        Navigator.of(context, rootNavigator: true).pop();
      }
    }).catchError((error) {
      print(error);
      styles.showSnackBar(scaffoldKey, context, context.localeString('error_occurred'),'error','');
      Navigator.of(context, rootNavigator: true).pop();
    });
  }

  void changeLoginType(String memberType){
    if(memberType == 'shop'){
      setState(() {
        loginType = 'shop';
      });
    }else if (memberType == 'delivery_company'){
      setState(() {
        loginType = 'delivery_company';
      });
    }
    else { loginType = 'factory';}
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      key: scaffoldKey,
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
              child: GestureDetector(
                onTap: ()=> FocusScope.of(context).requestFocus(FocusNode()),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    children: <Widget>[
                      const SizedBox(height: 20.0,),
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
                      const Padding(padding: EdgeInsets.only(top: 30.0)),
                      Text(context.localeString('reset_password_title'), style: const TextStyle(color: Color.fromRGBO(0, 0, 51, 1), fontSize: 25.0, fontWeight:FontWeight.bold ), textAlign: TextAlign.center),
                      const Padding(padding: EdgeInsets.only(top: 30.0)),

                      passwordSent == false ? Container(
                          child: Column(
                            children: <Widget>[
                              const Padding(padding: EdgeInsets.only(top: 30.0)),

                              Container(
                                padding: const EdgeInsets.only(right: 20.0, left: 20.0, top: 30.0),
                                child:
                                Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.only(right: 20.0, left: 20.0, top: 5.0),
                                  child: DropdownButton(
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
                                        changeLoginType(userkind);
                                      });
                                    },
                                  ),


                                ),

                                /* Row(
                                  children: [

                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: ()=> changeLoginType('store'),
                                        style:ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.only(right: 20.0, left: 20.0, top: 5.0, bottom: 5.0 ),
                                          elevation: 0.0,
                                          primary: loginType == 'store' ? Theme.of(context).secondaryHeaderColor: const Color.fromRGBO(230,230,230,1),
                                        ) ,

                                        child: Text(context.localeString('store_btn'),style: loginType == 'store' ? styles.activeBtn:styles.inActiveBtn, textAlign: TextAlign.center),

//                                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(30.0), bottomRight: Radius.circular(30.0))),

                                      ),
                                    ),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: ()=> changeLoginType('member'),
                                        style:ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.only(right: 20.0, left: 20.0, top: 5.0, bottom: 5.0 ),
                                          elevation: 0.0,
                                          primary:loginType == 'member' ? Theme.of(context).secondaryHeaderColor: const Color.fromRGBO(230,230,230,1),
                                        ) ,

                                        child: Text(context.localeString('member_btn'), style: loginType == 'member' ? styles.activeBtn:styles.inActiveBtn, textAlign: TextAlign.center),
//                                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(30.0), bottomLeft: Radius.circular(30.0))),

                                      ),
                                    ),
                                  ],
                                ),*/
                              ),
                              Container(
                                color: Colors.white,
                                padding: const EdgeInsets.only(top: 30.0),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
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
                                      hintText:context.localeString('mobile_number'), hintStyle:  styles.inputTextHintStyle, hintTextDirection: TextDirection.ltr,
                                      fillColor: Colors.white,
                                      filled: true,
                                    ),
                                    controller: _getMobileNumber,
                                    //inputFormatters: [maskFormatter],
                                    keyboardType: TextInputType.phone,
                                    maxLines: 1,

                                  ),
                                ),
                              ),
                             /* Container(
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
                                  style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w300),
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    border: UnderlineInputBorder(borderRadius:BorderRadius.circular(7.0)),
                                    hintText: '07-xxxx-xxxx', hintStyle:  styles.inputTextHintStyle, hintTextDirection: TextDirection.ltr,
                                    fillColor: Colors.white,
                                    filled: true,
                                  ),
                                  controller: _getMobileNumber,
                                  keyboardType: TextInputType.phone,
                                  //inputFormatters: [maskFormatter],
                                  maxLines: 1,
                                ),
                              ),*/
                              Container(
                                padding: const EdgeInsets.only(right: 40.0, left: 40.0, top: 20.0),
                                child: ElevatedButton(
                                  onPressed: (){
                                    if (_formKey.currentState!.validate()) {
                                      if(loginType == 'store'){
                                      resetStorePassword();
                                      }else{
                                        resetPassword();
                                      }
                                    }
                                  },
                                  style:ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.only(right: 30.0, left: 30.0, top: 5.0, bottom: 5.0 ),
                                    elevation: 0.0,
                                    primary: Color.fromRGBO(194, 171, 131, 1),
                                  ) ,

                                  child: Text(context.localeString('send'),style: TextStyle(color:Colors.white), textAlign: TextAlign.center),

                                  //todo shape: styles.circleBtn(),

                                ),
                              ),
                              const Padding(padding: EdgeInsets.only(top: 30.0)),
                            ],
                          ),

                      ):Container(
                        padding: const EdgeInsets.only(right: 35.0, left: 35.0, top: 5.0, bottom: 5.0 ),
                        child: Column(
                          children: <Widget>[
                            Text(context.localeString('new_password_sent'), style: const TextStyle(color: Colors.white, fontSize: 20.0), textAlign: TextAlign.center),
                            const Padding(padding: EdgeInsets.only(top: 40.0)),

                            ElevatedButton(
                              onPressed: ()=> Navigator.push(context, MaterialPageRoute(builder: (context) => Login()),),
                              style:ElevatedButton.styleFrom(
                                padding: const EdgeInsets.only(right: 20.0, left: 20.0, top: 5.0, bottom: 5.0 ),
                                elevation: 0.0,
                                primary: Theme.of(context).secondaryHeaderColor,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                              ) ,

                              child: Text(context.localeString('go_to_login'),style: Theme.of(context).textTheme.button, textAlign: TextAlign.center),



                            )
                          ],
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }

}