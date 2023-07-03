import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supplyplatform/components/funcs.dart';
import 'package:supplyplatform/components/styles.dart';
import 'package:supplyplatform/gui/addresses/add_edit_address.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:supplyplatform/components/bottom_navigation_bar.dart';
import 'package:supplyplatform/module/get_data.dart';
import 'package:supplyplatform/module/get_addresses.dart';
import 'package:supplyplatform/gui/settings.dart';
import 'package:supplyplatform/components/drawer.dart';

class Addresses extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _AddressesState();
  }

}

class _AddressesState extends State<Addresses>{

  late String memberId;
  late String fullName;
  late String theLanguage;
  late bool isLogin;
  late TextAlign theAlignment;
  late Alignment theTopAlignment;
  bool isLoading = true;

  var funcs = Funcs();
  var styles = Styles();

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  var addressList = <GetAddresses>[];

  _getDataList() {
    GetData.getDataList(
        funcs.mainLink+'api/getAddresses/$memberId/$theLanguage').then((response) {
        setState(() {
          Iterable list = json.decode(response.body);
          addressList = list.map((model) => GetAddresses.fromJson(model)).toList();
          isLoading = false;
        });
    });
  }

  @override
  void initState(){
    super.initState();
    getSharedData().then((result) {
      _getDataList();
    });
  }

  @override
  void dispose(){
    super.dispose();
  }

  getSharedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      memberId = prefs.getString('memberId')!;
      fullName = prefs.getString('fullName')!;
      theLanguage = prefs.getString('theLanguage')!;
      isLogin = prefs.getBool('isLogin')!;

      if(theLanguage == 'ar'){
        theAlignment = TextAlign.right;
        theTopAlignment = Alignment.topRight;
      }else{
        theAlignment = TextAlign.left;
        theTopAlignment = Alignment.topLeft;
      }

    });
  }

  needToRefresh(){
    _getDataList();
  }

  _addEditAddress(String addressId){
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => AddEditAddress(addressId.toString(),'Addresses',0,'0'))).then((val)=>val?needToRefresh():print('enter map here'));
  }

  void alertDialog(context, String theTitle, String theContent, String addressId) {
    String yes = Locales.string(context, 'yes');
    String no = Locales.string(context, 'no');

    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(theTitle, style: styles.dialogData, textAlign: TextAlign.center,),
        content: Text(theContent, style: styles.dialogData, textAlign: TextAlign.center,),

        actions: [
         TextButton(
            onPressed: (){
              Navigator.of(context, rootNavigator: true).pop();
            },
           style: TextButton.styleFrom(
             padding: const EdgeInsets.only(right: 20.0, left: 20.0, top: 5.0, bottom: 5.0 ),
            ),

            child: Text(no, style: styles.dialogData),
          ),
          TextButton (

            onPressed: (){
              Navigator.of(context, rootNavigator: true).pop();
              removeAddress(addressId);
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.only(right: 20.0, left: 20.0, top: 5.0, bottom: 5.0 ),
            ),

            child: Text(yes, style: styles.dialogData),
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
//            side: BorderSide(color: Colors.red)
        ),
      ),
    );
  }


  void removeAddress(String addressId) async{

    styles.onLoading(context);

    http.post(Uri.parse(funcs.mainLink+'api/removeAddress'), body: {
      "memberId" : memberId,
      "addressId" : addressId,
    }).then((result) async{
      var theResult = json.decode(result.body);
      if(theResult['resultFlag'] == 1){
      _getDataList();
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


  Widget widgetAddressesList(){

    return ListView.builder(
        itemCount: addressList.length,
        itemBuilder: (BuildContext context, int index) =>
        Column(
          children: <Widget>[
            ListTile(
              title: Text(addressList[index].theTitle, style: Theme.of(context).textTheme.headline2, textAlign: theAlignment),
              subtitle: Column(
                children: [
                  Container(
                    child: Text('''${addressList[index].fullName}
${addressList[index].addressDetails}
${addressList[index].street}
${addressList[index].theArea} - ${addressList[index].theCity} -   ${addressList[index].theCountry} 
${addressList[index].mobileNumber}         
''', style: styles.paragraphText, textAlign: theAlignment),
                    alignment: theTopAlignment,
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.only(right: 10.0, left: 10.0, top: 10.0),
                        alignment: theTopAlignment,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.only(right: 20.0, left: 20.0, top: 5.0, bottom: 5.0 ),
                            elevation: 0.0,
                            primary: Colors.redAccent,
                            shape: styles.circleBtn(),
                          ),
                          onPressed: ()=> alertDialog(context,context.localeString('delete_address_dialog_title'),context.localeString('delete_address_dialog_content'),'${addressList[index].adId}'),

                          child: Text(context.localeString('delete_btn'),style: Theme.of(context).textTheme.button, textAlign: TextAlign.center),

                          //todo

                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.only(right: 10.0, left: 10.0, top: 10.0),
                        alignment: theTopAlignment,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.only(right: 20.0, left: 20.0, top: 5.0, bottom: 5.0 ),
                            elevation: 0.0,
                            primary: Color.fromRGBO(194, 171, 131, 1),
                            shape: styles.circleBtn(),
                          ),
                          onPressed: ()=> _addEditAddress(addressList[index].adId),

                          child: Text(context.localeString('edit_btn'),style: Theme.of(context).textTheme.button, textAlign: TextAlign.center),

                          //todo

                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            const Divider(),
          ],
        ),
      );

  }

  _onBackPressed() async{
    return Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (context, animation, anotherAnimation){
        return const Settings();
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {

        return FadeTransition(
          opacity:animation,
          child: child,
        );
      },
    ));

  }

  @override
  Widget build(BuildContext context) {


    // TODO: implement build
    return WillPopScope(
      onWillPop:()=> _onBackPressed(),
      child: Scaffold(
        key: scaffoldKey,
        appBar: styles.theAppBar(context, theLanguage, isLogin, context.localeString('addresses') , true, false, '0'),
        body: Container(
          child: addressList.isNotEmpty || isLoading == true ? widgetAddressesList():
          Container(
            alignment: Alignment.center,
            child: Column(
              children: <Widget>[
                Image.asset(
                  'images/nodatafound.png',
                  width: 200.0,
                ),
                Text(context.localeString('no_data')),
              ],
            ),
          ),
        ),

        floatingActionButton : isLoading == false ? FloatingActionButton.extended(
          onPressed: () {
            _addEditAddress('0');
          },
          shape: styles.circleBtn(),
          tooltip: context.localeString('add_new_address'),
          label: Text(context.localeString('add_new_address'),style: Theme.of(context).textTheme.button,),
          icon: const Icon(Icons.add),
          foregroundColor: Colors.white,
          backgroundColor: Theme.of(context).primaryColor,
        ):styles.loadingPage(context),
        bottomNavigationBar: BottomNavigationBarWidget(3),
        drawer: DrawerClass(isLogin, fullName),
      ),

    );
  }

}
