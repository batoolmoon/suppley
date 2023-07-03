import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:html2md/html2md.dart' as html2md;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supplyplatform/components/funcs.dart';
import 'package:supplyplatform/components/styles.dart';

class NotificationsDetails extends StatefulWidget{
  NotificationsDetails(this.notificationId);
  String notificationId;

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _NotificationsDetailsState(notificationId);
  }

}

class _NotificationsDetailsState extends State<NotificationsDetails> {
  _NotificationsDetailsState(this.notificationId);
  String notificationId;

  late String theLanguage='en';
  late bool isLogin;
  late String notificationTitle = '';
  late String notificationText = '';
  late TextAlign theAlignment;
  late TextDirection theDirection;
  bool isLoading = false;

  var funcs = Funcs();
  var styles = Styles();

  @override
  void initState(){
    super.initState();
    getSharedData().then((result) {
      getNotificationData().then((result) {
        setState(() {
          notificationTitle = result['notifiData'][0]['theTitle'];
          notificationText = html2md.convert(result['notifiData'][0]['theDetails']);
        });
      });
    });
  }


  getSharedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
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

  Future<Map> getNotificationData() async{
    setState(() {
      isLoading = true;
    });
    var result;
    var myUrl = Uri.parse(funcs.mainLink+'api/getNotificationDetails/$notificationId/$theLanguage');
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

  Future<bool> _onWillPop() async{
    if (Navigator.canPop(context)) {
      Navigator.pop(context,true);
      return false;
    } else {
      exit(0);
    }
  }

  @override
  Widget build(BuildContext context) {

    // TODO: implement build
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: styles.theAppBar(context, theLanguage, isLogin, notificationTitle , true, false, '0'),
        body: ListView(
          padding: const EdgeInsets.all(15.0),
          children: <Widget>[
            Text(notificationTitle, style: styles.paragraphTitle, textAlign: theAlignment),
            const SizedBox(height: 25.0,),
            Text(notificationText, style: styles.paragraphText, textAlign: theAlignment),
            const SizedBox(height: 125.0,),
          ],
        ),
        floatingActionButton: isLoading == true ? styles.loadingPage(context):Container(),
      ),
    );
  }

}
