import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:supplyplatform/components/bottom_navigation_bar.dart';
import 'package:supplyplatform/module/get_data.dart';
import 'package:supplyplatform/module/get_currencies.dart';
import 'package:supplyplatform/components/styles.dart';
import 'package:supplyplatform/components/funcs.dart';

class Currencies extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _CurrenciesState();
  }

}

class _CurrenciesState extends State<Currencies>{

  late String memberId;
  late String theLanguage;
  late bool isLogin;
  late TextAlign theAlignment;
  late TextDirection theDirection;
  bool isLoading = true;

  late String notificationsCount = '0';

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  var funcs = Funcs();
  var styles = Styles();

  var currenciesList = <GetCurrencies>[];
  
  @override
  void initState(){
    super.initState();
    getSharedData().then((result) {
      getUnreadNotificationsCount();
      _getDataList();
    });
  }

  _getDataList() {
    GetData.getDataList(
        funcs.mainLink+'api/getCurrencies/$theLanguage').then((response) {
      setState(() {
        Iterable list = json.decode(response.body);
        currenciesList = list.map((model) => GetCurrencies.fromJson(model)).toList();
        isLoading = false;
      });
    });
  }

  getSharedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(mounted){
      setState(() {
        memberId = prefs.getString('memberId')!;
        theLanguage = prefs.getString('theLanguage')!;
        isLogin = prefs.getBool('isLogin')!;

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


  getUnreadNotificationsCount() async{
    if(isLogin == true){
      notificationsCount = await funcs.getUnreadNotificationsCount();
      setState(() {});
    }
  }

  changeCurrency(String currencyId) async{
    styles.onLoading(context);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currencyId', int.parse(currencyId));

    if(memberId == null){
      setState(() {
        memberId = '0';
      });
    }

    http.post(Uri.parse(funcs.mainLink+'api/changeCurrency'), body: {
      "memberId": memberId,
      "currencyId": currencyId,
    }).then((result) async{

      var theResult = json.decode(result.body);

      if(theResult['resultFlag'] == 'done'){

        String currencySymbol = theResult['theResult'][0]['currencySymbol'];
        String currencyExchange = theResult['theResult'][0]['currencyExchange'];

        await prefs.setString('currencySymbol', currencySymbol);
        await prefs.setDouble('currencyExchange', double.parse(currencyExchange));

        Navigator.of(context).pushNamedAndRemoveUntil('/MainPage',(Route<dynamic> route) => false);
      }else{
        styles.showSnackBar(scaffoldKey,context,context.localeString('error_occurred'),'error','');
      }
      Navigator.of(context, rootNavigator: true).pop();
    }).catchError((error) {
      print(error);
      Navigator.of(context, rootNavigator: true).pop();
      styles.showSnackBar(scaffoldKey,context,context.localeString('error_occurred'),'error','');
    });

  }


  Widget widgetCurrenciesList(){

    return ListView.builder(
      itemCount: currenciesList.length,
      itemBuilder: (BuildContext context, int index) =>
      Column(
        children: <Widget>[
          ListTile(
            title: Text(currenciesList[index].theTitle, style: Theme.of(context).textTheme.bodyText1, textAlign: theAlignment),
            onTap: ()=> changeCurrency(currenciesList[index].cuId),
          ),
          const Divider(),
        ],
      ),
    );

  }

  @override
  Widget build(BuildContext context) {

    // TODO: implement build
    return Scaffold(
      key: scaffoldKey,
      appBar: styles.theAppBar(context, theLanguage, isLogin, context.localeString('currency_title') , true, true, notificationsCount),
      body: Container(
        child: widgetCurrenciesList()
      ),
      floatingActionButton: isLoading == true ? styles.loadingPage(context):Container(),
      bottomNavigationBar: BottomNavigationBarWidget(3),
    );
  }

}