import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supplyplatform/gui/stores.dart';
import 'package:provider/provider.dart';
import 'package:supplyplatform/gui/orders/my_store.dart';
import 'package:supplyplatform/gui/main_page.dart';
import 'package:supplyplatform/gui/settings.dart';
import 'package:supplyplatform/gui/orders/cart.dart';
import 'package:badges/badges.dart';

class BottomNavigationBarWidget extends StatefulWidget{
  BottomNavigationBarWidget(this.selectedIndex);
  int selectedIndex;

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _BottomNavigationBarWidgetState(selectedIndex);
  }

}

class _BottomNavigationBarWidgetState extends State<BottomNavigationBarWidget>{

  _BottomNavigationBarWidgetState(this.selectedIndex);
  int selectedIndex;

  late String theLanguage;
  late String memberId;
  late String deviceId = '';
  late bool isLogin = false;
  bool isLoading = false;
  int _selectedIndex = 0;
  String user="shop";
  void initState(){
    super.initState();
    setState(() {
      _selectedIndex = selectedIndex;
    });
    getSharedData().then((result) {

    });

  }

  getSharedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      theLanguage = prefs.getString('theLanguage')!;
      memberId = prefs.getString('memberId')!;
      deviceId = prefs.getString('deviceId')!;
      isLogin = prefs.getBool('isLogin')!;
    });
  }

  void _onItemTapped(int index) {
    if(index == 0){
      Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, anotherAnimation){
          return MainPage();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {

          return FadeTransition(
            opacity:animation,
            child: child,
          );
        },
      ));
    }else if(index == 1){
      Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, anotherAnimation){
          return const Stores();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {

          return FadeTransition(
            opacity:animation,
            child: child,
          );
        },
      ));
    }else if(index == 2){
      Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, anotherAnimation){
          return const Cart();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {

          return FadeTransition(
            opacity:animation,
            child: child,
          );
        },
      ));
    }else if(index == 3){
      Navigator.of(context).push(PageRouteBuilder(
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
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    var store = Provider.of<MyStore>(context);

    if(isLogin == true){
      store.getCartCount(memberId,isLogin);
      setState(() {

      });
    }else{
     store.getCartCount(deviceId,isLogin);
    }

//    Timer.periodic(const Duration(seconds: 2), (timer) async{
//      if(isLogin == true){
//        store.getCartCount(memberId,isLogin);
//      }else{
//        print('ccccc');
//        store.getCartCount(deviceId,isLogin);
//      }
////      setState(() {});
//    });
//

      //print(memberId);

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
//      backgroundColor: Theme.of(context).primaryColor,
      backgroundColor: Colors.white,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: const Icon(Icons.home),
          label: context.localeString('home_page_title'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.store),
          label: context.localeString('companies'),
        ),
        BottomNavigationBarItem(
            icon: Badge(
              badgeContent: Text(store.cartCount, style: const TextStyle(color: Colors.white),),
              child: const Icon(Icons.shopping_cart),
              toAnimate: false,
              showBadge: int.parse(store.cartCount) > 0 ? true:false,
              position: BadgePosition.topEnd(top: -15, end: -12),
            ),
            label: context.localeString('cart')
        ),
        BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: context.localeString('account')
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Theme.of(context).secondaryHeaderColor,
      unselectedItemColor: Theme.of(context).primaryColor,
      onTap: _onItemTapped,
    );
  }

}