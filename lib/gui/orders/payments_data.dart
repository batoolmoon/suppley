import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:html2md/html2md.dart' as html2md;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supplyplatform/components/funcs.dart';
import 'package:supplyplatform/components/styles.dart';
import 'package:supplyplatform/components/bottom_navigation_bar.dart';
import 'package:supplyplatform/module/get_data.dart';
import 'package:supplyplatform/module/get_transfer_methods.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:url_launcher/url_launcher.dart';


class PaymentsData extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _PaymentsDataState();
  }
}

enum SingingCharacter {transfer, other}

class _PaymentsDataState extends State<PaymentsData>{

  late String theLanguage;
  late int sharedCartCount;
  late TextAlign theAlignment;
  late Alignment theTopAlignment;
  bool isLoading = true;
  String cartTotalPrice = '0.0';
  String whatsappNumber = '';
  String whatsappTitle = '';

  var funcs = Funcs();
  var styles = Styles();

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

//  SingingCharacter _paymentMethods = SingingCharacter.credit;
  late SingingCharacter _paymentMethods;

  @override
  void initState(){
    super.initState();
    getSharedData().then((result){
      _getTransferMethodsList();
      getWhatsappNumber().then((result) {
        setState(() {
          whatsappTitle = result['paymentMethodData'][0]['title1'];
          whatsappNumber = result['paymentMethodData'][0]['theValue'];
        });
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  getSharedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(mounted){
      setState(() {
        theLanguage = prefs.getString('theLanguage')!;

        if(theLanguage == 'ar'){
          theAlignment = TextAlign.right;
          theTopAlignment = Alignment.topRight;
        }else{
          theAlignment = TextAlign.left;
          theTopAlignment = Alignment.topLeft;
        }

      });
    }
  }



  Future<Map> getWhatsappNumber() async{
    setState(() {
      isLoading = true;
    });
    var result;
    var myUrl = Uri.parse(funcs.mainLink+'api/getWhatsappNumberForPayment/');
    http.Response response = await http.get(myUrl, headers: {"Accept": "application/json"});
    try{
      setState(() {
        isLoading = false;
      });
      result = json.decode(response.body);
    }catch(e){
      print(e);
    }

    return result;
  }


  var transferMethodsList = <GetTransferMethods>[];

  _getTransferMethodsList() {
    GetData.getDataList(
        funcs.mainLink+'api/getTransferMethods/').then((response) {
      setState(() {
        Iterable list = json.decode(response.body);
        transferMethodsList = list.map((model) => GetTransferMethods.fromJson(model)).toList();
        isLoading = false;
      });
    });
  }
  

  void _openLink(String theLink) async{
    await launch(theLink);
  }

  copyCode(String theCode){
    Clipboard.setData(ClipboardData(text: theCode));
    styles.showSnackBar(scaffoldKey,context,context.localeString('iban_copied'),'','');
  }

  Widget widgetTransferMethodsList(){

    return ListView.builder(
      itemCount: transferMethodsList.length,
      itemBuilder: (BuildContext context, int index) =>
      Column(
        children: <Widget>[
          ListTile(
            title: Row(
              children: [
                Container(
                  alignment: theTopAlignment,
                  child: Text(transferMethodsList[index].title1, style: Theme.of(context).textTheme.headline2, textAlign: theAlignment),
                ),
                const SizedBox(width: 10.0,),
              ],
            ),
            subtitle: Container(
              child: Column(
                children: [
                  Container(
                    alignment: theTopAlignment,
                    child: Text(html2md.convert(transferMethodsList[index].theValue), textAlign: theAlignment, style: const TextStyle(color: Colors.black87),),
                  ),
                  Container(
                    alignment: theTopAlignment,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.only(right: 20.0, left: 20.0, top: 5.0, bottom: 5.0 ),
                        elevation: 0.0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                        primary:Theme.of(context).secondaryHeaderColor,
                      ),
                      onPressed: ()=> copyCode(transferMethodsList[index].theValue2),

                      child: Text(context.localeString('copy_iban'),style: Theme.of(context).textTheme.button, textAlign: TextAlign.center),

                      //todo

                    ),
                  ),
                ],
              ),
              alignment: theTopAlignment,
            ),
          ),
          Divider(),
        ],
      ),
    );

  }

  Future<bool> _onWillPop() async{
    Navigator.pop(context,true);
    return false;
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          title: Row(
            children: [
              Expanded(
                child: Container(),
              ),
              Text(context.localeString('payments_data_title'), style: styles.checkoutPageTitle),
              const Icon(Icons.security, size: 20.0, color: Colors.green,),
              Expanded(
                child: Container(),
              ),
            ],
          ),
        ),
        body: Container(
            child: Column(
              children: [
                Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          ListTile(
                            title: Text(context.localeString('transfer').toString()),
                            leading: Radio(
                              activeColor: Theme.of(context).primaryColor,
                              value: SingingCharacter.transfer,
                              groupValue: _paymentMethods,
                              onChanged: (SingingCharacter? value) {
                                setState(() {
                                  _paymentMethods = value!;
                                });
                              },
                            ),
                          ),
                          transferMethodsList.isNotEmpty && _paymentMethods == SingingCharacter.transfer ?
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10.0),
                              child: widgetTransferMethodsList(),
                            ),
                          ):Container(),
                          ListTile(
                            title: Text(context.localeString('others_payment').toString()),
                            leading: Radio(
                              activeColor: Theme.of(context).primaryColor,
                              value: SingingCharacter.other,
                              groupValue: _paymentMethods,
                              onChanged: (SingingCharacter? value) {
                                setState(() {
                                  _paymentMethods = value!;
                                });
                              },
                            ),
                          ),
                          _paymentMethods == SingingCharacter.other && whatsappNumber.isNotEmpty ? Container(
                            child: Text(context.localeString('call_us_via_whatsapp'), style: Theme.of(context).textTheme.bodyText1, textAlign: TextAlign.center,),
                          ):Container(),
                          _paymentMethods == SingingCharacter.other && whatsappNumber.isNotEmpty ? Container(
                            child: ElevatedButton(
                              onPressed: ()=> _openLink('https://api.whatsapp.com/send?phone=$whatsappNumber'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.only(right: 20.0, left: 20.0, top: 5.0, bottom: 5.0 ),
                                elevation: 0.0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                                primary:  Theme.of(context).secondaryHeaderColor,
                              ),

                              child: Text(whatsappTitle,style: Theme.of(context).textTheme.button, textAlign: TextAlign.center),
                              //todo

                            ),
                          ):Container(
//                            child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor), strokeWidth: 1.3,),
                          )
                        ],
                      ),
                    )
                ),
              ],
            )
        ),
        bottomNavigationBar: BottomNavigationBarWidget(3),
      ),
    );
  }

}