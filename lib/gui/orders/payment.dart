//import 'dart:async';
//import 'package:flutter/material.dart';
//import 'package:shared_preferences/shared_preferences.dart';
//import 'package:supplyplatform/components/funcs.dart';
//import 'package:supplyplatform/components/styles.dart';
//import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
//import 'package:flutter_locales/flutter_locales.dart';
//
//class Payment extends StatefulWidget{
//  Payment(this.shippingFullName,this.emailAddress,this.shippingCity,this.shippingAddress,this.shippingMobileNumber,this.couponId,this.addressId);
//  String shippingFullName;
//  String couponId;
//  String addressId;
//  String emailAddress;
//  String shippingCity;
//  String shippingAddress;
//  String shippingMobileNumber;
//
//
//
//  @override
//  State<StatefulWidget> createState() {
//    // TODO: implement createState
//    return new _PaymentState(this.shippingFullName,this.emailAddress,this.shippingCity,this.shippingAddress,this.shippingMobileNumber, this.couponId, this.addressId);
//  }
//
//}
//
//class _PaymentState extends State<Payment>{
//  _PaymentState(this.shippingFullName,this.emailAddress, this.shippingCity, this.shippingAddress, this.shippingMobileNumber, this.couponId, this.addressId);
//  String shippingFullName;
//  String couponId;
//  String addressId;
//  String emailAddress;
//  String shippingCity;
//  String shippingAddress;
//  String shippingMobileNumber;
//
//  late String theLanguage;
//  late String memberId;
//  late String fullName;
//  late TextAlign theAlignment;
//  bool isLoading = true;
//
//  var funcs = new Funcs();
//  var styles = new Styles();
//
//  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
//
//  final flutterWebviewPlugin = new FlutterWebviewPlugin();
//  // On destroy stream
//  late StreamSubscription _onDestroy;
//
//  // On urlChanged stream
//  late StreamSubscription<String> _onUrlChanged;
//
//  @override
//  void initState(){
//    super.initState();
//    getSharedData().then((result) {
//
//    });
//
//    shippingCity = shippingCity.replaceAll(' ', '-');
//    setState(() {
//      shippingFullName = shippingFullName.replaceAll(' ', '-');
//
//      shippingAddress = shippingAddress.replaceAll(' ', '-');
//      shippingCity = Uri.encodeComponent(shippingCity);
//    });
//
////    _onDestroy = flutterWebviewPlugin.onDestroy.listen((_) {
////      if (mounted) {
////
////      }
////    });
//
//    _onUrlChanged = flutterWebviewPlugin.onUrlChanged.listen((String url) async{
//      String theURL = url.replaceAll(funcs.mainLink, '');
//      List theArrayURL = theURL.split('/');
//      if (mounted) {
//        if(theArrayURL[1] == 'makeAnOrder'){
//          SharedPreferences prefs = await SharedPreferences.getInstance();
//          await prefs.setInt('sharedCartCount', 0);
//          await new Future.delayed(const Duration(seconds :  8));
//          Navigator.of(context).pushNamedAndRemoveUntil('/Orders',(Route<dynamic> route) => false);
//
//          _onDestroy = flutterWebviewPlugin.onDestroy.listen((_) {
//            if (mounted) {
//
//            }
//          });
//        }
//      }
//    });
//
//  }
//
//  @override
//  void dispose(){
//
//    _onDestroy.cancel();
//    _onUrlChanged.cancel();
//
//    super.dispose();
//  }
//
//  getSharedData() async {
//    SharedPreferences prefs = await SharedPreferences.getInstance();
//    setState(() {
//      theLanguage = prefs.getString('theLanguage')!;
//      memberId = prefs.getString('memberId')!;
//      fullName = prefs.getString('fullName')!;
//
//      if(theLanguage == 'ar'){
//        theAlignment = TextAlign.right;
//      }else{
//        theAlignment = TextAlign.left;
//      }
//
//    });
//  }
//
//
//
//  @override
//  Widget build(BuildContext context) {
//
////    print(emailAddress);
////    print(shippingCity);
////    print(shippingAddress);
////    print(shippingMobileNumber);
//    // TODO: implement build
//    return new WebviewScaffold(
//      url: 'http://masajedna.qawii.com/tler/payments/$theLanguage/$memberId/$couponId/$addressId/$shippingFullName/$emailAddress/$shippingCity/$shippingAddress/$shippingMobileNumber',
//      appBar: new AppBar(
//        title: const Text('Widget webview'),
//      ),
//
//      withZoom: true,
//      withLocalStorage: true,
//      hidden: true,
//      initialChild: Container(
//        color: Colors.white,
//        child: const Center(
//          child: Text('Waiting.....'),
//        ),
//      ),
//
//    );
//  }
//
//}
