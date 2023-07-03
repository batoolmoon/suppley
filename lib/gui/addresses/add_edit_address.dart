import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supplyplatform/components/funcs.dart';
import 'package:supplyplatform/components/styles.dart';
import 'package:supplyplatform/components/bottom_navigation_bar.dart';
import 'package:supplyplatform/gui/orders/cart.dart';
import 'package:supplyplatform/gui/addresses/addresses.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../../components/bottom_navigation_bar.dart';
import '../../components/funcs.dart';

class AddEditAddress extends StatefulWidget{
  AddEditAddress(this.addressId,this.theType, this.couponDiscountValue, this.couponId);
  String addressId;
  String theType;
  int couponDiscountValue;
  String couponId;

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _AddEditAddressState(addressId,theType, couponDiscountValue, couponId);
  }

}

class _AddEditAddressState extends State<AddEditAddress>{
  _AddEditAddressState(this.addressId, this.theType, this.couponDiscountValue, this.couponId);
  String addressId;
  String theType;
  int couponDiscountValue;
  String couponId;

  final TextEditingController _getTheTitle = TextEditingController();
  final TextEditingController _getFullName = TextEditingController();
  final TextEditingController _getMobileNumber = TextEditingController();
  final TextEditingController _getMobileNumber2 = TextEditingController();
  final TextEditingController _getStreet = TextEditingController();
  final TextEditingController _getAddressDetails = TextEditingController();
  final TextEditingController _getSpecialDetails = TextEditingController();

  late String memberId;
  late String theLanguage;
  late String pageTitle;
  late String theTitle;
  late String fullName;

  late String mobileNumber;
  late String mobileNumber2;
  late String street;
  late String addressDetails;
  late String specialDetails;
  late bool isLogin = false;
  late TextAlign theAlignment;
  late Alignment topAlignment;
  late bool isLoading = false;
  List<DropdownMenuItem<String>> countriesList = [];
  String countryId = '0';
  List<DropdownMenuItem<String>> citiesList = [];
  String cityId = '0';
  List<DropdownMenuItem<String>> areaList = [];
  String areaId = '0';

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  late FocusNode myFocusNode;
  final _formKey = GlobalKey<FormState>();


  var funcs = Funcs();
  var styles = Styles();

  bool mapViewed = false;
  Set<Marker> _markers = {};

  String selectedLatitude = '';
  String selectedLongitude = '';
  String currentLatitude = '';
  String currentLongitude = '';
  LatLng myCurrentPosition = LatLng(0.0,0.0);

  var maskFormatter = MaskTextInputFormatter(mask: '##-####-####', filter: { "#": RegExp(r'[0-9]') });

  @override
  void initState(){
    super.initState();

    getSharedData().then((result) {
      getCountries();

      if(int.parse(addressId) > 0){
        getData().then((result) {
          if(mounted){
            setState (() {
              _getTheTitle.text = result['addressData'][0]['theTitle'];
              _getFullName.text = result['addressData'][0]['fullName'];
              _getMobileNumber.text = result['addressData'][0]['mobileNumber'];
              _getMobileNumber2.text = result['addressData'][0]['mobileNumber2'];
              countryId = result['addressData'][0]['country'];
              if(int.parse(countryId) > 0 ){
                getCities(countryId);
              }
              cityId = result['addressData'][0]['city'];
              if(int.parse(cityId) > 0 ){
                getAreas(cityId);
              }
              areaId = result['addressData'][0]['area'];
              _getStreet.text = result['addressData'][0]['street'];
              _getAddressDetails.text = result['addressData'][0]['addressDetails'];
              _getSpecialDetails.text = result['addressData'][0]['specialDetails'];
              currentLatitude = result['addressData'][0]['latitude'];
              currentLongitude = result['addressData'][0]['longitude'];
            });
          }
        });

      }else{
        _getFullName.text = fullName;
        _getMobileNumber.text = mobileNumber;
      }
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
        memberId = prefs.getString('memberId')!;
        fullName = prefs.getString('fullName')!;
        mobileNumber = prefs.getString('mobileNumber')!;
        theLanguage = prefs.getString('theLanguage')!;

        if(int.parse(addressId) > 0){
          pageTitle = context.localeString('edit_address');
        }else{
          pageTitle = context.localeString('add_new_address');
        }

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

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permantly denied, we cannot request permissions.');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return Future.error(
            'Location permissions are denied (actual value: $permission).');
      }
    }

