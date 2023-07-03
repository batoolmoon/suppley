import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:supplyplatform/components/funcs.dart';
import 'package:supplyplatform/components/styles.dart';

class EditProfile extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _EditProfileState();
  }

}

class _EditProfileState extends State<EditProfile>{

  final TextEditingController _getFullName = TextEditingController();
  final TextEditingController _getMobileNumber = TextEditingController();
  final TextEditingController _getPassword = TextEditingController();
  final TextEditingController _getEmailAddress = TextEditingController();
  final countryPicker = const FlCountryCodePicker();
  CountryCode?_countryCode;

  List<DropdownMenuItem<String>> countriesList = [];
  String countryId = '0';
  late String memberId;
  late String LogInType;
  late String storeId;
  late String deliveryId;
  late String theLanguage="en";
  late String fullName;
  late String mobileNumber;
  late String emailAddress;
  late bool isLogin = true;
  late TextAlign theAlignment=TextAlign.left;
  late Alignment topAlignment=Alignment.topLeft;
  bool isLoading = false;

  late String notificationsCount = '0';

  var funcs = Funcs();
  var styles = Styles();

  //var maskFormatter = MaskTextInputFormatter(mask: '##-####-####', filter: { "#": RegExp(r'[0-9]') });

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  late FocusNode myFocusNode;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState(){
    super.initState();
    getSharedData().then((result) {
      getUnreadNotificationsCount();
      getData().then((result) {
        if(mounted){
          setState (() {
            if(LogInType=="shop"){
            _getFullName.text = result['profileData'][0]['fullName'];}
            else if (LogInType=='delivery_company' || LogInType=='factory'){
              _getFullName.text=result['profileData'][0]['storeName'];
            }
            _getMobileNumber.text = result['profileData'][0]['mobileNumber'];
            _getPassword.text = result['profileData'][0]['thePassword'];
            _getEmailAddress.text = result['profileData'][0]['emailAddress'];

          });
        }
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
    LogInType=prefs.getString('LogInType')!;
    if(mounted){
      setState(() {
        if(LogInType=="shop"){
        memberId = prefs.getString('memberId')!;}

        else if(LogInType=="store" || LogInType=="factory"){
        storeId=prefs.getString('storeId')!;}
        else{deliveryId=prefs.getString('deliveryId')!;}

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


  Future<Map> getData() async{
    setState(() {
      isLoading = true;
    });
    var myUrl;
    var result;
    if (LogInType=="shop"){
    myUrl = Uri.parse(funcs.mainLink+'api/getMemberProfile/$memberId');
    }
    else if(LogInType=="store" || LogInType=="factory"){

    myUrl = Uri.parse(funcs.mainLink+'api/getStoreProfile/$storeId');
    }
    else {myUrl = Uri.parse(funcs.mainLink+'api/getStoreProfile/$deliveryId');}

    http.Response response = await http.get(myUrl, headers: {"Accept": "application/json"});
    try{
      setState(() {
        isLoading = false;
      });
      result = json.decode(response.body);
    }catch(e){

    }

    return result;
  }

  getUnreadNotificationsCount() async{
    if(isLogin == true){
      notificationsCount = await funcs.getUnreadNotificationsCount();
      setState(() {});
    }
  }

  void saveProfile() async{

   // styles.onLoading(context);

    String theFullName =  _getFullName.text.trim();
    String theMobileNumber =  "${_countryCode!.dialCode.toString()}${_getMobileNumber.text}".trim();
    String theEmailAddress =  _getEmailAddress.text.trim();
    String thePassword =  _getPassword.text.trim();
    theMobileNumber = funcs.replaceArabicNumber(theMobileNumber);
    theMobileNumber = funcs.removeCharacterFromMobile(theMobileNumber);

    http.post(Uri.parse(funcs.mainLink+'api/changeProfile'), body: {
if (LogInType=="shop"){
      "memberId" : memberId,
      "fullName" : theFullName,
      "emailAddress": theEmailAddress,
      "mobileNumber": theMobileNumber,
      "thePassword": thePassword,
      "LogInType" : LogInType,
      "countryId":countryId
}

else if (LogInType=="store" || LogInType=="factory"){
  "storeId" : storeId,
  "fullName" : theFullName,
  "emailAddress": theEmailAddress,
  "mobileNumber": theMobileNumber,
  "thePassword": thePassword,
  "LogInType" : LogInType,
  "countryId":countryId

}
else {
    "deliveryId" : deliveryId,
    "fullName" : theFullName,
    "emailAddress": theEmailAddress,
    "mobileNumber": theMobileNumber,
    "thePassword": thePassword,
    "LogInType" : LogInType,
    "countryId":countryId
  }

    }).then((result) async{
      var theResult = json.decode(result.body);
      if(theResult['resultFlag'] == 'done'){
        Navigator.of(context, rootNavigator: true).pop();

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('fullName', _getFullName.text);
        await prefs.setString('emailAddress', _getEmailAddress.text);

        styles.showSnackBar(scaffoldKey,context,context.localeString('profile_updated_successfully').toString(),'success','');
      }else if(theResult['resultFlag'] == 'duplicate'){
        styles.showSnackBar(scaffoldKey,context,context.localeString('email_already_registered').toString(),'error','');
        Navigator.of(context, rootNavigator: true).pop();
      }else if(theResult['resultFlag'] == 'duplicate_mobile'){
        styles.showSnackBar(scaffoldKey,context,context.localeString('mobile_number_already_registered').toString(),'error','');
        Navigator.of(context, rootNavigator: true).pop();
      }else{
        styles.showSnackBar(scaffoldKey,context,context.localeString('error_occurred'),'error','');
        Navigator.of(context, rootNavigator: true).pop();
      }
    }).catchError((error) {
      print(error);
      styles.showSnackBar(scaffoldKey,context,context.localeString('error_occurred'),'error','');
      Navigator.of(context, rootNavigator: true).pop();
    });

  }



  @override
  Widget build(BuildContext context) {

    // TODO: implement build
    return Scaffold(
      key: scaffoldKey,
      appBar: styles.theAppBar(context, theLanguage, isLogin, '', true, true, notificationsCount),
      body: GestureDetector(
        onTap: ()=> FocusScope.of(context).requestFocus(FocusNode()),
        child: Form(
          key: _formKey,
          child: CustomScrollView(
              slivers: [

                SliverList(
                    delegate: SliverChildListDelegate(
                        [
                          Column(
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0, bottom: 10.0),
                                child: Text(context.localeString('edit_profile'), style: styles.paragraphTitle),
                              ),
                              Column(
                                children: <Widget>[
                                  Container(
                                    padding: const EdgeInsets.only(right: 30.0, left: 30.0, top: 20.0),
                                    alignment: topAlignment,
                                    child: Text(context.localeString('full_name'), style: styles.paragraphTitle, textAlign: theAlignment,),
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
                                      autocorrect: false,
                                      style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w300),
                                      textAlign: TextAlign.center,
                                      decoration: InputDecoration(
                                        prefixIcon: Icon(Icons.person, color: Theme.of(context).secondaryHeaderColor),
                                        hintText: context.localeString('full_name').toString(), hintStyle: styles.inputTextHintStyle,
                                        fillColor: Colors.white70,
                                        filled: true,
                                      ),
                                      controller: _getFullName,
                                      keyboardType: TextInputType.text,
                                      maxLines: null,
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
                                        }else if(!regex.hasMatch(value)) {
                                          return context.localeString('enter_valid_email').toString();
                                        }
                                        return null;
                                      },
                                      autocorrect: false,
                                      style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w300),
                                      textAlign: TextAlign.center,
                                      decoration: InputDecoration(
                                        prefixIcon: Icon(Icons.email, color: Theme.of(context).secondaryHeaderColor),
                                        hintText: context.localeString('email_address').toString(), hintStyle: styles.inputTextHintStyle,
                                        fillColor: Colors.white70,
                                        filled: true,
                                      ),
                                      controller: _getEmailAddress,
                                      keyboardType: TextInputType.emailAddress,
                                      maxLines: null,
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
                                      autocorrect: false,
                                      style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w300),
                                      textAlign: TextAlign.center,
                                      decoration: InputDecoration(
                                        prefixIcon: Icon(Icons.phone_iphone, color: Theme.of(context).secondaryHeaderColor),
                                        hintText: '07-xxxx-xxxx', hintStyle:  styles.inputTextHintStyle, hintTextDirection: TextDirection.ltr,
                                        fillColor: Colors.white70,
                                        filled: true,
                                      ),
                                      controller: _getMobileNumber,
                                      keyboardType: TextInputType.phone,
                                      //inputFormatters: [maskFormatter],
                                      maxLines: null,
                                    ),
                                  ),

                                  Container(
                                    padding: const EdgeInsets.only(right: 30.0, left: 30.0, top: 40.0),
                                    alignment: topAlignment,
                                    child: Text(context.localeString('password'), style: styles.paragraphTitle, textAlign: theAlignment,),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.only(right: 30.0, left: 30.0, top: 0.0),
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
                                      style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w300),
                                      textAlign: TextAlign.center,
                                      decoration: InputDecoration(
                                        prefixIcon: Icon(Icons.lock, color: Theme.of(context).secondaryHeaderColor),
                                        hintText: context.localeString('password').toString(), hintStyle: styles.inputTextHintStyle,
                                        fillColor: Colors.white70,
                                        filled: true,
                                      ),
                                      controller: _getPassword,
                                      obscureText: true,
                                      keyboardType: TextInputType.text,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.only(right: 30.0, left: 30.0, top: 40.0),
                                    alignment: topAlignment,
                                    child: Text(context.localeString('country_title'), style: styles.paragraphTitle, textAlign: theAlignment,),
                                  ),
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
                                    padding: const EdgeInsets.only(right: 40.0, left: 40.0, top: 20.0),


                                    child: ElevatedButton(

                                      onPressed: (){
                                        if (_formKey.currentState!.validate()) {
                                          saveProfile();
                                        }
                                        else{print(fullName);
                                        print(mobileNumber);
                                        print(emailAddress);
                                        print(fullName);}
                                      },

                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.only(right: 35.0, left: 35.0, top: 5.0, bottom: 5.0 ),
                                        elevation: 0.0,
                                        primary: Color.fromRGBO(194, 171, 131, 1),
                                        shape: styles.circleBtn(),
                                    ),
                                      child: Text(context.localeString('save'),style:TextStyle(color: Colors.white) , textAlign: TextAlign.center),
                                  ),)
                                ],
                              ),
                              const Padding(padding: EdgeInsets.only(bottom: 40.0)),
                            ],
                          )
                        ]
                    )
                ),
              ]
          ),
        )
      ),
      floatingActionButton: isLoading == true ? styles.loadingPage(context):Container(),
    );
  }

}