import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supplyplatform/components/funcs.dart';
import 'package:supplyplatform/components/styles.dart';
import 'package:supplyplatform/components/bottom_navigation_bar.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DriverJoin extends StatefulWidget{
  DriverJoin();


  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _DriverJoinState();
  }

}

class _DriverJoinState extends State<DriverJoin>{

  final TextEditingController _getFirstName = TextEditingController();
  final TextEditingController _getLastName = TextEditingController();
  final TextEditingController _getEmailAddrress = TextEditingController();
  final TextEditingController _getMobileNumber = TextEditingController();

  late String theLanguage;
  late String pageTitle;

  late bool isLogin = false;
  late TextAlign theAlignment;
  late Alignment topAlignment;
  late bool isLoading = true;
  List<DropdownMenuItem<String>> countriesList = [];
  String countryId = '0';
  List<DropdownMenuItem<String>> citiesList = [];
  String cityId = '0';

  List<DropdownMenuItem<String>> licensesList = [];
  late String licenseValue = '0';

  List<DropdownMenuItem<String>> vehiclesList = [];
  late String vehicleValue = '0';

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  late FocusNode myFocusNode;
  final _formKey = GlobalKey<FormState>();

  var maskFormatter = MaskTextInputFormatter(mask: '##-####-####', filter: { "#": RegExp(r'[0-9]') });

  late String haveCar = '0';

  var funcs = Funcs();
  var styles = Styles();

  @override
  void initState(){
    super.initState();


    getSharedData().then((result) {
      getCountries();
      getLicenses();
      getVehicles();
    });
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    myFocusNode.dispose();

    super.dispose();
  }

  getSharedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(mounted){
      setState(() {
        theLanguage = prefs.getString('theLanguage')!;
        
        if(theLanguage == 'ar'){
          theAlignment = TextAlign.right;
          topAlignment = Alignment.topRight;
        }else{
          theAlignment = TextAlign.left;
          topAlignment = Alignment.topLeft;
        }
      });
    }
  }


  void joinDriver() async{

    styles.onLoading(context);

    String firstName =  _getFirstName.text;
    String lastName =  _getLastName.text;
    String theMobileNumber =  _getMobileNumber.text;
    String emailAddress =  _getEmailAddrress.text;

    theMobileNumber = funcs.replaceArabicNumber(theMobileNumber);
    theMobileNumber = funcs.removeCharacterFromMobile(theMobileNumber);

    http.post(Uri.parse(funcs.mainLink+'api/joinDriver'), body: {
      "firstName" : firstName,
      "lastName" : lastName,
      "theMobileNumber": theMobileNumber,
      "emailAddress": emailAddress,
      "countryId" : countryId,
      "cityId" : cityId,
      "licenseValue":licenseValue,
      "vehicleValue":vehicleValue,
      "haveCar":haveCar
    }).then((result) async{
      var theResult = json.decode(result.body);
      if(theResult['resultFlag'] == 1){
        Navigator.of(context, rootNavigator: true).pop();

        styles.showSnackBar(scaffoldKey,context,context.localeString('driver_join_successfully').toString(),'success','');

        await Future.delayed(const Duration(seconds: 2));

        Navigator.of(context).pushNamedAndRemoveUntil('/MainPage',(Route<dynamic> route) => false);
      }else{
        styles.showSnackBar(scaffoldKey,context,context.localeString('error_occurred'),'error','');
        Navigator.of(context, rootNavigator: true).pop();
      }
    }).catchError((error) {
      print(error);
      styles.showSnackBar(scaffoldKey,context,context.localeString('error_occurred'),'error','');
      Navigator.of(context, rootNavigator: true).pop();
    });
//    }else{
//      styles.showSnackBar(scaffoldKey,context,context.localeString('please_select_map_location'),'error','');
//    }
  }

  void getCountries() async{
    setState(() {
      isLoading = true;
    });
    var myUrl = Uri.parse(funcs.mainLink+'api/getCountries/$theLanguage/');
    http.Response response = await http.get(myUrl, headers: {"Accept": "application/json"});

    countriesList.add(DropdownMenuItem(
      child: SizedBox(
        width: double.infinity,
        child:  Text(context.localeString('please_select_country'), style: styles.inputTextStyle, textAlign: TextAlign.center),
      ),
      value: '0',
    ));


    try{
      setState(() {
        isLoading = false;
      });
      var responseData = json.decode(response.body);
      responseData.forEach((addresses){
        countriesList.add(DropdownMenuItem(
          child: SizedBox(
            width: double.infinity,
            child: Text(addresses['countryName'], style: styles.inputTextStyle, textAlign: TextAlign.center),
          ),
          value: "${addresses['coId']}",
        ));
      },
      );
    }catch(e){
      print(e);
    }

  }

  _changeCountry(String e){
    setState(() {
      countryId = e;
      cityId = '0';
      citiesList = [];
      getCities(countryId);
    });
  }


  void getCities(countryId) async{
    setState(() {
      isLoading = true;
    });
    var myUrl = Uri.parse(funcs.mainLink+'api/getCities/$theLanguage/$countryId');
    http.Response response = await http.get(myUrl, headers: {"Accept": "application/json"});

    citiesList.add(DropdownMenuItem(
      child: SizedBox(
        width: double.infinity,
        child: Text(context.localeString('please_select_city'), style: styles.inputTextStyle, textAlign: TextAlign.center),
      ),
      value: '0',
    ));


    try{
      setState(() {
        isLoading = false;
      });
      var responseData = json.decode(response.body);
      responseData.forEach((addresses){
        citiesList.add(DropdownMenuItem(
          child: SizedBox(
            width: double.infinity,
            child: Text(addresses['cityTitle'], style: styles.inputTextStyle,textAlign: TextAlign.center),
          ),
          value: "${addresses['ciId']}",
        ));
      },
      );
    }catch(e){
      print(e);
    }

  }

  _changeCity(String e){
    setState(() {
      cityId = e;
    });
  }


  void getLicenses() async{

    licensesList.add(DropdownMenuItem(
      child: SizedBox(
        width: double.infinity,
        child: Text(context.localeString('select_license'), style: styles.inputTextStyle, textAlign: TextAlign.center),
      ),
      value: '0',
    ));

    licensesList.add(DropdownMenuItem(
      child: SizedBox(
        width: double.infinity,
        child: Text(context.localeString('car'), style: styles.inputTextStyle, textAlign: TextAlign.center),
      ),
      value: 'car',
    ));

    licensesList.add(DropdownMenuItem(
      child: SizedBox(
        width: double.infinity,
        child: Text(context.localeString('bike'), style: styles.inputTextStyle, textAlign: TextAlign.center),
      ),
      value: 'bike',
    ));

  }

  _changeLicenses(String e){
    setState(() {
      licenseValue = e;
    });
  }

  void getVehicles() async{

    vehiclesList.add(DropdownMenuItem(
      child: SizedBox(
        width: double.infinity,
        child: Text(context.localeString('select_vehicle'), style: styles.inputTextStyle, textAlign: TextAlign.center),
      ),
      value: '0',
    ));

    vehiclesList.add(DropdownMenuItem(
      child: SizedBox(
        width: double.infinity,
        child: Text(context.localeString('car'), style: styles.inputTextStyle, textAlign: TextAlign.center),
      ),
      value: 'car',
    ));

    vehiclesList.add(DropdownMenuItem(
      child: SizedBox(
        width: double.infinity,
        child: Text(context.localeString('bike'), style: styles.inputTextStyle, textAlign: TextAlign.center),
      ),
      value: 'bike',
    ));

  }

  _changeVehicles(String e){
    setState(() {
      vehicleValue = e;
    });
  }

  @override
  Widget build(BuildContext context) {

    // TODO: implement build
    return Scaffold(
      key: scaffoldKey,
      appBar: styles.theAppBar(context, theLanguage, isLogin, context.localeString('driver_join') , true, false, '0'),
      body: GestureDetector(
        onTap: ()=> FocusScope.of(context).requestFocus(FocusNode()),
        child: Form(
          key: _formKey,
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: <Widget>[
              Column(
                children: <Widget>[

                  Container(
                    padding: const EdgeInsets.only(right: 30.0, left: 30.0, top: 40.0),
                    alignment: topAlignment,
                    child: Text(context.localeString('first_name'), style: styles.paragraphTitle, textAlign: theAlignment,),
                  ),
                  Container(
                    padding: const EdgeInsets.only(right: 30.0, left: 30.0, top: 0.0),
                    child: TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return context.localeString('field_is_empty').toString();
                        }else if(value.length < 3) {
                          return context.localeString('field_must_more_three').toString();
                        }
                        return null;
                      },
                      style: styles.inputTextStyle,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: context.localeString('first_name'), hintStyle:  styles.inputTextHintStyle,
                      ),
                      controller: _getFirstName,
                      keyboardType: TextInputType.text,
                      maxLines: 1,
                    ),
                  ),


                  Container(
                    padding: const EdgeInsets.only(right: 30.0, left: 30.0, top: 40.0),
                    alignment: topAlignment,
                    child: Text(context.localeString('last_name'), style: styles.paragraphTitle, textAlign: theAlignment,),
                  ),
                  Container(
                    padding: const EdgeInsets.only(right: 30.0, left: 30.0, top: 0.0),
                    child: TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return context.localeString('field_is_empty').toString();
                        }else if(value.length < 3) {
                          return context.localeString('field_must_more_three').toString();
                        }
                        return null;
                      },
                      style: styles.inputTextStyle,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: context.localeString('last_name'), hintStyle:  styles.inputTextHintStyle,
                      ),
                      controller: _getLastName,
                      keyboardType: TextInputType.text,
                      maxLines: 1,
                    ),
                  ),


                  Container(
                    padding: const EdgeInsets.only(right: 30.0, left: 30.0, top: 40.0),
                    alignment: topAlignment,
                    child: Text(context.localeString('email_address'), style: styles.paragraphTitle, textAlign: theAlignment,),
                  ),
                  Container(
                    padding: const EdgeInsets.only(right: 30.0, left: 30.0, top: 0.0),
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
                      style: styles.inputTextStyle,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: context.localeString('email_address'), hintStyle:  styles.inputTextHintStyle,
                      ),
                      controller:   _getEmailAddrress,
                      keyboardType: TextInputType.emailAddress,
                      maxLines: 1,
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.only(right: 30.0, left: 30.0, top: 40.0),
                    alignment: topAlignment,
                    child: Text(context.localeString('mobile_number'), style: styles.paragraphTitle, textAlign: theAlignment,),
                  ),
                  Container(
                    padding: const EdgeInsets.only(right: 30.0, left: 30.0, top: 0.0),
                    child: TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return context.localeString('field_is_empty').toString();
                        }else if(value.length < 10) {
                          return context.localeString('mobile_must_more_ten').toString();
                        }
                        return null;
                      },
                      style: styles.inputTextStyle,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: '07-xxxx-xxxx', hintStyle:  styles.inputTextHintStyle, hintTextDirection: TextDirection.ltr,
                      ),
                      controller: _getMobileNumber,
                      inputFormatters: [maskFormatter],
                      keyboardType: TextInputType.phone,
                      maxLines: 1,
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.only(right: 30.0, left: 30.0, top: 40.0),
                    alignment: topAlignment,
                    child: Text(context.localeString('country'), style: styles.paragraphTitle, textAlign: theAlignment,),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(right: 30.0, left: 30.0, top: 0.0),
                    alignment: Alignment.topCenter,
                    child: DropdownButtonFormField(
                      validator: (value) => countryId == '0' ? context.localeString('field_is_empty').toString() : null,
                      isExpanded: true,
                      items: countriesList,
                      onChanged: (value)=> _changeCountry(value.toString()),
                      value: countryId,
                    ),
                  ),

                  int.parse(countryId) > 0 ? Container(
                    padding: const EdgeInsets.only(right: 30.0, left: 30.0, top: 40.0),
                    alignment: topAlignment,
                    child: Text(context.localeString('city'), style: styles.paragraphTitle, textAlign: theAlignment,),
                  ):Container(),
                  int.parse(countryId) > 0 ?  Container(
                    width: 400.0,
                    padding: const EdgeInsets.only(right: 30.0, left: 30.0, top: 0.0),
                    alignment: Alignment.topCenter,
                    child: DropdownButtonFormField(
                      validator: (value) => cityId == '0' ? context.localeString('field_is_empty').toString() : null,
                      isExpanded: true,
                      items: citiesList,
                      onChanged: (value)=> _changeCity(value.toString()),
                      value: cityId,
                    ),
                  ):Container(),

                  Container(
                    padding: const EdgeInsets.only(right: 30.0, left: 30.0, top: 40.0),
                    alignment: topAlignment,
                    child: Text(context.localeString('select_license'), style: styles.paragraphTitle, textAlign: theAlignment,),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(right: 30.0, left: 30.0, top: 0.0),
                    alignment: Alignment.topCenter,
                    child: DropdownButtonFormField(
                      validator: (value) => licenseValue == '0' ? context.localeString('field_is_empty').toString() : null,
                      isExpanded: true,
                      items: licensesList,
                      onChanged: (value)=> _changeLicenses(value.toString()),
                      value: licenseValue,
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.only(right: 30.0, left: 30.0, top: 40.0),
                    alignment: topAlignment,
                    child: Text(context.localeString('select_vehicle'), style: styles.paragraphTitle, textAlign: theAlignment,),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(right: 30.0, left: 30.0, top: 0.0),
                    alignment: Alignment.topCenter,
                    child: DropdownButtonFormField(
                      validator: (value) => vehicleValue == '0' ? context.localeString('field_is_empty').toString() : null,
                      isExpanded: true,
                      items: vehiclesList,
                      onChanged: (value)=> _changeVehicles(value.toString()),
                      value: vehicleValue,
                    ),
                  ),

                  Container(
                      alignment: Alignment.topLeft,
                      padding: const EdgeInsets.only(right: 30.0, left: 30.0, top: 20.0),
                      child: Row(
                        children: [
                          GestureDetector(
                            child: haveCar == '0' ? const FaIcon(FontAwesomeIcons.checkCircle, size: 20.0,) : FaIcon(FontAwesomeIcons.solidCheckCircle, color : Theme.of(context).primaryColor, size: 20.0,),
                            onTap: (){
                              if(haveCar == '0'){
                                haveCar = '1';
                              }else{
                                haveCar = '0';
                              }
                              setState(() {});
                            },
                          ),
                          const SizedBox(width: 10,),
                          Expanded(
                            child: Container(
                              child: Text(context.localeString('i_have_car'), style: styles.acceptPrivacy, textAlign: theAlignment),
                            ),
                          )
                        ],
                      )
                  ),

                  Container(
                    padding: const EdgeInsets.only(right: 40.0, left: 40.0, top: 20.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.only(right: 20.0, left: 20.0, top: 5.0, bottom: 5.0 ),
                        elevation: 0.0,
                        primary:  Theme.of(context).primaryColor,
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          joinDriver();
                        }
                      },

                      child: Text(context.localeString('join_btn'),style: Theme.of(context).textTheme.button, textAlign: TextAlign.center),
                      //todo shape: styles.circleBtn(),

                    ),
                  ),
                ],
              ),
              const  Padding(padding: EdgeInsets.only(bottom: 40.0)),
            ],
          ),
        ),
      ),
      floatingActionButton: isLoading == true ? styles.loadingPage(context):Container(),
      bottomNavigationBar: BottomNavigationBarWidget(0),
    );
  }

}