    final geolocator = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    setState(() {
      if(currentLongitude.isEmpty || currentLatitude.isEmpty){
        currentLatitude = '${geolocator.latitude}';
        currentLongitude = '${geolocator.longitude}';
        selectedLatitude = currentLatitude;
        selectedLongitude = currentLongitude;

        myCurrentPosition = LatLng(double.parse(currentLatitude),double.parse(currentLongitude));
        _markers.add(
            Marker(
              markerId: MarkerId("${geolocator.latitude},${geolocator.longitude}"),
              position: LatLng(geolocator.latitude,geolocator.longitude),
              icon: BitmapDescriptor.defaultMarker,

            )
        );
      }else{
        myCurrentPosition = LatLng(double.parse(currentLatitude),double.parse(currentLongitude));
        _markers.add(
            Marker(
              markerId: MarkerId("$currentLatitude,$currentLongitude"),
              position: LatLng(double.parse(currentLatitude),double.parse(currentLongitude)),
              icon: BitmapDescriptor.defaultMarker,

            )
        );
      }
    });

    return await Geolocator.getCurrentPosition();
  }


  Future<Map> getData() async{
    setState(() {
      isLoading = true;
    });
    var result;
    var myUrl = Uri.parse(funcs.mainLink+'api/getAddressData/$addressId/$memberId');
    http.Response response = await http.get(myUrl, headers: {"Accept": "application/json"});
    try{
      setState(() {
        isLoading = false;
      });
      result = json.decode(response.body);
    }catch(e){
//      print(e);
    }

    return result;
  }


  void saveAddress() async{

//    if(currentLatitude.isNotEmpty && currentLongitude.isNotEmpty ){

    styles.onLoading(context);

    String theTitle =  _getTheTitle.text;
    String theFullName =  _getFullName.text;
    String theMobileNumber =  _getMobileNumber.text;
    String theMobileNumber2 =  _getMobileNumber2.text;
    String street =  _getStreet.text;
    String addressDetails =  _getAddressDetails.text;
    String specialDetails  =  _getSpecialDetails.text;

    theMobileNumber = funcs.replaceArabicNumber(theMobileNumber);
    theMobileNumber2 = funcs.replaceArabicNumber(theMobileNumber2);

    theMobileNumber = funcs.removeCharacterFromMobile(theMobileNumber);
    theMobileNumber2 = funcs.removeCharacterFromMobile(theMobileNumber2);

    if(theMobileNumber2 == null || theMobileNumber2 == ''){
      theMobileNumber2 = '-';
    }

    if(specialDetails == null || specialDetails == ''){
      specialDetails = '-';
    }

//      if(currentLatitude == '' || currentLongitude == ''){
//        currentLatitude = '-';
//        currentLongitude = '-';
//      }

    print(memberId);
    print(addressId);
    print(theTitle);
    print(theFullName);
    print(theMobileNumber);
    print(theMobileNumber2);
    print(street);
    print(addressDetails);
    print(specialDetails);
    print(countryId);
    print(currentLatitude);
    print(currentLongitude);
    print(cityId);
    print(areaId);

    http.post(Uri.parse(funcs.mainLink+'api/addEditAddress'), body: {
      "memberId" : memberId,
      "addressId" : addressId,
      "theTitle" : theTitle,
      "fullName" : theFullName,
      "theMobileNumber": theMobileNumber,
      "theMobileNumber2": theMobileNumber2,
      "street": street,
      "addressDetails" : addressDetails,
      "specialDetails" : specialDetails,
      "countryId" : countryId,
      "latitude" : currentLatitude.toString(),
      "longitude" : currentLongitude.toString(),
      "cityId" : cityId,
      "areaId" : areaId
    }).then((result) async{
      var theResult = json.decode(result.body);
      if(theResult['resultFlag'] == 1){
        Navigator.of(context, rootNavigator: true).pop();
        if(theType == 'DeliveryAddress'){
          Navigator.push(context, MaterialPageRoute(builder: (context) => Cart()),);
        }else if(theType == 'Addresses'){
          Navigator.push(context, MaterialPageRoute(builder: (context) => Addresses()),);
        }
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
      areaId = '0';
      citiesList = [];
      getCities(countryId);
      areaList = [];
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
      areaId = '0';
      areaList = [];
      getAreas(cityId);
    });
  }

  void getAreas(cityId) async{
    setState(() {
      isLoading = true;
    });
    var myUrl = Uri.parse(funcs.mainLink+'api/getAreas/$theLanguage/$cityId');
    http.Response response = await http.get(myUrl, headers: {"Accept": "application/json"});

    areaList.add(DropdownMenuItem(
      child: SizedBox(
        width: double.infinity,
        child: Text(context.localeString('please_select_area'), style: styles.inputTextStyle, textAlign: TextAlign.center),
      ),
      value: '0',
    ));


    try{
      setState(() {
        isLoading = false;
      });
      var responseData = json.decode(response.body);
      responseData.forEach((addresses){
        areaList.add(DropdownMenuItem(
          child: SizedBox(
            width: double.infinity,
            child: Text(addresses['areaTitle'], style: styles.inputTextStyle,textAlign: TextAlign.center),
          ),
          value: "${addresses['arId']}",
        ));
      },
      );
    }catch(e){
      print(e);
    }

  }

  _changeArea(String e){
    setState(() {
      areaId = e;
    });
  }

  @override
  Widget build(BuildContext context) {

    // TODO: implement build
    return Scaffold(
      key: scaffoldKey,
      appBar: styles.theAppBar(context, theLanguage, isLogin, pageTitle , true, false, '0'),
      body: isLoading ? Center(
        child: Container(),
      ):mapViewed == false ? GestureDetector(
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
                    child: Text(context.localeString('address_title'), style: styles.paragraphTitle, textAlign: theAlignment,),
                  ),
                  Container(
                    padding: const EdgeInsets.only(right: 30.0, left: 30.0, top: 0.0),
                    child: TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return context.localeString('field_is_empty').toString();
                        }
                        return null;
                      },
                      style: styles.inputTextStyle,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: context.localeString('address_title'), hintStyle:  styles.inputTextHintStyle,
                      ),
                      controller: _getTheTitle,
                      keyboardType: TextInputType.text,
                      maxLines: null,
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.only(right: 30.0, left: 30.0, top: 40.0),
                    alignment: topAlignment,
                    child: Text(context.localeString('address_full_name'), style: styles.paragraphTitle, textAlign: theAlignment,),
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
                        hintText: context.localeString('address_full_name'), hintStyle:  styles.inputTextHintStyle,
                      ),
                      controller: _getFullName,
                      keyboardType: TextInputType.text,
                      maxLines: null,
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.only(right: 30.0, left: 30.0, top: 40.0),
                    alignment: topAlignment,
                    child: Text(context.localeString('address_mobile_number'), style: styles.paragraphTitle, textAlign: theAlignment,),
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
                      maxLines: null,
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.only(right: 30.0, left: 30.0, top: 40.0),
                    alignment: topAlignment,
                    child: Text(context.localeString('address_mobile_number2'), style: styles.paragraphTitle, textAlign: theAlignment,),
                  ),
                  Container(
                    padding: const EdgeInsets.only(right: 30.0, left: 30.0, top: 0.0),
                    child: TextField(
                      style: styles.inputTextStyle,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: '07-xxxx-xxxx', hintStyle:  styles.inputTextHintStyle, hintTextDirection: TextDirection.ltr,
                      ),
                      controller: _getMobileNumber2,
                      keyboardType: TextInputType.phone,
                      maxLines: null,
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

                  int.parse(cityId) > 0 ? Container(
                    padding: const EdgeInsets.only(right: 30.0, left: 30.0, top: 40.0),
                    alignment: topAlignment,
                    child: Text(context.localeString('area'), style: styles.paragraphTitle, textAlign: theAlignment,),
                  ):Container(),
                  int.parse(cityId) > 0 ?  Container(
                    width: 400.0,
                    padding: const EdgeInsets.only(right: 30.0, left: 30.0, top: 0.0),
                    alignment: Alignment.topCenter,
                    child: DropdownButtonFormField(
                      validator: (value) => areaId == '0' ? context.localeString('field_is_empty').toString() : null,
                      isExpanded: true,
                      items: areaList,
                      onChanged: (value)=> _changeArea(value.toString()),
                      value: areaId,
                    ),
                  ):Container(),

                  Container(
                    padding: const EdgeInsets.only(right: 30.0, left: 30.0, top: 40.0),
                    alignment: topAlignment,
                    child: Text(context.localeString('street_title'), style: styles.paragraphTitle, textAlign: theAlignment,),
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
                        hintText: context.localeString('street_title'), hintStyle:  styles.inputTextHintStyle,
                      ),
                      controller: _getStreet,
                      keyboardType: TextInputType.text,
                      maxLines: null,
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.only(right: 30.0, left: 30.0, top: 40.0),
                    alignment: topAlignment,
                    child: Text(context.localeString('address_details'), style: styles.paragraphTitle, textAlign: theAlignment,),
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
                        hintText: context.localeString('address_details'), hintStyle:  styles.inputTextHintStyle,
                      ),
                      controller: _getAddressDetails,
                      keyboardType: TextInputType.text,
                      maxLines: null,
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.only(right: 30.0, left: 30.0, top: 40.0),
                    alignment: topAlignment,
                    child: Text(context.localeString('special_details'), style: styles.paragraphTitle, textAlign: theAlignment,),
                  ),
                  Container(
                    padding: const EdgeInsets.only(right: 30.0, left: 30.0, top: 0.0),
                    child: TextField(
                      style: styles.inputTextStyle,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: context.localeString('special_details'), hintStyle:  styles.inputTextHintStyle,
                      ),
                      controller: _getSpecialDetails,
                      keyboardType: TextInputType.text,
                      maxLines: null,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(right: 30.0, left: 30.0, top: 40.0),
                    alignment: topAlignment,
                    child: InkWell(
                      onTap:(){
                        setState(() {
                          mapViewed = true;
                          _determinePosition();
                        });
                      },
                      child: currentLatitude.isNotEmpty || currentLongitude.isNotEmpty ? Row(
                        children: [
                          Expanded(
                            child: Text(context.localeString('map_position_selected'), style: styles.positionSelectedTitle, textAlign: theAlignment,),
                          ),
                          const Icon(Icons.pin_drop, color: Colors.green),
                        ],
                      ):
                      Row(
                        children: [
                          Expanded(
                            child: Text(context.localeString('add_map_link'), style: TextStyle(color: Theme.of(context).primaryColor), textAlign: theAlignment,),
                          ),
                          Icon(Icons.pin_drop, color: Theme.of(context).primaryColor),
                        ],
                      ),
                    ),
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
                          saveAddress();
                        }
                      },

                      child: Text(context.localeString('save'),style: Theme.of(context).textTheme.button, textAlign: TextAlign.center),

                      //todo shape: styles.circleBtn(),

                    ),
                  ),
                ],
              ),
              const  Padding(padding: EdgeInsets.only(bottom: 40.0)),
            ],
          ),
        ),
      ):Column(
        children: [
          Expanded(
            child: myCurrentPosition.latitude > 0.0 ? GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                target: myCurrentPosition,
                zoom: 14,
              ),
              markers: _markers,
              onTap: (position){
                setState(() {
                  _markers = {};
                  selectedLatitude = "${position.latitude}";
                  selectedLongitude = "${position.longitude}";
                  _markers.add(
                      Marker(
                        markerId: MarkerId("${position.latitude},${position.longitude}"),
                        position: position,
                        icon: BitmapDescriptor.defaultMarker,
                      )
                  );
                });
              },
            ):Center(child: Text(context.localeString('loading_map')),),
          ),
          Container(
            padding: const EdgeInsets.only(right: 30.0, left: 30.0),
            child: Row(
              children: [


                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.only(right: 20.0, left: 20.0, top: 5.0, bottom: 5.0 ),
                      elevation: 0.0,
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: styles.circleBtn(),),


                    onPressed: (){
                      if(myCurrentPosition.latitude > 0.0) {
                        setState(() {
                          currentLatitude = selectedLatitude;
                          currentLongitude = selectedLongitude;
                          mapViewed = false;
                        });
                      }else{
                        styles.showSnackBar(scaffoldKey, context, context.localeString('please_wait'),'error','');
                      }

                    },
                    child:
                       Text(context.localeString('ok'),style: Theme.of(context).textTheme.button, textAlign: TextAlign.center),

                  ),
                ),
                const SizedBox(
                  width: 40.0,
                ),
                Expanded(
                  child: ElevatedButton(


                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.only(right: 20.0, left: 20.0, top: 5.0, bottom: 5.0 ),
                      elevation: 0.0,
                      backgroundColor: Colors.redAccent,
                      shape: styles.circleBtn(),),

                    onPressed: (){
                      setState(() {
                        print(isLoading);
                        mapViewed = false;
                        currentLatitude = currentLatitude;
                        currentLongitude = currentLongitude;
                      });
                    },

                    child: Text(context.localeString('cancel'),style: Theme.of(context).textTheme.button, textAlign: TextAlign.center),

                  ),
                )
              ],
            ),
          )
        ],
      ),
      floatingActionButton: isLoading == true ? styles.loadingPage(context):Container(),
      bottomNavigationBar: BottomNavigationBarWidget(3),
    );
  }

}